-- Copyright (c) 2018, Souche Inc.

local Object = require "utility.object"
local Array = require "utility.array"
local String = require "utility.string"
local fs = require "fs"

local rewire = {}

setmetatable(rewire, {
    __call = function(self, module)
        local file, err = rewire.resolve(module)
        if not file then error(err) end
        local content, err = fs.read(file)
        if not content then error(err) end

        if String.endsWith(file, ".lua") then
            local lines = Array(String.split(content, "\n"))
            local env = Object.assign({}, _G)
            env._G = env

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
            if not fn then error(err) end

            local res, err = fn()
            if err then error(err) end

            if type(res) == "function" then
                res = setmetatable({}, { __call = res })
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
        else
            error("unsupport file: " .. file)
        end
    end
})

function rewire.resolve(module)
    return package.searchpath(module, package.path, ".", "/")
end

return rewire
