# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

SenseVoice是一个多功能语音理解基础模型，具备自动语音识别(ASR)、口语言识别(LID)、语音情感识别(SER)和音频事件检测(AED)等多种语音理解能力。支持中文、粤语、英语、日语、韩语等50多种语言的识别。

## 环境配置

### 依赖安装
```bash
pip install -r requirements.txt
```

### 核心依赖
- torch<=2.3, torchaudio
- funasr>=1.1.3 (语音处理框架)
- modelscope, huggingface (模型管理)
- gradio (Web UI)
- fastapi>=0.111.1 (API服务)

### 设备配置
```bash
# 设置CUDA设备
export SENSEVOICE_DEVICE=cuda:0
```

## 常用开发命令

### 推理和测试
```bash
# 基础推理演示
python demo1.py

# 直接推理演示
python demo2.py

# ONNX模型推理
python demo_onnx.py

# LibTorch模型推理
python demo_libtorch.py
```

### 模型导出
```bash
# 导出ONNX模型
python export.py

# 导出LibTorch模型
python export.py  # 需要配置导出类型
```

### Web界面和API服务
```bash
# 启动Gradio Web UI
python webui.py

# 启动FastAPI服务
export SENSEVOICE_DEVICE=cuda:0
fastapi run api.py --port 50000

# OpenAI Whisper兼容API (雷哥新增)
python openai_whisper_compatible_api.py
```

### 模型微调
```bash
# 分布式训练脚本
bash finetune.sh

# 手动设置GPU
export CUDA_VISIBLE_DEVICES="0,1"
bash finetune.sh
```

## 核心组件架构

### 主要文件结构
```
├── model.py                    # SenseVoice模型定义 
├── api.py                      # FastAPI服务端点
├── demo1.py, demo2.py          # 推理演示脚本
├── webui.py                    # Gradio Web界面
├── export.py                   # 模型导出工具
├── finetune.sh                 # 训练脚本
├── utils/                      # 工具模块
│   ├── ctc_alignment.py        # CTC对齐工具
│   ├── export_utils.py         # 导出工具
│   ├── frontend.py             # 前端处理
│   ├── infer_utils.py          # 推理工具
│   └── model_bin.py            # 模型二进制
├── data/                       # 训练数据示例
└── deepspeed_conf/             # DeepSpeed配置
```

### 核心模型类
- `SenseVoiceSmall`: 主模型类 (model.py)
- `SinusoidalPositionEncoder`: 位置编码器
- API服务支持的语言: auto, zh, en, yue, ja, ko, nospeech

### 推理流程
1. **AutoModel方式**: 通过FunASR框架加载，支持VAD分割
2. **直接推理**: 使用SenseVoiceSmall.from_pretrained加载
3. **批量处理**: 支持动态批处理和VAD合并

## 开发工作流程

### 模型调试
```bash
# 检查模型加载
python -c "from model import SenseVoiceSmall; print('Model loaded successfully')"

# 验证CUDA可用性
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

### 数据准备 (微调场景)
- 训练数据格式: JSONL, 包含key, source, target等字段
- 示例文件: `data/train_example.jsonl`, `data/val_example.jsonl`
- 支持语言标记: `<|zh|>`, `<|en|>`, `<|yue|>`, `<|ja|>`, `<|ko|>`
- 情感标记: `<|HAPPY|>`, `<|SAD|>`, `<|ANGRY|>`, `<|NEUTRAL|>`等
- 事件标记: `<|Speech|>`, `<|BGM|>`, `<|Applause|>`等

### 模型导出和部署
```bash
# 导出为ONNX (生产部署)
python export.py

# 检查导出的模型
ls -la ~/.cache/modelscope/hub/iic/SenseVoiceSmall/
```

### API开发
- FastAPI端点: `/api/v1/asr`
- 输入: 音频文件 (wav/mp3, 16KHz)
- 输出: JSON格式，包含raw_text, clean_text, text字段
- 支持批量音频处理

## 配置要点

### 推理参数
- `language`: 支持auto自动检测
- `use_itn`: 是否启用逆文本标准化
- `batch_size_s`: 动态批处理时长(秒)
- `merge_vad`: 是否合并VAD片段
- `vad_kwargs`: VAD配置，如max_single_segment_time

### 训练配置
- DeepSpeed: 支持ZeRO-1优化，bf16精度
- 分布式: 通过torchrun启动多GPU训练
- 数据: 支持token-based batching
- 检查点: 自动保存和恢复训练状态

### 性能优化
- 非自回归架构: 推理延迟极低(70ms处理10秒音频)
- VAD分割: 支持长音频自动分段处理
- 批处理: 支持动态批次大小优化吞吐量

## 常见问题排查

### 模型加载失败
- 检查网络连接(ModelScope/HuggingFace下载)
- 验证CUDA设备可用性
- 确认funasr版本>=1.1.3

### 推理错误
- 音频格式: 确保16KHz采样率
- 内存不足: 调整batch_size或启用VAD分割
- 设备错误: 检查SENSEVOICE_DEVICE环境变量

### 训练问题
- 数据格式: 验证JSONL文件格式正确性
- GPU内存: 调整batch_size和gradient_accumulation_steps
- DeepSpeed: 检查deepspeed_conf配置文件

## 扩展功能

### 第三方集成
- Triton GPU部署: 支持TensorRT加速
- Sherpa-onnx: 支持10种编程语言
- SenseVoice.cpp: 纯C++推理实现
- 流式处理: streaming-sensevoice支持实时推理

### 自定义开发
- 热词增强: 支持上下文短语预测网络
- 时间戳: 基于CTC对齐的时间戳生成
- 模型量化: 支持3-bit到8-bit量化