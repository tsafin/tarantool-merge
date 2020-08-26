set(PROJECT_NAME mergerx)
if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS
        ${CMAKE_SHARED_LINKER_FLAGS}
        -undefined suppress
        -flat_namespace)
endif(APPLE)

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
