echo "Start to sync personal config"
cd ~/hpf_Linux_Config
echo "Sync hpf_Linux_Config"
git pull
cd ~/hpf_Linux_Config/install-script/basic/linux-package-repository/ 
echo "Sync linux-package-repository"
git pull
cd ~/project/self-learning-project/ 
echo "Sync self-learning-project"
git pull
