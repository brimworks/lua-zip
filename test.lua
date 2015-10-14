#!/usr/bin/env lua

-- Global symbols:
local _0 = string.sub(debug.getinfo(1,'S').source, 2)
local tap
local zip
local ok
local is_deeply
local test_zip_file
local tmp_dir

function load_libs(build_dir)
    -- Set-up cpath and path properly:
    build_dir = build_dir:gsub("(.*)/*", "%1")
    local f=io.open(build_dir .. "/brimworks/zip.so", "r")
    if ( f ) then
        f:close()
        package.cpath = build_dir .. "/?.so;" .. package.cpath
    end

    package.path = _0:gsub("(.*/)(.*)", "%1?.lua;") .. package.path

    -- Load libraries:
    tap = require("tap")
    zip = require("brimworks.zip")
    ok  = tap.ok
    is_deeply = tap.is_deeply

    -- Export some globals:
    test_zip_file = string.gsub(_0, "(.*/)(.*)", "%1test.zip")
    tmp_dir = build_dir .. "/test-tmp/"
    os.execute("mkdir -p " .. tmp_dir)
end

load_libs(...)



function main()
    test_zip_source_circular()
    test_open_close()
    test_file_count()
    test_name_locate()
    test_read_file()
    test_stat()
    test_get_name()
    test_get_archive_comment()
    test_set_archive_comment()
    test_get_file_comment()
    test_set_file_comment()
    test_add_dir()
    test_add()
    test_replace()
    test_rename()
    test_delete()
    test_zip_source()
    test_file_source()
end

