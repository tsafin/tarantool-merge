cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(tuple_merger C CXX)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()
set(CMAKE_MODULE_PATH 
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${CMAKE_MODULE_PATH})

include(cmake/utils.cmake)

# Set CFLAGS/CXXFLAGS
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Werror -std=gnu99")

# Find Tarantool dependencies
set(TARANTOOL_FIND_REQUIRED ON)
find_package(Tarantool)
include_directories(${TARANTOOL_INCLUDE_DIRS})

# Find MsgPuck library
# set(MsgPuck_FIND_REQUIRED ON)
# find_package(MsgPuck)
# include_directories(${MSGPUCK_INCLUDE_DIRS})

# add LuaJIT dependencies
include_directories(${LUA_INCDIR})

# Build module
add_subdirectory(extra)
add_subdirectory(src)

