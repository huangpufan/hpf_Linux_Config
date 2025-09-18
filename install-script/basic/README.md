# WSL Basic Environment Configuration and Installation Guide

[简体中文](/install-script/basic/README-CN.md)

This installation script is primarily aimed at `Ubuntu 20.04`. Due to the limitations of the development environment, the installation is mainly performed on `20.04`.

The environment configuration process is very straightforward:

0. `sudo apt -y install make`

   To use the provided makefile to run the installation script.

1. Edit the username and email in sshkey-generate.sh to your own.

2. Open a proxy on your local machine
   
   - Access related to github must use a proxy.
   
   - The script will write the aliases proxy and unp into bashrc, using the former to enable the proxy and the latter to disable it.

3. `make sshkey-generate-and-cat` 

   - And place the corresponding public key into the popping-up links, including github gitee.

4. `make install-after-sshkey-genarate`

   You may encounter points during the process where you need to press Enter; just keep pressing Enter.

   With that, the basic environment is installed. You can then proceed to install a series of configurations such as nvim/tmux according to your interests.
