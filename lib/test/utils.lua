-- Copyright (c) 2018, Souche Inc.

local fs = require "fs"
local Array = require "utility.array"
local Function = require "utility.function"
local String = require "utility.string"

local Error = require "test.error"

local utils = {}

function utils.tree(root)
    if fs.isFile(root) then return Array({ root }) end
    local file_or_dirs, err = fs.readdir(root)
    if not file_or_dirs then return nil, err end
    if #file_or_dirs == 0 then return Array() end

    local files = Array()
    for i, file_or_dir in ipairs(file_or_dirs) do
        if String.endsWith(root, "/") then
            file_or_dir = root .. file_or_dir
        else
            file_or_dir = root .. "/" .. file_or_dir
        end
        local yes = fs.isDir(file_or_dir)

        if yes then 
            local _files, err = utils.tree(file_or_dir)
            if not _files then return nil, err end

            files = files:concat(_files)
        else
            files:push(file_or_dir)
        end
    end

    return files
end

function utils.combine(fns)
    fns = fns or Array()

    return function()
        fns:each(function(fn)
            fn()
        end)
    end
end

function utils.call(...)
    local args = Array({...})
    args:splice(1, 0, function(err)
        return Error("unknow", err)
    end)

    local ok, err = Function.apply(xpcall, args)
    if not ok then
        error(err)
    end
end

local cache = setmetatable({}, {
    __index = {
        get = function(self, accpet, expect)
            return (self[accpet] or {})[expect]
        end,
        set = function(self, accpet, expect, value, asymmetric)
            local map = self[accpet] or {}
            if not map then map = {} end

            map[expect] = value
            self[accpet] = map

            if not asymmetric then
                self:set(expect, accpet, value, true)
            end

            return value
        end,
        clear = function(self)
            table.clear(self)
            return self
        end
    }
})

function utils.deepEqual(accpet, expect, not_first)
    local type_a, type_e = type(accpet), type(expect)
    if type_a ~= type_e then return false end
    if type_a ~= "table" then return accpet == expect end

    if not not_first then cache:clear() end
    if accpet == expect then return cache:set(accpet, expect, true) end

    local equal = cache:get(accpet, expect)
    if equal ~= nil then return equal end

    cache:set(accpet, expect, false)
    if #accpet ~= #expect then return false end

    local keyMatched = {}
    for k, v in pairs(accpet) do
        if utils.deepEqual(v, expect[k], true) then
            keyMatched[k] = true
        else
            return false
        end
    end

    for k, v in pairs(expect) do
        if not keyMatched[k] then
            return false
        end
    end

    return cache:set(accpet, expect, true)
end

return utils
