
module("player_t", package.seeall)

_template = {
}

_table_name = "player"

module_class(player_t, player_base_t)

local skynet = require "skynet"

-- local need_save = {
--     name = 1,
--     lv = 1,
--     exp = 1,
--     stone = 1,
--     tm_create = 1,
--     book = 1,
--     tm_book = 1,
-- }

ctor = function(self, name, db)
    self._id = name
    self.name = name
    self.tm_create = get_time()
    self.stone = resmng.INIT_STONE_NUM
    self.db = db
    self.fd = fd
end

init = function(self)
end

get_name = function(self)
    return self.name
end

set_name = function(self, name)
    self.name = name
    -- 先从数据库加载
end

set_info = function(self, info)
    for k,v in pairs(info) do
        self[k] = v
    end
end

get_fd = function(self)
    return self.fd
end

is_online = function(self)
    return self.name
end

-- get_base_info = function(self)
--     return {
--         name = self.name,
--         tm_create = self.tm_create,
--         lv = self.lv,
--         exp = self:show_exp(),
--         stone = self.stone,
--         book = self:show_book(),
--     }
-- end

get_base_info = function(self)
    return {
        name = self.name,
        tm_create = self.tm_create,
        lv = self.lv,
        exp = self.exp,
        stone = self.stone,
        book = self.book,
        tm_book = self.tm_book,
        items = self.items,
        tm_card = self.tm_card,
        task_need = self.task_need,
    }
end

on_login = function(self, fd, db, send, dog)
    self.fd = fd
    self.db = db
    self.dog = dog
    self.actions = {}
    self.rpc = setmetatable({ply = self}, {__index = function(_, fname)
        return function(rpc, data)
            local ply = rpc.ply
            local socket = require "skynet.socket"
            local pack = send(fname, data)
            local package = string.pack(">s2", pack)
            socket.write(ply.fd, package)
        end
    end})
    --self:register_cmds()
    self:register_npcs()
    self:set_state(PLY_STATE.NORMAL)
    self.tm_login = get_time()
    self.tm_exp = self.tm_login
    self.tm_book = 0
    self.book = ""
    printf("散修[%s]登录成功", self.name)
end

calc_exp = function(self)
    if not self:has_book() then return end
    local now = get_time()
    local dura = now - self.tm_exp
    local speed = resmng.prop_level[self.lv].BaseSpeed
    local value = speed * dura
    self:add_exp(value)
    self.tm_exp = now
end

on_logout = function(self)
    self:calc_exp()
    printf("散修[%s]下线", self.name)
end

add_exp = function(self, exp)
    self.exp = self.exp + exp
    self:save({exp = self.exp})
    print(string.format("散修[%s]获得了[%s]点经验", self.name, self.exp))
end

on_keep_alive = function(self)
    if get_time() % 5 == 0 then
        self:calc_exp()
    end
    self:calc_mine()
end

save = function(self, chgs)
    --self.db.player:update({_id = self.name}, {["$set"] = chgs}, true, false)
end

drop = function(self, chgs)
    self.db.player:update({_id = self.name}, {["$unset"] = chgs}, true, false)
end

-- get_save_info = function(self)
--     local chgs = {_id = self.name}
--     for k,_ in pairs(need_save) do
--         printf("need_save,%s, value,%s", k, self[k])
--         if self[k] then
--             chgs[k] = self[k]
--         end
--     end
--     printf("save: %s", stringify(chgs))
--     return chgs
-- end

add_book = function(self, book)
    self.book = book
    self.tm_book = get_time()
    self:save({book = book, tm_book = self.tm_book})
    printf("[%s]获得了功法书[%s]", self.name, self.book)
end

state_machine = {
    [PLY_STATE.NORMAL] = {
        on_begin = function(self)
        end,
        on_over = function(self)
        end,
        on_running = function(self)
        end,
    },
    [PLY_STATE.MINE] = {
        on_begin = function(self)
            self.tm_mine = get_time()
            self.rpc:tips({tips = string.format("开始采矿，每[%s]秒可随机收获一次矿石", resmng.CFG_MINE.cd)})
        end,
        on_over = function(self)
            self:calc_mine()
        end,
        on_running = function(self)
            self:tips("采矿结束")
            self:set_state(PLY_STATE.NORMAL)
        end,
    },
    [PLY_STATE.SELL] = {
        on_begin = function(self)
            skynet.send(self.dog, "lua", "start_sell", self.name, self.items)
            self:tips("开始摆摊")
        end,
        on_over = function(self)
            -- self:calc_mine()
            skynet.send(self.dog, "lua", "end_sell", self.name)
            self:tips("结束摆摊")
        end,
        on_running = function(self)
            self:set_state(PLY_STATE.NORMAL)
        end,
    },
    -- [PLY_STATE.TALK] = {
    --     on_begin = function(self)
    --     end,
    --     on_over = function(self)
    --     end,
    --     on_running = function(self, name, args)
    --         if self[name] then
    --             self:set_state(PLY_STATE.NORMAL)
    --             return self[fname](self, args)
    --         end
    --         local npc = self.npcs[self.now_npc]
    --         npc:talk()
    --     end,
    -- },
}

set_state = function(self, state)
    local old_state = self.state
    if old_state == state then
        return
    end
    if old_state and state_machine[old_state] and state_machine[old_state].on_over then
        state_machine[old_state].on_over(self)
    end
    self.state = state
    if state_machine[state] and state_machine[state].on_over then
        state_machine[state].on_begin(self)
    end
