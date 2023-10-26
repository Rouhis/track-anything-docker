# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.11.5
FROM python:${PYTHON_VERSION}-slim as base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV MPLCONFIGDIR /tmp/matplotlib_cache

WORKDIR /app

# Create a non-privileged user with a real home directory.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/appuser" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    appuser
# Grant permissions to the home directory.
RUN chown appuser:appuser /home/appuser

# Install necessary dependencies.
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0

# Note: Ensure requirements.txt is present alongside the Dockerfile.
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# Switch to the non-privileged user.
USER appuser

# Copy the source code into the container.
COPY . .

EXPOSE 8080

# If you want GPU support, keep this. If not, change to just python app.py.
CMD python app.py --device cuda:0
