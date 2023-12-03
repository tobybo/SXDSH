
module("cmd_base_t", package.seeall)

module_class(cmd_base_t, NIL._base)

on_begin = function(self, ply)
end

on_readstdin = function(self, ply, input)

end

get_quit_tips = function(self, ply)
    return "退出子命令模式"
end

check_quit = function(self, ply, input)
    if input == "quit" then
        ply:system_print(self:get_quit_tips())
        ply:unmount_sub_cmd()
        return true
    end
    return false
end

need_deal = function(self, fname)
    return false
end

on_response = function(self, fname)
    return false
end

get_pre_name = function(self, fname)
    return "子命令系统: "
end

