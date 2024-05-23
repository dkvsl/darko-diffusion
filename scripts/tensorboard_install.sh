#!/usr/bin/env bash
set -e

# Install tensorboard into the system (no venv)
pip3 uninstall -y tensorboard tb-nightly
pip3 install tensorboard==2.14.1 tensorflow==2.14.0