
module("city_t", package.seeall)

module_class(city_t, NIL._base)

local skynet = require "skynet"

ctor = function(self, onlines)
    self.onlines = onlines
    self.market_seller = {} -- { name = {agent = agent, items = items}, }
end

start_sell = function(self, agent, name, items)
    self.market_seller[name] = {
        agent = agent,
        items = items,
    }
    self:broad_cast_to_onlines(agent, "notice_start_sell", {name = name})
    print("city: ", agent, "开始摆摊", name)
end

end_sell = function(self, agent, name)
    self.market_seller[name] = nil
    self:broad_cast_to_onlines({name = name, del = 1})
    print("city: ", agent, "结束摆摊", name)
end

broad_cast_to_onlines = function(self, exclude_agent, ...)
    for fd, source in pairs(self.onlines) do
        if exclude_agent ~= source then
            skynet.send(source, "lua", ...)
        end
    end
end

request_market = function(self, agent)
    return self.market_seller
end

check_seller_name = function(self, agent, name)
    print("check_seller_name", name)
    return self.market_seller[name] and true or false
end

check_seller_item = function(self, agent, name, item_name)
    print("check_seller_item", name, item_name)
    return self.market_seller[name] and self.market_seller[name].items[item_name] and true or false
end

do_buy = function(self, agent, name, item_name, num)
    local seller = self.market_seller[name]
    if seller and seller.items[item_name]then
        local ret = skynet.call(seller.agent, "lua", "do_buy", item_name, num)
        if ret then
            seller.items[item_name] = seller.items[item_name] - num
            if seller.items[item_name] == 0 then
                seller.items[item_name] = nil
                if table.empty(seller.items) then
                    self:end_sell(seller.agent, name)
                    skynet.send(seller.agent, "lua", "force_end_sell")
                end
            end
        end
        return ret
    end
    return false
end

