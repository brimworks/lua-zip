package = "lua-zip"
version = "git-1"

description = {
    summary = "Lua binding to libzip",
    detailed = [[
To use this library, you need libzip, get it here:
     http://www.nih.at/libzip/

To build this library, you need CMake, get it here:
    http://www.cmake.org/cmake/resources/software.html
    ]],
    homepage = "https://github.com/brimworks/lua-zip",
    license = "MIT"
}

source = {
    url = "git://github.com/brimworks/lua-zip.git",
    dir = "lua-zip"
}

dependencies = {
    "lua >= 5.1"
}

external_dependencies = {
   ZIP = {
      header  = "zip.h",
      library = "zip",
   }
}
build = {
   type = "builtin",
   modules = {
      ["brimworks.zip"] = {
         sources   = { "lua_zip.c" },
         incdirs   = { "$(ZIP_INCDIR)" },
         libdirs   = { "$(ZIP_LIBDIR)" },
         libraries = { "zip" },
      }
   }
}

