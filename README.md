<div align="center">

# Docker image for A1111 Stable Diffusion & Kohya_ss & JupyterLab
</div>

![Docker Image Version](https://img.shields.io/docker/v/darkovisual/darko-diffusion?sort=semver&arch=amd64&style=flat&logo=docker&logoColor=white&logoSize=auto&labelColor=blue&color=black)
![Docker Image Size](https://img.shields.io/docker/image-size/darkovisual/darko-diffusion?sort=semver&arch=amd64&style=flat&logo=docker&logoColor=white&logoSize=auto&labelColor=blue&color=black)

## Packages included

* Ubuntu 22.04 LTS
* CUDA 12.1
* Python 3.10.12
* Torch 2.1.2
* JupyterLab
* [Automatic1111 Stable Diffusion Web UI](
  https://github.com/AUTOMATIC1111/stable-diffusion) 1.9.3
* [ControlNet extension](
  https://github.com/Mikubill/sd-webui-controlnet) v1.1.445
* [Inpaint Anything extension](https://github.com/Uminosachi/sd-webui-inpaint-anything)
* [Infinite Image Browsing extension](https://github.com/zanllp/sd-webui-infinite-image-browsing)
* [Kohya_ss](https://github.com/bmaltais/kohya_ss) v24.1.4
* [sd_xl_base_1.0.safetensors](
  https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors)
* [cyberrealistic_v42.safetensors](
  https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V4.2_FP16.safetensors)
* [sdxl_vae.safetensors](
  https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors)

### Running Locally

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 3010:3011 \
  -p 6006:6066 \
  -p 8000:8000 \
  -p 8888:8888 \
  -e JUPYTER_PASSWORD="Put your password here" \
  -e ENABLE_TENSORBOARD=1 \
  darkovisual/darko-diffusion:1.0.5
```


### Ports

| Connect Port | Internal Port | Description                   |
|--------------|---------------|-------------------------------|
| 3000         | 3001          | A1111 Stable Diffusion Web UI |
| 3010         | 3011          | Kohya_ss                      |
| 6006         | 6066          | Tensorboard                   |
| 8000         | 8000          | Application Manager           |
| 8888         | 8888          | Jupyter Lab                   |

### Environment Variables

| Variables            | Description                                  | Default                                 |
|----------------------|----------------------------------------------|-----------------------------------------|
| VENV_PATH            | Set the path for the Python venv for the app | /workspace/venvs/stable-diffusion |
| JUPYTER_LAB_PASSWORD | Set a password for Jupyter lab               | not set - no password                   |
| DISABLE_AUTOLAUNCH   | Disable Web UIs from launching automatically | enabled                                 |
| ENABLE_TENSORBOARD   | Enables Tensorboard on port 6006             | enabled                                 |

## Logs

Stable Diffusion, Kohya_ss and Jupyter Lab each create log
files, and you can tail the log files instead of killing
the services to view the logs

| Application             | Log file                     |
|-------------------------|------------------------------|
| Stable Diffusion Web UI | /workspace/logs/webui.log    |
| Kohya SS                | /workspace/logs/kohya_ss.log |
| JupyterLab              | /workspace/logs/jupyter.log  |
