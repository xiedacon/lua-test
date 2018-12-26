-- Copyright (c) 2018, Souche Inc.

local String = require "utility.string"
local Array = require "utility.array"

local Color = require "test.color"
local json = require "pretty.json"

local Output = {}

setmetatable(Output, {
    __call = function(self, stdout)
        stdout = stdout or io.stdout

        if type(stdout.write) ~= "function" then return false, "stdout.write should be a function" end

        return setmetatable({ stdout = stdout }, { __index = self })
    end
})

function Output:startRunner(runner)
    self.stdout:write("\n Start tests in " .. runner.root .. "\n\n")
end

function Output:startTest(test)
end

function Output:error(err, test)
    local stdout = self.stdout
    local space = "\n     "

    stdout:write(Color.red("✖"), "  ", test.key)
    stdout:write(space, err.msg and tostring(err.msg) or ("Failed to execute t." .. err.type))
    if err.expect then
        stdout:write(space, "expect: ", space, Array(String.split(json.stringify(err.expect, nil, 4, true), "\n")):join(space), "\n")
    end
    if err.accpet then
        stdout:write(space, "accpet: ", space, Array(String.split(json.stringify(err.accpet, nil, 4, true), "\n")):join(space), "\n")
    end
    if err.type ~= "plan" then
        stdout:write(space, Array(String.split(err.stack, "\n\t")):join(space .. "  "))
    end
    stdout:write("\n")
end

function Output:endTest(test)
    local stdout = self.stdout

    if test.pass then
        stdout:write(Color.green("✔"), "  ", test.key, "\n")
    else
        stdout:write("\n")
    end
end

function Output:endRunner(runner)
    local failed = #runner.failures
    local passed = #runner.tests - failed

    local line = Array({ Color.green(passed .. " passed") })
    if failed > 0 then line:push(Color.red(failed .. " failed")) end
    self.stdout:write("\n" .. line:join(", ") .. "\n")
end

return Output
