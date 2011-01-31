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
end

function test_open_close()
    local ar = assert(zip.open("test_open_close.zip", zip.CREATE))
    ar:close()

    local err = select(2, zip.open("test_open_close.zip"))
    ok(string.match(err, "No such file or directory"),
       tostring(err) .. " matches 'No such file or directory'")

    ar = assert(zip.open(test_zip))
    ar:close()

    ar = assert(zip.open("test_open_close.zip",
                         zip.OR(zip.CREATE,
                                zip.EXCL,
                                zip.CHECKCONS)))
    ar:close()
    ok(true, "test_open_close was successful")
end

main()
tap.exit()
