# ============================================================
# Nix 安装测试环境
# 从零开始的 Ubuntu 镜像，验证完整安装流程
# ============================================================

FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Shanghai

# 设置工作目录
WORKDIR /root

# ============================================================
# 第一阶段：先用 HTTP 安装 ca-certificates
# ============================================================
RUN echo "正在配置 Ubuntu 镜像源 (HTTP 临时源)..." && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# ============================================================
# 第二阶段：安装基础依赖
# ============================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
        git \
        sudo \
        locales \
        tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 切换到 HTTPS 源
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# ============================================================
# 第三阶段：创建测试用户 (Nix 需要非 root 用户)
# ============================================================
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/testuser/.config && \
    chown -R testuser:testuser /home/testuser

# 切换到测试用户
USER testuser
WORKDIR /home/testuser

# 设置 HOME 和 USER 环境变量 (Nix 需要)
ENV HOME=/home/testuser
ENV USER=testuser

# ============================================================
# 第四阶段：复制配置文件
# ============================================================
COPY --chown=testuser:testuser install-nix.sh /home/testuser/nix-config/
COPY --chown=testuser:testuser packages.txt /home/testuser/nix-config/
COPY --chown=testuser:testuser test-installation.sh /home/testuser/nix-config/

RUN chmod +x /home/testuser/nix-config/*.sh

# ============================================================
# 第五阶段：安装 Nix
# ============================================================
RUN echo "开始安装 Nix..." && \
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# 配置 Nix 环境变量
ENV PATH="/home/testuser/.nix-profile/bin:$PATH"

# ============================================================
# 第六阶段：配置中国镜像源
# ============================================================
RUN mkdir -p ~/.config/nix && \
    echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf && \
    echo "substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/" >> ~/.config/nix/nix.conf && \
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" >> ~/.config/nix/nix.conf && \
    echo "connect-timeout = 15" >> ~/.config/nix/nix.conf && \
    echo "download-attempts = 3" >> ~/.config/nix/nix.conf && \
    echo "max-jobs = auto" >> ~/.config/nix/nix.conf

# ============================================================
# 第七阶段：使用 nix profile 安装包 (更简单可靠)
# ============================================================
# 安装核心工具
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "安装核心工具..." && \
    nix profile install nixpkgs#eza nixpkgs#bat nixpkgs#fzf nixpkgs#zoxide nixpkgs#ripgrep

# 安装更多工具
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "安装更多工具..." && \
    nix profile install nixpkgs#fd nixpkgs#htop nixpkgs#btop nixpkgs#lazygit nixpkgs#delta

# 安装文件管理和搜索工具
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "安装文件管理工具..." && \
    nix profile install nixpkgs#ranger nixpkgs#broot nixpkgs#dust nixpkgs#ncdu

# 安装终端工具
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "安装终端工具..." && \
    nix profile install nixpkgs#tmux nixpkgs#neovim nixpkgs#jq nixpkgs#tldr

# 安装其他工具
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "安装其他工具..." && \
    nix profile install nixpkgs#sd nixpkgs#procs nixpkgs#git nixpkgs#neofetch

# ============================================================
# 第八阶段：验证安装
# ============================================================
RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    echo "========================================" && \
    echo "验证已安装的工具:" && \
    echo "========================================" && \
    echo "Nix 版本: $(nix --version)" && \
    echo "" && \
    for tool in eza bat fzf zoxide lazygit btop nvim rg fd tmux htop; do \
        if command -v $tool &> /dev/null; then \
            echo "✓ $tool: $(which $tool)"; \
        else \
            echo "✗ $tool: 未找到"; \
        fi; \
    done && \
    echo "========================================"

# 设置入口点
COPY --chown=testuser:testuser entrypoint.sh /home/testuser/
RUN chmod +x /home/testuser/entrypoint.sh

ENTRYPOINT ["/home/testuser/entrypoint.sh"]
CMD ["bash"]
