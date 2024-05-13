#!/usr/bin/env bash
export PYTHONUNBUFFERED=1
echo "Starting Tensorboard"
cd /workspace
mkdir -p /workspace/logs/ti
mkdir -p /workspace/logs/dreambooth

if [[ ! -L /workspace/logs/dreambooth ]]; then
    ln -s /workspace/stable-diffusion/models/dreambooth /workspace/logs/dreambooth
fi
if [[ ! -L /workspace/logs/ti ]]; then
    ln -s /workspace/stable-diffusion/textual_inversion /workspace/logs/ti
fi

nohup tensorboard --logdir=/workspace/logs --port=6066 --host=0.0.0.0 > /workspace/logs/tensorboard.log 2>&1 &
echo "Tensorboard Started"
