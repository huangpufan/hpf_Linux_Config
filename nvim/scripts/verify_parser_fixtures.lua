local workdir = "@WORKDIR@"
vim.fn.mkdir(workdir, "p")

for _, fixture in ipairs(require("config.languages").runtime().fixtures) do
  if fixture.parser then
    local path = workdir .. "/" .. fixture.filename
    vim.fn.writefile(vim.split(fixture.content, "\n", { plain = true }), path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.cmd "filetype detect"
    local ok, error = pcall(vim.treesitter.start, 0, fixture.parser)
    assert(ok, string.format("parser fixture failed for %s: %s", fixture.parser, tostring(error)))
    vim.treesitter.stop(0)
    vim.cmd "bdelete!"
  end
end

print "LANGUAGE_FIXTURE_PARSERS_OK"
