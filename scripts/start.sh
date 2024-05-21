#!/usr/bin/env bash
# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

start_nginx() {
    echo "Starting Nginx service..."
    service nginx start
}

execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

generate_ssh_host_keys() {
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
    fi

    if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
        ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
    fi

    if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
        ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
    fi

    if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
        ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
    fi
}

setup_ssh() {
    echo "Setting up SSH..."
    mkdir -p ~/.ssh

    # Add SSH public key from environment variable to ~/.ssh/authorized_keys
    # if the PUBLIC_KEY environment variable is set
    if [[ ${PUBLIC_KEY} ]]; then
        echo -e "${PUBLIC_KEY}\n" >> ~/.ssh/authorized_keys
    fi

    chmod 700 -R ~/.ssh

    # Generate SSH host keys if they don't exist
    generate_ssh_host_keys

    service ssh start

    echo "SSH host keys:"
    cat /etc/ssh/*.pub
}


start_jupyter() {
    # Default to not using a password
    JUPYTER_PASSWORD=""

    # Allow a password to be set by providing the JUPYTER_PASSWORD environment variable
    if [[ ${JUPYTER_LAB_PASSWORD} ]]; then
        JUPYTER_PASSWORD=${JUPYTER_LAB_PASSWORD}
    fi

    echo "Starting Jupyter Lab..."
    mkdir -p /workspace/logs
    cd / && \
    nohup jupyter lab --allow-root \
      --no-browser \
      --port=8888 \
      --ip=* \
      --FileContentsManager.delete_to_trash=False \
      --ContentsManager.allow_hidden=True \
      --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
      --ServerApp.token=${JUPYTER_PASSWORD} \
      --ServerApp.allow_origin=* \
      --ServerApp.preferred_dir=/workspace &> /workspace/logs/jupyter.log &
    echo "Jupyter Lab started"
}

start_cron() {
    echo "Starting Cron service..."
    service cron start
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

echo "Container Started, configuration in progress..."
start_nginx
setup_ssh
start_cron
start_jupyter
execute_script "/pre_start.sh" "Running pre-start script..."
echo "Container is READY!"
sleep infinity