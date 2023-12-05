package.path = "../game/myservice/?.lua;" .. package.path

local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mongo = require "skynet.db.mongo"

local client_fd

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

dbL = dbL

local WATCHDOG
local host
local send_request

local ply
local CMD = setmetatable({}, {__index = function(_, fname)
    return function(...)
        local f = ply[fname]
        return f(ply, ...)
    end
end})
local talk_msgs = {}

local function request(fname, args, response)
    ply:state_check_on_rpc()
    local r = ply[fname](ply, args)
    print("fname: "..fname)
	if response then
        print(string.format("response: %s,%s", fname, stringify(r)))
		return response(r)
    else
        print("non response: "..fname)
	end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (fd, _, type, ...)
		assert(fd == client_fd)	-- You can use fd to reply message
        if not ply or ply:get_fd() ~= fd then
            ply = player_t.create(fd, dbL, send_request, WATCHDOG)
        end
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		skynet.trace()
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
        ply:run_action()
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
    skynet.fork(function()
        while true do
            --send_package(send_request "heartbeat")
            skynet.sleep(100)
            if ply then
                ply:on_keep_alive()
            end
        end
    end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
    if ply then
        ply:on_logout()
    end
	skynet.exit()
end

skynet.start(function()
    dbL = mongo.client(
		{
			host = "127.0.0.1", port = 27017,
			authdb = "admin",
		}
	)["sxdsh"]
    status.load_data(dbL)
	skynet.dispatch("lua", function(_,_, command, ...)
		skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
