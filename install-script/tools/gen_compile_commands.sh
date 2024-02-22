CURRENT_DIR=/home/hpf/project/oceanbase_competition
TARGET_FILE=compile_commands.json
./build.sh debug --init -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
mv build_debug/ 

