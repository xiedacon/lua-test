-- Copyright (c) 2018, Souche Inc.

local Object = require "utility.object"
local Array = require "utility.array"
local Function = require "utility.function"
local String = require "utility.string"
local fs = require "fs"
local inner_modules = require "test.inner_modules"

return function(name, loaded_modules)
    local path = package.path
    local cpath = package.cpath
    local loaded = Object.assign({}, package.loaded)

    table.clear(package.loaded)
    Object.assign(package.loaded, inner_modules, package_loaded or {}, loaded_modules)

    package.path = package_path or package.path
    package.cpath = package_cpath or package.cpath

    local file, err = package.searchpath(name, package.path, ".", "/")
    if not file then error(err) end
    if not String.endsWith(file, ".lua") then error("unsupport file: " .. file) end

    local content, err = fs.read(file)
    if not content then error(err) end

    local env = Object.assign({}, _G)
    env._G = env
    
    local lines = Array(String.split(content, "\n"))
    local fn, err = load(function()
        local line = nil

        while(not line and #lines > 0) do
            line = lines:shift()
            
            if String.startsWith(line, "local ") then
                line = String.trimLeft(string.sub(line, 6))
            end
        end

        if line then 
            return line .. "\n"
        else
            return line
        end
    end, content, "bt", env)

    local ok, res
    if type(fn) == "function" then
        ok, res = pcall(fn)
    end
    
    package.path = path
    package.cpath = cpath

    table.clear(package.loaded)
    Object.assign(package.loaded, loaded)

    if type(fn) ~= "function" or not ok then error(err or res) end

    if type(res) == "function" then
        local _res = res
        res = setmetatable({}, {
            __call = function(self, ...) return Function.apply(_res, {...}) end
        })
    end

    if type(res) == "table" then
        local index = res
        local metatable = getmetatable(res)

        while (metatable and metatable.__index) do
            index = metatable.__index
            metatable = getmetatable(index)
        end

        setmetatable(index, Object.assign(metatable or {}, {
            __index = {
                __set__ = function(self, k, v) env[k] = v end,
                __get__ = function(self, k) return env[k] end
            }
        }))
    else
        error("module should be a table or function")
    end

    return res
end
