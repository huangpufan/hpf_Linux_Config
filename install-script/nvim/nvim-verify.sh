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

run_lua_file() {
    local timeout_seconds="$1"
    local script="$2"
    timeout "$timeout_seconds" nvim --headless \
        "+lua local ok,err=xpcall(function() dofile([[$script]]) end, debug.traceback); if not ok then io.stderr:write(err .. '\n'); vim.cmd('cquit 1') end" \
        '+qa'
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

    local config_link="$HOME/.config/nvim"
    if [ -n "${HPF_NVIM_RELEASE_DIR:-}" ]; then
        config_link="${XDG_CONFIG_HOME:?}/nvim"
    fi
    [ -L "$config_link" ] || fail "$config_link is not a symlink"
    [ "$(readlink -f "$config_link")" = "$(readlink -f "$NVIM_CONFIG")" ] ||
        fail "$config_link does not point to $NVIM_CONFIG"
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    [ -d "$data_home/nvim/lazy/lazy.nvim" ] ||
        fail "lazy.nvim is not installed under $data_home/nvim/lazy"

    if [ -n "${HPF_NVIM_RELEASE_DIR:-}" ]; then
        [ "$(readlink -f "$data_home")" = "$(readlink -f "$HPF_NVIM_RELEASE_DIR/xdg/data")" ] ||
            fail "candidate data path does not belong to $HPF_NVIM_RELEASE_DIR"
        [ "$(readlink -f "${XDG_STATE_HOME:-}")" = "$(readlink -f "$HPF_NVIM_RELEASE_DIR/xdg/state")" ] ||
            fail "candidate state path does not belong to $HPF_NVIM_RELEASE_DIR"
        [ "$(readlink -f "${XDG_CACHE_HOME:-}")" = "$(readlink -f "$HPF_NVIM_RELEASE_DIR/xdg/cache")" ] ||
            fail "candidate cache path does not belong to $HPF_NVIM_RELEASE_DIR"
    fi

    local startup_output="$TMPDIR/startup.out"
    if ! timeout 120s nvim --headless "$NVIM_CONFIG/init.lua" \
        "+lua if vim.v.errmsg ~= '' then io.stderr:write(vim.v.errmsg .. '\\n'); vim.cmd('cquit 1') end" \
        '+qa' >"$startup_output" 2>&1; then
        cat "$startup_output" >&2
        fail "startup reported an error"
    fi
    if grep -qE 'Error (detected while processing|in command line)|Failed to run `config`' "$startup_output"; then
        cat "$startup_output" >&2
        fail "startup printed an error"
    fi
    pass "binary, config link, and startup"
}

check_external_tools() {
    log "checking external tools used by Nvim plugins"
    python3 "$SCRIPT_DIR/language_catalog.py" verify --include-mason
    pass "external tools"
}

check_catalogs() {
    log "checking language and action catalogs"
    python3 "$SCRIPT_DIR/language_catalog.py" validate
    python3 -m unittest discover -s "$SCRIPT_DIR/tests" -p 'test_language_catalog.py'
    timeout 60s nvim --headless '+lua assert(require("config.languages").validate())' '+lua assert(require("config.actions").validate())' '+qa'
    pass "language and action catalogs"
}

