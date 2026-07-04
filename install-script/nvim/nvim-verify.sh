#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$INSTALL_ROOT/.." && pwd)"
NVIM_CONFIG="$REPO_ROOT/nvim"
TMPDIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

log() {
    printf '[nvim-verify] %s\n' "$*"
}

fail() {
    printf '[nvim-verify] FAIL: %s\n' "$*" >&2
    exit 1
}

pass() {
    printf '[nvim-verify] OK: %s\n' "$*"
}

require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || fail "missing command: $cmd"
}

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
if [ -d "$HOME/.nvm/versions/node" ]; then
    for node_bin in "$HOME"/.nvm/versions/node/*/bin; do
        [ -d "$node_bin" ] && export PATH="$node_bin:$PATH"
    done
fi

check_basic_state() {
    log "checking Neovim binary and config link"
    require_command nvim

    local version
    version="$(nvim --version | sed -n '1p')"
    case "$version" in
        "NVIM v0.12.2"*) ;;
        *) fail "expected NVIM v0.12.2, got: $version" ;;
    esac

    [ -L "$HOME/.config/nvim" ] || fail "$HOME/.config/nvim is not a symlink"
    [ "$(readlink -f "$HOME/.config/nvim")" = "$(readlink -f "$NVIM_CONFIG")" ] ||
        fail "$HOME/.config/nvim does not point to $NVIM_CONFIG"
    [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ] ||
        fail "lazy.nvim is not installed under ~/.local/share/nvim/lazy"

    timeout 120s nvim --headless "$NVIM_CONFIG/init.lua" '+qa' >/dev/null
    pass "binary, config link, and startup"
}

check_external_tools() {
    log "checking external tools used by Nvim plugins"
    local commands=(
        tree-sitter
        lua-language-server
        clangd
        pyright-langserver
        bash-language-server
        vscode-json-language-server
        marksman
        shellcheck
        shfmt
        stylua
        prettier
        rst-lint
        pandoc
    )
    local cmd
    for cmd in "${commands[@]}"; do
        require_command "$cmd"
    done
    pass "external tools"
}

check_health() {
    log "running checkhealth"
    local health_file="$TMPDIR/checkhealth.txt"
    local health_output="$TMPDIR/checkhealth.out"
    if ! timeout 180s nvim --headless '+checkhealth' "+w! $health_file" '+qa' >"$health_output" 2>&1; then
        cat "$health_output" >&2
        fail "checkhealth command failed"
    fi
    local health_grep="$TMPDIR/checkhealth-grep.txt"
    if grep -nE '(ERROR|WARNING|FAIL|not installed|outdated)' "$health_file" | grep -vE 'WARNING Nvim [0-9.]+ is available \(current: [0-9.]+\)' >"$health_grep" 2>/dev/null; then
        cat "$health_grep" >&2
        fail "checkhealth reported problems"
    fi
    pass "checkhealth"
}

check_plugin_loads() {
    log "loading every configured lazy.nvim plugin"
    local script="$TMPDIR/plugin-load.lua"
    cat >"$script" <<'LUA'
local lazy = require("lazy")
local cfg = require("lazy.core.config")
local names = {}
for name, _ in pairs(cfg.plugins) do
  if name ~= "lazy.nvim" then
    names[#names + 1] = name
  end
end
table.sort(names)

local failed = {}
for _, name in ipairs(names) do
  local ok, err = pcall(lazy.load, { plugins = { name }, wait = true })
  if not ok then
    failed[#failed + 1] = name .. ": " .. tostring(err)
  end
end

if #failed > 0 then
  for _, item in ipairs(failed) do
    print("PLUGIN_LOAD_FAIL\t" .. item)
  end
  vim.cmd("cquit 1")
end
print("PLUGIN_LOAD_OK\t" .. tostring(#names))
LUA
    local output="$TMPDIR/plugin-load.out"
    if ! timeout 180s nvim --headless "+luafile $script" '+qa' >"$output" 2>&1; then
        cat "$output" >&2
        fail "plugin load matrix failed"
    fi
    pass "plugin load matrix"
}

check_plugin_commands() {
    log "checking lazy.nvim command entrypoints"
    local script="$TMPDIR/plugin-commands.lua"
    cat >"$script" <<'LUA'
local cfg = require("lazy.core.config")
local lazy = require("lazy")
local cmds = {}

for name, plugin in pairs(cfg.plugins) do
  if plugin.cmd then
    local list = type(plugin.cmd) == "table" and plugin.cmd or { plugin.cmd }
    for _, cmd in ipairs(list) do
      cmds[#cmds + 1] = { name = name, cmd = cmd }
    end
  end
end
table.sort(cmds, function(a, b)
  return a.cmd < b.cmd
end)

local failed = {}
for _, item in ipairs(cmds) do
  if item.name == "markdown-preview.nvim" then
    vim.bo.filetype = "markdown"
  end
  local ok, err = pcall(lazy.load, { plugins = { item.name }, wait = true })
  local exists = vim.fn.exists(":" .. item.cmd) == 2
  if not ok or not exists then
    failed[#failed + 1] = item.cmd .. " (" .. item.name .. "): " .. tostring(err or "missing command")
  end
end

if #failed > 0 then
  for _, item in ipairs(failed) do
    print("PLUGIN_CMD_FAIL\t" .. item)
  end
  vim.cmd("cquit 1")
end
print("PLUGIN_CMD_OK\t" .. tostring(#cmds))
LUA
    local output="$TMPDIR/plugin-commands.out"
    if ! timeout 180s nvim --headless "+luafile $script" '+qa' >"$output" 2>&1; then
        cat "$output" >&2
        fail "plugin command matrix failed"
    fi
    pass "plugin command matrix"
}

check_lsp_matrix() {
    log "checking LSP attach matrix"
    local workdir="$TMPDIR/lsp"
    mkdir -p "$workdir"
    git -C "$workdir" init -q
    printf 'local x = vim.version()\n' >"$workdir/test.lua"
    printf '#include <stdio.h>\nint main(void) { return 0; }\n' >"$workdir/test.c"
    printf 'print("hello")\n' >"$workdir/test.py"
    printf '#!/usr/bin/env bash\necho hello\n' >"$workdir/test.sh"
    printf '{"ok": true}\n' >"$workdir/test.json"
    printf '# Title\n\ntext\n' >"$workdir/test.md"

    verify_lsp "$workdir/test.lua" '{"lua_ls"}'
    verify_lsp "$workdir/test.c" '{"clangd"}'
    verify_lsp "$workdir/test.py" '{"pyright"}'
    verify_lsp "$workdir/test.sh" '{"bashls"}'
    verify_lsp "$workdir/test.json" '{"jsonls"}'
    verify_lsp "$workdir/test.md" '{"marksman"}'
    pass "LSP attach matrix"
}

check_format_lint_matrix() {
    log "checking formatter and linter matrix"
    local workdir="$TMPDIR/format-lint"
    mkdir -p "$workdir"

    printf 'local  x={1,2}\n' >"$workdir/test.lua"
    timeout 30s nvim --headless "$workdir/test.lua" \
        '+lua require("conform").format({ async = false, timeout_ms = 10000, lsp_format = "never" })' \
        '+write' '+qa'
    grep -q 'local x = { 1, 2 }' "$workdir/test.lua" ||
        fail "conform stylua smoke test did not format Lua"

    printf '%s\n' "#!/usr/bin/env bash" "echo \$UNQUOTED" >"$workdir/test.sh"
    timeout 30s nvim --headless "$workdir/test.sh" \
        "+lua local lint=require('lint'); lint.try_lint('shellcheck'); local ok=vim.wait(10000, function() return #vim.diagnostic.get(0) > 0 end, 100); if not ok then print('LINT_FAIL\tshellcheck'); vim.cmd('cquit 1') end" \
        '+qa'

    printf 'Title\n=====\n\nBad `link\n' >"$workdir/test.rst"
    timeout 30s nvim --headless "$workdir/test.rst" \
        "+lua local lint=require('lint'); lint.try_lint('rst_lint'); local ok=vim.wait(10000, function() return #vim.diagnostic.get(0) > 0 end, 100); if not ok then print('LINT_FAIL\trst_lint'); vim.cmd('cquit 1') end" \
        '+qa'

    pass "formatter and linter matrix"
}

verify_lsp() {
    local file="$1"
    local expected_lua="$2"
    timeout 45s nvim --headless "$file" \
        "+lua local expected=$expected_lua; local ok=vim.wait(20000, function() local seen={} for _,client in ipairs(vim.lsp.get_clients({bufnr=0})) do seen[client.name]=true end for _,name in ipairs(expected) do if not seen[name] then return false end end return true end, 100); if not ok then local names={} for _,client in ipairs(vim.lsp.get_clients({bufnr=0})) do names[#names+1]=client.name end table.sort(names); print('LSP_FAIL\t' .. vim.bo.filetype .. '\t' .. table.concat(names, ',')); vim.cmd('cquit 1') end" \
        '+qa'
}

check_treesitter_matrix() {
    log "checking Treesitter parser matrix"
    local required_script="$TMPDIR/treesitter-required.lua"
    cat >"$required_script" <<'LUA'
local required = {
  "bash",
  "c",
  "cpp",
  "css",
  "html",
  "javascript",
  "json",
  "just",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}
local installed = {}
for _, parser in ipairs(require("nvim-treesitter").get_installed("parsers")) do
  installed[parser] = true
end
for _, parser in ipairs(required) do
  if not installed[parser] then
    print("TS_PARSER_MISSING\t" .. parser)
    vim.cmd("cquit 1")
  end
end
print("TS_PARSERS_OK\t" .. tostring(#required))
LUA
    local parser_output="$TMPDIR/treesitter-parsers.out"
    if ! timeout 60s nvim --headless "+luafile $required_script" '+qa' >"$parser_output" 2>&1; then
        cat "$parser_output" >&2
        fail "Treesitter parser install matrix failed"
    fi

    local workdir="$TMPDIR/treesitter"
    mkdir -p "$workdir"
    printf 'local x = 1\n' >"$workdir/test.lua"
    printf '#include <stdio.h>\nint main(void){return 0;}\n' >"$workdir/test.c"
    printf 'int main(){return 0;}\n' >"$workdir/test.cpp"
    printf 'print("hi")\n' >"$workdir/test.py"
    printf '#!/usr/bin/env bash\necho hi\n' >"$workdir/test.sh"
    printf '{"ok":true}\n' >"$workdir/test.json"
    printf 'ok: true\n' >"$workdir/test.yaml"
    printf '# T\n\ntext\n' >"$workdir/test.md"
    printf 'let x = 1;\n' >"$workdir/test.js"
    printf 'const x: number = 1;\n' >"$workdir/test.ts"
    printf '<html><body></body></html>\n' >"$workdir/test.html"
    printf 'body { color: red; }\n' >"$workdir/test.css"
    printf 'default:\n\techo hi\n' >"$workdir/justfile"

    local file
    for file in "$workdir"/*; do
        timeout 20s nvim --headless "$file" \
            '+lua local ok, err = pcall(vim.treesitter.start); if not ok then print("TS_START_FAIL\t" .. vim.bo.filetype .. "\t" .. tostring(err)); vim.cmd("cquit 1") end' \
            '+qa'
    done
    pass "Treesitter parser matrix"
}

check_plugin_cache_clean() {
    log "checking plugin cache directories that previously generated dirty files"
    local plugins=(
        markdown-preview.nvim
        lsp_signature.nvim
        nvim-treesitter
    )
    local plugin dir status
    for plugin in "${plugins[@]}"; do
        dir="$HOME/.local/share/nvim/lazy/$plugin"
        [ -d "$dir/.git" ] || fail "missing plugin git directory: $plugin"
        status="$(git -C "$dir" status --short)"
        [ -z "$status" ] || fail "$plugin has dirty cache state: $status"
    done
    pass "plugin cache cleanliness"
}

main() {
    check_basic_state
    check_external_tools
    check_health
    check_plugin_loads
    check_plugin_commands
    check_lsp_matrix
    check_format_lint_matrix
    check_treesitter_matrix
    check_plugin_cache_clean
    pass "Neovim verification complete"
}

main "$@"
