**********************************************************************
* Author  : Brian Maher <maherb at brimworks dot com>
* Library : lua_zip - Lua 5.1 interface to libzip
*
* The MIT License
* 
* Copyright (c) 2009 Brian Maher
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
**********************************************************************

To use this library, you need libzip, get it here:
     http://www.nih.at/libzip/

To build this library, you need CMake, get it here:
    http://www.cmake.org/cmake/resources/software.html

Loading the library:

    If you built the library as a loadable package
        [local] zip = require 'brimworks.zip'

    If you compiled the package statically into your application, call
    the function "luaopen_brimworks_zip(L)". It will create a table
    with the zip functions and leave it on the stack.

Note:

    There is not a "streaming" interface supplied by this library.  If
    you want to work with zip files as streams, please see
    lua-archive.  However, libarchive is currently not compatible with
    "office open xml", and therefore the author was motivated to write
    this zip specific binding.

Why brimworks prefix?

    When this module was created, there was already a binding to
    zziplib named "zip" and since the author owns the brimworks.com
    domain he felt prefixing with brimworks would avoid in collisions
    in case people need to use the zziplib binding at the same time.

-- zip functions --

zip.CREATE
zip.EXCL
zip.CHECKCONS

    Numbers that represent open "flags", see zip.open().

zip.FL_NOCASE
zip.FL_NODIR

    Numbers that represent locate "flags", see zip_arc:name_locate().

zip.FL_COMPRESSED
zip.FL_UNCHANGED

    Numbers that represent fopen "flags", see zip_arc:open().

flags = zip.OR(flag1[, flag2[, flag3 ...]])

    Perform a bitwise or on all the flags.

local zip_arc = zip.open(filename [, flags])

    Open a zip archive optionally specifying a bitwise or of any of
    these flags:

        zip.CREATE
            Create the archive if it does not exist.

        zip.EXCL
            Error if archive already exists.

        zip.CHECKCONS
            Perform additional consistency checks on the archive, and
            error if they fail.

    If an error occurs, returns nil plus an error message.

local zip_arc = zip.open_memory()
local zip_arc = zip.open_memory("file", filename [, flags])
local zip_arc = zip.open_memory("string", str [, flags])
    Make zip in memory.
    Fill it up with a zip file or a string content (which must be a zip)
    Optionally specify a bitwise flags (see zip.open)

    zip_arc:close() will return zip content.
    ---
    local arc = zip.open_memory("file", "template.odt")
    local icon = arc:name_locate"content.xml"
    arc:replace(icon, "string", newcontent)
    local zdata = arc:close()
    send_over_network(zdata)
    ---

    If an error occurs, returns nil plus an error message.

zip_arc:close()

    If any files within were changed, those changes are written to
    disk first. If writing changes fails, zip_arc:close() fails and
    archive is left unchanged. If archive contains no files, the file
    is completely removed (no empty archive is written). 

    Unlike the other functions, this function will "throw" an error if
    there is any failure.  The reason to be different is that it is
    easy to forget to check if close is successful, and a failure to
    close is truely an exceptional event.

    NOTE: If a zip_arc object is garbage collected without having
    called close(), then the memory associated with that object will
    be free'ed, but changes made to the archive are not committed.

local last_file_idx = zip_arc:get_num_files()
local last_file_idx = #zip_arc

    Return the number of files in this zip archive, and since the
    index is one based, it also is the last file index.

local file_idx = zip_arc:name_locate(filename [, flags])

    Returns the 1 based index for this file.  The flags argument may
    be a bitwise or of these flags:

        zip.FL_NOCASE
            Ignore case distinctions.

        zip.FL_NODIR
            Ignore directory part of file name in archive.

    If it is not found, it returns nil plus an error message.

local file = zip_arc:open(filename | file_idx [, flags])

    Returns a new file handle for the specified filename or file
    index.  The flags argument may be a bitwise or of these flags:

        zip.FL_COMPRESSED
            Read the compressed data. Otherwise the data is
            uncompressed by file:read().

        zip.FL_UNCHANGED
            Read the original data from the zip archive, ignoring any
            changes made to the file.

        zip.FL_NOCASE
        zip.FL_NODIR
            See zip_arc:name_locate().

    Note that this file handle can only be used for reading purposes.

