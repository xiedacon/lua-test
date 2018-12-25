-- Copyright (c) 2018, Souche Inc.

local luaunit = require "luaunit"
local Array = require "utility.array"
local String = require "utility.string"
local fs = require "fs"

local T = require "test.t"
local utils = require "test.utils"
local Output = require "test.output"

local Runner = {
    rewire = require "test.rewire",
    require = require "test.require"
}

local proto = {
    __index = Runner,
    __call = function (self, key, fn)
        if type(key) ~= "string" or key == "" then return false, "key should be a not empty string" end
        if type(fn) ~= "function" then return false, "fn should be a function" end
    
        self.__tests:push({
            key = String.replace(self.__test, self.__root, "") .. ": " .. key,
            befores = self.__befores,
            beforeEachs = self.__beforeEachs,
            fn = fn,
            afters = self.__afters,
            afterEachs = self.__afterEachs
        })
    
        return self
    end
}

setmetatable(Runner, {
    __call = function(self, root)
        if type(root) ~= "string" then return false, "root should be a string" end

        local runner = {
            __tests = Array(),
            __root = root,
            __befores = Array(),
            __beforeEachs = Array(),
            __afters = Array(),
            __afterEachs = Array()
        }

        local files, err = utils.tree(root)
        if not files then return nil, err end

        runner.__files = files:filter(function(file)
            return String.slice(file, -4) == ".lua"
        end)

        setmetatable(runner, proto)

        return runner
    end
})

Array({
    "before",
    "beforeEach",
    "after",
    "afterEach"
}):each(function(key)
    Runner[key] = function(self, fn)
        if type(fn) ~= "function" then return false, "fn sould be a function" end

        self["__" .. key .. "s"]:push(fn)
    end
end)

function Runner:__run()
    self.__files:each(function(file)
        self.__test = file

        local first_index = #self.__tests + 1
        loadfile(self.__test)()
        local last_index = #self.__tests
        
        if last_index >= first_index then
            self.__tests[first_index].first = true
            self.__tests[last_index].last = true
        end

        self.__befores = Array()
        self.__beforeEachs = Array()
        self.__afters = Array()
        self.__afterEachs = Array()
    end)

    self.__tests = self.__tests:map(function(test)
        return {
            test.key,
            function()
                if test.first then utils.combine(test.befores)()  end
                utils.combine(test.beforeEachs)()

                local t = T(test)
                test.fn(t)
                if t.i ~= 0 then luaunit.fail("planed: " .. tostring(t.total) .. " assert, expected: " .. tostring(t.total - t.i) .. " assert") end

                utils.combine(test.afterEachs)()
                if test.last then utils.combine(test.afters)()  end
            end
        }
    end)

    local runner = luaunit.LuaUnit.new()
    runner.outputType = Output
    runner:runSuiteByInstances(self.__tests)
end

return Runner
