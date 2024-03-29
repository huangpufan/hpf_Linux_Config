# Download
# wget -O ~/download/code-v4.0-Release.tar.gz "https://gitee.com/link?target=https%3A%2F%2Frepo.huaweicloud.com%2Fopenharmony%2Fos%2F4.0-Release%2Fcode-v4.0-Release.tar.gz"

# Extract
tar -xzvf ~/download/code-v4.0-Release.tar.gz

# Get folder name after extract
folder_name=$(tar -tzf ~/download/code-v4.0-Release.tar.gz | head -1 | cut -f1 -d"/")

# Move to project
mv "$folder_name" ~/project/
rm -rf ~/download/code-v4.0-Release.tar.gz 

# The 4.0 has fatal git error,we need to handly clone some repo
cd ~/project/OpenHarmony-v4.0-Release/OpenHarmony/base/sensors/miscdevice/
wget https://gitee.com/openharmony/sensors_miscdevice/repository/archive/OpenHarmony-4.0-Release.zip
unzip OpenHarmony-4.0-Release.zip 
mv ./sensors_miscdevice-OpenHarmony-4.0-Release/* ./
rm -rf OpenHarmony-4.0-Release.zip

cd ~/project/OpenHarmony-v4.0-Release/OpenHarmony/
# Install build tools.
python3 -m pip install --user build/hb
bash build/prebuilts_download.sh
