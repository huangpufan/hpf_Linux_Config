{ config, pkgs, lib, username ? "hpf", homeDirectory ? "/home/hpf", ... }:

{
  # Home Manager 基础配置
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;

  # ============================================================
  # 包安装配置
  # ============================================================
  home.packages = with pkgs; [
    # ----------------------------------------------------------
    # 替代 cargo 安装的工具 (原本编译很慢，现在秒装)
    # ----------------------------------------------------------
    eza           # 现代化 ls 替代品 (原 cargo install eza)
    broot         # 目录树浏览工具 (原 cargo install broot)
    yazi          # 终端文件管理器 (原 cargo install yazi)
    sd            # sed 的现代替代品 (原 cargo install sd)
    ouch          # 压缩解压工具 (原 cargo install ouch)
    mprocs        # 多进程管理器 (原 cargo install mprocs)

    # ----------------------------------------------------------
    # 替代 snap 安装的工具 (无需 snapd 依赖)
    # ----------------------------------------------------------
    btop          # 系统监视器 (原 snap install btop)
    dust          # 磁盘使用分析 (原 snap install dust)
    procs         # 进程查看工具 (原 snap install procs)
    zellij        # 终端多路复用器 (原 snap install zellij)
    lnav          # 日志文件查看器 (原 snap install lnav)
    bandwhich     # 网络带宽监视 (原 snap install bandwhich)

    # ----------------------------------------------------------
    # 替代 curl/手动安装的工具
    # ----------------------------------------------------------
    fzf           # 模糊查询工具 (原 curl 安装)
    lazygit       # Git 终端 UI (原 curl 安装)
    zoxide        # 智能目录导航 (原 curl 安装)

    # ----------------------------------------------------------
    # 替代 apt 安装的工具 (版本更新、跨发行版)
    # ----------------------------------------------------------
    bat           # 语法高亮的 cat 替代品
    htop          # 进程监视器
    tmux          # 终端多路复用
    ranger        # 终端文件管理器
    ncdu          # 磁盘使用分析工具
    tldr          # 命令简化手册
    neofetch      # 系统信息显示
    ripgrep       # 快速搜索工具 (rg)
    fd            # find 的现代替代品
    silver-searcher # ag 搜索工具
    jq            # JSON 处理工具
    tree          # 目录树显示
    wget          # 下载工具
    curl          # HTTP 客户端
    unzip         # 解压工具

    # ----------------------------------------------------------
    # 替代 npm 安装的工具
    # ----------------------------------------------------------
    fkill-cli     # 进程杀死工具 (原 npm install -g fkill-cli)

    # ----------------------------------------------------------
    # 开发工具
    # ----------------------------------------------------------
    neovim        # 编辑器
    delta         # Git 差异查看工具
    git           # 版本控制
    tig           # Git 终端 UI

    # ----------------------------------------------------------
    # 可选：根据需要取消注释
    # ----------------------------------------------------------
    # gdb           # 调试器
    # cgdb          # 彩色 GDB
    # gdbgui        # GDB GUI (如果可用)
    # nodejs        # Node.js 运行时
    # python3       # Python 3
  ];

  # ============================================================
  # 程序配置
  # ============================================================

  # Git 配置
  programs.git = {
    enable = true;
    # 取消注释并填写你的信息
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # fzf 配置
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # zoxide 配置
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # eza 配置 (ls 替代)
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # bat 配置 (cat 替代)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # btop 配置
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      vim_keys = true;
    };
  };

  # tmux 配置
  programs.tmux = {
    enable = true;
    # 如果你有自己的 tmux 配置，可以在这里导入或设置
    # extraConfig = builtins.readFile ./tmux.conf;
  };

  # ============================================================
  # Shell 配置
  # ============================================================

  # Bash 配置
  programs.bash = {
    enable = true;
    shellAliases = {
      # ls 别名 (使用 eza)
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";

      # cat 别名 (使用 bat)
      cat = "bat --paging=never";

      # grep 别名 (使用 ripgrep)
      grep = "rg";

      # find 别名 (使用 fd)
      find = "fd";

      # 其他常用别名
      ".." = "cd ..";
      "..." = "cd ../..";
      cls = "clear";
      vi = "nvim";
      vim = "nvim";
    };

    initExtra = ''
      # 加载 fzf 键绑定
      if command -v fzf &> /dev/null; then
        eval "$(fzf --bash)"
      fi

      # 加载 zoxide
      if command -v zoxide &> /dev/null; then
        eval "$(zoxide init bash)"
      fi

      # 自定义 PATH (如果需要)
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # ============================================================
  # 环境变量
  # ============================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -FR";

    # fzf 默认选项
    FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
  };
}
