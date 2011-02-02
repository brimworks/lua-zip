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
local is_deeply = tap.is_deeply

function main()
    test_open_close()
    test_file_count()
    test_name_locate()
    test_read_file()
    test_stat()
    test_get_name()
    test_get_archive_comment()
end

function test_get_archive_comment()
    local ar = assert(zip.open(test_zip))

    local comment = ar:get_archive_comment(zip.FL_UNCHANGED);

    ok(nil == comment, "No comment is set.  TODO: test w/ real comment")

    ar:close()
end

function test_get_name()
    local ar = assert(zip.open(test_zip))

    local name = ar:get_name(2, zip.FL_UNCHANGED);

    ok(name == "test/text.txt", tostring(name) .. " == 'test/text.txt'")

    ar:close()
end

function test_stat()
    local ar = assert(zip.open(test_zip))

    local expect = {
        name = "test/text.txt",
        index = 2,
        crc = 635884982,
        size = 14,
        mtime = 1296450278,
        comp_size = 14,
        comp_method = 0,
        encryption_method = 0,
    }

    local stat =
        assert(ar:stat("TEXT.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))

    is_deeply(stat, expect, "TEST.TXT stat")

    stat = assert(ar:stat(2))

    is_deeply(stat, expect, "index 2 stat")

    ar:close()
end

function test_read_file()
    local ar = assert(zip.open(test_zip))

    local file =
        assert(ar:open("TEXT.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))

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

    -- Closing the file after the archive was closed!
    file:close()
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
