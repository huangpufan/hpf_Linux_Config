current_gcc_version=$(gcc --version | grep '^gcc' | sed 's/^.* //g')
if [[ $current_gcc_version == 11.* ]]; then
    echo "GCC version 11.x is already installed."
    exit 0
fi
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt-get install -y gcc-11 g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11
