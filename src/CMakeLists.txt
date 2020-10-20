set(LIBSUBDIR tuple)
set(LIBNAME merger)

set(lua_sources)
lua_source(lua_sources postload.lua)
set_property(DIRECTORY PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${lua_sources})

add_library(${LIBNAME} SHARED
            compat/utils.c
            merger/merger.c merger/merger-source.c
            ${lua_sources}
)
set_target_properties(${LIBNAME}
                      PROPERTIES PREFIX ""
                      OUTPUT_NAME ${LIBNAME}
)

add_subdirectory(msgpuck)
target_link_libraries(${LIBNAME} msgpuck)

# The dynamic library will be loaded from tarantool executable
# and will use symbols from it. So it is completely okay to have
# unresolved symbols at build time.
if (APPLE)
    set_target_properties(${LIBNAME} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

# Install module
install(TARGETS ${LIBNAME} LIBRARY DESTINATION ${TARANTOOL_INSTALL_LIBDIR}/${LIBSUBDIR})
