REPO_DIR="./linux-package-repository"
# 检查目录是否存在，如果不存在，克隆仓库
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning linux-package-repository..."
    git clone git@github.com:huangpufan/linux-package-repository.git $REPO_DIR --depth=1
fi # 这里的 'if' 应为 'fi' 来关闭 if 语句

echo "Updating linux-package-repository..."

cd $REPO_DIR
git pull
bash ./cmake-install.sh
bash ./cp-to-bin.sh 
bash ./deb-install.sh
echo "Linux repository install done."
