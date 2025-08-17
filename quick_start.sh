#!/bin/bash

# SenseVoice 快速启动脚本
echo "🚀 启动 SenseVoice API..."

# 进入脚本所在目录
cd "$(dirname "$0")"

# 检查并停止占用8000端口的进程
echo "🔍 检查8000端口占用情况..."
if lsof -i :8000 >/dev/null 2>&1; then
    echo "⚠️  端口8000被占用，正在停止相关进程..."
    pkill -f "8000"
    sleep 2
    echo "✅ 已停止占用8000端口的进程"
else
    echo "✅ 端口8000空闲"
fi

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "❌ 虚拟环境 .venv 不存在，请先创建虚拟环境"
    exit 1
fi

# 激活虚拟环境并启动API在8000端口
echo "🔧 激活虚拟环境..."
source .venv/bin/activate

echo "🌐 启动 OpenAI Whisper 兼容 API 服务 (端口: 8000)..."
python openai_whisper_compatible_api.py --port 8000