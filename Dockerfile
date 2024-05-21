ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN mkdir -p /models

RUN wget -P /models https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
    wget -P /models https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors && \
    wget -P /models https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V4.2_FP16.safetensors && \
    wget -P /models https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
ARG WEBUI_VERSION
WORKDIR /
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git stable-diffusion&& \
    cd /stable-diffusion && \
    git checkout tags/${WEBUI_VERSION}

WORKDIR /stable-diffusion
COPY a1111/install-automatic.py ./

RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip install --no-cache-dir torch torchvision torchaudio && \
    pip install -U --no-cache-dir xformers --index-url https://download.pytorch.org/whl/cu121 && \
    # Clone the Automatic1111 Extensions
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    # Install dependencies for Stable Diffusion + ControlNet + Infinity Image Browsing
    pip install basicsr && \
    pip install -r requirements_versions.txt && \
    python -m install-automatic --skip-torch-cuda-test && \
    cd /stable-diffusion/extensions/infinite-image-browsing && \
    pip install -r requirements.txt && \
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
    pip install -r requirements.txt && \
    ./setup.sh && \
    pip cache purge && \
    pip install bitsandbytes==0.43.0 \
        tensorboard==2.14.1 tensorflow==2.14.0 \
        wheel packaging tensorrt && \
    deactivate

# Install Tensorboard
RUN pip install tensorboard
    
# Install Application Manager
ARG APP_MANAGER_VERSION
WORKDIR /

RUN git clone https://github.com/dkvsl/app-manager.git /app-manager && \
    apt update && apt install npm rsync -y && \
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
