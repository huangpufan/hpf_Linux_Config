cd ~/download/

# Cmake 3.28.3
wget https://sourceforge.net/projects/cmake.mirror/files/v3.28.3/cmake-3.28.3.tar.gz
tar -xvzf cmake-3.28.3.tar.gz
cd cmake-3.28.3
chmod 777 ./configure
./configure   
make -j
sudo make install
sudo update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
