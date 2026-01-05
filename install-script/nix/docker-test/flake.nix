{
  description = "hpf Linux Config - Nix Home Manager Configuration";

  inputs = {
    # 使用稳定版 nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # 支持的系统架构
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # 为每个系统生成配置
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # 获取对应系统的 pkgs
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Home Manager 配置
      homeConfigurations = {
        # 默认配置，用户名从环境变量获取
        "default" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          };
        };

        # x86_64 配置
        "x86_64" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./home.nix ];
        };

        # aarch64 配置 (ARM64)
        "aarch64" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-linux";
          modules = [ ./home.nix ];
        };
      };

      # 开发环境 shell
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # 基础工具
              git
              curl
              wget
            ];
          };
        }
      );

      # 可以直接运行的包集合
      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          # 最小工具集
          minimal = pkgs.buildEnv {
            name = "hpf-minimal";
            paths = with pkgs; [
              git tmux htop bat fzf zoxide
            ];
          };

          # CLI 开发工具集
          dev-cli = pkgs.buildEnv {
            name = "hpf-dev-cli";
            paths = with pkgs; [
              # 基础
              git tmux htop bat fzf zoxide
              # 文件管理
              ranger eza broot yazi
              # 搜索
              ripgrep fd silver-searcher
              # 系统监控
              btop dust procs bandwhich
              # Git 工具
              lazygit delta
              # 其他
              ncdu tldr neofetch sd ouch
            ];
          };

          # 完整开发环境
          dev-full = pkgs.buildEnv {
            name = "hpf-dev-full";
            paths = with pkgs; [
              # CLI 工具
              git tmux htop bat fzf zoxide
              ranger eza broot yazi
              ripgrep fd silver-searcher
              btop dust procs bandwhich
              lazygit delta
              ncdu tldr neofetch sd ouch
              # 终端复用
              zellij mprocs
              # 日志
              lnav
              # 编辑器
              neovim
              # 进程管理
              fkill-cli
            ];
          };
        }
      );
    };
}
