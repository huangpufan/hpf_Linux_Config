import os
import sys
import json

def load_config(config_file):
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            return json.load(f)
    return {"ignore_completely": [], "ignore_contents": [], "exclude_files": []}

def print_directory_structure(startpath, ignore_completely, ignore_contents, exclude_files):
    for root, dirs, files in os.walk(startpath):
        level = root.replace(startpath, '').count(os.sep)
        indent = '│   ' * (level - 1) + '├── ' if level > 0 else ''
        folder_name = os.path.basename(root)
        
        # 检查是否完全忽略
        if any(folder_name.startswith(ignored) for ignored in ignore_completely):
            continue

        print(f'{indent}{folder_name}/')
        
        # 检查是否忽略内容
        if any(folder_name.startswith(ignored) for ignored in ignore_contents):
            continue

        subindent = '│   ' * level + '├── '
        for file in files:
            if not any(file.startswith(excluded) for excluded in exclude_files):
                print(f'{subindent}{file}')
        
        # 从dirs列表中移除被完全忽略的目录
        dirs[:] = [d for d in dirs if not any(d.startswith(ignored) for ignored in ignore_completely)]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <directory_path> [config_file]")
        sys.exit(1)

    path = sys.argv[1]
    config_file = sys.argv[2] if len(sys.argv) > 2 else 'project_structure_config.json'

    config = load_config(config_file)
    ignore_completely = set(config.get("ignore_completely", []))
    ignore_contents = set(config.get("ignore_contents", []))
    exclude_files = set(config.get("exclude_files", []))

    print(f"Project structure for: {path}")
    print(f"Using config file: {config_file}")
    print(f"Completely ignored directories: {', '.join(ignore_completely)}")
    print(f"Directories with ignored contents: {', '.join(ignore_contents)}")
    print(f"Excluded files: {', '.join(exclude_files)}")
    print("\nStructure:")
    print_directory_structure(path, ignore_completely, ignore_contents, exclude_files)
