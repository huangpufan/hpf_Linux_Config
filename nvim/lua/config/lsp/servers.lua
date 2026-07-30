--[[
  LSP server configurations
--]]

local M = {}

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

local bashls_path = table.concat(
  compact {
    command_dir "bash-language-server",
    vim.fn.expand "~/.local/bin",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
  },
  ":"
)

function M.overrides()
  return {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              [vim.fn.stdpath "config" .. "/lua"] = true,
            },
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },

    clangd = {
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
    },

    pyright = {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off",
          },
        },
      },
    },

    bashls = {
      cmd = { exepath "bash-language-server", "start" },
      cmd_env = {
        BASH_IDE_LOG_LEVEL = "error",
        PATH = bashls_path,
      },
    },
  }
end

function M.setup()
  local handlers = require "config.lsp.handlers"
  local languages = require "config.languages"
  local runtime = languages.runtime()
  local servers = languages.lsp_configs {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities(),
  }

  for _, name in ipairs(runtime.lsp_names) do
    assert(servers[name], "missing LSP configuration for " .. name)
  end

  for name, config in pairs(servers) do
    vim.lsp.config(name, config)
  end

  vim.lsp.enable(runtime.lsp_names)
end

return M
