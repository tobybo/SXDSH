
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
                if mod._table_name and not obj._init then
                    obj.db[mod._table_name]:update({_id = obj._id}, {["$set"] = {[k] = v}}, true, false)
                end
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

        obj._init = true
        obj:ctor(...)
        obj:init(...)
        obj._init = false
        if mod._table_name then
            obj.db[mod._table_name]:insert(obj._proxy)
        end
        return obj
    end

    mod.on_wrap = function(self)
        if base then base.on_wrap(self) end
    end

	mod.wrap = function(t, ...)
        local proxy = rawget(t, '_proxy')
        if proxy then
            local str = string.format("[class] double wrap! %s", debug.traceback())
            error(str)
        end
        local obj = { _proxy = {} }
        setmetatable(obj, _meta)

        obj._init = true
		check_template(obj, t, mod._template)
        obj:init(...)
        obj:on_wrap()
        obj._init = nil

        return obj
    end
end

function get_time()
    local skynet = require "skynet"
    local time = skynet.time()
    return math.floor(time)
end

local function _copy(object, lookup_table)
    if type(object) ~= "table" then
        return object
    elseif lookup_table[object] then
        return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
        new_table[_copy(index, lookup_table)] = _copy(value, lookup_table)
    end
    return new_table
end

function copyTab(object)
    local lookup_table = {}
    return _copy(object, lookup_table)
end

---将数据wrap至obj的proxy中, template中有的字段才会赋值
---@param obj 对象
---@param data 数据
---@param template 数据模板
function check_template(obj, data, template)
	for k, v in pairs(data) do
		if template[k] ~= nil then
			obj._proxy[k] = v
		else
			--TODO: $unset from db
			rawset(obj, k, v) --过去入库的数据 不再入库 但是这样删除不了数据库中的数据
		end
	end
end
