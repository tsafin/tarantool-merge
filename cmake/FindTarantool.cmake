# Define GNU standard installation directories
include(GNUInstallDirs)

macro(extract_definition name output input)
    string(REGEX MATCH "#define[\t ]+${name}[\t ]+\"([^\"]*)\""
        _t "${input}")
    string(REGEX REPLACE "#define[\t ]+${name}[\t ]+\"(.*)\"" "\\1"
        ${output} "${_t}")
endmacro()

find_path(TARANTOOL_INCLUDE_DIR src/module.h tarantool/module.h
  HINTS ${TARANTOOL_BUILD_INCDIR} TARANTOOL_INCLUDE_DIRS ENV
  PATH_SUFFIXES include
)

if(TARANTOOL_INCLUDE_DIR)
    set(_config "-")
    file(READ "${TARANTOOL_INCLUDE_DIR}/src/module.h" _config0)
    string(REPLACE "\\" "\\\\" _config ${_config0})
    unset(_config0)
    extract_definition(PACKAGE_VERSION TARANTOOL_VERSION ${_config})
    extract_definition(INSTALL_PREFIX _install_prefix ${_config})
    unset(_config)
endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TARANTOOL
    REQUIRED_VARS TARANTOOL_INCLUDE_DIR VERSION_VAR TARANTOOL_VERSION)
if(TARANTOOL_FOUND)
    set(TARANTOOL_INCLUDE_DIRS 
            ${TARANTOOL_INCLUDE_DIR}
            ${TARANTOOL_INCLUDE_DIR}/src/
            ${TARANTOOL_INCLUDE_DIR}/../
            ${TARANTOOL_INCLUDE_DIR}/../src/
            ${TARANTOOL_INCLUDE_DIR}/../src/box/
            ${TARANTOOL_INCLUDE_DIR}/../src/lib/core/
            ${TARANTOOL_INCLUDE_DIR}/../src/lib/
            ${TARANTOOL_INCLUDE_DIR}/../src/lib/small/
            ${TARANTOOL_INCLUDE_DIR}/../src/lib/small/third_party/
            ${TARANTOOL_INCLUDE_DIR}/../src/lib/msgpuck/
            ${TARANTOOL_INCLUDE_DIR}/../third_party/
            ${TARANTOOL_INCLUDE_DIR}/../third_party/luajit/src

        CACHE PATH "Include directories for Tarantool")

    set (LUAJIT_BUNDLED_PREFIX  ${TARANTOOL_INCLUDE_DIR}/third_party/luajit/src)
    set (LUAJIT_LIBRARIES       ${LUAJIT_BUNDLED_PREFIX}/libluajit.a)

    set(TARANTOOL_INSTALL_LIBDIR 
            ${CMAKE_INSTALL_LIBDIR}/tarantool
        CACHE PATH "Directory for storing Lua modules written in Lua")
    set(TARANTOOL_INSTALL_LUADIR 
            ${CMAKE_INSTALL_DATADIR}/tarantool
        CACHE PATH "Directory for storing Lua modules written in C")

    if (NOT TARANTOOL_FIND_QUIETLY AND NOT FIND_TARANTOOL_DETAILS)
        set(FIND_TARANTOOL_DETAILS ON CACHE INTERNAL "Details about TARANTOOL")
        message(STATUS "Tarantool LUADIR is ${TARANTOOL_INSTALL_LUADIR}")
        message(STATUS "Tarantool LIBDIR is ${TARANTOOL_INSTALL_LIBDIR}")
    endif ()
endif()
mark_as_advanced(
    TARANTOOL_INCLUDE_DIRS
    TARANTOOL_INSTALL_LIBDIR
    TARANTOOL_INSTALL_LUADIR
)
