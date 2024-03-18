hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')
export all_proxy="socks5://${hostip}:7890"

./bashrc-init.sh
./profile-set.sh
./folder-create.sh
./ubuntu-source-change.sh
./apt-snap-install.sh
./pip-install.sh
./git-install.sh
./optional/clang13-install.sh
./npm-install.sh
./hosts-adjust.sh
./curl-install.sh
./cargo-install.sh
./linux-repository-install
