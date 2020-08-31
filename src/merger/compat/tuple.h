#ifndef MERGER_TUPLE_H_INCLUDED
#define MERGER_TUPLE_H_INCLUDED
/*
 * Copyright 2020, Tarantool AUTHORS, please see AUTHORS file.
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

#include <module.h>

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

// box/lua/tuple.h

/**
 * Create a new tuple with specific format from a Lua table, a
 * tuple, or objects on the lua stack.
 *
 * Set idx to zero to create the new tuple from objects on the lua
 * stack.
 *
 * In case of an error set a diag and return NULL.
 */
struct tuple *
luaT_tuple_new(struct lua_State *L, int idx, box_tuple_format_t *format);


// box/tuple.h
// FIXME - this is dangerous zone
/**
 * An atom of Tarantool storage. Represents MsgPack Array.
 * Tuple has the following structure:
 *                           uint32       uint32     bsize
 *                          +-------------------+-------------+
 * tuple_begin, ..., raw =  | offN | ... | off1 | MessagePack |
 * |                        +-------------------+-------------+
 * |                                            ^
 * +---------------------------------------data_offset
 *
 * Each 'off_i' is the offset to the i-th indexed field.
 */
struct PACKED tuple
{
	union {
		/** Reference counter. */
		uint16_t refs;
		struct {
			/** Index of big reference counter. */
			uint16_t ref_index : 15;
			/** Big reference flag. */
			bool is_bigref : 1;
		};
	};
	/** Format identifier. */
	uint16_t format_id;
	/**
	 * Length of the MessagePack data in raw part of the
	 * tuple.
	 */
	uint32_t bsize;
	/**
	 * Offset to the MessagePack from the begin of the tuple.
	 */
	uint16_t data_offset : 15;
	/**
	 * The tuple (if it's found in index for example) could be invisible
	 * for current transactions. The flag means that the tuple must
	 * be clarified by transaction engine.
	 */
	bool is_dirty : 1;
	/**
	 * Engine specific fields and offsets array concatenated
	 * with MessagePack fields array.
	 * char raw[0];
	 */
};

/** Size of the tuple including size of struct tuple. */
static inline size_t
tuple_size(struct tuple *tuple)
{
	/* data_offset includes sizeof(struct tuple). */
	return tuple->data_offset + tuple->bsize;
}

/**
 * Get pointer to MessagePack data of the tuple.
 * @param tuple tuple.
 * @return MessagePack array.
 */
static inline const char *
tuple_data(struct tuple *tuple)
{
	return (const char *) tuple + tuple->data_offset;
}

/**
 * Wrapper around tuple_data() which returns NULL if @tuple == NULL.
 */
static inline const char *
tuple_data_or_null(struct tuple *tuple)
{
	return tuple != NULL ? tuple_data(tuple) : NULL;
}

/**
 * Get pointer to MessagePack data of the tuple.
 * @param tuple tuple.
 * @param[out] size Size in bytes of the MessagePack array.
 * @return MessagePack array.
 */
static inline const char *
tuple_data_range(struct tuple *tuple, uint32_t *p_size)
{
	*p_size = tuple->bsize;
	return (const char *) tuple + tuple->data_offset;
}

/**
 * Check tuple data correspondence to space format.
 * Actually, checks everything that is checked by
 * tuple_field_map_create.
 *
 * @param format Format to which the tuple must match.
 * @param tuple  MessagePack array.
 *
 * @retval  0 The tuple is valid.
 * @retval -1 The tuple is invalid.
 */
int
tuple_validate_raw(struct tuple_format *format, const char *data);

/**
 * Check tuple data correspondence to the space format.
 * @param format Format to which the tuple must match.
 * @param tuple  Tuple to validate.
 *
 * @retval  0 The tuple is valid.
 * @retval -1 The tuple is invalid.
 */
static inline int
box_tuple_validate(box_tuple_format_t *format, box_tuple_t *tuple)
{
	#if 0
	return tuple_validate_raw(format, tuple_data(tuple));
	#else
	return 0;
	#endif
}
#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */

#endif /* MERGER_TUPLE_H_INCLUDED */
