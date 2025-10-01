# Build Stage 
FROM python:3.12 AS builder
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml ./
# create venv and install dependencies
RUN uv venv /simple-server/venv
RUN uv pip compile pyproject.toml -o requirements.txt 
RUN uv pip install --python /simple-server/venv/bin/python -r requirements.txt

# Runtime Stage 
FROM python:3.12-slim
WORKDIR /app

# use prebuilt venv
ENV VIRTUAL_ENV=/simple-server/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PYTHONPATH=/app

# copy venv and source
COPY --from=builder /simple-server/venv /simple-server/venv
COPY . .

# non-root user for security
RUN useradd -ms /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
