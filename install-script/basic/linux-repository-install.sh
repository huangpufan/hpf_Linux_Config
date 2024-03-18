git clone git@github.com:huangpufan/linux-package-repository.git ../linux-package-repository --depth=1
cd ../linux-package-repository/
bash ./cmake-install.sh
bash ./cp-to-bin.sh 
bash ./deb-install.sh
