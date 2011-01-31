#!/usr/bin/env lua

local src_dir, build_dir = ...
package.path  = src_dir .. "?.lua;" .. package.path
package.cpath = build_dir .. "?.so;" .. package.cpath

local tap = require("tap")
local zip = require("zip")
local ok  = tap.ok
local _0 = string.sub(debug.getinfo(1,'S').source, 2)

function main()
    test_open_close()
end

function test_open_close()
    local ar = zip.open("test_open_close.zip", zip.CREATE)
    ar:close()
end

main()
tap.exit()
