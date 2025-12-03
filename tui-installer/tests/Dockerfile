# Dockerfile for TUI Installer Testing
# 基于 Ubuntu 22.04 的全面测试环境

FROM ubuntu:22.04

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    tmux \
    htop \
    curl \
    wget \
    sudo \
    openssh-client \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 创建测试用户 (模拟真实环境)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 设置工作目录
WORKDIR /workspace

# 复制项目文件
COPY . /workspace/tui-installer/

# 设置文件权限
RUN chown -R testuser:testuser /workspace

# 切换到测试用户
USER testuser

# 安装 Python 依赖
RUN pip3 install --user -e /workspace/tui-installer/[dev]

# 设置 PATH
ENV PATH="/home/testuser/.local/bin:${PATH}"

# 工作目录设为 tui-installer
WORKDIR /workspace/tui-installer

# 默认运行测试
CMD ["pytest", "-v", "--tb=short"]

