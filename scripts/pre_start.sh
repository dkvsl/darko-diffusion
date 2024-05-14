#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export APP="stable-diffusion"
DOCKER_IMAGE_VERSION_FILE="/workspace/${APP}/docker_image_version"

echo "Template version: ${TEMPLATE_VERSION}"
echo "venv: ${VENV_PATH}"

if [[ -e ${DOCKER_IMAGE_VERSION_FILE} ]]; then
    EXISTING_VERSION=$(cat ${DOCKER_IMAGE_VERSION_FILE})
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync main venv to workspace to support Network volumes
    echo "Syncing main venv to workspace, please wait..."
    mkdir -p ${VENV_PATH}
    rsync --remove-source-files -rlptDu /venv/ ${VENV_PATH}/
    rm -rf /venv

    # Sync application to workspace to support Network volumes
    echo "Syncing ${APP} to workspace, please wait..."
    rsync --remove-source-files -rlptDu /${APP}/ /workspace/${APP}/
    rm -rf /stable-diffusion

    # Sync Kohya_ss to workspace to support Network volumes
    echo "Syncing Kohya_ss to workspace, please wait..."
    rsync --remove-source-files -rlptDu /kohya_ss/ /workspace/kohya_ss/
    rm -rf /kohya_ss

    # Sync models
    echo "Syncing models to stable-diffusion..."
    rsync --remove-source-files -rlptDu /models/ /workspace/models/
    rm -rf /models

    # Sync Application Manager to workspace to support Network volumes
    echo "Syncing Application Manager to workspace, please wait..."
    rsync --remove-source-files -rlptDu /app-manager/ /workspace/app-manager/
    rm -rf /app-manager

    echo "${TEMPLATE_VERSION}" > ${DOCKER_IMAGE_VERSION_FILE}
    echo "${VENV_PATH}" > "/workspace/${APP}/venv_path"
}

fix_venvs() {
    echo "Fixing Stable Diffusion Web UI venv..."
    /fix_venv.sh /venv ${VENV_PATH}

    echo "Fixing Kohya_ss venv..."
    /fix_venv.sh /kohya_ss/venv /workspace/kohya_ss/venv
}

link_models() {
   # Link models and VAE if they are not already linked
   if [[ ! -L /workspace/stable-diffusion/models/Stable-diffusion/sd_xl_base_1.0.safetensors ]]; then
       ln -s /workspace/models/sd_xl_base_1.0.safetensors /workspace/stable-diffusion/models/Stable-diffusion/sd_xl_base_1.0.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion/models/Stable-diffusion/CyberRealistic_V4.2_FP16.safetensors ]]; then
       ln -s /workspace/models/CyberRealistic_V4.2_FP16.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V4.2_FP16.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion/models/VAE/sdxl_vae.safetensors ]]; then
       ln -s /workspace/models/sdxl_vae.safetensors /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion/models/VAE/vae-ft-mse-840000-ema-pruned.safetensors ]]; then
       ln -s /workspace/models/vae-ft-mse-840000-ema-pruned.safetensors /workspace/stable-diffusion-webui/models/VAE/vae-ft-mse-840000-ema-pruned.safetensors
   fi
}
if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs
        link_models

        # Add VENV_PATH to webui-user.sh
        sed -i "s|venv_dir=VENV_PATH|venv_dir=${VENV_PATH}\"\"|" /workspace/stable-diffusion/webui-user.sh

        # Configure accelerate
        echo "Configuring accelerate..."
        mkdir -p /root/.cache/huggingface/accelerate
        mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

        # Create logs directory
        mkdir -p /workspace/logs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
else
    echo "Existing version is newer than the template version, not syncing!"
fi

# Start application manager
cd /workspace/app-manager
npm start > /workspace/logs/app-manager.log 2>&1 &

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   /start_a1111.sh"
    echo ""
    echo "   Kohya_ss"
    echo "   ---------------------------------------------"
    echo "   /start_kohya.sh"
    echo ""
    echo ""
    echo "   ---------------------------------------------"
    echo ""
else
    /start_a1111.sh
    /start_kohya.sh
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "All services have been started"