#ifndef MERGER_UTILS_H_INCLUDED
#define MERGER_UTILS_H_INCLUDED

/*
 * Copyright 2010-2020, Tarantool AUTHORS, please see AUTHORS file.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* 
 * Drastically simplified utils.h for using at the external modules
 * at the moment it's about iterators mostly, with a few external 
 * symbols declared
 * 
 * NB! Most ptobably this whole set of declarations should be part
 *     of binary compatible module api. Using this hack only temporary.
 */

#include <stdint.h>
#include <string.h>
#include <math.h> /* modf, isfinite */

#include <module.h>

#include <lua.h>
#include <lauxlib.h> /* luaL_error */

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

extern struct lua_State *tarantool_L;

void
luaL_register_type(struct lua_State *L, const char *type_name,
		   const struct luaL_Reg *methods);


void
luaL_register_module(struct lua_State *L, const char *modname,
		     const struct luaL_Reg *methods);


/**
 * Check if a value on @a L stack by index @a idx is an ibuf
 * object. Both 'struct ibuf' and 'struct ibuf *' are accepted.
 * Returns NULL, if can't convert - not an ibuf object.
 */
struct ibuf *
luaL_checkibuf(struct lua_State *L, int idx);

/* {{{ Helper functions to interact with a Lua iterator from C */

/**
 * Holds iterator state (references to Lua objects).
 */
struct luaL_iterator;

/**
 * Create a Lua iterator from a gen, param, state triplet.
 *
 * If idx == 0, then three top stack values are used as the
 * triplet. Note: they are not popped.
 *
 * Otherwise idx is index on Lua stack points to a
 * {gen, param, state} table.
 */
struct luaL_iterator *
luaL_iterator_new(lua_State *L, int idx);

/**
 * Move iterator to the next value. Push values returned by
 * gen(param, state).
 *
 * Return count of pushed values. Zero means no more results
 * available. In case of a Lua error in a gen function return -1
 * and set a diag.
 */
int
luaL_iterator_next(lua_State *L, struct luaL_iterator *it);

/**
 * Free all resources held by the iterator.
 */
void luaL_iterator_delete(struct luaL_iterator *it);

/* }}} */

#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */


#endif /* MERGER_UTILS_H_INCLUDED */
