#!/usr/bin/env bash
# =============================================================================
# generate-certs.sh — Self-Signed TLS Certificate Generator (EdgeForge)
# =============================================================================
# Project context:
#   EdgeForge terminates TLS at the edge proxy (the first hop a client hits).
#   This script creates a local cert for the mock domain 'edgeforge.local' so
#   we can demo HTTPS delivery, TLS 1.3 handshakes, and HSTS without a public CA.
#
# Cryptographic standards:
#   - ECDSA P-256 (prime256v1) with SHA-256 — modern, fast, widely supported
#   - SAN includes the edge hostname and localhost for local testing
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SCRIPT_DIR}/certs"
DOMAIN="edgeforge.local"
VALIDITY_DAYS=365

echo "=============================================="
echo " EdgeForge TLS Certificate Generator"
echo " Domain: ${DOMAIN}"
echo " Output: ${CERT_DIR}"
echo "=============================================="

mkdir -p "${CERT_DIR}"

# -----------------------------------------------------------------------------
# Step 1: Generate ECDSA Private Key (P-256 / prime256v1)
# -----------------------------------------------------------------------------
# WHY ECDSA P-256: smaller keys and faster signing than RSA at equivalent
# security — important when an edge handles many TLS handshakes.
# -----------------------------------------------------------------------------
echo "[1/3] Generating ECDSA P-256 private key with SHA-256..."
openssl ecparam -genkey -name prime256v1 -out "${CERT_DIR}/edge.key"
chmod 600 "${CERT_DIR}/edge.key"

# -----------------------------------------------------------------------------
# Step 2: OpenSSL config with SAN (required by modern browsers / curl)
# -----------------------------------------------------------------------------
OPENSSL_CNF="${CERT_DIR}/openssl.cnf"
cat > "${OPENSSL_CNF}" <<EOF
[ req ]
default_bits       = 256
prompt             = no
default_md         = sha256
distinguished_name = req_distinguished_name
x509_extensions    = v3_req
req_extensions     = v3_req

[ req_distinguished_name ]
C  = IN
ST = Lab
L  = Local
O  = EdgeForge
OU = Edge Security Lab
CN = ${DOMAIN}

[ v3_req ]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = localhost
IP.1  = 127.0.0.1
EOF

# -----------------------------------------------------------------------------
# Step 3: Self-signed X.509 certificate
# -----------------------------------------------------------------------------
# Self-signed is fine for a local lab; production edges use a public CA chain.
# Test scripts use curl -k or trust this cert explicitly.
# -----------------------------------------------------------------------------
echo "[2/3] Generating self-signed X.509 certificate (${VALIDITY_DAYS}-day validity)..."
openssl req -new -x509 \
    -key "${CERT_DIR}/edge.key" \
    -out "${CERT_DIR}/edge.crt" \
    -days "${VALIDITY_DAYS}" \
    -config "${OPENSSL_CNF}" \
    -extensions v3_req \
    -sha256

echo "[3/3] Verifying certificate properties..."
echo ""
openssl x509 -in "${CERT_DIR}/edge.crt" -noout -text | grep -E "Signature Algorithm|Public-Key Algorithm|Subject:|DNS:|Not After"
echo ""
echo "Certificate files created successfully:"
echo "  Private Key : ${CERT_DIR}/edge.key"
echo "  Certificate : ${CERT_DIR}/edge.crt"
echo ""
echo "Next steps:"
echo "  1. Run: docker compose up --build -d"
echo "  2. Run: ./test-suite.sh"
echo "=============================================="
