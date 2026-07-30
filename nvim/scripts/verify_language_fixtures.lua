local workdir = "@WORKDIR@"
vim.fn.mkdir(workdir, "p")

for _, fixture in ipairs(require("config.languages").runtime().fixtures) do
  if fixture.format or fixture.lint then
    local path = workdir .. "/" .. fixture.filename
    vim.fn.writefile(vim.split(fixture.content, "\n", { plain = true }), path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.cmd "filetype detect"

    if fixture.format then
      require("conform").format { async = false, timeout_ms = 10000, lsp_format = "never" }
      vim.cmd.write()
      local contents = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      assert(contents:find(fixture.format.expected_contains, 1, true), "format fixture failed: " .. fixture.filename)
    end

    if fixture.lint and fixture.lint.expect_diagnostics then
      require("lint").try_lint()
      assert(
        vim.wait(10000, function()
          return #vim.diagnostic.get(0) > 0
        end, 100),
        "lint fixture produced no diagnostics: " .. fixture.filename
      )
    end
    vim.cmd "bdelete!"
  end
end

print "LANGUAGE_FIXTURE_FORMAT_LINT_OK"
