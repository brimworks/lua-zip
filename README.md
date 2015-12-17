
This is a fork from github.com/MisterDA/lua-zip which is a fork from brimworks/lua-zip which only supports Lua 5.3.x

# Requirements

E.g. for Archlinux

  * lua
  * libzip
  * cmake
  
# Installation

  * `cmake .`
  * `make`
  * `lua test.lua brimworks/`
  
  
# Status

Two tests are currently failing. Dunno why...

		$ lua test.lua brimworks/
		ok 1 - Circular reference is error: Circular reference of zip sources is not allowed
		ok 2 - No such file matches 'No such file'
		ok 3 - test_open_close was successful
		ok 4 - 2 == 2
		ok 5 - 2 == 2
		ok 6 - 2 == 2
		ok 7 - No such file matches 'No such file'
		ok 8 - 2 == 2
		ok 9 - 2 == 2
		ok 10 - [one
		two
		three
		] == [one
		two
		three
		]
		ok 11 - [one
		two
		three
		] == [one
		two
		three
		]
		# Expected [mtime] to be '1296450278', but got '1296417878.0'
		not ok 12 - TEST.TXT stat
		# Expected [mtime] to be '1296450278', but got '1296417878.0'
		not ok 13 - index 2 stat
		ok 14 - test/text.txt == 'test/text.txt'
		ok 15 - No comment is set.  TODO: test w/ real comment
		ok 16 - zip.FL_UNCHANGED works
		ok 17 - test fun == 'test fun'
		ok 18 - No comment set. TODO: test w/ real comment
		ok 19 - Invalid argument == 'Invalid argument'
		ok 20 - add_dir returns 1
		ok 21 - Archive contains one entry: 1
		ok 22 - dir exists
		ok 23 - name_locate returns nil if FL_NODIR flag is passed
		ok 24 - Archive contains one entry: 1
		ok 25 - Contents == 'Contents'
		ok 26 - Archive contains one entry: 1
		ok 27 - Replacement == 'Replacement'
		ok 28 - Rename non-existant file error=No such file 'DNE'
		ok 29 - Archive contains one entry: 1
		ok 30 - Contents == 'Contents'
		ok 31 - Delete non-existant file error=No such file 'DNE'
		ok 32 - Archive contains one entry: 1
		ok 33 - Archive contains one entry: 1
		ok 34 - two == 'two'
		ok 35 - Archive contains one entry: 1
		ok 36 - /usr/bin/env == '/usr/bin/env'
