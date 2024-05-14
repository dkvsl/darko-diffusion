ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN mkdir -p /models

# Add SDXL and SD15 models and VAE's
RUN wget -P /models https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
    wget -P /models https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors && \
    wget -P /models https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V4.2_FP16.safetensors && \
    wget -P /models https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
ARG WEBUI_VERSION
WORKDIR /
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /stable-diffusion && \
    cd /stable-diffusion && \
    git checkout tags/${WEBUI_VERSION}

ARG TORCH_VERSION
ARG XFORMERS_VERSION
ARG INDEX_URL
WORKDIR /stable-diffusion
RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} &&  \
    pip3 install tensorflow[and-cuda] && \
    deactivate

# Install the dependencies for the Automatic1111 Stable Diffusion Web UI
COPY a1111/cache-sd-model.py a1111/install-automatic.py ./
RUN source /venv/bin/activate && \
    pip3 install -r requirements_versions.txt && \
    python3 -m install-automatic --skip-torch-cuda-test && \
    deactivate

# Clone the Automatic1111 Extensions
RUN git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything

# Install dependencies for ControlNet and Infinite Image Browsing,
ARG CONTROLNET_COMMIT
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir basicsr && \
    cd /stable-diffusion/extensions/sd-webui-controlnet && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion/extensions/infinite-image-browsing && \
    pip3 install -r requirements.txt && \
    deactivate

# Install dependencies for inpaint anything extension
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir segment_anything lama_cleaner && \
    deactivate

# Install Kohya_ss
ARG KOHYA_VERSION
WORKDIR /
RUN git clone https://github.com/bmaltais/kohya_ss.git /kohya_ss && \
    cd /kohya_ss && \
    git checkout ${KOHYA_VERSION} && \
    git submodule update --init --recursive

WORKDIR /kohya_ss
COPY kohya_ss/requirements* ./
RUN python3 -m venv --system-site-packages venv && \
    source venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} && \
    pip3 install bitsandbytes==0.43.0 \
        tensorboard==2.14.1 tensorflow==2.14.0 \
        wheel packaging tensorrt && \
    pip3 install --no-cache-dir tensorflow[and-cuda] && \
    pip3 install -r requirements.txt && \
    pip3 cache purge && \
    deactivate

# Install Tensorboard
RUN pip3 uninstall -y tensorboard tb-nightly && \
    pip3 install --no-cache-dir tensorboard==2.14.1 tensorflow==2.14.0

# Install Application Manager
ARG APP_MANAGER_VERSION
WORKDIR /
RUN git clone https://github.com/dkvsl/app-manager.git /app-manager && \
    cd /app-manager && \
    git checkout tags/${APP_MANAGER_VERSION} && \
    npm install
COPY app-manager/config.json /app-manager/public/config.json

# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion/styles.csv

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

# Prune cache
RUN rm -Rf /root/.cache/pip

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]