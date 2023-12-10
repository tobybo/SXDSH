
module("npc_guess_t", package.seeall)

module_class(npc_guess_t, npc_t)

ctor = function(self)
    local name = "意图识别"
    local role = [[你是一个意图识别机器人，我会给你一段话，并且告诉你识别的目标，你必须遵守我给你的回答要求。]]
    self:prepare(name, role)
end

