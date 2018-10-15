-- Copyright (c) 2018, Souche Inc.

local Color = {}

setmetatable(Color, {
    __call = function (self, code)
        return function(str)
            return "\x1b[38;5;" .. tostring(code) .. "m" .. str .. "\x1b[0m"
        end
    end
})

for k, v in pairs({
    black = 0,
    red = 1,
    green = 2,
    yellow = 3,
    blue = 4,
    magenta = 5,
    cyan = 6,
    white = 7
}) do
    Color[k] = Color(v)
end

return Color