end

get_state = function(self)
    return self.state
end

is_state = function(self, state)
    return self:get_state() == state
end

calc_mine = function(self)
    if self:is_state(PLY_STATE.MINE) then
        local tm_mine = self.tm_mine
        local dura = get_time() - tm_mine
        if dura > 0 and dura % resmng.CFG_MINE.cd == 0 then
            -- -- 随机矿石
            -- local sum = 0
            -- for _, v in pairs(resmng.CFG_MINE.pool) do
            --     sum = sum + v[2]
            -- end
            -- local num = math.random(sum)
            -- local id
            -- for _, v in ipairs(resmng.CFG_MINE.pool) do
            --     if num < v[2] then
            --         id = v[1]
            --         break
            --     else
            --         num = num - v[2]
            --     end
            -- end
            print("calc_mine, produce")
            self:get_npc("m"):produce()
        end
    end
end

add_item = function(self, name, num)
    local items = self.items
    items[name] = (items[name] or 0) + num
    self.items = items
    self:save({items = items})
    self.rpc:tips({tips = string.format("恭喜你获得了[%s x %s]", name, num)})
end

dec_item = function(self, name, num)
    local items = self.items
    if not items[name] or items[name] < num then
        self:tips("材料不足")
        return true
    end
    items[name] = items[name] - num
    if items[name] == 0 then
        items[name] = nil
    end
    self:save({items = items})
    self.rpc:tips({tips = string.format("减少[%s x %s]", name, num)})
    return false
end

register_cmds = function(self)
    self.cmds = {
        quit = cmd_quit.create(),
        h = cmd_help.create(),
        a = cmd_chengzhu.create(),
        b = cmd_wuying.create(),
        m = cmd_mine.create(),
        s = cmd_show.create(),
    }
end

register_npcs = function(self)
    self.npcs = {
        a = npc_chengzhu_t.create(),
        b = npc_wuying_t.create(),
        c = npc_tiewan_t.create(),
        d = npc_mingwu_t.create(),
        m = npc_mine_t.create(),
        guess = npc_guess_t.create(),
    }
    for name, npc in pairs(self.npcs) do
        npc:mount_ply(self)
    end
end

-- get_cmd = function(self, name)
--     return self.cmds[name]
-- end
--
-- get_running_cmd = function(self)
--     return self.running and self:get_cmd(self.running)
-- end
--
-- run_command = function(self, cmd, args)
--     local last_cmd = self:get_running_cmd()
--     if last_cmd then
--         last_cmd:on_over(self)
--         self.running = nil
--     end
--     local cur = self:get_cmd(cmd)
--     local data = cur:on_begin(args)
--     self.running = cmd
--     return data or ""
-- end
--
state_check_on_rpc = function(self, fname, args)
    local state = self.state
    state_machine[state].on_running(self)
end

prepare_npc = function(self, name)
    self.now_npc = name
    --self:set_state(PLY_STATE.TALK)
end

get_npc = function(self, name)
    return self.npcs[name]
end

action = function(self, f, ...)
    table.insert(self.actions, {f, {...}})
end

run_action = function(self)
    while #self.actions > 0 do
        local f_tab = table.remove(self.actions, 1)
        f_tab[1](self, table.unpack(f_tab[2]))
    end
end

tips = function(self, fmt, ...)
    if select("#", ...) > 0 then
        self.rpc:tips({tips = string.format(fmt, ...)})
    else
        self.rpc:tips({tips = fmt})
    end
end

start_dig_mine = function(self)
    self:set_state(PLY_STATE.MINE)
end

start_sell = function(self)
    if self:is_bag_empty() then
        self:tips("背包内没有货品可出售!!!")
        return
    end
    self:set_state(PLY_STATE.SELL)
end

is_bag_empty = function(self)
    if table.empty(self.items) then
        return true
    end
    local total = 0
    for id, num in pairs(self.items) do
        total = total + num
        if num == 0 then
            self.items[id] = nil
        end
    end
    return total == 0
end

get_lv_name = function(self)
    return resmng.prop_level[self.lv].Name
end

get_mine_min = function(self)
    return math.ceil((get_time() - self.tm_mine) / MIN_SECS)
end

add_card = function(self)
    self.tm_card = get_time()
    self:save({tm_card = self.tm_card})
    self:action(tips, "恭喜你获得<<摆摊许可证>>，有效期30天")
end

add_task = function(self, task_need)
    self.task_need = task_need
    self:save({task_need = self.task_need})
    self:action(tips, "恭喜你获得了突破线索：收集%s", task_need)
end

del_task = function(self)
    self.task_need = nil
    self:drop({task_need = 1})
end

need_break = function(self)
    if self.lv >= #resmng.prop_level then
        return false
    end
    local exp = self.exp
    local break_exp = resmng.prop_level[self.lv].BreakExp
    return exp >= break_exp
end

upgrade_lv = function(self)
    self.lv = self.lv + 1
    self:save({lv = self.lv})
    self:tips("恭喜你晋级到%s", self:get_lv_name())
end

add_stone = function(self, stone)
    self.stone = self.stone + stone
    self:save({stone = self.stone})
    self:tips("增加了 %s 灵石", stone)
end

dec_stone = function(self, stone)
    self.stone = self.stone - stone
    self:save({stone = self.stone})
    self:tips("减少了 %s 灵石", stone)
end
