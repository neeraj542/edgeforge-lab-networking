# Origin Server Container — customer backend for ns-cdn-lab
# Not exposed to the host; all traffic must traverse the edge proxy.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup --system nscdnlab && \
    adduser --system --ingroup nscdnlab --home /app nscdnlab && \
    chown -R nscdnlab:nscdnlab /app

USER nscdnlab

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "4", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
