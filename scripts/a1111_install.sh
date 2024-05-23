#!/usr/bin/env bash
set -e

# Clone Stable Diffusion WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /stable-diffusion
cd /stable-diffusion
# git checkout tags/${WEBUI_VERSION}

# Create and activate environment
python3 -m venv --system-site-packages /venv
source /venv/bin/activate

# Install torch and xformers
pip3 install --no-cache-dir torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu118
pip3 install --no-cache-dir xformers==0.0.23.post1+cu118 --index-url https://download.pytorch.org/whl/cu118
pip3 install tensorflow[and-cuda]

# Install A1111
pip3 install -r requirements_versions.txt
python3 -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

# Clone the Automatic1111 Extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet
git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing
git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything

# Install dependencies for ControlNet, Infinite Image Browsing
cd /stable-diffusion/extensions/sd-webui-controlnet
pip3 install -r requirements.txt
pip3 install ultralytics

cd /stable-diffusion/extensions/infinite-image-browsing
pip3 install -r requirements.txt

# Install dependencies for inpaint anything extension
pip3 install segment_anything lama_cleaner
