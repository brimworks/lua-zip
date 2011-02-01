#!/usr/bin/env lua

local build_dir = ...
if ( build_dir ) then
    package.cpath = build_dir .. "?.so;" .. package.cpath
end

local _0 = string.sub(debug.getinfo(1,'S').source, 2)
package.path = string.gsub(_0, "(.*/)(.*)", "%1?.lua;") .. package.path

local test_zip = string.gsub(_0, "(.*/)(.*)", "%1test.zip")

local tap = require("tap")
local zip = require("zip")
local ok  = tap.ok


function main()
    test_open_close()
    test_file_count()
    test_name_locate()
    test_read_file()
end

function test_read_file()
    local ar = assert(zip.open(test_zip))

    local file = assert(ar:open("test/text.txt"))
    local str = file:read(256)
    ok(str == "one\ntwo\nthree\n",
       "[" .. tostring(str) .. "] == [one\ntwo\nthree\n]")

    file:close()

    -- The data at index 2 is not compressed:
    file = assert(ar:open(2, zip.FL_COMPRESSED))
    str = file:read(256)
    ok(str == "one\ntwo\nthree\n",
       "[" .. tostring(str) .. "] == [one\ntwo\nthree\n]")

    ar:close()
end

function test_name_locate()
    local ar = assert(zip.open(test_zip))

    ok(2 == ar:name_locate("test/text.txt"),
       tostring(ar:name_locate("test/text.txt")) .. " == 2");

    local err = select(2, ar:name_locate("DNE"))
    ok(string.match(err, "No such file"),
       tostring(err) .. " matches 'No such file'")

    local idx = ar:name_locate("teST/teXT.txt", zip.FL_NOCASE)
    ok(2 == idx, tostring(idx) .. " == 2")

    idx = ar:name_locate("teXT.txt", zip.OR(zip.FL_NOCASE, zip.FL_NODIR))
    ok(2 == idx, tostring(idx) .. " == 2")

    ar:close()
end

function test_file_count()
    local ar = assert(zip.open(test_zip))
    ok(2 == #ar, tostring(#ar) .. " == 2")
    ok(2 == ar:get_num_files(), tostring(ar:get_num_files()) .. " == 2")
    ar:close()
end

function test_open_close()
    local ar = assert(zip.open("test_open_close.zip", zip.CREATE))
    ar:close()

    local err = select(2, zip.open("test_open_close.zip"))
    ok(string.match(err, "No such file or directory"),
       tostring(err) .. " matches 'No such file or directory'")

    ar = assert(zip.open(test_zip))
    ar:close()

    do
        local ar = assert(zip.open("test_open_close.zip",
                                   zip.OR(zip.CREATE,
                                          zip.EXCL,
                                          zip.CHECKCONS)))
        -- Purposfully do not close it so gc will close it.
        --ar:close()
    end

    collectgarbage"collect"

    ok(true, "test_open_close was successful")
    
end

main()
tap.exit()
