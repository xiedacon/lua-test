-- Copyright (c) 2018, Souche Inc.

local fs = require "fs"
local Array = require "utility.array"

local utils = {}

function utils.tree(root)
    if fs.isFile(root) then return Array({ root }) end
    local file_or_dirs, err = fs.readdir(root)
    if not file_or_dirs then return nil, err end
    if #file_or_dirs == 0 then return Array() end

    local files = Array()
    for i, file_or_dir in ipairs(file_or_dirs) do
        file_or_dir = root .. "/" .. file_or_dir
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

return utils
