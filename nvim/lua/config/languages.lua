local M = {}

local catalog_path = vim.fn.stdpath "config" .. "/languages.json"
local allowed_owners = { apt = true, npm = true, cargo = true, github_release = true, mason = true }
local cache

local function read_catalog()
  if cache then
    return cache
  end

  local file, open_error = io.open(catalog_path, "r")
  assert(file, "cannot open language catalog: " .. tostring(open_error))
  local contents = file:read "*a"
  file:close()

  local ok, decoded = pcall(vim.json.decode, contents)
  assert(ok, "invalid language catalog JSON: " .. tostring(decoded))
  cache = decoded
  return cache
end

local function append_unique(target, seen, value, label)
  assert(type(value) == "string" and value ~= "", label .. " must be a non-empty string")
  assert(not seen[value], "duplicate " .. label .. ": " .. value)
  seen[value] = true
  target[#target + 1] = value
end

local function tool_index(catalog)
  local tools = {}
  for _, tool in ipairs(catalog.tools or {}) do
    assert(type(tool.id) == "string" and tool.id ~= "", "tool id must be a non-empty string")
    assert(not tools[tool.id], "duplicate tool id: " .. tool.id)
    assert(type(tool.command) == "string" and tool.command ~= "", "tool command is required: " .. tool.id)
    assert(allowed_owners[tool.owner], "unknown install owner for " .. tool.id .. ": " .. tostring(tool.owner))
    assert(tool.package ~= nil, "tool package is required: " .. tool.id)
    tools[tool.id] = tool
  end
  return tools
end

function M.validate()
  local catalog = read_catalog()
  assert(catalog.schema_version == 1, "unsupported language catalog schema version")
  assert(type(catalog.tools) == "table", "language catalog tools must be a list")
  assert(type(catalog.languages) == "table", "language catalog languages must be a list")
  assert(type(catalog.extra_parsers) == "table", "language catalog extra_parsers must be a list")

  local tools = tool_index(catalog)
  local language_ids = {}
  local filetypes = {}
  local lsp_names = {}
  local parsers = {}

  for _, language in ipairs(catalog.languages) do
    assert(type(language.id) == "string" and language.id ~= "", "language id must be a non-empty string")
    assert(not language_ids[language.id], "duplicate language id: " .. language.id)
    language_ids[language.id] = true
    assert(type(language.filetypes) == "table" and #language.filetypes > 0, "language needs filetypes: " .. language.id)
    assert(type(language.parsers) == "table", "language parsers must be a list: " .. language.id)
    assert(type(language.formatters) == "table", "language formatters must be a list: " .. language.id)
    assert(type(language.linters) == "table", "language linters must be a list: " .. language.id)
    assert(type(language.fixtures) == "table" and #language.fixtures > 0, "language needs fixtures: " .. language.id)

    for _, filetype in ipairs(language.filetypes) do
      assert(not filetypes[filetype], "filetype conflict: " .. filetype)
      filetypes[filetype] = language.id
    end

    if language.lsp then
      assert(type(language.lsp.name) == "string" and language.lsp.name ~= "", "LSP name is required: " .. language.id)
      assert(not lsp_names[language.lsp.name], "duplicate LSP name: " .. language.lsp.name)
      lsp_names[language.lsp.name] = true
      assert(tools[language.lsp.tool], "unknown LSP tool reference: " .. tostring(language.lsp.tool))
      assert(tools[language.lsp.tool].owner == "mason", "LSP must be owned by Mason: " .. language.lsp.name)
    end

    for _, parser in ipairs(language.parsers) do
      assert(not parsers[parser], "duplicate parser: " .. parser)
      parsers[parser] = true
    end

    for _, field in ipairs { "formatters", "linters" } do
      local names = {}
      for _, entry in ipairs(language[field]) do
        assert(type(entry.name) == "string" and entry.name ~= "", field .. " entry needs a name: " .. language.id)
        assert(not names[entry.name], "duplicate " .. field .. " entry for " .. language.id .. ": " .. entry.name)
        names[entry.name] = true
        assert(tools[entry.tool], "unknown tool reference: " .. tostring(entry.tool))
      end
    end

    for _, fixture in ipairs(language.fixtures) do
      assert(
        type(fixture.filename) == "string" and fixture.filename ~= "",
        "fixture filename is required: " .. language.id
      )
      assert(type(fixture.content) == "string", "fixture content is required: " .. fixture.filename)
      if fixture.parser then
        assert(
          vim.list_contains(language.parsers, fixture.parser),
          "fixture parser is not declared by language: " .. fixture.parser
        )
      end
      if fixture.lsp then
        assert(language.lsp, "fixture requests LSP but language has none: " .. fixture.filename)
      end
    end
  end

  for _, parser_entry in ipairs(catalog.extra_parsers) do
    local name = type(parser_entry) == "string" and parser_entry or parser_entry.name
    assert(type(name) == "string" and name ~= "", "extra parser needs a name")
    assert(not parsers[name], "duplicate parser: " .. name)
    parsers[name] = true
  end

  return true
end

local function project_runtime()
  M.validate()
  local catalog = read_catalog()
  local tools = tool_index(catalog)
  local runtime = {
    catalog = catalog,
    tools = tools,
    lsp_names = {},
    mason_packages = {},
    parsers = {},
    formatters_by_ft = {},
    linters_by_ft = {},
    fixtures = {},
  }

  local seen_lsp = {}
  local seen_mason = {}
  local seen_parsers = {}

  for _, language in ipairs(catalog.languages) do
    if language.lsp then
      append_unique(runtime.lsp_names, seen_lsp, language.lsp.name, "LSP name")
      append_unique(runtime.mason_packages, seen_mason, tools[language.lsp.tool].package, "Mason package")
    end

    for _, parser in ipairs(language.parsers) do
      append_unique(runtime.parsers, seen_parsers, parser, "parser")
    end

    for _, filetype in ipairs(language.filetypes) do
      if #language.formatters > 0 then
        runtime.formatters_by_ft[filetype] = vim
          .iter(language.formatters)
          :map(function(entry)
            return entry.name
          end)
          :totable()
      end
      if #language.linters > 0 then
        runtime.linters_by_ft[filetype] = vim
          .iter(language.linters)
          :map(function(entry)
            return entry.name
          end)
          :totable()
      end
    end

    for _, fixture in ipairs(language.fixtures) do
      local item = vim.deepcopy(fixture)
      item.language = language.id
      item.filetypes = vim.deepcopy(language.filetypes)
      item.lsp_name = fixture.lsp and language.lsp.name or nil
      item.formatters = vim.deepcopy(language.formatters)
      item.linters = vim.deepcopy(language.linters)
      runtime.fixtures[#runtime.fixtures + 1] = item
    end
  end

  for _, parser_entry in ipairs(catalog.extra_parsers) do
    local name = type(parser_entry) == "string" and parser_entry or parser_entry.name
    append_unique(runtime.parsers, seen_parsers, name, "parser")
    if type(parser_entry) == "table" and parser_entry.fixture then
      local item = vim.deepcopy(parser_entry.fixture)
      item.parser = name
      item.extra_parser = true
      runtime.fixtures[#runtime.fixtures + 1] = item
    end
  end

  return runtime
end

function M.runtime()
  return project_runtime()
end

function M.lsp_configs(defaults)
  local server_overrides = require("config.lsp.servers").overrides()
  local configs = {}

  for _, name in ipairs(project_runtime().lsp_names) do
    configs[name] = vim.tbl_deep_extend("force", vim.deepcopy(defaults or {}), server_overrides[name] or {})
  end

  for name in pairs(server_overrides) do
    assert(configs[name], "LSP override references an unknown catalog server: " .. name)
  end

  return configs
end

return M
