cp ../linux-package-repository/clash-for-linux-master.zip .
unzip clash-for-linux-master.zip
cd clash-for-linux-master
read -p "Please enter your vpn subscription link: " vpn_subscription_link
sed -i "s|export CLASH_URL='.*'|export CLASH_URL='$vpn_subscription_link'|g" .env
sudo bash ./start.sh
