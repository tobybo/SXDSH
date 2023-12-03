--------------------------------------------------------------------------------
-- Brief   : CJson
-- Author  : Yang Cong <mr.yng@foxmail.com>
-- History : 2021-06-04 14:37:20 Updated
-- Copyright © 2021 IGG SINGAPORE PTE. LTD. All rights reserved.
--------------------------------------------------------------------------------

-- NOTE(YangCong@2021-06-04):
-- Lua CJSON 2.1.0 Manual: https://www.kyne.com.au/~mark/software/lua-cjson-manual.html
-- openresty/lua-cjson: https://github.com/openresty/lua-cjson


local _M = {}
local cjson_safe = require "cjson"

_M.new = function()
    local inst = cjson_safe.new()
    inst.encode_keep_buffer(true)
    inst.encode_max_depth(1000)
    inst.decode_max_depth(1000)
    inst.encode_number_precision(14)
    inst.encode_sparse_array(true, 1, 1)

    return inst
end

return _M.new()

