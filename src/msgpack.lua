--local bit = require 'bit'
--local buffer = require 'buffer'
local ffi = require 'ffi'
local msgpack = require 'msgpack'
--local msgpackffi = require 'msgpackffi'

ffi.cdef([[

enum mp_type {
	MP_NIL = 0,
	MP_UINT,
	MP_INT,
	MP_STR,
	MP_BIN,
	MP_ARRAY,
	MP_MAP,
	MP_BOOL,
	MP_FLOAT,
	MP_DOUBLE,
	MP_EXT
};

enum mp_type
mp_typeof(const char c);

ptrdiff_t
mp_check_array(const char *cur, const char *end);

uint32_t
mp_decode_array(const char **data);

ptrdiff_t
mp_check_map(const char *cur, const char *end);

uint32_t
mp_decode_map(const char **data);

]])

-- @p DEBUG_CHECK - activate extra checks during function calls
-- may introduce slight overhead
local DEBUG_CHECK = false

local verify_args
if DEBUG_CHECK then
    verify_args = function(funcname,...)
        if (select('#', ...) ~= 2) then
            error("Usage: %s(ptr, size)", funcname)
        end
        local buf, size = ...
        if (type(buf) ~= 'cdata') then
            error("%s: 'char *' expected", funcname)
        end
        return true
    end
else
    verify_args = function(...) return true end
end

local char_ptr_t = ffi.typeof('char *')
local bufp = ffi.new('const unsigned char *[1]');

local function init_type_hints_array(format)
    local xlat_table = {}
    for _, value in ipairs(format) do
        local from, to, filler = unpack(value)
        for i=from,to,1 do
            xlat_table[i] = filler
        end
    end
    return xlat_table
end

local mp_type_hints = init_type_hints_array({
    {0x00, 0x7f, ffi.C.MP_UINT}, -- MP_UINT (fixed)
    {0x80, 0x8f, ffi.C.MP_MAP}, -- MP_MAP (fixed)
    {0x90, 0x9f, ffi.C.MP_ARRAY}, -- MP_ARRAY (fixed)
    {0xa0, 0xbf, ffi.C.MP_STR}, -- MP_STR (fixed)
    {0xc0, 0xc0, ffi.C.MP_NIL}, -- MP_NIL
    {0xc1, 0xc1, ffi.C.MP_EXT}, -- MP_EXT -- never used
    {0xc2, 0xc3, ffi.C.MP_BOOL}, -- MP_BOOL
    {0xc4, 0xc6, ffi.C.MP_BIN}, -- MP_BIN(8|16|32)
    {0xc7, 0xc9, ffi.C.MP_EXT}, -- MP_EXT
    {0xca, 0xca, ffi.C.MP_FLOAT}, -- MP_FLOAT
    {0xcb, 0xcb, ffi.C.MP_DOUBLE}, -- MP_DOUBLE
    {0xcc, 0xcf, ffi.C.MP_UINT}, -- MP_UINT
    {0xd0, 0xd3, ffi.C.MP_INT}, -- MP_INT (8,16,32,64)
    {0xd4, 0xd8, ffi.C.MP_EXT}, -- MP_INT? (8,16,32,64,127)
    {0xd9, 0xdb, ffi.C.MP_STR}, -- MP_STR (8,16,32)
    {0xdc, 0xdd, ffi.C.MP_ARRAY}, -- MP_ARRAY (16,32)
    {0xde, 0xdf, ffi.C.MP_MAP}, -- MP_MAP (16,32)
    {0xe0, 0xff, ffi.C.MP_INT}, -- MP_INT
})
local function mp_typeof(c)
    return mp_type_hints[c] or ffi.C.MP_NIL
end

local function decode_array_header_compat(...)
    verify_args('decode_array_header_compat', ...)
    local buf, size = ...
    assert(ffi.istype(char_ptr_t, buf))
    bufp[0] = buf

    local c = bufp[0][0]
    if (mp_typeof(c) ~= ffi.C.MP_ARRAY) then
        error("decode_array_header_compat: unexpected msgpack type")
    end
    --if (ffi.C.mp_check_array(bufp[0], bufp[0] + size) > 0) then
    --    error("decode_array_header_compat: unexpected end of buffer")
    --end 

    local len = ffi.C.mp_decode_array(bufp)

    return len, ffi.cast(ffi.typeof(buf), bufp[0])
end

local function decode_map_header_compat(...)
    verify_args('decode_map_header_compat', ...)
    local buf, size = ...
    assert(ffi.istype(char_ptr_t, buf))
    bufp[0] = buf

    local c = bufp[0][0]
    if (mp_typeof(c) ~= ffi.C.MP_MAP) then
        error("decode_array_header_compat: unexpected msgpack type")
    end
    if (ffi.C.mp_check_map(bufp[0], bufp[0] + size) > 0) then
        error("decode_map_header_compat: unexpected end of buffer")
    end 

    local len = ffi.C.mp_decode_map(bufp)

    return len, ffi.cast(ffi.typeof(buf), bufp[0])
end

print(msgpack.decode_array_header, msgpack.decode_array_header or decode_array_header_compat)

return {
    NULL = msgpack.NULL,
    new = msgpack.new,
    array_mt = msgpack.array_mt,
    cfg = msgpack.cfg,
    map_mt = msgpack.map_mt,

    ibuf_decode = msgpack.ibuf_decode,

    encode = msgpack.encode,
    decode = msgpack.decode,

    decode_unchecked = msgpack.decode_unchecked,
    decode_array_header = msgpack.decode_array_header or decode_array_header_compat,
    decode_map_header = msgpack.decode_map_header or decode_map_header_compat,
}
