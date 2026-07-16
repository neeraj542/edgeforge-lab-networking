#!/usr/bin/env bash
# =============================================================================
# test-suite.sh — ns-cdn-lab CDN / Edge Security Verification Suite
# =============================================================================
# Validates:
#   1. HTTP → HTTPS 301 redirect
#   2. Cache MISS on first fetch (origin round-trip)
#   3. Cache HIT on repeat fetch (edge served)
#   4. TLS 1.3 handshake
#   5. Security blocks (method filter + WAF + rate limit)
#
# Prerequisites:
#   - docker compose up -d
#   - ./nginx/generate-certs.sh
#   - curl + openssl on the host
#
# Usage: ./test-suite.sh
# =============================================================================

set -euo pipefail

DOMAIN="ns-cdn-lab.local"
EDGE_HTTPS="https://${DOMAIN}"
EDGE_HTTP="http://${DOMAIN}"
CURL_RESOLVE=(--resolve "${DOMAIN}:443:127.0.0.1" --resolve "${DOMAIN}:80:127.0.0.1")

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL=$((FAIL + 1))
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

section() {
    echo ""
    echo "=============================================="
    echo " $1"
    echo "=============================================="
}

wait_for_edge() {
    info "Waiting for edge-proxy to become ready..."
    for i in $(seq 1 30); do
        if curl -sS -k "${CURL_RESOLVE[@]}" "${EDGE_HTTPS}/edge-health" >/dev/null 2>&1; then
            info "Edge proxy is ready."
            return 0
        fi
        sleep 2
    done
    fail "Edge proxy did not become ready within 60 seconds. Run: docker compose up -d"
    exit 1
}

