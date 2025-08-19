# Use Python 3.11 slim image as base
FROM python:3.11-slim


# Use a non-root user
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash appuser

USER appuser

WORKDIR /app

COPY pyproject.toml uv.lock ./
COPY src/ ./src/
COPY README.md LICENSE ./

# Install uv
RUN pip install uv
ENV PATH="/home/appuser/.local/bin:$PATH"

# Install project dependencies using uv
RUN uv sync --frozen

ENTRYPOINT ["uv", "run", "mcp-proxy", "--port=8000", "uv", "run", "mcp-server-ds"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ps aux | grep -q mcp-server-ds || exit 1
