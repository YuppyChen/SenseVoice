#!/bin/bash

# SenseVoice 快速启动脚本
echo "🚀 启动 SenseVoice API..."

# 进入脚本所在目录
cd "$(dirname "$0")"

# 激活虚拟环境并启动API
source .venv/bin/activate && python openai_whisper_compatible_api.py