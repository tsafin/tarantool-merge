set(PROJECT_NAME merger)
set(PROJECT_PREFIX mergerx)

# Add C library
add_library(${PROJECT_NAME} SHARED
            init.c
            compat/utils.c
            merger/merger.c merger/merger-source.c
)
# target_link_libraries(merger ${LUAJIT_LIBRARIES} ${MSGPUCK_LIBRARIES})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" OUTPUT_NAME ${PROJECT_NAME})

add_subdirectory(msgpuck)
target_link_libraries(${PROJECT_NAME} msgpuck)

# The dynamic library will be loaded from tarantool executable
# and will use symbols from it. So it is completely okay to have
# unresolved symbols at build time.
if (APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

# Install module
install(FILES mergerx.lua DESTINATION ${TARANTOOL_INSTALL_LUADIR}/${PROJECT_PREFIX}/)
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${TARANTOOL_INSTALL_LIBDIR}/${PROJECT_PREFIX})
