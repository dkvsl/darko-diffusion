#!/usr/bin/env bash
export PYTHONUNBUFFERED=1
echo "Starting Stable Diffusion"
cd /workspace/stable-diffusion-webui
nohup ./webui.sh -f > /workspace/logs/webui.log 2>&1 &
echo "Stable Diffusion started"
echo "Log file: /workspace/logs/webui.log"
