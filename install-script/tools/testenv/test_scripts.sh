#!/usr/bin/env bash
# install-script 全面测试脚本
# 用于检测脚本中的各种问题

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 计数器
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[PASS]${NC} $*"; ((PASSED++)); ((TOTAL++)); }
fail()    { echo -e "${RED}[FAIL]${NC} $*"; ((FAILED++)); ((TOTAL++)); }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; ((WARNINGS++)); }

# ========================================
# 测试函数
# ========================================

# 检查脚本语法
check_syntax() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    if bash -n "$script" 2>/dev/null; then
        success "语法正确: $relpath"
        return 0
    else
        fail "语法错误: $relpath"
        bash -n "$script" 2>&1 | head -5 | sed 's/^/       /'
        return 1
    fi
}

# 检查 shebang
check_shebang() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    local first_line
    first_line=$(head -1 "$script")
    
    if [[ "$first_line" =~ ^#! ]]; then
        return 0
    else
        warn "缺少 shebang: $relpath"
        return 1
    fi
}

# 检查是否有 set -e 或类似的错误处理
check_error_handling() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    if grep -qE '^set\s+(-[eEuo]|.*pipefail)' "$script"; then
        return 0
    else
        warn "建议添加 set -e 或 set -Eeuo pipefail: $relpath"
        return 1
    fi
}

# 检查未定义变量使用
check_undefined_vars() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    local issues=""
    
    # 检查常见的未定义变量模式
    if grep -qE '\$ubuntu_version\b' "$script" && ! grep -qE 'ubuntu_version=' "$script"; then
        issues="$issues ubuntu_version"
    fi
    if grep -qE '\$SCRIPT_DIR\b' "$script" && ! grep -qE 'SCRIPT_DIR=' "$script"; then
        issues="$issues SCRIPT_DIR"
    fi
    
    if [ -n "$issues" ]; then
        fail "可能使用未定义变量: $relpath -> $issues"
        return 1
    fi
    return 0
}

# 检查硬编码的用户路径
check_hardcoded_paths() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    # 检查硬编码的 /home/username 路径（不是 $HOME 或 ~）
    if grep -qE '/home/[a-z]+[^/]' "$script" && ! grep -qE '^\s*#' "$script"; then
        # 排除注释行
        local matches
        matches=$(grep -nE '/home/[a-z]+' "$script" | grep -v '^\s*#' || true)
        if [ -n "$matches" ]; then
            warn "可能有硬编码用户路径: $relpath"
            echo "$matches" | head -3 | sed 's/^/       /'
            return 1
        fi
    fi
    return 0
}

# 检查 snap 相关命令（容器中不可用）
check_snap_usage() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    if grep -qE '^\s*sudo\s+snap\s+' "$script" || grep -qE '^\s*snap\s+' "$script"; then
        warn "使用 snap（容器中不可用）: $relpath"
        return 1
    fi
    return 0
}

# 检查相对路径脚本调用
check_relative_calls() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    local script_dir
    script_dir=$(dirname "$script")
    
    # 查找 bash ./xxx.sh 或 ./xxx.sh 调用
    while IFS= read -r line; do
        if [[ "$line" =~ bash[[:space:]]+\./ ]] || [[ "$line" =~ ^\./ && "$line" =~ \.sh$ ]]; then
            # 提取被调用的脚本名
            local called_script
            called_script=$(echo "$line" | grep -oE '\./[a-zA-Z0-9_-]+\.sh' | head -1)
            if [ -n "$called_script" ]; then
                local full_path="$script_dir/$called_script"
                if [ ! -f "$full_path" ]; then
                    fail "调用不存在的脚本: $relpath -> $called_script"
                    return 1
                fi
            fi
        fi
    done < "$script"
    return 0
}

# 检查是否使用了过时的 apt-key
check_apt_key() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    if grep -qE 'apt-key\s+add' "$script"; then
        warn "使用了过时的 apt-key（Ubuntu 22.04+ 已弃用）: $relpath"
        return 1
    fi
    return 0
}

# 检查是否有交互式命令（无 -y 参数）
check_interactive() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    # apt install 没有 -y
    if grep -qE 'apt(-get)?\s+install\s+[^-]' "$script"; then
        if ! grep -qE 'apt(-get)?\s+install\s+-y' "$script" && ! grep -qE 'DEBIAN_FRONTEND=noninteractive' "$script"; then
            # 可能有交互式安装
            local matches
            matches=$(grep -nE 'apt(-get)?\s+install' "$script" | grep -v '\-y' || true)
            if [ -n "$matches" ]; then
                warn "可能有交互式 apt install（建议加 -y）: $relpath"
                return 1
            fi
        fi
    fi
    return 0
}

# 检查 source 命令的文件是否存在
check_source_files() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    # 检查 source ~/.bashrc 等
    if grep -qE 'source\s+~/.bashrc' "$script"; then
        warn "source ~/.bashrc 在脚本开头可能失败（文件可能不存在或非交互式）: $relpath"
        return 1
    fi
    return 0
}

# 运行 shellcheck（如果可用）
run_shellcheck() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    if ! command -v shellcheck >/dev/null 2>&1; then
        return 0
    fi
    
    local output
    output=$(shellcheck -S warning "$script" 2>&1 || true)
    if [ -n "$output" ]; then
        warn "ShellCheck 警告: $relpath"
        echo "$output" | head -10 | sed 's/^/       /'
        return 1
    fi
    return 0
}

# ========================================
# 主测试流程
# ========================================

find_scripts() {
    find "$REPO_ROOT" -type f -name "*.sh" \
        ! -path "*/no-use/*" \
        ! -path "*/.git/*" \
        ! -path "*/tools/testenv/*" \
        | sort
}

test_single_script() {
    local script="$1"
    local relpath="${script#$REPO_ROOT/}"
    
    echo ""
    info "测试: $relpath"
    echo "----------------------------------------"
    
    check_syntax "$script"
    check_shebang "$script"
    check_error_handling "$script"
    check_undefined_vars "$script"
    check_hardcoded_paths "$script"
    check_snap_usage "$script"
    check_relative_calls "$script"
    check_apt_key "$script"
    check_interactive "$script"
    check_source_files "$script"
    run_shellcheck "$script"
}

print_summary() {
    echo ""
    echo "========================================"
    echo "  测试总结"
    echo "========================================"
    echo -e "  总测试数: ${BLUE}$TOTAL${NC}"
    echo -e "  通过: ${GREEN}$PASSED${NC}"
    echo -e "  失败: ${RED}$FAILED${NC}"
    echo -e "  警告: ${YELLOW}$WARNINGS${NC}"
    echo "========================================"
    
    if [ "$FAILED" -gt 0 ]; then
        echo -e "\n${RED}存在失败的测试！${NC}"
        return 1
    else
        echo -e "\n${GREEN}所有语法测试通过！${NC}"
        return 0
    fi
}

main() {
    echo "========================================"
    echo "  install-script 脚本测试"
    echo "========================================"
    echo "仓库根目录: $REPO_ROOT"
    
    local scripts
    scripts=$(find_scripts)
    local script_count
    script_count=$(echo "$scripts" | wc -l)
    
    info "找到 $script_count 个脚本"
    
    for script in $scripts; do
        test_single_script "$script"
    done
    
    print_summary
}

# 支持测试单个脚本
if [ $# -gt 0 ]; then
    if [ -f "$1" ]; then
        test_single_script "$1"
        print_summary
    else
        echo "文件不存在: $1"
        exit 1
    fi
else
    main
fi

