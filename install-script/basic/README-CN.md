# WSL 环境基本配置安装指南

本安装脚本主要面向 `Ubuntu 20.04`，由于开发环境所限，因此主要在 `20.04` 中进行安装。

环境配置过程非常简洁：

0. `sudo apt -y install make`

   以使用提供的 makefile 运行安装脚本

1. 修改 sshkey-generate.sh 中的用户名与邮箱为你自己的。

2. 在你的本机打开代理
   
   - 和 github 相关的访问必须使用代理。
   
   - 脚本将 proxy 与 unp 作为 alias 写入 bashrc 中，通过前者开启代理，后者关闭代理。

3. `make sshkey-generate-and-cat` 

   - 并将相应的公钥存放到弹出的链接中，包含 github gitee

4. `make install-after-sshkey-genarate`

   中途可能会有需要回车的地方，一路回车即可。

   这样，基本环境就安装完毕了，接下来你可以按照兴趣去安装 nvim/tmux 等一系列相关的配置了。
