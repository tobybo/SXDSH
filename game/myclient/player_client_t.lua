
module("player_client_t", package.seeall)

module_class(player_client_t, NIL._base)

ctor = function(self, fd, send)
    self.fd = fd
    self.sr = {}
    self.session = 0
    self.rpc = setmetatable({ply = self}, {__index = function(_, fname)
        return function(rpc, data)
            local ply = rpc.ply
            ply.session = ply.session + 1
            ply.sr[ply.session] = fname
            local socket = require "client.socket"
            local pack = send(fname, data, ply.session)
            local package = string.pack(">s2", pack)
            socket.send(ply.fd, package)
        end
    end})
end

on_request = function(self, fname, args)
    if fname == "baseinfo" or fname == "handshake" then
        for k, v in pairs(args) do
            self[k] = v
        end
        if fname == "handshake" then
            self:show_loading()
            self:show_help()
        end
        self:show_info()
    elseif fname == "talk" then
        local msg = args.msg
        self:npc_print(msg)
    elseif fname == "tips" then
        self:system_print(args.tips)
    end
end

on_response = function(self, session, args)
    local fname = self.sr[session]
    if self.sub_cmd and self.sub_cmd:need_deal(fname) then
        self.sub_cmd:on_response(self, fname, args)
        return
    end
    --print("session: "..session)
    self:on_request(fname, args)
end

cmds = {
    h = function(self)
        self:show_help()
        --self.rpc[COMMANDS.h](self.rpc)
    end,
    s = function(self)
        self.rpc[COMMANDS.s](self.rpc)
    end,
    m = function(self)
        self.rpc[COMMANDS.m](self.rpc)
    end,
    n = function(self)
        self.rpc[COMMANDS.n](self.rpc)
    end,
    j = function(self)
        self.rpc[COMMANDS.j](self.rpc)
    end,
    k = function(self)
        self.rpc[COMMANDS.k](self.rpc)
    end,
    a = function(self)
        self.npc = "a"
        self.rpc:talk({npc_name = "a", clear = 1, question = string.format("我是修士%s，你能给我提供帮助吗", self.name)})
    end,
    b = function(self)
        self.npc = "b"
        self.rpc:talk({npc_name = "b", clear = 1, question = string.format("我是修士%s", self.name)})
    end,
    c = function(self)
        if self:get_card_rest() then
            self:system_print("你的摆摊许可尚未过期，不要骚扰铁腕守护者大人!")
            return
        end
        self.npc = "c"
        self.rpc:talk({npc_name = "c", clear = 1, question = string.format("我是修士%s", self.name)})
    end,
    d = function(self)
        self.npc = "d"
        self.rpc:talk({npc_name = "d", clear = 1, question = string.format("我是修士%s", self.name)})
    end,
    buy = function(self)
        self:mount_sub_cmd(cmd_buy_t.create(self))
    end,
}

on_readstdin = function(self, input)
    if self.sub_cmd then
        if not self.sub_cmd:check_quit(self, input) then
            self.sub_cmd:on_readstdin(self, input)
        end
        return
    end
    if cmds[input] then
        cmds[input](self)
    else
        if self.npc then
            self.rpc:talk({npc_name = self.npc, clear = 0, question = input})
        else
            self:system_print("无效命令或先唤醒指定npc再进行对话!!")
        end
    end
end

system_print = function(self, fmt, ...)
    local len = select("#", ...)
    local pre = self.sub_cmd and self.sub_cmd:get_pre_name() or "系统: "
    fmt = pre..fmt
    if len > 0 then
        print(string.format(fmt, ...))
    else
        print(fmt)
    end
end

npc_print = function(self, msg)
    if not self.npc then return end
    local show_name = NPC_SHOW_NAMES[self.npc]
    print(show_name..": "..msg)
    print()
end

show_loading = function(self)
    local list = {
        "********************************************************************",
        "*                    欢迎进入灵风城灵风系统！                      *",
        "********************************************************************",
    }
    for _, v in ipairs(list) do
        self:system_print(v)
    end
    print()
end

show_help = function(self)
    local list = {
        "********************************************************************",
        "* 指令介绍: h 帮助   s 信息     quit 退出                          *",
        "*           a 老城主 b 雾影大叔 c 铁腕守护者 d 明悟师父            *",
        "*           m 采矿   n 突破     j 摆摊       k 逛摊   buy 集市购买 *",
        "********************************************************************",
    }
    for _, v in ipairs(list) do
        self:system_print(v)
    end
    print("")
end

show_info = function(self)
    local list_head = {
        "----------------------------- 修士信息 -----------------------------",
    }
    local list_tail = {
        "--------------------------------------------------------------------",
    }
    table.insert(list_head, string.format("大名: %s", self.name))
    table.insert(list_head, string.format("实力: %s", self:get_lv_name()))
    table.insert(list_head, string.format("经验: %s", self:show_exp()))
    table.insert(list_head, string.format("灵石: %s", self.stone))
    table.insert(list_head, string.format("功法: %s", self:show_book()))
    table.insert(list_head, string.format("背包: %s", self:show_items()))
    table.insert(list_head, string.format("证件: %s", self:show_card()))
    for _, v in ipairs(list_head) do
        self:system_print(v)
    end
    for _, v in ipairs(list_tail) do
        self:system_print(v)
    end
    print("")
end

get_lv_name = function(self)
    return resmng.prop_level[self.lv].Name
end

show_exp = function(self)
    local exp = self.exp
    local break_exp = resmng.prop_level[self.lv].BreakExp
    if exp >= break_exp then
        if self:has_task() then
            return string.format("%s/%s(待突破)[材料: %s(%s/1)]", exp, break_exp, self.task_need, self.items[self.task_need] or 0)
        else
            return string.format("%s/%s(待突破)[无突破线索]", exp, break_exp)
        end
    else
        return string.format("%s/%s", exp, break_exp)
    end
end

show_book = function(self)
    if not self.book then
        return "暂未获得"
    end
    return string.format("<<%s>> %s天后需归还", self.book, math.floor((self.tm_book - get_time())/DAY_SECS) + 30)
end

show_items = function(self)
    if not self.items or table.empty(self.items) then
        return "空空如也"
    end
    local total = 0
    local str = ""
    for name, num in pairs(self.items) do
        if num > 0 then
            str = str..string.format("[%s x %s] ", name, num)
            total = total + num
        end
    end
    if total == 0 then
        return "空空如也"
    end
    return str
end

get_card_rest = function(self)
    return self.tm_card and 30 * DAY_SECS - (get_time() - self.tm_card)
end

show_card = function(self)
    local rest_sec = self:get_card_rest()
    if not rest_sec or rest_sec <= 0 then
        return "暂未获得"
    end
    return string.format("摆摊许可证(%s天后到期)", math.ceil(rest_sec/DAY_SECS))
end

has_task = function(self)
    return self.task_need
end

unmount_sub_cmd = function(self)
    self.sub_cmd = nil
end

mount_sub_cmd = function(self, cmd)
    self.sub_cmd = cmd
    self.sub_cmd:on_begin(self)
end


