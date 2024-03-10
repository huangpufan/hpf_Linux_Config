cd ~/download/

# Cmake 3.22.1

wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz
tar -xvzf cmake-3.22.1.tar.gz
cd cmake-3.22.1
chmod 777 ./configure
./configure   
make -j
sudo make install
sudo update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
