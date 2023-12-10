
module("npc_mingwu_t", package.seeall)

module_class(npc_mingwu_t, npc_t)

ctor = function(self)
    local name = "明悟师父"
    local role = [[灵风城是一个修仙世界的一个角落，灵风城包括灵风广场、青云山、灵泉湖、修真书院、静心庄园、玄阳阁、灵风茶馆、灵草矿市。灵风广场是城市的中心广场，是散修们交流的地方。广场中央有一座高大的石雕。你是明悟师父，不定时出现在灵风广场为散修免费解答修炼上的疑惑，好像没有什么修炼上的事情能难倒你。如果修士询问你他怎样才能突破瓶颈，你需要根据他的当前实力判断他应该需要收集哪种矿石或者灵草才能突破，并且你的回答中需要带有“你需要收集到【xxx】才能突破”，其中xxx代表一种矿石或者灵草的名字，如果他没有达到待突破的状态，你不能告诉他突破相关的信息，如果你已经告诉过他，请不要改变你的答案。其他事情都让散修找老城主。]]
    self:prepare(name, role)
end

on_talk = function(self, msg)
    local ply = self.ply
    if ply:has_task() then
        return
    end
    local task_need = ply:get_npc("guess"):talk(1, string.format("请你分析这段话[%s]，然后告诉我说这句话的人是否告知了突破所需的材料，如果告知了，你直接说出这种材料的名字，绝对不能有其他多余的字符，请你务必遵守。如果没有告知，你只能回答未告知三个字，请你严格遵守这个回答格式。", msg))
    printf("task, name,%s", task_need)
    if not task_need:find("未告知") then
        ply:add_task(task_need)
    end
end

get_role = function(self)
    local role = self.role
    local ply = self.ply
    local need_break = ply:need_break()
    local has_task = ply:has_task()
    local lv_name = ply:get_lv_name()
    if not need_break then
        return role..string.format("%s尚未达到待突破状态，请不要跟他透露突破相关信息。", ply.name)
    else
        if has_task then
            return role..string.format("%s已达到%s待突破状态，你已经告诉过他突破需要收集%s。", ply.name, lv_name, ply.task_need)
        else
            return role..string.format("%s已达到%s待突破状态。", ply.name, lv_name)
        end
    end
end
