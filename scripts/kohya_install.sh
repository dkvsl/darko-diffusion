#!/usr/bin/env bash
set -e

# Clone the repo, checkout the version and the submodule
git clone https://github.com/bmaltais/kohya_ss.git /kohya_ss
cd /kohya_ss
git submodule update --init --recursive

# Set environment
python3 -m venv --system-site-packages venv
source venv/bin/activate

# Install torch
pip3 install --no-cache-dir torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu118
pip3 install --no-cache-dir xformers==0.0.23.post1+cu118 --index-url https://download.pytorch.org/whl/cu118

# Install modules
pip3 install bitsandbytes==0.43.0 \
    tensorboard==2.14.1 tensorflow==2.14.0 \
    wheel packaging tensorrt
pip3 install tensorflow[and-cuda]

# Install requirements and cleanup
pip3 install -r requirements.txt
pip3 cache purge
deactivate