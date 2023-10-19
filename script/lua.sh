cd ../install_package
mkdir lua-language-server-folder
tar -xf ./lua-language-server-3.7.0-linux-x64.tar.gz ./lua-language-server-folder
mv ./lua-language-server-folder ~/.local/bin/
ln -s ~/.local/bin/lua-language-server-folder/bin/lua-language-server ~/.local/bin/lua-language-server
