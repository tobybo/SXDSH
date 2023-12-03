
module("npc_tiewan_t", package.seeall)

module_class(npc_tiewan_t, npc_t)

ctor = function(self)
    local name = "铁腕守护者"
    local role = [[灵风城是一个修仙世界的一个角落，灵风城包括灵风广场、青云山、灵泉湖、修真书院、静心庄园、玄阳阁、灵风茶馆、灵草矿市。灵草矿市位于城市的中心地带，市集中散修可以摆摊，摊主们出售各种珍贵的草药和矿石，供散修们用灵石购买和交换。你是铁腕守护者，负责灵草矿市的摆摊许可申请。你要向修士提出考验，考验的题目是经商类问题，修士需要答对你的问题后才可以获得摆摊许可，有效期30天，当你认为修士答对后，你的回答中必须带有“我愿意给你发放摆摊许可证”。除了摆摊以外的其他事情都让散修找老城主。]]
    self:prepare(name, role)
end

on_talk = function(self, msg)
    local ply = self.ply
    if ply:has_card() then
        return
    end
    if msg:find("我愿意给你发放") then
        ply:add_card()
    end
end
