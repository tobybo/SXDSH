
module("npc_t", package.seeall)

_template = {
}

module_class(npc_t, NIL._base)

local skynet = require "skynet"

ctor = function()
end

prepare = function(self, name, role)
    self.name = name
    self.role = role
    self.talk_msgs = {}
    self.host_api = "https://aip.baidubce.com"
    self.request_url = string.format("https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?access_token=%s", skynet.getenv("access_token"))
end

mount_ply = function(self, ply)
    self.ply = ply
end

talk = function(self, clear, question, ...)
    local npc_name = self.name
    if clear == 1 then
        self.talk_msgs = {}
    end
    local talk_msgs = self.talk_msgs
    local old_msgs = talk_msgs
    local role = self:get_role()
    if not role then
        return "no role"
    end
    if #old_msgs % 2 ~= 0 then
        return string.format("repeated msg: %s", stringify(self))
    end
    table.insert(old_msgs, {role = "user", content = self:build_question(question, ...)})
    local json = require "json"
    local old_msg_str = json.encode(old_msgs)
    --print("old_msg_str", old_msg_str)
    local form = {
        messages = old_msgs,
        system = role,
    }
    local respheader = {}
    local skynet = require "skynet"
    local httpc = require "http.httpc"
    local tm_start = skynet.time()
    local status, body = httpc.post(self.host_api, self.request_url, form, respheader)
    local tm_end = skynet.time()
    printf("npc_name: %s, tm_cost: %s", npc_name, tm_end - tm_start)
    -- print("[header] =====>")
    -- for k,v in pairs(respheader) do
    --     print(k,v)
    -- end
    -- print("[body] =====>", status)
    local res = json.decode(body)
    print(string.format("%s", stringify(res)))
    -- print("test_image_recognition --------------------------")
    local result = res.result:gsub("%s",""):gsub("\n", " ")
    print(string.format("npc %s: %s", npc_name, result))
    table.insert(old_msgs, {role = "assistant", content = result})
    self:on_talk(result)
    return result
end

build_question = function(self, question)
    return question
end

on_talk = function(self, msg)
end

get_role = function(self)
    return self.role
end
