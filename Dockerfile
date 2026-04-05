# Debian-based slim image
FROM debian:bookworm-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install core utilities and Terraform
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unzip \
    git \
    ca-certificates \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf awscliv2.zip ./aws \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
# Set the working directory
WORKDIR /app

CMD ["tail", "-f", "/dev/null"]