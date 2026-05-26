--[[
  LSP handlers and on_attach configuration
--]]

local M = {}

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local map = vim.keymap.set

  map("n", "gD", vim.lsp.buf.declaration, opts)
  map("n", "gd", vim.lsp.buf.definition, opts)
  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "gi", vim.lsp.buf.implementation, opts)
  map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  map("n", "gr", function()
    require("telescope.builtin").lsp_references({
      include_declaration = false,
      show_line = true,
      trim_text = true,
    })
  end, opts)
  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, opts)
  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, opts)
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)

  -- Attach navic for breadcrumbs
  if client.server_capabilities.documentSymbolProvider then
    local ok, navic = pcall(require, "nvim-navic")
    if ok then
      navic.attach(client, bufnr)
    end
  end
end

M.capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok, blink_cmp = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink_cmp.get_lsp_capabilities(capabilities)
  end

  return capabilities
end

function M.setup()
  -- Diagnostic config
  vim.diagnostic.config({
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
      },
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  -- Hover and signature help borders
  local hover = vim.lsp.handlers.hover
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, { border = "rounded" })
    return hover(err, result, ctx, config)
  end

  local signature_help = vim.lsp.handlers.signature_help
  vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, { border = "rounded" })
    return signature_help(err, result, ctx, config)
  end
end

return M
