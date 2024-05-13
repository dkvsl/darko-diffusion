ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN mkdir -p /sd-models

# Add SDXL models and VAE
# These need to already have been downloaded:
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
#   wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
COPY sd_xl_base_1.0.safetensors /sd-models/sd_xl_base_1.0.safetensors
COPY sd_xl_refiner_1.0.safetensors /sd-models/sd_xl_refiner_1.0.safetensors
COPY sdxl_vae.safetensors /sd-models/sdxl_vae.safetensors

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
ARG WEBUI_VERSION
WORKDIR /
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd /stable-diffusion-webui && \
    git checkout tags/${WEBUI_VERSION}

ARG TORCH_VERSION
ARG XFORMERS_VERSION
ARG INDEX_URL
WORKDIR /stable-diffusion-webui
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

# Cache the Stable Diffusion Models
# SDXL models result in OOM kills with 8GB system memory, need 30GB+ to cache these
RUN source /venv/bin/activate && \
    python3 cache-sd-model.py --no-half-vae --no-half --xformers --use-cpu=all --ckpt /sd-models/sd_xl_base_1.0.safetensors && \
    python3 cache-sd-model.py --no-half-vae --no-half --xformers --use-cpu=all --ckpt /sd-models/sd_xl_refiner_1.0.safetensors && \
    deactivate

# Clone the Automatic1111 Extensions
RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum && \
    git clone --depth=1 https://github.com/ashleykleynhans/a1111-sd-webui-locon.git extensions/a1111-sd-webui-locon && \
    git clone --depth=1 https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor && \
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything && \
    git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer && \
    git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension && \
    git clone https://github.com/BlafKing/sd-civitai-browser-plus.git extensions/sd-civitai-browser-plus && \
    git clone https://github.com/NVIDIA/Stable-Diffusion-WebUI-TensorRT.git extensions/Stable-Diffusion-WebUI-TensorRT

# Install dependencies for Deforum, ControlNet, ReActor, Infinite Image Browsing,
# After Detailer, and CivitAI Browser+ extensions
ARG CONTROLNET_COMMIT
ARG CIVITAI_BROWSER_PLUS_VERSION
RUN source /venv/bin/activate && \
    pip3 install basicsr && \
    cd /stable-diffusion-webui/extensions/sd-webui-controlnet && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui/extensions/deforum && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui/extensions/sd-webui-reactor && \
    pip3 install -r requirements.txt && \
    pip3 install onnxruntime-gpu && \
    cd /stable-diffusion-webui/extensions/infinite-image-browsing && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui/extensions/adetailer && \
    python3 -m install && \
    cd /stable-diffusion-webui/extensions/sd_civitai_extension && \
    pip3 install -r requirements.txt && \
    deactivate

# Install dependencies for inpaint anything extension
RUN source /venv/bin/activate && \
    pip3 install segment_anything lama_cleaner && \
    deactivate

# Install dependencies for Civitai Browser+ extension
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd-civitai-browser-plus && \
    pip3 install send2trash beautifulsoup4 ZipUnicode fake-useragent packaging pysocks && \
    deactivate

# Set Dreambooth extension version
ARG DREAMBOOTH_COMMIT
WORKDIR /stable-diffusion-webui/extensions/sd_dreambooth_extension
RUN git checkout main && \
    git reset ${DREAMBOOTH_COMMIT} --hard

# Install the dependencies for the Dreambooth extension
WORKDIR /stable-diffusion-webui
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd_dreambooth_extension && \
    pip3 install -r requirements.txt && \
    pip3 cache purge && \
    deactivate

# Install dependencies for TensorRT extension \
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/Stable-Diffusion-WebUI-TensorRT && \
    pip3 install importlib_metadata && \
    pip3 uninstall -y tensorrt && \
    pip3 install --no-cache-dir nvidia-cudnn-cu11==8.9.4.25 && \
    pip3 install --no-cache-dir --pre --extra-index-url https://pypi.nvidia.com tensorrt==9.0.1.post11.dev4 && \
    pip3 uninstall -y nvidia-cudnn-cu11 && \
    pip3 install protobuf==3.20.2 && \
    pip3 install polygraphy --extra-index-url https://pypi.ngc.nvidia.com && \
    pip3 install onnx-graphsurgeon --extra-index-url https://pypi.ngc.nvidia.com && \
    pip3 install install optimum && \
    deactivate

# Add inswapper model for the ReActor extension
RUN mkdir -p /stable-diffusion-webui/models/insightface && \
    cd /stable-diffusion-webui/models/insightface && \
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx

# Configure ReActor to use the GPU instead of the CPU
RUN echo "CUDA" > /stable-diffusion-webui/extensions/sd-webui-reactor/last_device.txt

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /ComfyUI
WORKDIR /ComfyUI
RUN python3 -m venv --system-site-packages venv && \
    source venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} &&  \
    pip3 install -r requirements.txt && \
    deactivate

# Install ComfyUI Custom Nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager && \
    cd custom_nodes/ComfyUI-Manager && \
    source /ComfyUI/venv/bin/activate && \
    pip3 install -r requirements.txt && \
    pip3 cache purge && \
    deactivate

# Install InvokeAI
ARG INVOKEAI_VERSION
WORKDIR /InvokeAI
RUN python3 -m venv --system-site-packages venv && \
    source venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} && \
    pip3 install InvokeAI[xformers]==${INVOKEAI_VERSION} --use-pep517 && \
    deactivate

# Install Kohya_ss
ARG KOHYA_VERSION
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
    pip3 install tensorflow[and-cuda] && \
    pip3 install -r requirements.txt && \
    pip3 cache purge && \
    deactivate

# Install Tensorboard
RUN pip3 uninstall -y tensorboard tb-nightly && \
    pip3 install tensorboard==2.14.1 tensorflow==2.14.0

# Install Application Manager
ARG APP_MANAGER_VERSION
WORKDIR /
RUN git clone https://github.com/ashleykleynhans/app-manager.git /app-manager && \
    cd /app-manager && \
    git checkout tags/${APP_MANAGER_VERSION} && \
    npm install
COPY app-manager/config.json /app-manager/public/config.json

# Install CivitAI Model Downloader
ARG CIVITAI_DOWNLOADER_VERSION
RUN git clone https://github.com/ashleykleynhans/civitai-downloader.git && \
    cd civitai-downloader && \
    git checkout tags/${CIVITAI_DOWNLOADER_VERSION} && \
    cp download.py /usr/local/bin/download-model && \
    chmod +x /usr/local/bin/download-model && \
    cd .. && \
    rm -rf civitai-downloader

# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion-webui/styles.csv

# Copy ComfyUI Extra Model Paths (to share models with A1111)
COPY comfyui/extra_model_paths.yaml /ComfyUI/

# Copy InvokeAI config file
COPY invokeai/invokeai.yaml /InvokeAI/

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
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
