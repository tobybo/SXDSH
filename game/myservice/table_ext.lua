local table = table

table.copy = copyTab

-- [ 浅拷贝 ]
function table.shallow_copy(data)
    local t = {}
    for k, v in pairs(data) do
        t[k] = v
    end
    return t
end

-- [ 交换kv ]
function table.swap(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[v] = k
    end
    return ret
end

-- [ 反向列表中的元素 ]
function table.reverse(t)
    local ret = {}
    for i=#t, 1, -1 do
        ret[#ret+1] = t[i]
    end
    return ret
end

-- [ 清空 ]
function table.cleanup(t)
    if type(t) == "table" then
        for k, v in pairs(t) do
            t[k] = nil
        end
    end
end

-- [ return first index of value ]
function table.index(t, val)
    for k, v in pairs(t) do
        if val == v then
            return k
        end
    end
end

-- [ return the sum of tables ]
function table.add(...)
    local ret = {}
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = (ret[k] or 0) + v
        end
    end
    return ret
end

function table.addM(t1, ...)
    local ret = t1
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = (ret[k] or 0) + v
        end
    end
    return ret
end

function table.sub(base, ...)
    local ret = copyTab(base)
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = (ret[k] or 0) - v
        end
    end
    return ret
end

function table.subM(t1, ...)
    local ret = t1
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = (ret[k] or 0) - v
        end
    end
    return ret
end

-- [ return the sum of values ]
function table.sum(t)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

-- [ return the sum of t[key] ]
function table.sum_by_key(t, key)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v[key]
    end
    return sum
end

-- [ return the number of elements ]
function table.len(t)
    local len = 0
    for k, v in pairs(t) do
        len = len + 1
    end
    return len
end

function table.len_val(t, val)
    local len = 0
    for k, v in pairs(t) do
        if v == val then
            len = len + 1
        end
    end
    return len
end

function table.maxkey(t)
    local len = 0
    for k, v in pairs(t) do
        if k > len then
            len = k
        end
    end
    return len
end

-- [ integer -- return number of occurrences of value ]
function table.count(t, value)
    local num = 0
    for _, v in pairs(t) do
        if value == v then
            num = num + 1
        end
    end
    return num
end

-- 多层向下查找
function table.peek(tab, ...)
    if type(tab) == "table" then
        local _value = tab
        for i, v in ipairs({...}) do
            _value = _value[v]
            if not _value then
                break
            end
        end
        return _value
    end
end

function table.find(t, f, ...)
    for k, v in pairs(t) do
        if f(v, k, ...) then
            return v
        end
    end
    return nil
end

function table.find_index(t, f)
    for k, v in pairs(t) do
        if f(v, k) then
            return k
        end
    end
    return nil
end

-- 只比较数组类型的table元素
function table.icompare(t1, t2)
    if #t1 ~= #t2 then
        return
    end
    for k, v in ipairs(t1) do
        if t2[k] ~= v then
            if type(v) ~= "table" or type(t2[k]) ~= "table" then
                return
            end
            if not table.icompare(v, t2[k]) then
                return
            end
        end
    end
    return true
end

function table.empty(val)
    return table.is_empty(val)
end

function table.is_empty(val)
    return next(val) == nil
end

function table.not_empty(val)
    return next(val) ~= nil
end

-- 得到一个table的前n名的元素(从大到小)
function table.topk(t, knum, lesscmp)
    if knum == 0 then
        return
    end
    local min = 1
    local flag = true
    local topk = {}
    local sort = table.sort
    for k, v in pairs(t) do
        if #topk < knum then
            table.insert(topk, k)
        else
            if flag then
                table.sort(
                    topk,
                    function(k1, k2)
                        return not lesscmp(t[k1], t[k2])
                    end
                )
                flag = false
            end
            if lesscmp(t[topk[knum]], v) then
                topk[knum] = k
                flag = true
            end
        end
    end
    table.sort(
        topk,
        function(k1, k2)
            if t[k1] ~= t[k2] then
                return not lesscmp(t[k1], t[k2])
            else
                return false
            end
        end
    )
    return topk
end

local function go_inject(t, k, v, tail, ...)
    if tail == nil then
        t[k] = v
    else
        if not t[k] then
            t[k] = {}
        end
        go_inject(t[k], v, tail, ...)
    end
end
function table.inject(t, ...)
    local args = {...}
    if #args ~= tabNum(args) then
        assert(false, string.format('%s', stringify(args)))
    end
    go_inject(t, ...)
    return t
end

local function go_clear(t, k, tail, ...)
    if t[k] == nil then
        return
    end
    if not tail then
        t[k] = nil
        return
    end

    go_clear(t[k], tail, ...)
    if is_table_empty(t[k]) then
        t[k] = nil
    end
end

function table.clear(t, ...)
    local args = {...}
    assert(#args == table.len(args))
    go_clear(t, ...)
    return t
end

function table.acquire(t, ...)
    local node = t
    for _, k in pairs({...}) do
        if not node[k] then
            node[k] = {}
        end
        node = node[k]
    end
    return node
end

-- key值列表
-- {a=b} => {a}
function table.keys(t)
    local res = {}
    for k, v in pairs(t) do
        table.insert(res, k)
    end
    return res
end

function table.values(t)
    local res = {}
    for k, v in pairs(t) do
        table.insert(res, v)
    end
    return res
end

-- [ 切片 ]
function table.slice(t, start, stop, step)
	step = step or 1
    assert(lua_types.is_table(t) and lua_types.is_number(start) and lua_types.is_number(stop) and lua_types.is_number(step) and start <= stop and step > 0,
        string.format("invalid params. t=%s, start=%s, stop=%s, step=%s", t, start, stop, step))

    local index = start
    local sliced, remainder = {}, {}
    for k, v in ipairs(t) do
        if k == index and index <= stop then
            table.insert(sliced, v)
            index = index + step
        else
            table.insert(remainder, v)
        end
    end
    return sliced, remainder
end

function table.range(tab, start, stop, step)
    step = step or 1
    assert(lua_types.is_number(start) and lua_types.is_number(stop) and lua_types.is_number(step) and (stop - start) * step > 0,
        string.format("invalid params. start=%s, stop=%s, step=%s", start, stop, step))
    local t = {}
    for i=start, stop, step do
        t[i] = tab[i]
    end
    return t
end

function table.last_equal(t, f, ...)
    local idx = 0
    for i = 1, #t do
        if f(t[i], ...) then
            idx = i
        else
            break
        end
    end
    return idx, t[idx]
end

function table.first_equal(t, f, ...)
    local idx = 0
    for i = 1, #t do
        if f(t[i], ...) then
            idx = i
            break
        end
    end
    return idx, t[idx]
end

-- 用其它table扩展t1
function table.extend(t1, ...)
    for _, t2 in pairs({...}) do
        for _, v in pairs(t2) do
            t1[#t1 + 1] = v
        end
    end
    return t1
end

function table.merge(...)
    local ret = {}
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = v
        end
    end
    return ret
end


function table.mergeM(t1, t2)
    for k, v in pairs(t2 or {}) do t1[k] = v end
    return t1
end

function table.update(t1, ...)
    for _, t2 in pairs({...}) do
        for k, v in pairs(t2) do
            t1[k] = v
        end
    end
    return t1
end

function table.map(t, func, ...)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = func(v, ...)
    end
    return ret
end

function table.filter(t, f, ...)
    local ret = {}
    for k, v in pairs(t) do
        if f(v, ...) then
            table.insert(ret, v)
        end
    end
    return ret
end

function table.filter_keys(t, f, ...)
    local ret = {}
    for k, v in pairs(t) do
        if f(v, ...) then
            table.insert(ret, k)
        end
    end
    return ret
end

table.unpack = table.unpack or unpack

table.pack = table.pack or function(...)
    local t = {...}
    t.n = table.len(t)
    return t
end

table.foreach = table.foreach or function(t, func)
    for k, v in pairs(t) do
        func(k, v)
    end
end

table.foreachi = table.foreachi or function(t, func)
    for k, v in ipairs(t) do
        func(k, v)
    end
end

function table.fold(t, d, fn)
    local x = d
    for _, v in pairs(t) do
        x = fn(x, v)
    end
    return x
end

function table.get(t, k)
    return t[k]
end

function table.pick(tab, keys)
    local ret = {}
    for _, key in ipairs(keys) do
        ret[key] = tab[key]
    end
    return ret
end

function table.append(t1, t2)
    local t = {}
    for _,v in pairs(t1 or {}) do t[#t+1] = v end
    for _,v in pairs(t2 or {}) do t[#t+1] = v end
    return t
end

function table.appendM(t1, t2)
    for _,v in pairs(t2 or {}) do t1[#t1+1] = v end
    return t1
end


function table.detect(t, value, ...)
    if lua_types.is_function(value) then
        for k, v in pairs(t) do
            if value(v, ...) then return k end
        end
    else
        for k, v in pairs(t) do
            if v == value then return k end
        end
    end
end

function table.search(t, value, ...)
    local k = table.detect(t, value, ...)
    return k and t[k]
end

function table.flatten(t)
    local ret = {}
    for k, v in pairs(t) do
        t[#t+1] = k
        t[#t+1] = v
    end
    return ret
end

function table.weak(mode)
    return setmetatable({}, {__mode=mode})
end

function table.is_array(t)
    return table.not_empty(t) and table.len(t) == #t
end

function table.multiply(t, x)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = math.floor(v*x)
    end
    return ret
end
-- Hx@2016-11-18: 数组/序对转换
-- {{a, b}} => {a=b}
table.list2pair = function(t)
    local res = {}
    for k, v in pairs(t) do
        if res[v[1]] then
            ERROR("[tool] list2pair: unexcepted same key")
            return
        end
        res[v[1]] = v[2]
    end
    return res
end

-- {a=b} => {{a, b}}
table.pair2list = function(t)
    local res = {}
    for k, v in pairs(t) do
        table.insert(res, {k, v})
    end
    return res
end

function table.cmp(a, b)
    if a == b then
        return true, {}, {}
    elseif type(a) == 'table' and type(b) == 'table' then
        local s, xs, ys = true, {}, {}

        local watched = {}
        for k, _ in pairs(a) do
            local r, x, y = table.cmp(a[k], b[k])
            if not r then
                s, xs[k], ys[k] = false, x, y
            end
            watched[k] = true
        end
        for k, _ in pairs(b) do
            if not watched[k] then
                s, xs[k], ys[k] = false, a[k], b[k]
            end
        end
        return s, xs, ys
    elseif a ~= b then
        return false, a, b
    else
        return true, {}, {}
    end
end

local readonly_mt = {
    __newindex = function()
        error("Attempt to modify a readonly table", 2)
    end
}

table.set_readonly = function(t)
    if getmetatable(t) then
        ERROR("[%s], try set readonly fault, trace,%s", _NAME, debug.traceback())
        return
    end
    setmetatable(t, readonly_mt)
end

table.add_readonly = function(t)
    if getmetatable(t) then
        local meta = getmetatable(t)
        if meta.__newindex then
            ERROR("[%s], try add readonly fault, trace,%s", _NAME, debug.traceback())
            return
        end
        meta.__newindex = function()
            error("Attempt to modify a readonly table", 2)
        end
        return
    end
    setmetatable(t, readonly_mt)
end

table.bound_high = function(t, standard, high, low)
    local diff = high > low and -1 or 1
    for i = high, low, diff do
        if t[i] then
            t[i] = math.min(t[i], standard)
            standard = standard - t[i]
            if t[i] == 0 then
                t[i] = nil
            end
        end
    end
end

table.list_del = function(list, val)
    for i = #list, 1, -1 do
        if list[i] == val then
            table.remove(list, i)
        end
    end
end

