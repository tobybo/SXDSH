package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;../game/myservice/?.lua;../game/myclient/?.lua"

if _VERSION ~= "Lua 5.4" then
	error "Use lua 5.4"
end

local socket = require "client.socket"
local proto = require "proto"
local sproto = require "sproto"
local skynet = require "skynet.core"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local server_host = os.getenv("SERVER_HOST")
local server_port = tonumber(os.getenv("SERVER_PORT"))
local fd = assert(socket.connect(server_host, server_port))

local ply = player_client_t.create(fd, request)

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

------------------------------------------------
cmds = {
    h = 1, -- help
    s = 2, -- show
    m = 3, -- mountain
}

talkcmds = {
    a = "老城主",
    b = "雾影大叔",
}

talk_state = nil

top_lines = {
    "*                 欢迎进入灵风城灵风系统！                  *",
    "* 指令介绍: h 帮助 a 老城主 b 雾影大叔 m 进山采矿 quit 退出 *",
    "*************************************************************",
}

top_lines_distinct = {}

top_lins_show = false

top_lins_up = 40
top_lins_rest = 20

-- local _print = print
-- local print = function(...)
--     local len = select("#", ...)
--     local format = "%s: "
--     local pre_name = talkcmds[talk_state] or "系统"
--     format = string.format(format, pre_name)
--     for i = 1, len do
--         format = format.."%s"
--     end
--     _print(string.format(format, ...))
--     if top_lins_show then
--         skynet.printf_cursor_move(top_lins_up, top_lins_rest, top_lines)
--     end
-- end

local last = ""

local show_keys = {
    lv = "等级: ",
    tm_create = "开始修炼时间: ",
    name = "姓名: ",
    stone = "灵石: ",
    exp = "经验: ",
    book = "功法: ",
}

local function print_msg(args)
    if type(args) == "table" then
		for k,v in pairs(args) do
            if type(v) == "table" then
                print_msg(v)
            else
                if show_keys[k] then
                    local show = string.format("%s%s", show_keys[k], v)
                    print(show)
                    if not top_lines_distinct[k] then
                        table.insert(top_lines, show)
                    else
                        top_lines[top_lines_distinct[k]] = show
                    end
                else
                    print(v)
                end
            end
		end
        _print("")
    end
end

local function on_recv_package(t, ...)
    --print("on_recv_package: "..t)
	if t == "REQUEST" then
		ply:on_request(...)
	else
		assert(t == "RESPONSE")
		ply:on_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
        --print("dispatch_package 11")

		on_recv_package(host:dispatch(v))
	end
end

print("请输入你的名字")
local name = socket.readstdin()
while not name do
    socket.usleep(100)
    name = socket.readstdin()
end
ply.rpc:handshake({name = name})
--skynet.printf_cursor_move(top_lins_up, top_lins_rest, top_lines)
top_lins_show = true

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
        ply:on_readstdin(cmd)
		socket.usleep(100)
	else
		socket.usleep(100)
	end
end
