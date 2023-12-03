-- Hx@2022-04-06: 引入服务器客户端写法兼容组件
-- 服务器用的lua53 with module(方便热更)
-- 客户端纯lua53
local debug = debug
local string = string
local type = type
local ipairs = ipairs
local set_upvalue = function (f, name, value)
    local i = 1
    local up_name, up_value
    repeat
        up_name, up_value = debug.getupvalue(f, i)
        if up_name == name then
            debug.setupvalue(f, i, value)
            return
        end
        i = i + 1
    until not up_name
end

function module(modname, ...)
    local function findtable(tbl,fname)
        for key in string.gmatch(fname,"([%w_]+)") do
            if key and key~="" then
                local val = rawget(tbl,key)
                if not val then
                    local field = {}
                    tbl[key]=field
                    tbl = field
                elseif type(val)~="table" then
                    return nil
                else
                    tbl = val
                end
            end
        end
        return tbl
    end

    assert(type(modname)=="string")
    local value = package.loaded[modname]
    local modul = nil
    if type(value)~="table" then
        modul = findtable(_G,modname)
        assert(modul,"name conflict for module '"..modname.."'" )
        package.loaded[modname] = modul
    else
        modul = value
    end

    local name = modul._NAME
    if not name then
        modul._M = modul
        modul._NAME = modname
        modul._PACKAGE = string.match(modname,"([%w%._]*)%.[%w_]*$")
    end
    local func = debug.getinfo(2,"f").func
    -- debug.setupvalue(func,1,modul)
    set_upvalue(func, "_ENV", modul)
    for _,f in ipairs({...}) do
        f(modul)
    end
end

function package.seeall(modul)
    setmetatable(modul,{__index=_G})
end

function module_class(mod, base)
    mod._base     = base
    mod._template = rawget(mod, "_template") or {}
    mod._property = rawget(mod, "_property") or {}

    if base then
        setmetatable(mod, {__index = base})
    end

    if mod._base then
        if mod._base._template then
            for k, v in pairs(mod._base._template) do
                if mod._template[k] == nil then
                    mod._template[k] = v
                end
            end
        end
        if mod._base._property then
            for k, v in pairs(mod._base._property) do
                if mod._property[k] == nil then
                    mod._property[k] = v
                end
            end
        end
    end

    local _meta = {
        __index = function(obj, k)
            -- 查询代理
            local v = obj._proxy[k]
            if v ~= nil then
                return v
            end

            -- 查询模板
            v = mod._template[k]
            if v ~= nil then
                if type(v) == 'table' then
                    v = copyTab(v)
                end
                obj._proxy[k] = v
                return v
            end

            -- 查询属性
            v = mod._property[k]
            if v ~= nil then
                return v(obj)
            end

            -- 查询方法
            local now_mod = mod
            while now_mod do
                v = rawget(now_mod, k)
                if v ~= nil then
                    return v
                end
                now_mod = now_mod._base
            end
        end,

        __newindex = function(obj, k, v)
            if mod._template[k] ~= nil then
                if type(v) ~= "table" then
                    if obj._proxy[k] == v then
                        -- 新值=旧值，且类型不为table，则未发生改变
                        return
                    end
                    if obj._proxy[k] == nil and mod._template[k] == v then
                        -- 初次赋值且新值与默认值相同
                        return
                    end
                end
                obj._proxy[k] = v
            elseif mod._property[k] ~= nil then
                local str = string.format("[class] can't set property. %s", debug.traceback())
                print(str)
                -- error(str)
            else
                rawset(obj, k, v)
            end
        end
    }

    mod.init = function(self, ...)
        if base then base.init(self, ...) end
    end

    mod.ctor = function(self, ...)
        if base then base.ctor(self, ...) end
    end

    mod.create = function(...)
        return mod.new(...)
    end

    mod.new = function(...)
        local obj = { _proxy = {} }
        setmetatable(obj, _meta)

        obj._initializing = true
        obj:ctor(...)
        obj:init(...)
        obj._initializing = false

        return obj
    end
end

function get_time()
    local skynet = require "skynet"
    local time = skynet.time()
    return math.floor(time)
end


