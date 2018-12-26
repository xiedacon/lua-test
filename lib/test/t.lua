-- Copyright (c) 2018, Souche Inc.

local Error = require "test.error"
local utils = require "test.utils"

local T = {
    i = 0,
    total = 0
}

setmetatable(T, {
    __call = function(self, test)
        local t = {
            __test = test
        }

        setmetatable(t, { __index = self })

        return t
    end
})

function T:plan(i)
    self.total = i
    self.i = i
end

function T:done()
    if self.i ~= 0 then
        error(Error(
            "plan",
            "planed: " .. tostring(self.total) .. " assert, expected: " .. tostring(self.total - self.i) .. " assert"
        ))
    end
end

function T:pass()
    if self.total ~= 0 then self.i = self.i - 1 end
end

function T:fail(msg)
    error(Error("fail", msg))
end

function T:truthy(a, msg)
    if a then
        self:pass()
    else
        error(Error("truthy", msg, a))
    end
end

function T:falsy(a, msg)
    if not a then 
        self:pass()
    else
        error(Error("falsy", msg, a))
    end
end

function T:assertTrue(a, msg)
    if a == true then
        self:pass()
    else
        error(Error("assertTrue", msg, a, true))
    end
end

function T:assertFalse(a, msg)
    if a == false then
        self:pass()
    else
        error(Error("assertFalse", msg, a, false))
    end
end

function T:assertIs(a, b, msg)
    if a == b then
        self:pass()
    else
        error(Error("assertIs", msg, a, b))
    end
end

function T:assertNot(a, b, msg)
    if a ~= b then
        self:pass()
    else
        error(Error("assertNot", msg, a, b))
    end
end

function T:deepEqual(a, b, msg)
    if utils.deepEqual(a, b) then
        self:pass()
    else
        error(Error("deepEqual", msg, a, b))
    end
end

function T:notDeepEqual(a, b, msg)
    if not utils.deepEqual(a, b) then
        self:pass()
    else
        error(Error("notDeepEqual", msg, a, b))
    end
end

return T
