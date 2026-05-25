--[[
  LSP server configurations
--]]

local handlers = require("config.lsp.handlers")

local on_attach = handlers.on_attach
local capabilities = handlers.capabilities()

local function exepath(command)
  local path = vim.fn.exepath(command)
  return path ~= "" and path or command
end

local function compact(list)
  local result = {}
  for _, item in ipairs(list) do
    if item and item ~= "" then
      table.insert(result, item)
    end
  end
  return result
end

local function command_dir(command)
  local path = vim.fn.exepath(command)
  return path ~= "" and vim.fn.fnamemodify(path, ":h") or nil
end

local bashls_path = table.concat(compact({
  command_dir("bash-language-server"),
  vim.fn.expand("~/.local/bin"),
  "/usr/local/bin",
  "/usr/bin",
  "/bin",
}), ":")

local function server_config(config)
  return vim.tbl_deep_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
  }, config or {})
end

local servers = {
  lua_ls = server_config({
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
  }),

  clangd = server_config({
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
  }),

  pyright = server_config({
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "off",
        },
      },
    },
  }),

  bashls = server_config({
    cmd = { exepath("bash-language-server"), "start" },
    cmd_env = {
      BASH_IDE_LOG_LEVEL = "error",
      PATH = bashls_path,
    },
  }),
  jsonls = server_config(),
  marksman = server_config(),

  efm = server_config({
    cmd = { "efm-langserver", "-c", vim.fn.stdpath("config") .. "/efm.yaml" },
    init_options = { documentFormatting = true },
    filetypes = { "sh", "rst" },
  }),
}

local server_names = {}
for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  table.insert(server_names, name)
end

vim.lsp.enable(server_names)
