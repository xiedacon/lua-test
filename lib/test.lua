-- Copyright (c) 2018, Souche Inc.

local Array = require "utility.array"
local String = require "utility.string"

local T = require "test.t"
local Output = require "test.output"
local utils = require "test.utils"
local Runner = require "test.runner"

local test = {}

function test:run(opts)
    local roots = opts.roots
    if type(roots) == "string" then roots = Array({ roots }) end
    if type(roots) ~= "table" then return false, "opts.roots should be a string or table" end
    roots = Array(roots)

    local runner
    local err
    local not_ok = roots:some(function(root)
        runner, err = Runner(root)
        package.loaded["test"] = runner

        if not runner then return true end
        runner:__run()

        package.loaded["test"] = test
    end)
    
    if not_ok then
        package.loaded["test"] = test
        return false, "failed to excute test, error: " .. err
    else 
        return true
    end
end

return test
