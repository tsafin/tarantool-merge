set(PROJECT_NAME mergerx)
if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS
        ${CMAKE_SHARED_LINKER_FLAGS}
        -undefined,dynamic_lookup
        -multiply_defined,suppress
        -flat_namespace)
endif(APPLE)

# FIXME - get rid of those, after we would migrate to module_api in key_def
if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "86" OR ${CMAKE_SYSTEM_PROCESSOR} MATCHES "amd64")
    add_definitions("-DCORO_ASM")
elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm" OR ${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64")
    add_definitions("-DCORO_ASM")
else()
    add_definitions("-DCORO_SJLJ")
endif()

# Add C library
add_library(${PROJECT_NAME} SHARED
            init.c
            merger/merger.c merger/merger-source.c
            merger/compat/utils.c
            key_def/key_def.c)
# target_link_libraries(merger ${LUAJIT_LIBRARIES} ${MSGPUCK_LIBRARIES})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" OUTPUT_NAME ${PROJECT_NAME})

# Install module
install(FILES mergerx.lua key_defx.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/${PROJECT_NAME}/)
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${TARANTOOL_INSTALL_LIBDIR}/)
