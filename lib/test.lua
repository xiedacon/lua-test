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
    local output = opts.output or Output(opts.stdout or io.stdout)
    if type(roots) == "string" then roots = {roots } end
    if type(roots) ~= "table" then return false, "opts.roots should be a string or table" end
    if package_path and type(package_path) ~= "string" then return false, "opts.package_path should be a string or nil" end
    if package_cpath and type(package_cpath) ~= "string" then return false, "opts.package_cpath should be a string or nil" end
    if type(extension) ~= "string" then extension = ".lua" end
    if type(output) ~= "table" then return false, "opts.output should be a table" end
    if type(output.startRunner) ~= "function" then return false, "opts.output.startRunner should be a function" end
    if type(output.startTest) ~= "function" then return false, "opts.output.startTest should be a function" end
    if type(output.error) ~= "function" then return false, "opts.output.error should be a function" end
    if type(output.endTest) ~= "function" then return false, "opts.output.endTest should be a function" end
    if type(output.endRunner) ~= "function" then return false, "opts.output.endRunner should be a function" end

    local loaded = Object.assign({}, package.loaded)
    local runner
    local err
    local not_ok = Array.some(roots, function(root)
        table.clear(package.loaded)
        Object.assign(package.loaded, inner_modules)

        _G.package_path = package_path
        _G.package_cpath = package_cpath
        _G.package_loaded = package_loaded

        runner, err = require "test.runner" (root, extension, output)
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
