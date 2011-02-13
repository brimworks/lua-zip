# Copyright (C) 2007-2009 LuaDist.
# Submitted by David Manura
# Redistribution and use of this file is allowed according to the
# terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own
# license.

PROJECT(lua-zip C)
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# Basic configurations
  SET(INSTALL_CMOD share/lua/cmod CACHE PATH "Directory to install Lua binary modules (configure lua via LUA_CPATH)")
# / configs

# Find libzip
  FIND_LIBRARY (LIBZIP_LIBRARY NAMES zip)
  FIND_PATH (LIBZIP_INCLUDE_DIR zip.h
    PATH_SUFFIXES include/zip include
    ) # Find header
  INCLUDE(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(libzip  DEFAULT_MSG  LIBZIP_LIBRARY LIBZIP_INCLUDE_DIR)
# / Find libzip

# Find lua
  FIND_PACKAGE(Lua51 REQUIRED)
# / Find lua

# Define how to build zip.so:
  INCLUDE_DIRECTORIES(${LIBZIP_INCLUDE_DIR} ${LUA_INCLUDE_DIR})
  ADD_LIBRARY(cmod_zip MODULE lua_zip.c lua_zip.def)
  SET_TARGET_PROPERTIES(cmod_zip PROPERTIES PREFIX "")
  SET_TARGET_PROPERTIES(cmod_zip PROPERTIES LIBRARY_OUTPUT_DIRECTORY brimworks)
  SET_TARGET_PROPERTIES(cmod_zip PROPERTIES OUTPUT_NAME zip)
  TARGET_LINK_LIBRARIES(cmod_zip ${LUA_LIBRARIES} ${LIBZIP_LIBRARY})  
# / build zip.so

# Define how to test zip.so:
  INCLUDE(CTest)
  FIND_PROGRAM(LUA NAMES lua lua.bat)
  ADD_TEST(basic ${LUA} ${CMAKE_CURRENT_SOURCE_DIR}/test.lua ${CMAKE_CURRENT_BINARY_DIR})
# / test zip.so

# Where to install stuff
  INSTALL (TARGETS cmod_zip DESTINATION ${INSTALL_CMOD}/brimworks)
# / Where to install.
