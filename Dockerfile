ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Madrid \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

WORKDIR /

# Set Python & install packages
COPY --chmod=755 scripts/* ./
RUN /packages.sh

#Download models
RUN mkdir -p /models && \
    wget -P /models https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
    wget -P /models https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors && \
    wget -P /models https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V4.2_FP16.safetensors && \
    wget -P /models https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

# Install Stable Diffusion WebUI
RUN /a1111_install.sh
WORKDIR /stable-diffusion
COPY --chmod=755 a1111/* /stable-diffusion/

# Install Kohya_ss
WORKDIR /
RUN /kohya_install.sh

# Copy the accelerate configuration
COPY kohya_ss/accelerate.yaml ./

# Install Tensorboard
RUN /tensorboard_install.sh

# Install Application Manager
RUN /app_manager.sh
COPY app-manager/config.json /app-manager/public/config.json

# Cleanup installation scripts
RUN rm -f /a1111_install.sh /app_manager.sh /kohya_install.sh \
    /packages.sh /tensorboard_install.sh

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# copy NGINX config
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the main venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

WORKDIR /workspace

SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]