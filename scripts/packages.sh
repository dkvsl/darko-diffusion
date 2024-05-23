#!/usr/bin/env bash

# Install Ubuntu packages
apt update && apt upgrade -y && apt install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    aria2 \
    bash \
    bc \
    build-essential \
    bzip2 \
    ca-certificates \
    cron \
    curl \
    git \
    git-lfs \
    libcairo2-dev \
    libgl1 \
    libglib2.0-0 \
    libgoogle-perftools4 \
    libsm6 \
    libstdc++-12-dev \
    libtcmalloc-minimal4 \
    libxext6 \
    libxrender1 \
    mc \
    nano \
    ncdu \
    nginx \
    npm \
    nvtop \
    nvtop \
    openssh-server \
    p7zip-full \
    pkg-config \
    plocate \
    procps \
    psmisc \
    python3.10-full \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    rsync \
    screen \
    software-properties-common \
    unzip \
    wget
update-ca-certificates
apt clean
rm -rf /var/lib/apt/lists/*
echo "es_ES.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
ln -s /usr/bin/python3.10 /usr/bin/python