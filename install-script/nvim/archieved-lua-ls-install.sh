#!/bin/bash
MYPATH="/home/$(whoami)"
mkdir ss
rm -rf ss
rm -rf $MYPATH/hpf_Linux_Config/install_package/lua-language-server-folder
rm -rf $MYPATH/.local/bin/lua-language-server-folder ~/.local/bin/lua-language-server
 
mkdir $MYPATH/.local/bin/lua-language-server-folder
tar -xf $MYPATH/hpf_Linux_Config/install_package/lua-language-server-3.7.0-linux-x64.tar.gz -C  $MYPATH/.local/bin/lua-language-server-folder
ln -s $MYPATH/.local/bin/lua-language-server-folder/bin/lua-language-server $MYPATH/.local/bin/lua-language-server
