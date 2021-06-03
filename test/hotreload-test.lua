#!/usr/bin/env tarantool

local tap = require('tap')
local ffi = require('ffi')
local key_def_lib = require('tuple.keydef')

-- Some `tuple.merger` methods are created in Lua API and
-- some methods are installed in postload.lua script.
-- Check that all of them are presence.
--
-- Here we don't verify how the methods work.
local function test_module_methods_presence(test, tuple_merger)
    local methods = {
        'new_buffer_source',
        'new_table_source',
        'new',
        'new_source_fromtable',
        'new_source_frombuffer',
        'new_tuple_source',
    }
    test:plan(#methods)

    for _, m in ipairs(methods) do
        test:ok(tuple_merger[m] ~= nil, ('%s is present'):format(m))
    end
end

-- Presence of the methods confirms that correct metatype is set
-- for the <struct tuple_merge_source> ctype.
--
-- Here we don't verify how the methods work.
local function test_instance_methods_presence(test, tuple_merger_instance)
    local methods = {
        'select',
        'pairs',
    }
    test:plan(#methods)

    for _, m in ipairs(methods) do
        test:ok(tuple_merger_instance[m] ~= nil, ('%s is present'):format(m))
    end
end

-- gh-21: verify hot reload.
--
-- https://github.com/tarantool/tuple-merger/issues/21
local test = tap.test('hot reload')

test:plan(3)

-- Verify the case, when <struct tuple_merge_source> is declared via
-- LuaJIT's FFI before a first load of the module.
--
-- This case looks strange on the first glance, but someone may
-- declare <struct tuple_merge_source> to use ffi.istype(). So it may
-- be the valid usage.
--
-- Important: keep this test case first, don't require the module
-- before it (otherwise it'll not test anything).
test:test('declared_ctype', function(test)
    test:plan(6)

    -- Declare the ctype before first loading of the module.
    ffi.cdef('struct tuple_merge_source')

    -- Verify the first load.
    local ok, tuple_merger = pcall(require, 'tuple.merger')
    test:ok(ok, 'first load succeeds')
    test:test('module methods presence', test_module_methods_presence, tuple_merger)

    local key_def = key_def_lib.new({{field = 1, type = 'string'}})
    local tuple_merger_instance = tuple_merger.new(key_def, {})
    test:test('instance methods presence', test_instance_methods_presence, tuple_merger_instance)

    -- Verify reload just in case.
    package.loaded['tuple.merger'] = nil
    local ok, tuple_merger = pcall(require, 'tuple.merger')
    test:ok(ok, 'reload succeeds')
    test:test('module methods presence', test_module_methods_presence, tuple_merger)

    local tuple_merger_instance = tuple_merger.new(key_def, {})
    test:test('instance methods presence', test_instance_methods_presence, tuple_merger_instance)
end)

-- Verify the case, when there are alive links to the previous
-- module table.
test:test('hot_reload_keep_old_table', function(test)
    test:plan(3)

    -- Reload.
    local tuple_merger_old = require('tuple.merger')
    package.loaded['tuple.merger'] = nil
    local ok, tuple_merger_new = pcall(require, 'tuple.merger')

    -- Verify.
    --
    -- It does not matter, whether the module table is the same or
    -- a new one.
    test:ok(ok, 'reload succeeds')
    test:istable(tuple_merger_new, 'the module is a table (just in case)')

    -- Fake usage of tuple_merger_old. Just to hide it from
    -- LuaJIT's optimizer. I don't know whether it may eliminate
    -- the variable in this particular case (without the fake
    -- usage). But in some cases the optimizer is powerful enough:
    --
    -- https://gist.github.com/mejedi/d61752c5fd582d2507360d375513c6b8
    test:istable(tuple_merger_old, 'fake usage of the old module table')
end)

-- Collect the old module table before load the module again.
test:test('hot_reload_after_gc', function(test)
    test:plan(2)

    require('tuple.merger')

    package.loaded['tuple.merger'] = nil

    -- Ensure the module table is garbage collected.
    --
    -- There is opinion that collectgarbage() should be called
    -- twice to actually collect everything.
    --
    -- https://stackoverflow.com/a/28320364/1598057
    collectgarbage()
    collectgarbage()

    local ok, tuple_merger = pcall(require, 'tuple.merger')
    test:ok(ok, 'reload succeeds')
    test:istable(tuple_merger, 'the module is a table (just in case)')
end)

os.exit(test:check() and 0 or 1)