file:close()

    Close a file handle opened by zip_arc:open()

local str = file:read(num)

    Read at most num characters from the file handle.

local stat = zip_arc:stat(filename | file_idx [, flags])

    Obtain information about the specified filename or file index.
    The flags may be a bitwise or of these flags:

        zip.FL_UNCHANGED
            See zip_arc:open().

        zip.FL_NOCASE
        zip.FL_NODIR
            See zip_arc:name_locate().

    The returned stat table contains the following fields:

        stat.name              = name of the file
        stat.index             = index within archive
        stat.crc               = crc of file data
        stat.size              = size of file (uncompressed)
        stat.mtime             = modification time
        stat.comp_size         = size of file (compressed)
        stat.comp_method       = compression method used
        stat.encryption_method = encryption method used

    If an error occurs, this function returns nil and an error
    message.

local filename = zip_arc:get_name(file_idx [, flags])

    Returns the name of the file at the specified file index.  The
    only valid flag is:

        zip.FL_UNCHANGED
            See zip_arc:open().

local comment = zip_arc:get_archive_comment([flags])

    Return any comment contained in the archive.  The only valid flag
    is:

        zip.FL_UNCHANGED
            See zip_arc:open().

zip_arc:set_archive_comment(comment)

    Sets the comment of an archive.  May throw an error if the comment
    exceeds 65,535 bytes.

local comment = zip_arc:get_file_comment(file_idx [, flags])

    Return any comment about the specified file.  The only valid flag
    is:

        zip.FL_UNCHANGED
            See zip_arc:open().

zip_arc:set_file_comment(file_idx, comment)

    Set the comment for a specified file index within the archive.
    Throws an error if input is invalid.

zip_arc:add_dir(dirname)

    Creates a new directory within the archive.  May throw an error if
    an entry already exists in the archive with that name or input is
    invalid.

file_idx = zip_arc:add(filename, ...zip_source)

    Adds the specified filename to the archive from the specified
    "...zip_source" (see below).

    If an error occurs, throws an error.

file_idx = zip_arc:replace(file_idx, ...zip_source)

    Replaces the specified file index with a new "...zip_source"
    (see below).

    If an error occurs, throws an error.

zip_arc:rename(filename | file_idx, new_filename)

    Rename the specified file in the archive.  May throw an error if
    the entry being renamed does not exist.

zip_arc:delete(filename | file_idx)

    Delete the specified file from the archive.  May throw an error if
    the specified filename or file index does not exist.

..zip_source = "string", str

    The source to use will come from the specified string.

...zip_source = "zip", other_zip_arc, file_idx[, flags[, start[, len]]])

    The "...zip_source" is an archive and file index into that archive
    along with an optional flag, start file offset and length.  The
    flags are an optional bitwise or of:

        zip.FL_UNCHANGED
            See zip_arc:open().

        zip.FL_RECOMPRESS
            When adding the data from srcarchive, re-compress it using
            the current settings instead of copying the compressed
            data.

    Circular zip source references are not allowed.  For example, if
    you add a file from ar2 into ar1, then you can't add a file from
    ar1 to ar2.  Here is an example of this error:

        ar1:add("filename.txt", "zip", ar2, 1)
        ar2:add("filename.txt", "zip", ar1, 1) -- ERROR!


...zip_source = "file", filename[, start[, len]]

    Create a "zip_source" from a file on disk.  Opens filename and
    reads len bytes from offset start from it. If len is 0 or -1, the
    whole file (starting from start) is used.

######################################################################
TODO: The following functions are not implemented yet:
######################################################################

...zip_source = "object", obj

    The "...zip_source" is an object with any of these methods:

        success = obj:open()
            Prepare for reading. Return true on success, nil on
            error.

        str = obj:read(len)
            Read len bytes, returning it as a string.  Return nil on
            error.

        obj:close()
            Reading is done.

        stat = obj:stat()
            Get meta information for the input data.  See
            zip_arc:stat() for the table of fields that may be set.
            Usually, for uncompressed data, only the mtime and size
            fields will need to be set.

        libzip_err, system_err = obj:error()
            Get error information.  Must return two integers whic
            correspond to the libzip error code and system error code
            for any error (see above functions that may cause errors)

