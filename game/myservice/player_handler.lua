
module("player_t")

local skynet = require("skynet")

function command(self, pack)
    local cmd = pack.cmd
    local args = pack.args
    return {msg = self:run_command(cmd, args)}
end

function talk(self, args)
    local npc = self:get_npc(args.npc_name)
    if not npc then
        return {msg = "无效指令（也许您可以先输入指令呼唤对应修士）"}
    end
    local msg = npc:talk(args.clear, args.question)
    return {msg = msg}
end

function help(self)
    self:tips(HELP_TIPS)
end

function show(self)
    self.rpc:baseinfo(self:get_base_info())
end

function mine(self)
    self:start_dig_mine()
end

function sell(self)
    if not self:has_card() then
        self:tips("先找铁腕申请摆摊许可吧！")
        return
    end
    self:start_sell()
end

function look(self)
    local seller = skynet.call(self.dog, "lua", "request_market")
    if table.empty(seller) then
        self:tips("当前集市无人摆摊，请稍后再来~")
        return
    end
    local lines = {}
    for name, v in pairs(seller) do
        local one = string.format("%s : ", name)
        for item_name, num in pairs(v.items) do
            one = one .. string.format("[%s x %s] ", item_name, num)
        end
        table.insert(lines, one)
    end
    self:tips(table.concat(lines, "\n"))
end

function break_lv(self)
    local need_break = self:need_break()
    local has_task = self:has_task()
    if not need_break then
        self:tips("先努力修炼达到极限再尝试突破吧!")
        return
    end
    if not has_task then
        self:tips("可以找明悟师父寻求突破线索!")
        return
    end
    local num = self.items[self.task_need] or 0
    if num < 1 then
        self:tips("先收集好突破所需材料：%s", self.task_need)
        return
    end
    self:dec_item(self.task_need, 1)
    self:upgrade_lv()
end

function notice_start_sell(self, info)
    local name = info.name
    self:tips("%s开始摆摊了，大爷快去瞧瞧吧!", name)
end

function do_buy(self, item_name, num)
    local my_num = self.items[item_name] or 0
    if my_num < num then
        return false
    end
    self:dec_item(item_name, num)
    self:add_stone(num)
    return true
end

function buy(self, args)
    local fname = args.city_fname
    if fname == "do_buy" then
        if self.stone < args.num then
            return {ret = false}
        end
        self:dec_stone(args.num)
    end
    local ret = skynet.call(self.dog, "lua", fname, args.name, args.item, args.num)
    if fname == "do_buy" then
        if not ret then
            self:add_stone(args.num)
            self:tips("交易失败，灵石已返还，请重新输入交易数量")
        else
            self:add_item(args.item, args.num)
        end
    end
    return {ret = ret}
end

function force_end_sell(self)
    self:tips("恭喜你，货物已售罄")
    self:set_state(PLY_STATE.NORMAL)
end

