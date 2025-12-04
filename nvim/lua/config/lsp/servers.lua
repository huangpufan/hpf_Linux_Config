--[[
  LSP server configurations
--]]

local lspconfig = require("lspconfig")
local handlers = require("config.lsp.handlers")

local on_attach = handlers.on_attach
local capabilities = handlers.capabilities()

-- Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Clangd (C/C++)
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

-- Pyright (Python)
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
      },
    },
  },
})

-- Bash
lspconfig.bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JSON
lspconfig.jsonls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Marksman (Markdown)
lspconfig.marksman.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- EFM
lspconfig.efm.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = { documentFormatting = true },
  filetypes = { "sh", "rst" },
})

