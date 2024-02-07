hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')
export all_proxy="socks5://${hostip}:7890"

./bashrc-init.sh
./folder-create.sh
./ubuntu-source-change.sh
./apt-install.sh
unset all_proxy 
./pip-install.sh
./curl-install.sh
./cargo-install.sh
