variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "darkovisual"
}

variable "APP" {
    default = "stable-diffusion"
}

variable "RELEASE" {
    default = "latest"
}

variable "CU_VERSION" {
    default = "118"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "darkovisual/gpu-base-cuda11.8.0"
}

variable "BASE_IMAGE_VERSION" {
    default = "latest"
}

variable "CUDA_VERSION" {
    default = "11.8.0"
}

variable "TORCH_VERSION" {
    default = "2.1.2"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/darko-diffusion-${TORCH_VERSION}-cu${CU_VERSION}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "${TORCH_VERSION}+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.23.post1+cu${CU_VERSION}"
        WEBUI_VERSION = "v1.9.3"
        CONTROLNET_COMMIT = "59d5998823daabd73d6339b3d21c9cdda27b0286"
        KOHYA_VERSION = "v24.1.4"
        APP_MANAGER_VERSION = "1.1.0"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
