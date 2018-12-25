-- Copyright (c) 2018, Souche Inc.

local Array = require "utility.array"
local Object = require "utility.object"
local String = require "utility.string"

local T = require "test.t"
local Output = require "test.output"
local utils = require "test.utils"
local inner_modules = require "test.inner_modules"

local test = { _VERSION = "0.1" }

function test:run(opts)
    local roots = opts.roots
    local package_path = opts.package_path
    local package_cpath = opts.package_cpath
    local package_loaded = opts.package_loaded
    local extension = opts.extension
    if type(roots) == "string" then roots = {roots } end
    if type(roots) ~= "table" then return false, "opts.roots should be a string or table" end
    if package_path and type(package_path) ~= "string" then return false, "" end
    if type(extension) ~= "string" then extension = ".lua" end

    local loaded = Object.assign({}, package.loaded)
    local runner
    local err
    local not_ok = Array.some(roots, function(root)
        table.clear(package.loaded)
        Object.assign(package.loaded, inner_modules)

        _G.package_path = package_path
        _G.package_cpath = package_cpath
        _G.package_loaded = package_loaded

        runner, err = require "test.runner" (root, extension)
        package.loaded["test"] = runner

        if not runner then return true end
        runner:__run()
    end)

    table.clear(package.loaded)
    Object.assign(package.loaded, loaded)

    if not_ok then
        return false, "failed to excute test, error: " .. err
    else 
        return true
    end
end

return test
