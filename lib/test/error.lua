-- Copyright (c) 2018, Souche Inc.

local Error = { __type = "test.error" }

setmetatable(Error, {
    __call = function(self, _type, msg, accpet, expect, stack)
        if msg and type(msg) ~= "string" then
            if msg.__type == self.__type then
                _type = msg.type
                stack = msg.stack
                accpet = msg.accpet
                expect = msg.expect
                msg = msg.msg
            elseif _type == "unknow" then

            else
                msg = "Failed to execute t." .. _type .. ", msg should be a string"
                _type = nil
                accpet = nil
                expect = nil
            end
        end

        local err = {
            type = _type or "unknow",
            msg = msg,
            stack = stack or string.sub(debug.traceback("", 3), 2),
            accpet = accpet,
            expect = expect
        }

        setmetatable(err, { __index = Error })

        return err
    end
})

return Error
