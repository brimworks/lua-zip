package = "lua-zip"
version = "0.2-0"
source = {
   url = "git://github.com/brimworks/lua-zip.git",
   tag = "v0.2.0"
}
description = {
   summary = "Lua binding to libzip",
   detailed = [[
lua-zip is a binding to libzip, which you can get from:
    http://www.nih.at/libzip/
]],
   homepage = "https://github.com/brimworks/lua-zip",
   license = "MIT"
}
dependencies = {
   "lua"
}
external_dependencies = {
   ZIP = {
      header = "zip.h",
      library = "zip"
   }
}
build = {
   type = "builtin",
   modules = {
      ["brimworks.zip"] = {
         incdirs = {
            "$(ZIP_INCDIR)"
         },
         libdirs = {
            "$(ZIP_LIBDIR)"
         },
         libraries = {
            "zip"
         },
         sources = {
            "lua_zip.c"
         }
      }
   }
}
