FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app
COPY app.py ./
COPY public ./public

RUN addgroup --system nscdnlab && \
    adduser --system --ingroup nscdnlab --home /app nscdnlab && \
    chown -R nscdnlab:nscdnlab /app

USER nscdnlab
EXPOSE 5000
CMD ["python", "app.py"]
