<div align="center">

# Stable Diffusion + Kohya_ss + Jupyterlab Torch 2.1.2 and Nvidia CUDA 11.8
</div>

![Docker Image Version](https://img.shields.io/docker/v/darkovisual/darko-diffusion?sort=semver&arch=amd64&style=flat&logo=docker&logoColor=white&logoSize=auto&labelColor=blue&color=black)
![Docker Image Size](https://img.shields.io/docker/image-size/darkovisual/darko-diffusion?sort=semver&arch=amd64&style=flat&logo=docker&logoColor=white&logoSize=auto&labelColor=blue&color=black)

## Packages included

* Ubuntu 22.04 LTS
* CUDA 11.8
* Torch 2.1.2
* Xformers 0.0.23
* Python 3.10.12
* JupyterLab 4.2.0
* A1111 Stable Diffusion WebUI 1.9.3
* ControlNet extension v1.1.445
* Inpaint Anything extension
* Infinite Image Browsing extension
* Kohya_ss v24.1.4
* sd_xl_base_1.0.safetensors
* sdxl_vae.safetensors
* cyberrealistic_v42.safetensors
* vae-ft-mse-840000-ema-pruned.safetensors

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
| 8000         | 8000          | App Manager                   |
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
