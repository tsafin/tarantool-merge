cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(merger C CXX)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()
set(CMAKE_MODULE_PATH 
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${CMAKE_MODULE_PATH})

# Find Tarantool dependecies
set(TARANTOOL_FIND_REQUIRED ON)
find_package(Tarantool)
include_directories(${TARANTOOL_INCLUDE_DIRS})

# Find MsgPuck llibrary
# set(MsgPuck_FIND_REQUIRED ON)
# find_package(MsgPuck)
# include_directories(${MSGPUCK_INCLUDE_DIRS})

# add LuaJIT dependencies
include_directories(${LUA_INCDIR})


set(CMAKE_C_FLAGS_DEBUG     ${CMAKE_C_FLAGS_DEBUG}   -Wall -Wextra)
set(CMAKE_CXX_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra)

# Build module
add_subdirectory(src)

