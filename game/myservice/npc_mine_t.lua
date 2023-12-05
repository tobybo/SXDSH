
module("npc_mine_t", package.seeall)

module_class(npc_mine_t, npc_t)

ctor = function(self)
    local name = "刷矿"
    local role = [[你是修真世界的矿灵，负责随机生成矿石，我会提供你某一个散修的段位和挖矿的时长，还有已经出现过的矿石名单，你告诉我一个矿石的名字，需要符合修真世界的风格, 长度不要超过5个字。请注意，你的回答不能有任何多余字符，只能提供一个矿石的名字。矿石名字要用<<>>符号包起来。]]
    self:prepare(name, role)
end

build_question = function(self, question)
    local mine_list = status.get_data("mine") or {}
    local tail_str = ""
    if not table.empty(mine_list) then
        -- tail_str = "当前矿石名单中有"
        -- local punctuation
        -- for mine_name, _ in pairs(mine_list) do
        --     if punctuation then
        --         tail_str = tail_str..punctuation
        --     end
        --     tail_str = tail_str..mine_name
        --     punctuation = "、"
        -- end
        -- tail_str = tail_str.."。"
    end
    return question..tail_str
end

on_talk = function(self, msg)
    print("mine msg: ", msg)
    local mine = msg:match("<<(.*)>>")
    if not mine then
        print("produce failed")
        return
    end
    print("mine: ", mine)
    local mine_list = status.get_data("mine") or {}
    mine_list[mine] = 1
    status.save_data("mine", mine_list)
    self.ply:add_item(mine, 1)
end

produce = function(self)
    local question = string.format("我当前是%s，已经挖矿挖了%s分钟了，给我一个矿石", self.ply:get_lv_name(), self.ply:get_mine_min())
    self:talk(1, question)
end

