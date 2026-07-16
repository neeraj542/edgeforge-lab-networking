# Origin Server Container — customer backend for EdgeForge
# Not exposed to the host; all traffic must traverse the edge proxy.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup --system edgeforge && \
    adduser --system --ingroup edgeforge --home /app edgeforge && \
    chown -R edgeforge:edgeforge /app

USER edgeforge

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "4", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
