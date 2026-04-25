FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir google-generativeai instructor

COPY . /app/backend/

# The application looks for analytics directory relatively, so we might need to copy it or bind mount it.
# We will copy it for simplicity if it exists, but the docker-compose will likely mount it or the parent directory.

ENV PYTHONPATH=/app
EXPOSE 8000

CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
