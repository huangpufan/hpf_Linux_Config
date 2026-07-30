--[[
  LSP handlers and on_attach configuration
--]]

local M = {}

M.on_attach = function(client, bufnr)
  require("config.actions").install("lsp", { bufnr = bufnr, client = client })
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
  vim.diagnostic.config {
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
  }

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
