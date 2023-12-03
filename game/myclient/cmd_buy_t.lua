
module("cmd_buy_t", package.seeall)

module_class(cmd_buy_t, cmd_base_t)

local skynet = require "skynet"

WAIT_SELLER_NAME = 0
WAIT_SELLER_ITEM = 1
WAIT_SELLER_NUM = 2

ctor = function(self, ply)
end

on_begin = function(self, ply)
    self.state = WAIT_SELLER_NAME
    ply:system_print("quit: 退出集市")
    ply:system_print("请输入你想交易的修士名称:")
end

state_machine = {
    [WAIT_SELLER_NAME] = {
        call = function(self, ply, input)
            self.name = input
            ply.rpc:buy({city_fname = "check_seller_name", name = input})
        end,
        response = function(self, ply, ret)
            if not ret then
                self.name = nil
                ply:system_print("该修士未在摆摊，请重新输入:")
            else
                self.state = WAIT_SELLER_ITEM
                ply:system_print("请输入你想交易的物品名称:")
            end
        end,
    },
    [WAIT_SELLER_ITEM] = {
        call = function(self, ply, input)
            self.item = input
            ply.rpc:buy({city_fname = "check_seller_item", name = self.name, item = input})
        end,
        response = function(self, ply, ret)
            if not ret then
                self.item = nil
                ply:system_print("该修士没有对应物品，请重新输入:")
            else
                self.state = WAIT_SELLER_NUM
                ply:system_print("请输入你想交易的数量:")
            end
        end,
    },
    [WAIT_SELLER_NUM] = {
        call = function(self, ply, input)
            input = tonumber(input)
            if not input then
                ply:system_print("交易失败，请重新输入正确的交易数量:")
                return
            end
            local new_input = math.floor(input)
            if new_input ~= input then
                ply:system_print("交易失败，请输入整数的交易数量:")
                return
            end
            if input <= 0 then
                ply:system_print("交易失败，请重新输入正确的交易数量:")
                return
            end
            --(toby@2023-12-02): 先扣钱
            if ply.stone < input then
                ply:system_print("交易失败，您的灵石不够，请重新输入交易数量:")
                return
            end
            ply.rpc:buy({city_fname = "do_buy", name = self.name, item = self.item, num = input})
        end,
        response = function(self, ply, input)
            if ret then
                self.state = WAIT_SELLER_NAME
                self.name = nil
                self.item = nil
                ply:system_print("恭喜你交易成功，如需继续交易，请输入交易修士名称，或者请输入 quit 退出集市。")
            end
        end,
    }
}

on_readstdin = function(self, ply, input)
    state_machine[self.state].call(self, ply, input)
end

get_quit_tips = function(self, ply)
    return "退出集市成功"
end

response = {
    buy = function(self, ply, args)
        state_machine[self.state].response(self, ply, args.ret)
    end,
}

need_deal = function(self, fname)
    return response[fname]
end

on_response = function(self, ply, fname, args)
    response[fname](self, ply, args)
end

get_pre_name = function(self, fname)
    return "集市: "
end
