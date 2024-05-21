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
    default = "1.0.3"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "darkovisual/base-cuda121-gpu"
}

variable "BASE_IMAGE_VERSION" {
    default = "1.0.3"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/darko-diffusion:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}"
        WEBUI_VERSION = "v1.9.3"
        KOHYA_VERSION = "v24.1.4"
        APP_MANAGER_VERSION = "1.1.0"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}