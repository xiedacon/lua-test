-- Copyright (c) 2018, Souche Inc.

local Array = require "utility.array"

return Array({ "coroutine", "io", "bit", "jit.opt", "table", "math", "os", "package", "string", "debug", "jit" }):reduce(function(modules, name)
  modules[name] = package.loaded[name]

  return modules
end, {})