check_health() {
    log "running checkhealth"
    local health_file="$TMPDIR/checkhealth.txt"
    local health_output="$TMPDIR/checkhealth.out"
    local health_targets=(
        lazy
        nvim-treesitter
        snacks
        vim.deprecated
        vim.lsp
        vim.pack
        vim.provider
        vim.treesitter
    )
    if ! timeout 180s nvim --headless "+checkhealth ${health_targets[*]}" "+w! $health_file" '+qa' >"$health_output" 2>&1; then
        cat "$health_output" >&2
        fail "checkhealth command failed"
    fi
    local health_grep="$TMPDIR/checkhealth-grep.txt"
    if grep -nE '(ERROR|WARNING|FAIL|not installed|outdated)' "$health_file" |
        grep -vE 'WARNING Nvim [0-9.]+ is available \(current: [0-9.]+\)|WARNING found existing packages at .*/site/pack/core|WARNING .*SQLite3.* is not available|WARNING Lockfile is absent, plugin directory is present' \
            >"$health_grep" 2>/dev/null; then
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

check_targeted_behavior() {
    log "checking terminal, Sixel image, and Markdown reading-mode behavior"
    local test_file
    for test_file in \
        "$NVIM_CONFIG/tests/actions_spec.lua" \
        "$NVIM_CONFIG/tests/sixel_image_spec.lua" \
        "$NVIM_CONFIG/tests/terminal_manager_spec.lua" \
        "$NVIM_CONFIG/tests/terminal_state_frame_spec.lua" \
        "$NVIM_CONFIG/tests/terminal_keymaps_spec.lua" \
        "$NVIM_CONFIG/tests/markdown_preview_spec.lua"; do
        local output
        output="$TMPDIR/$(basename "$test_file").out"
        if ! timeout 60s nvim --headless "+luafile $test_file" >"$output" 2>&1; then
            cat "$output" >&2
            fail "targeted behavior check failed: $(basename "$test_file")"
        fi
    done
    pass "terminal, Sixel image, and Markdown reading-mode behavior"
}

check_lsp_matrix() {
    log "checking LSP attach matrix"
    local workdir="$TMPDIR/lsp"
    mkdir -p "$workdir"
    git -C "$workdir" init -q
    local script="$TMPDIR/fixture-lsp.lua"
    sed "s|@WORKDIR@|$workdir|g" "$NVIM_CONFIG/scripts/verify_lsp_fixtures.lua" >"$script"
    run_lua_file 240 "$script"
    pass "LSP attach matrix"
}

check_lsp_auto_install_contract() {
    log "checking automatic LSP installation contract"
    local script="$TMPDIR/lsp-auto-install.lua"
    cat >"$script" <<'LUA'
require("lazy").load({ plugins = { "mason-lspconfig.nvim" } })

local runtime = require("config.languages").runtime()
local configured = vim.deepcopy(runtime.lsp_names)
local expected = vim.deepcopy(configured)
local settings = require("mason-lspconfig.settings").current
local actual = vim.deepcopy(settings.ensure_installed)
local automatic_enable = vim.deepcopy(settings.automatic_enable)
table.sort(expected)
table.sort(actual)
table.sort(automatic_enable)

if not vim.deep_equal(expected, actual) then
  error("automatic LSP install list differs from configured servers")
end

if not vim.deep_equal(expected, automatic_enable) then
  error("automatic LSP enable list differs from configured servers")
end

    if vim.fn.exists(":MasonInstallAll") ~= 2 then
      error("MasonInstallAll command is unavailable")
    end

local mapping = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
local actual_packages = {}
for _, name in ipairs(configured) do
  actual_packages[#actual_packages + 1] = mapping[name]
end
if not vim.deep_equal(runtime.mason_packages, actual_packages) then
  error("catalog Mason package projection differs from mason-lspconfig")
end
LUA

    run_lua_file 60 "$script"
    pass "automatic LSP installation contract"
}

check_replacement_capabilities() {
    log "checking capabilities provided by consolidated plugins"

    local workdir="$TMPDIR/replacements"
    mkdir -p "$workdir"
    git -C "$workdir" init -q
    git -C "$workdir" config user.name "Nvim Verify"
    git -C "$workdir" config user.email "nvim-verify@example.invalid"
    printf 'first line\nsecond line\n' >"$workdir/blame.txt"
    git -C "$workdir" add blame.txt
    git -C "$workdir" commit -qm "initial blame fixture"
    printf 'updated line\nsecond line\n' >"$workdir/blame.txt"
    git -C "$workdir" add blame.txt
    git -C "$workdir" commit -qm "verify blame replacement"

    timeout 30s nvim --headless "$workdir/blame.txt" \
        "+lua assert(vim.wait(10000, function() return vim.b.gitsigns_head ~= nil end, 100), 'gitsigns did not attach on direct file open'); vim.cmd('Gitsigns toggle_current_line_blame'); assert(vim.wait(10000, function() return vim.b.gitsigns_blame_line_dict ~= nil end, 50), 'current line blame did not appear'); local blame=vim.b.gitsigns_blame_line_dict; assert(blame.author == 'Nvim Verify', 'unexpected blame author'); assert(blame.summary == 'verify blame replacement', 'unexpected blame summary')" \
        '+qa'

    printf 'local result = string.format("value: %%s", "ok")\n' >"$workdir/signature.lua"
    timeout 45s nvim --headless "$workdir/signature.lua" \
        "+lua vim.api.nvim_win_set_cursor(0, { 1, 29 }); assert(vim.wait(20000, function() return #vim.lsp.get_clients({ bufnr = 0, name = 'lua_ls' }) > 0 end, 100), 'lua_ls did not attach'); local params=vim.lsp.util.make_position_params(0, 'utf-16'); local responses=vim.lsp.buf_request_sync(0, 'textDocument/signatureHelp', params, 10000); local found=false; for _, response in pairs(responses or {}) do if response.result and response.result.signatures and #response.result.signatures > 0 then found=true end end; assert(found, 'signatureHelp returned no signatures')" \
        '+qa'

    pass "Git blame and LSP signature help"
}

check_format_lint_matrix() {
    log "checking formatter and linter matrix"
    local script="$TMPDIR/fixture-format-lint.lua"
    sed "s|@WORKDIR@|$TMPDIR/catalog-fixtures|g" "$NVIM_CONFIG/scripts/verify_language_fixtures.lua" >"$script"
    run_lua_file 120 "$script"

    pass "formatter and linter matrix"
}

check_treesitter_matrix() {
    log "checking Treesitter parser matrix"
    local required_script="$TMPDIR/treesitter-required.lua"
    cat >"$required_script" <<'LUA'
local required = require("config.languages").runtime().parsers
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

    local script="$TMPDIR/fixture-parsers.lua"
    sed "s|@WORKDIR@|$TMPDIR/catalog-parser-fixtures|g" "$NVIM_CONFIG/scripts/verify_parser_fixtures.lua" >"$script"
    run_lua_file 120 "$script"
    pass "Treesitter parser matrix"
}

check_plugin_cache_clean() {
    log "checking plugin cache directories that previously generated dirty files"
    local plugins=(
        markdown-preview.nvim
        nvim-treesitter
    )
    local plugin dir status
    for plugin in "${plugins[@]}"; do
        dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/$plugin"
        [ -d "$dir/.git" ] || fail "missing plugin git directory: $plugin"
        status="$(git -C "$dir" status --short)"
        [ -z "$status" ] || fail "$plugin has dirty cache state: $status"
    done
    pass "plugin cache cleanliness"
}

main() {
    check_basic_state
    check_catalogs
    check_external_tools
    check_health
    check_plugin_loads
    check_plugin_commands
    check_targeted_behavior
    check_lsp_matrix
    check_lsp_auto_install_contract
    check_replacement_capabilities
    check_format_lint_matrix
    check_treesitter_matrix
    check_plugin_cache_clean
    pass "Neovim verification complete"
}

main "$@"
