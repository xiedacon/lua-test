-- Copyright (c) 2018, Souche Inc.

local luaunit = require "luaunit"

local Color = require "test.color"

local String = require "utility.string"
local Array = require "utility.array"

local genericOutput = luaunit.genericOutput
local stdout = io.stdout

local function replace_stack(node)
    local msg = node.msg
    local stackTrace = node.stackTrace

    if String.endsWith(String.split(String.split(msg, ": ")[1], ":")[1], "/t.lua") then
        local lines = Array(String.split(stackTrace, "\n"))
        local line = lines:splice(1, 2)[2]
        line = String.split(line, ": ")[1]
        lines:splice(1, 0, line)

        local fragments = Array(String.split(msg, ": "))
        fragments[1] = String.trim(line)

        node.msg = table.concat(fragments, ": ")
        node.stackTrace = table.concat(lines, "\n")
    end
end

local Output = genericOutput.new()

function Output.new(runner)
    return setmetatable(genericOutput.new(runner), { __index = Output })
end

function Output:startSuite()
    stdout:write("\n")
end

function Output:startTest(testName) end

function Output:addStatus( node )
    replace_stack(node)
end

function Output:endTest( node )
    if node:isPassed() then
        stdout:write(Color.green("✔") .. "  ", node.testName , "\n")
    else
        stdout:write(Color.red("✖") .. "  ", node.testName, "\n")
        stdout:write("     " .. node.msg .. "\n")
        stdout:write("     " .. Array(String.split(node.stackTrace, "\n\t")):join("\n       ") .. "\n")
    end
end

function Output:endSuite()
    local result = self.result
    local failed = #result.failures
    local error = #result.errors
    local passed = #result.tests - failed - error

    local line = Array({ Color.green(passed .. " passed") })

    if failed > 0 then line:push(Color.red(failed .. " failed")) end
    if error > 0 then line:push(Color.red(error .. "error")) end

    stdout:write("\n" .. line:join(", ") .. "\n")
end

return Output
