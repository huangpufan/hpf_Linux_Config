local lspconfig = require "lspconfig"
local opts = {
  capabilities = lspconfig.util.default_config.capabilities, -- default capabilities, with offsetEncoding utf-8
  cmd = {
    "clangd",
    "--fallback-style=Google",
    "--header-insertion=iwyu",
    -- "--log=verbose",
  }, -- Command to start clangd
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" }, -- File types to handle
  root_dir = lspconfig.util.root_pattern( -- Logic to determine the root directory of a project
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    -- "compile_flags.txt",
    -- "configure.ac",
    ".git"
  ),
  single_file_support = true, -- Support for single standalone files
  -- Add additional configurations below if needed
}

return opts
