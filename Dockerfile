FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your Prefect flows and deployment configurations
COPY . .

# Create a startup script
COPY start.sh .
RUN chmod +x start.sh

# Default command
CMD ["./start.sh"]