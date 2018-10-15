-- Copyright (c) 2018, Souche Inc.

local luaunit = require('luaunit')

local T = {
    __pass = false,
    i = 0,
    total = 0
}

setmetatable(T, {
    __call = function(self, test)
        local t = {
            __test = test
        }

        setmetatable(t, {
            __index = self
        })

        return t
    end
})

function T:plan(i)
    self.total = i
    self.i = i
end

function T:pass(msg)
    luaunit.success()
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:fail(msg)
    luaunit.fail(msg)
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:truthy(a, msg)
    luaunit.assertEvalToTrue(a, msg)
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:falsy(a, msg)
    luaunit.assertEvalToFalse(a, msg)
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:assertTrue(a, msg)
    luaunit.assertTrue(a, msg)
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:assertFalse(a, msg)
    luaunit.assertFalse(a, msg)
    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:assertIs(a, b, msg)
    if a ~= b then luaunit.fail(msg) end

    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:assertNot(a, b, msg)
    if a == b then luaunit.fail(msg) end

    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:deepEqual(a, b, msg)
    luaunit.assertEquals(a, b, msg)

    if self.i ~= 0 then self.i = self.i - 1 end
end

function T:notDeepEqual(a, b, msg)
    luaunit.assertNotEquals(a, b, msg)

    if self.i ~= 0 then self.i = self.i - 1 end
end

return T
