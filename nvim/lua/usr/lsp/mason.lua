local servers = {
  "lua_ls",
  -- "cssls",
  -- "html",
  "pyright",
  -- "rust_analyzer",
  -- "bashls",
  -- "jsonls",
  -- "yamlls",
  "efm",
  "vimls",
  "marksman",
  "clangd",
  -- "nixd",
  -- "rnix",
  -- "tsserver",
}

-- local settings = {
-- 	ui = {
-- 		border = "none",
-- 		icons = {
-- 			package_installed = "◍",
-- 			package_pending = "◍",
-- 			package_uninstalled = "◍",
-- 		},
-- 	},
-- 	log_level = vim.log.levels.INFO,
-- 	max_concurrent_installers = 4,
-- }

-- require("mason").setup(settings)
-- require("mason-lspconfig").setup({
-- 	ensure_installed = servers,
-- 	automatic_installation = true,
--  })
local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_status_ok then
  local opts = {}
    for _, server in pairs(servers) do
      opts = {
        on_attach = require("usr.lsp.handlers").on_attach,
        capabilities = require("usr.lsp.handlers").capabilities,
      }

      server = vim.split(server, "@")[1]

      local require_ok, conf_opts = pcall(require, "usr.lsp.settings." .. server)
      if require_ok then
        opts = vim.tbl_deep_extend("force", conf_opts, opts)
      end

      -- vim.api.nvim_err_writeln(opts)
      lspconfig[server].setup(opts)
    end
end
