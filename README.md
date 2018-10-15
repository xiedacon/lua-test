# lua-utility

[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/xiedacon/lua-test/blob/master/LICENSE)

## Requirements

* luaunit
* lua-utility
* lua-fs-module

## Usage

## API

### test:run(opts)

* ``opts.roots`` ``<string|table>`` 测试根目录

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