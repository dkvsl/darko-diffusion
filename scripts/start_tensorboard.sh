#!/usr/bin/env bash
export PYTHONUNBUFFERED=1
echo "Starting Tensorboard"
cd /workspace

nohup tensorboard --logdir=/workspace/logs --port=6066 --host=0.0.0.0 > /workspace/logs/tensorboard.log 2>&1 &
echo "Tensorboard Started"
