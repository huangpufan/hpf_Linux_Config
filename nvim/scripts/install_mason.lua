local packages = require("config.languages").runtime().mason_packages

require("lazy").load { plugins = { "mason.nvim" }, wait = true }
local registry = require "mason-registry"

local refreshed
local refresh_error
registry.refresh(function(success, error)
  refreshed = success
  refresh_error = error
end)
assert(
  vim.wait(300000, function()
    return refreshed ~= nil
  end, 100),
  "Mason registry refresh timed out"
)
assert(refreshed, "Mason registry refresh failed: " .. tostring(refresh_error))

local pending = 0
local failures = {}
for _, name in ipairs(packages) do
  local package = registry.get_package(name)
  if not package:is_installed() then
    pending = pending + 1
    package:install({}, function(success, error)
      if not success then
        failures[#failures + 1] = name .. ": " .. tostring(error)
      end
      pending = pending - 1
    end)
  end
end

assert(
  vim.wait(600000, function()
    return pending == 0
  end, 100),
  "Mason package installation timed out"
)
assert(#failures == 0, "Mason package installation failed:\n" .. table.concat(failures, "\n"))

for _, name in ipairs(packages) do
  assert(registry.get_package(name):is_installed(), "Mason package is missing after installation: " .. name)
end

print("MASON_CATALOG_OK\t" .. tostring(#packages))
