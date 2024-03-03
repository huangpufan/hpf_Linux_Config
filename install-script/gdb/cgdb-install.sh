# Dependencies
sudo apt install -y texinfo libreadline-dev autoconf automake libtool flex bison

# Latest version install
git clone git@github.com:cgdb/cgdb.git ~/download/cgdb --depth=1
cd ~/download/cgdb
./autogen.sh
./configure
make -j
sudo make install
rm -rf ~/download/cgdb

mkdir ~/.cgdb
ln -s /home/hpf/hpf_Linux_Config/install-script/gdb/cgdbrc /home/hpf/.cgdb/cgdbrc 
