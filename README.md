# lua-test

[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/xiedacon/lua-test/blob/master/LICENSE)

## Requirements

* lua-utility
* lua-fs-module
* lua-pretty-json

## Usage

```lua
-- test.lua

local test = require "test"

local ok, err = test:run({
    roots = "/path/to/test/suits/"
})
```

```lua
-- /path/to/test/suits/index.lua

local test = require "test"

test("Test suit 1", function(t)
    t:pass()
end)

test("Test suit 2", function(t)
    t:assertIs("a", "a")
end)

test("Test suit 3", function(t)
    t:deepEqual({
        a = {
            a = {
                a = "a"
            }
        }
    }, {
        a = {
            a = {
                a = "a"
            }
        }
    })
end)

test("Test suit 4", function(t)
    t:deepEqual({
        a = {
            a = {
               a = "a"
            }
        }
    }, {
        a = {
            a = {
                a = "b"
            }
        }
    })
end)
```

```sh
$ export LUA_PATH="/path/to/lualib/?.lua;"
$ export LUA_CPATH="/path/to/lualib/?.so;"
$ /path/to/lua test.lua

 Start tests in /path/to/test/suits/

✔  index.lua: Test suit 1
✔  index.lua: Test suit 2
✔  index.lua: Test suit 3
✖  index.lua: Test suit 4
     Failed to execute t.deepEqual
     expect:
     {
         "a": {
             "a": {
                 "a": "b"
             }
         }
     }

     accpet:
     {
         "a": {
             "a": {
                 "a": "a"
             }
         }
     }

     stack traceback:
       ...

3 passed, 1 failed
```

## API

### test:run(opts)

* ``opts.roots`` ``<string|array>`` 测试根目录
* ``opts.package_path`` ``<string>`` test.require 和 test.rewire 模块内部的 package.path，默认为当前的 package.path
* ``opts.package_cpath`` ``<string>`` test.require 和 test.rewire 模块内部的 package.cpath，默认为当前的 package.cpath
* ``opts.package_loaded`` ``<array>`` test.require 和 test.rewire 模块内部的 package.loaded，默认为 {}
* ``opts.extension`` ``<string>`` 测试文件扩展名，如 .test.lua
* ``opts.output`` ``<table>`` 测试结果输出处理
* ``opts.stdout`` ``<table>`` 测试结果输出 stdout，默认 io.stdout

### Runner

#### test(key, fn)

* ``key`` ``<string>`` 测试用例标识
* ``fn`` ``<function>`` 测试函数

#### test.before(fn)

* ``fn`` ``<function>`` 测试函数

#### test.beforeEach(fn)

* ``fn`` ``<function>`` 测试函数

#### test.after(fn)

* ``fn`` ``<function>`` 测试函数

#### test.afterEach(fn)

* ``fn`` ``<function>`` 测试函数

#### test.require(module, loaded)

* ``module`` ``<string>`` 加载的模块名称
* ``loaded`` ``<table>`` 在 module 上下文中，已加载的模块

```lua
-- index.lua
local unknow_module = require "unknow.module"

return {
    say = function()
        return unknow_module
    end
}
```

```lua
-- index.test.lua
local test = require "test"

local loaded = {}
loaded["unknow.module"] = "aaa"

local index = test.require("index", loaded)

test("It should hack unknow.module", function(t)
    t:assertIs(index.say(), "aaa")
end)
```

#### test.rewire(module, loaded)

* ``module`` ``<string>`` 加载的模块名称
* ``loaded`` ``<table>`` 在 module 上下文中，已加载的模块

```lua
-- index.lua
local inner_prop = "inner_prop"

return {
    say = function()
        return inner_prop
    end
}
```

```lua
-- index.test.lua
local test = require "test"
local index = test.rewire("index")

test("It should get inner prop", function(t)
    t:assertIs(index:__get__("inner_prop"), "inner_prop")
end)

test("It should set inner porp", function(t)
    index:__set__("inner_prop", "inner_prop")
    t:assertIs(index.say(), "aaa")
end)
```

### T

#### t:plan(n)

* ``n`` ``<number>`` 测试执行次数

#### t:pass()
#### t:fail([msg])

* ``msg`` ``<string>`` 失败信息

#### t:truthy(a, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:falsy(a, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:assertTrue(a, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:assertFalse(a, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:assertIs(a, b, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:assertNot(a, b, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:deepEqual(a, b, [msg])

* ``msg`` ``<string>`` 失败信息

#### t:notDeepEqual(a, b, [msg])

* ``msg`` ``<string>`` 失败信息

## License

[MIT License](https://github.com/xiedacon/lua-test/blob/master/LICENSE)

Copyright (c) 2018 xiedacon
