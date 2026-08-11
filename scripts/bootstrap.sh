#!/bin/bash

set -e

LOG_FILE="/var/log/ia-lab-bootstrap.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== IA Lab bootstrap started ==="
date

echo "Updating package information..."
apt-get update

echo "Installing basic tools..."
apt-get install -y \
  curl \
  git \
  htop \
  jq \
  unzip \
  ca-certificates \
  gnupg

echo "Installing AWS SSM Agent..."

snap install amazon-ssm-agent --classic

systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

echo "Installing Docker..."

apt-get install -y docker.io

systemctl enable docker
systemctl start docker

echo "Adding ubuntu user to docker group..."

usermod -aG docker ubuntu

echo "Checking installed versions..."

echo "Docker:"
docker --version

echo "SSM Agent:"
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service --no-pager

echo "=== IA Lab bootstrap completed ==="
date