if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS
        ${CMAKE_SHARED_LINKER_FLAGS}
        -undefined suppress
        -flat_namespace)
endif(APPLE)

# Add C library
add_library(merger SHARED
            merger.c key_def.c)
# target_link_libraries(merger ${LUAJIT_LIBRARIES} ${MSGPUCK_LIBRARIES})
set_target_properties(merger PROPERTIES PREFIX "" OUTPUT_NAME "merger")

# Install module
install(FILES init.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/${PROJECT_NAME}/)
install(TARGETS merger LIBRARY DESTINATION ${TARANTOOL_INSTALL_LIBDIR}/${PROJECT_NAME}/)
