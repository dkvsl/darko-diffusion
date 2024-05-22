ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Download models
RUN mkdir -p /models && \
    wget -P /models https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
    wget -P /models https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors && \
    wget -P /models https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V4.2_FP16.safetensors && \
    wget -P /models https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

# Set version
ARG WEBUI_VERSION
WORKDIR /

# Clone the A1111 repo & extensions
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git stable-diffusion&& \
    cd /stable-diffusion && \
    git checkout tags/${WEBUI_VERSION} && \
    git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything && \
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

WORKDIR /stable-diffusion
COPY a1111/install-automatic.py ./

# Install dependencies for Stable Diffusion + ControlNet + Infinity Image Browsing
RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip install --no-cache-dir torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 --index-url https://download.pytorch.org/whl/cu121 && \
    pip install tensorflow[and-cuda] && \
    pip install -r requirements_versions.txt && \
    python -m install-automatic --skip-torch-cuda-test && \
    cd /stable-diffusion/extensions/sd-webui-controlnet && \
    pip install -r requirements.txt && \
    cd /stable-diffusion/extensions/infinite-image-browsing && \
    pip install -r requirements.txt && \
    pip install segment_anything lama_cleaner && \
    pip cache purge && \
    deactivate

# Install Kohya_ss
ARG KOHYA_VERSION
RUN git clone https://github.com/bmaltais/kohya_ss.git /kohya_ss && \
    cd /kohya_ss && \
    git checkout ${KOHYA_VERSION} && \
    git submodule update --init --recursive

WORKDIR /kohya_ss
RUN python -m venv --system-site-packages venv && \
    source venv/bin/activate && \
    pip install --no-cache-dir torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 --index-url https://download.pytorch.org/whl/cu121 && \
    pip install bitsandbytes==0.43.0 \
        tensorboard==2.14.1 tensorflow==2.14.0 \
        wheel packaging tensorrt && \
    pip install tensorflow[and-cuda] && \
    pip install -r requirements.txt && \
    pip cache purge && \
    deactivate

# Install Tensorboard
RUN pip uninstall -y tensorboard tb-nightly && \
    pip install tensorboard==2.14.1 tensorflow==2.14.0
    
# Install Application Manager
ARG APP_MANAGER_VERSION
WORKDIR /

RUN git clone https://github.com/dkvsl/app-manager.git /app-manager && \
    cd /app-manager && \
    git checkout tags/${APP_MANAGER_VERSION} && \
    npm install

# Copy Stable Diffusion files and add styles.csv
COPY app-manager/config.json /app-manager/public/config.json 
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json a1111/styles.csv /stable-diffusion/

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the main venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Copy the accelerate configuration
COPY kohya_ss/accelerate.yaml ./

# Start the container
WORKDIR /workspace
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