test_http_redirect() {
    section "TEST 1: HTTP to HTTPS 301 Redirect"

    RESPONSE=$(curl -sS -o /dev/null -w "%{http_code} %{redirect_url}" \
        "${CURL_RESOLVE[@]}" "${EDGE_HTTP}/")

    HTTP_CODE=$(echo "$RESPONSE" | awk '{print $1}')
    REDIRECT_URL=$(echo "$RESPONSE" | awk '{print $2}')

    info "HTTP response code : ${HTTP_CODE}"
    info "Redirect target    : ${REDIRECT_URL}"

    if [[ "$HTTP_CODE" == "301" ]] && [[ "$REDIRECT_URL" == https://* ]]; then
        pass "HTTP correctly redirects to HTTPS with 301"
    else
        fail "Expected 301 redirect to https:// — got code=${HTTP_CODE} url=${REDIRECT_URL}"
    fi
}

test_cache_miss() {
    section "TEST 2: Cache MISS on First Request"

    CACHE_BUST="?test_miss=$(date +%s)"
    HEADERS=$(curl -sS -I -k "${CURL_RESOLVE[@]}" "${EDGE_HTTPS}/${CACHE_BUST}")

    info "Response headers:"
    echo "$HEADERS" | grep -iE "x-cache-status|x-origin-server|cache-control" || true

    CACHE_STATUS=$(echo "$HEADERS" | grep -i "x-cache-status" | awk '{print $2}' | tr -d '\r')
    ORIGIN_HEADER=$(echo "$HEADERS" | grep -i "x-origin-server" | awk '{print $2}' | tr -d '\r')

    if [[ "$CACHE_STATUS" == "MISS" ]]; then
        pass "X-Cache-Status is MISS (edge fetched from origin)"
    else
        fail "Expected X-Cache-Status: MISS — got '${CACHE_STATUS}'"
    fi

    if [[ "$ORIGIN_HEADER" == "Flask-Backend-01" ]]; then
        pass "X-Origin-Server confirms origin round-trip (Flask-Backend-01)"
    else
        fail "Expected X-Origin-Server: Flask-Backend-01 — got '${ORIGIN_HEADER}'"
    fi
}

test_cache_hit() {
    section "TEST 3: Cache HIT on Second Request"

    CACHE_URL="${EDGE_HTTPS}/?test_hit=fixed_key"

    curl -sS -o /dev/null -k "${CURL_RESOLVE[@]}" "${CACHE_URL}"

    HEADERS=$(curl -sS -D - -o /dev/null -k "${CURL_RESOLVE[@]}" "${CACHE_URL}")
    CACHE_STATUS=$(echo "$HEADERS" | grep -i "x-cache-status" | awk '{print $2}' | tr -d '\r' | head -1)

    info "X-Cache-Status on repeat request: ${CACHE_STATUS}"

    if [[ "$CACHE_STATUS" == "HIT" ]]; then
        pass "X-Cache-Status is HIT (served from edge cache)"
    else
        fail "Expected X-Cache-Status: HIT — got '${CACHE_STATUS}'"
    fi
}

test_tls13() {
    section "TEST 4: TLS 1.3 Handshake Verification"

    # macOS system curl (SecureTransport) often rejects --tlsv1.3 / --tls-max.
    # OpenSSL s_client is the reliable protocol check.
    if command -v openssl >/dev/null 2>&1; then
        OPENSSL_OUT=$(echo | openssl s_client -connect 127.0.0.1:443 -servername "${DOMAIN}" -tls1_3 2>&1) || true
        info "OpenSSL negotiated protocol:"
        echo "$OPENSSL_OUT" | grep -iE "Protocol|Cipher" | head -5 || true

        if echo "$OPENSSL_OUT" | grep -qi "TLSv1.3"; then
            pass "OpenSSL s_client confirms TLS 1.3 handshake"
        else
            fail "OpenSSL s_client could not confirm TLS 1.3"
        fi

        if echo "$OPENSSL_OUT" | grep -qiE "Cipher.*(AES_256_GCM|CHACHA20|AES_128_GCM)"; then
            pass "TLS 1.3 cipher suite negotiated (AES-GCM or ChaCha20)"
        else
            info "Cipher line: $(echo "$OPENSSL_OUT" | grep -i Cipher | head -1)"
        fi
    else
        fail "openssl not found — cannot verify TLS 1.3"
    fi

    HTTPS_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -k "${CURL_RESOLVE[@]}" "${EDGE_HTTPS}/edge-health")
    if [[ "$HTTPS_CODE" == "200" ]]; then
        pass "HTTPS edge-health reachable over TLS (HTTP ${HTTPS_CODE})"
    else
        fail "HTTPS edge-health failed — got HTTP ${HTTPS_CODE}"
    fi
}

test_security_blocks() {
    section "TEST 5: Security Engine Blocks"

    info "5a: Testing DELETE method rejection..."
    DELETE_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X DELETE \
        -k "${CURL_RESOLVE[@]}" "${EDGE_HTTPS}/")

    info "DELETE response code: ${DELETE_CODE}"
    if [[ "$DELETE_CODE" == "405" ]]; then
        pass "DELETE method blocked with 405 Method Not Allowed"
    else
        fail "Expected 405 for DELETE — got ${DELETE_CODE}"
    fi

    info "5b: Testing malicious User-Agent block (nikto)..."
    BOT_CODE=$(curl -sS -o /dev/null -w "%{http_code}" \
        -k "${CURL_RESOLVE[@]}" \
        -H "User-Agent: Nikto/2.1.6" \
        "${EDGE_HTTPS}/")

    info "Nikto UA response code: ${BOT_CODE}"
    if [[ "$BOT_CODE" == "403" ]]; then
        pass "Malicious User-Agent (nikto) blocked with 403 Forbidden"
    else
        fail "Expected 403 for nikto User-Agent — got ${BOT_CODE}"
    fi

    info "5c: Testing rate limit (sending 35 rapid requests to /)..."
    RATE_LIMIT_HIT=0
    for i in $(seq 1 35); do
        CODE=$(curl -sS -o /dev/null -w "%{http_code}" \
            -k "${CURL_RESOLVE[@]}" "${EDGE_HTTPS}/" 2>/dev/null || echo "000")
        if [[ "$CODE" == "429" ]]; then
            RATE_LIMIT_HIT=1
            info "Rate limit triggered on request #${i} (HTTP 429)"
            break
        fi
    done

    if [[ "$RATE_LIMIT_HIT" -eq 1 ]]; then
        pass "Rate limiting active — received 429 Too Many Requests"
    else
        fail "Rate limit not triggered after 35 rapid requests"
    fi
}

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║   ns-cdn-lab — CDN & Edge Security Verification Suite        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"

    wait_for_edge

    test_http_redirect
    test_cache_miss
    test_cache_hit
    test_tls13
    test_security_blocks

    section "RESULTS SUMMARY"
    echo -e "  Passed: ${GREEN}${PASS}${NC}"
    echo -e "  Failed: ${RED}${FAIL}${NC}"
    echo ""

    if [[ "$FAIL" -eq 0 ]]; then
        echo -e "${GREEN}All tests passed. ns-cdn-lab is ready for demo.${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed. Review nginx.conf and docker compose logs.${NC}"
        echo "  Debug: docker compose logs edge-proxy"
        exit 1
    fi
}

main "$@"
