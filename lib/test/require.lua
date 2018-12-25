-- Copyright (c) 2018, Souche Inc.

local Object = require "utility.object"
local inner_modules = require "test.inner_modules"

return function(name, loaded_modules)
    local path = package.path
    local cpath = package.cpath
    local loaded = Object.assign({}, package.loaded)
    
    table.clear(package.loaded)
    Object.assign(package.loaded, inner_modules, package_loaded or {}, loaded_modules)
    
    package.path = package_path or package.path
    package.cpath = package_cpath or package.cpath

    local module = package.loaded[name]
    local err = ""
    local i = 1
    local loaders = package.loaders
    while(i < #loaders and not module) do
        local fn = loaders[i](name)

        if type(fn) == "function" then
            local ok, res = pcall(fn)
            if ok then
                module = res or true
            else
                err = res
            end
            break
        else
            err = err .. fn
        end

        i = i + 1
    end

    package.path = path
    package.cpath = cpath
    
    table.clear(package.loaded)
    Object.assign(package.loaded, loaded)

    if module then
        return module
    else
        error(err)
    end
end