function test_file_source()
    local test_file_source = tmp_dir .. "test_file_source.zip"

    os.remove(test_file_source)

    local ar = assert(zip.open(test_file_source, 
                                zip.OR(zip.CREATE, zip.EXCL)));

    ar:add("dir/add.txt", "file", _0, 2, 12)
    ar:close()

    local ar = assert(zip.open(test_file_source, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    local file =
        assert(ar:open("add.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))
    local str = assert(file:read(256))
    ok(str == "/usr/bin/env", str .. " == '/usr/bin/env'")

    file:close()
    ar:close()
end

function test_zip_source_circular()
    -- What appens if two archives try to reference each other?  Let's
    -- just make sure it doesn't crash.
    local test_zip_source1 = tmp_dir .. "test_zip_source1_gc.zip"
    local test_zip_source2 = tmp_dir .. "test_zip_source2_gc.zip"

    os.remove(test_zip_source1)
    os.remove(test_zip_source2)

    local ar1 = assert(zip.open(test_zip_source1, 
                                zip.OR(zip.CREATE, zip.EXCL)));
    local ar2 = assert(zip.open(test_zip_source2, 
                                zip.OR(zip.CREATE, zip.EXCL)));

    assert(ar1:add("file.txt", "string", "AR1"))
    assert(ar2:add("file.txt", "string", "AR2"))
    ar1:close()
    ar2:close()

    local ar1 = assert(zip.open(test_zip_source1))
    local ar2 = assert(zip.open(test_zip_source2))

    assert(ar1:add("other.txt", "zip", ar2, 1))
    local isok, err = pcall(ar2.add, ar2, "other.txt", "zip", ar1, 1)
    ok(not isok, "Circular reference is error: " .. err)
end

function test_zip_source()
    local test_zip_source = tmp_dir .. "test_zip_source.zip"

    os.remove(test_zip_source)

    local ar_ro = assert(zip.open(test_zip_file))

    local ar = assert(zip.open(test_zip_source, 
                                zip.OR(zip.CREATE, zip.EXCL)));

    ar:add("dir/add.txt", "zip", ar_ro, 2,
           zip.OR(zip.FL_UNCHANGED,
                  zip.FL_RECOMPRESS),
           4, 3)

    ar:close()

    ar_ro:close()

    local ar = assert(zip.open(test_zip_source, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    local file =
        assert(ar:open("add.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))
    local str = assert(file:read(256))
    ok(str == "two", str .. " == 'two'")

    file:close()
    ar:close()
end

function test_replace()
    -- Make sure we start with a clean slate:
    local test_replace_file = tmp_dir .. "test_replace.zip"
    os.remove(test_replace_file)
    local ar = assert(zip.open(test_replace_file,
                                zip.OR(zip.CREATE, zip.EXCL)));

    local idx = ar:add("dir/test.txt", "string", "Contents")
    ar:replace(idx, "string", "Replacement")

    ar:close()

    local ar = assert(zip.open(test_replace_file, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    local file =
        assert(ar:open("test.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))
    local str = assert(file:read(256))
    ok(str == "Replacement", tostring(str) .. " == 'Replacement'")

    file:close()
    ar:close()
end

function test_rename()
    -- Make sure we start with a clean slate:
    local test_rename_file = tmp_dir .. "test_rename.zip"
    os.remove(test_rename_file)
    local ar = assert(zip.open(test_rename_file,
                                zip.OR(zip.CREATE, zip.EXCL)));

    local idx = ar:add("dir/test.txt", "string", "Contents")
    local err = select(2, pcall(ar.rename, ar, "DNE", "new.txt"))
    ok(string.match(err, "No such file"), "Rename non-existant file error="..tostring(err))

    ar:rename(idx, "temp.txt")
    ar:rename("temp.txt", "new.txt")
    ar:close()

    local ar = assert(zip.open(test_rename_file, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    local file =
        assert(ar:open("new.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))
    local str = assert(file:read(256))
    ok(str == "Contents", tostring(str) .. " == 'Contents'")

    file:close()
    ar:close()
end

function test_delete()
    -- Make sure we start with a clean slate:
    local test_delete_file = tmp_dir .. "test_delete.zip"
    os.remove(test_delete_file)
    local ar = assert(zip.open(test_delete_file,
                                zip.OR(zip.CREATE, zip.EXCL)));

    ar:add_dir(".ignore")
    local idx = ar:add("dir/test.txt", "string", "Contents")
    local err = select(2, pcall(ar.delete, ar, "DNE"))
    ok(string.match(err, "No such file"), "Delete non-existant file error="..tostring(err))

    -- Delete using the index:
    ar:delete(idx)

    -- Delete using the filename:
    idx = ar:add("dir/test2.txt", "string", "Content2")
    ar:delete("dir/test2.txt")
    ar:close()

    local ar = assert(zip.open(test_delete_file, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    -- TODO: How do you determine if this is a directory?
    local sb = ar:stat(".ignore")

    ar:close()
end

function test_add()
    -- Make sure we start with a clean slate:
    local test_add_file = tmp_dir .. "test_add.zip"

    os.remove(test_add_file)
    local ar = assert(zip.open(test_add_file,
                                zip.OR(zip.CREATE, zip.EXCL)));

    ar:add("dir/add.txt", "string", "Contents")

    ar:close()

    local ar = assert(zip.open(test_add_file, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    local file =
        assert(ar:open("add.TXT",
                       zip.OR(zip.FL_NOCASE, zip.FL_NODIR)))
    local str = assert(file:read(256))
    ok(str == "Contents", str .. " == 'Contents'")

    file:close()
    ar:close()
end

function test_add_dir()
    -- Make sure we start with a clean slate:
    local test_add_dir = tmp_dir .. "test_add_dir.zip"

    os.remove(test_add_dir)
    local ar = assert(zip.open(test_add_dir,
                                zip.OR(zip.CREATE, zip.EXCL)));

    ok(1 == ar:add_dir("arbitary/directory/name"), "add_dir returns 1")

    ar:close()

    local ar = assert(zip.open(test_add_dir, zip.CHECKCONS))
    ok(1 == #ar, "Archive contains one entry: " .. #ar)

    -- "/" is always appended to the directory name
    ok(1 == ar:name_locate("arbitary/directory/name/"), "dir exists")
    ok(nil == ar:name_locate("arbitary/directory/name/",
                                  zip.FL_NODIR),
       "name_locate returns nil if FL_NODIR flag is passed")

    ar:close()
end

function test_set_file_comment()
    os.remove("test_set_file_comment.zip")
    local ar = assert(zip.open("test_set_file_comment.zip",
                                zip.OR(zip.CREATE, zip.EXCL)));

    local err = select(2, pcall(ar.set_file_comment, ar, 1,
                                "test\0fun"))

    -- TODO: Add better testing once we can 'add' archive entries.
    ok(err == "Invalid argument", tostring(err) .. " == 'Invalid argument'")

    ar:close()
end

function test_get_file_comment()
    local ar = assert(zip.open(test_zip_file))

    local comment = ar:get_file_comment(2, zip.FL_UNCHANGED)

    ok("" == comment, "No comment set. TODO: test w/ real comment")

    ar:close()
end

function test_set_archive_comment()
    os.remove("test_set_archive_comment.zip")
    local ar = assert(zip.open("test_set_archive_comment.zip",
                                zip.OR(zip.CREATE, zip.EXCL)));

    ar:set_archive_comment("test fun")

    ok("" == ar:get_archive_comment(zip.FL_UNCHANGED),
       "zip.FL_UNCHANGED works")

    ok("test fun" == ar:get_archive_comment(),
       tostring(ar:get_archive_comment()) .. " == 'test fun'")

    -- BUG in libzip? Version 1.0.1 of libzip gives an error if you
    -- don't add anything to the zip file.
    ar:add_dir("something")
    ar:close()
end

function test_get_archive_comment()
    local ar = assert(zip.open(test_zip_file))

    local comment = ar:get_archive_comment(zip.FL_UNCHANGED);

    ok("" == comment, "No comment is set.  TODO: test w/ real comment")

    ar:close()
end

function test_get_name()
    local ar = assert(zip.open(test_zip_file))

    local name = ar:get_name(2, zip.FL_UNCHANGED);

    ok(name == "test/text.txt", tostring(name) .. " == 'test/text.txt'")

    ar:close()
end

function test_stat()
    local ar = assert(zip.open(test_zip_file))

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
    local ar = assert(zip.open(test_zip_file))

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
    local ar = assert(zip.open(test_zip_file))

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
    local ar = assert(zip.open(test_zip_file))
    ok(2 == #ar, tostring(#ar) .. " == 2")
    ok(2 == ar:get_num_files(), tostring(ar:get_num_files()) .. " == 2")
    ar:close()
end

function test_open_close()
    os.remove("test_open_close.zip")
    local ar = assert(zip.open("test_open_close.zip", zip.CREATE))
    ar:close()

    local err = select(2, zip.open("test_open_close.zip"))
    ok(string.match(err, "No such file"),
       tostring(err) .. " matches 'No such file'")

    ar = assert(zip.open(test_zip_file))
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
