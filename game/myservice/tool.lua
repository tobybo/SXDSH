
local insert = table.insert
local format = string.format
local concat = table.concat

function _stringify_lvalue(object, deep)
    local typ = type(object)
    if typ == "table" then
        if deep <= 0 then
            return "['(table)']"
        else
            local tab = {}
            for k, v in pairs(object) do
                insert(
                    tab,
                    format("%s=%s", _stringify_lvalue(k, deep - 1), _stringify_rvalue(v, deep - 1))
                )
            end
            return format("[{%s}]", concat(tab, ","))
        end
    elseif typ == "string" then
        if tonumber(object) then
            return format("['%s']", object)
        else
            return object
        end
    elseif typ == "userdata" or typ == "function" then
        return format("'(%s)'", object)
    else
        return format("[%s]", object)
    end
end

function _stringify_rvalue(object, deep)
    local typ = type(object)
    if typ == "table" then
        if deep <= 0 then
            return "'...'"
        else
            local tab = {}
            for k, v in pairs(object) do
                insert(
                    tab,
                    format("%s=%s", _stringify_lvalue(k, deep - 1), _stringify_rvalue(v, deep - 1))
                )
            end
            return format("{%s}", concat(tab, ","))
        end
    elseif typ == "string" then
        return format("'%s'", object)
    elseif typ == "userdata" or typ == "function" then
        return format("'(%s)'", typ)
    else
        return tostring(object)
    end
end

-- Hx@2021-11-30:
-- stringify代理，实现懒计算，
-- 这个包装会因为多一层调用，format的时候大概会损失2%-4%的性能
-- 但是提高日志级别，不输出所有日志的时候就比较划算

-- Hx@2021-11-30:
-- CJson.encode 比 stringify快一倍多，但是不支持function等
-- 再看看有没有更快的实现

-- Hx@2021-11-30:
-- 在C层重新实现了stringify，比纯lua快4倍

_StringifyDftDepth = 10
_StringifyProxyNum = 20
_StringifyProxyId = _StringifyProxyId or 0
_StringifyProxies = _StringifyProxies or {}

local c_stringify = c_stringify
local function init_stringify_proxies()
    for i = 1, _StringifyProxyNum do
        _StringifyProxies[i] = setmetatable({}, {
            __tostring = function(t)
                return c_stringify(t.data, t.depth, t.maxlen)
            end,
        })
    end
end
--init_stringify_proxies()

function stringify(object, depth, maxlen)
    depth = depth or _StringifyDftDepth

    if true then return _stringify_rvalue(object, depth) end
    -- if _StringifyProxyId < _StringifyProxyNum then
    --     _StringifyProxyId = _StringifyProxyId + 1
    -- else
    --     _StringifyProxyId = 1
    -- end
    -- local proxy = _StringifyProxies[_StringifyProxyId]
    -- proxy.data = object
    -- proxy.depth = depth
    -- proxy.maxlen = maxlen
    -- return proxy
end

function printf(format, ...)
    if select("#", ...) > 0 then
        print(string.format(format, ...))
    else
        print(format)
    end
end

