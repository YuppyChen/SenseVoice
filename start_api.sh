#!/bin/bash

# SenseVoice OpenAI兼容API一键启动脚本
# 作者: Claude Code
# 用途: 一键启动SenseVoice语音识别API服务

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_info "SenseVoice API 启动脚本开始执行..."
print_info "当前工作目录: $SCRIPT_DIR"

# 检查Python环境
print_info "检查Python环境..."
if ! command -v python3 &> /dev/null; then
    print_error "Python3 未安装，请先安装Python3"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
print_success "Python版本: $PYTHON_VERSION"

# 检查虚拟环境
print_info "检查虚拟环境..."
if [ ! -d ".venv" ]; then
    print_warning "虚拟环境不存在，正在创建..."
    
    # 检查是否有uv
    if command -v uv &> /dev/null; then
        print_info "使用uv创建虚拟环境..."
        uv venv .venv
    else
        print_info "使用python3 -m venv创建虚拟环境..."
        python3 -m venv .venv
    fi
    
    if [ $? -eq 0 ]; then
        print_success "虚拟环境创建成功"
    else
        print_error "虚拟环境创建失败"
        exit 1
    fi
else
    print_success "虚拟环境已存在"
fi

# 激活虚拟环境
print_info "激活虚拟环境..."
source .venv/bin/activate

if [ $? -eq 0 ]; then
    print_success "虚拟环境激活成功"
else
    print_error "虚拟环境激活失败"
    exit 1
fi

# 检查依赖
print_info "检查项目依赖..."
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt 文件不存在"
    exit 1
fi

# 安装依赖
print_info "安装项目依赖..."
if command -v uv &> /dev/null; then
    print_info "使用uv安装依赖..."
    uv pip install -r requirements.txt
else
    print_info "使用pip安装依赖..."
    pip install -r requirements.txt
fi

if [ $? -eq 0 ]; then
    print_success "依赖安装成功"
else
    print_error "依赖安装失败"
    exit 1
fi

# 检查API文件
print_info "检查API文件..."
if [ ! -f "openai_whisper_compatible_api.py" ]; then
    print_error "openai_whisper_compatible_api.py 文件不存在"
    exit 1
fi

# 检查MPS支持（Mac专用）
print_info "检查设备支持..."
python3 -c "
import torch
print(f'PyTorch版本: {torch.__version__}')
if torch.backends.mps.is_available():
    print('✅ MPS (Mac GPU) 可用')
elif torch.cuda.is_available():
    print('✅ CUDA (NVIDIA GPU) 可用')
else:
    print('⚠️  仅支持CPU运行')
"

# 创建临时目录
mkdir -p ./tmp

# 设置环境变量
export SENSEVOICE_DEVICE="mps"

print_success "环境准备完成！"
print_info "正在启动SenseVoice API服务器..."
print_info "服务地址: http://localhost:8000"
print_info "API文档: http://localhost:8000/docs"
print_info ""
print_warning "首次启动需要下载模型文件（约893MB），请耐心等待..."
print_warning "按 Ctrl+C 可停止服务"
print_info ""

# 启动API服务器
python openai_whisper_compatible_api.py