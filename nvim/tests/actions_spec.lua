local actions = require "config.actions"

assert(actions.validate(), "action catalog validation failed")

local expected_global = {
  { "n", "<Space>ad", "Remove trailing space" },
  { "n", "<Space>ff", "Search files (include submodules)" },
  { "n", "<Space>md", "Markdown reading mode" },
  { "n", "<Space>sp", "Search and replace" },
  { "x", "<Space>sp", "Search and replace selection" },
  { "n", "gb", "Add cursor at next match" },
  { "x", "gb", "Add cursor at next match" },
  { "n", "<C-p>", "Toggle floating terminal" },
  { "t", "<C-p>", "Toggle floating terminal" },
  { "n", "-", "Toggle horizontal terminal" },
  { "n", "=", "Toggle vertical terminal" },
}

for _, expectation in ipairs(expected_global) do
  local mode, lhs, description = unpack(expectation)
  local mapping = vim.fn.maparg(lhs, mode, false, true)
  assert(not vim.tbl_isempty(mapping), string.format("missing global mapping %s %s", mode, lhs))
  assert(mapping.desc == description, string.format("unexpected description for %s %s", mode, lhs))
end

assert(vim.tbl_isempty(vim.fn.maparg("<Space>at", "n", false, true)), "removed translation action is still mapped")

local owners = {
  multicursor = 9,
  grug_far = 3,
  flash = 2,
  goto_preview = 6,
  snacks = 1,
  spider = 3,
  toggleterm = 7,
}
for owner, count in pairs(owners) do
  assert(#actions.lazy_keys(owner) == count, string.format("unexpected lazy action count for %s", owner))
end

local duplicate_buffer = vim.api.nvim_create_buf(false, true)
local fake_client = { name = "actions-test" }
actions.install("lsp", { bufnr = duplicate_buffer, client = fake_client })
actions.install("lsp", { bufnr = duplicate_buffer, client = fake_client })

local expected_lsp = {
  ["gD"] = "Go to declaration",
  gd = "Go to definition",
  gi = "Go to implementation",
  K = "Document",
  gr = "Go to reference",
  ["[d"] = "Previous diagnostic",
  ["]d"] = "Next diagnostic",
  ["<C-K>"] = "Signature help",
}

local seen = {}
for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(duplicate_buffer, "n")) do
  if expected_lsp[mapping.lhs] then
    assert(not seen[mapping.lhs], "duplicate LSP mapping: " .. mapping.lhs)
    assert(mapping.desc == expected_lsp[mapping.lhs], "unexpected LSP mapping description: " .. mapping.lhs)
    seen[mapping.lhs] = true
  end
end
for lhs in pairs(expected_lsp) do
  assert(seen[lhs], "missing LSP action: " .. lhs)
end

print "actions_spec: ok"
vim.cmd "qa!"
