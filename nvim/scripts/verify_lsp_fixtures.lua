local workdir = "@WORKDIR@"

for _, fixture in ipairs(require("config.languages").runtime().fixtures) do
  if fixture.lsp_name then
    local path = workdir .. "/" .. fixture.filename
    vim.fn.writefile(vim.split(fixture.content, "\n", { plain = true }), path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.cmd "filetype detect"
    assert(
      vim.wait(20000, function()
        return #vim.lsp.get_clients { bufnr = 0, name = fixture.lsp_name } > 0
      end, 100),
      string.format("LSP fixture did not attach: %s (%s)", fixture.filename, fixture.lsp_name)
    )
    vim.cmd "bdelete!"
  end
end

print "LANGUAGE_FIXTURE_LSP_OK"
