local skynet = require "skynet"
local httpc = require "http.httpc"
local dns = require "skynet.dns"
local image_to_url = require "limage_to_url.c"
local json = require "json"
require "tool"

local function http_test(protocol)
	--httpc.dns()	-- set dns server
	httpc.timeout = 100	-- set timeout 1 second
	print("GET baidu.com")
	protocol = protocol or "http"
	local respheader = {}
	local host = string.format("%s://baidu.com", protocol)
	print("geting... ".. host)
	local status, body = httpc.get(host, "/", respheader)
	print("[header] =====>")
	for k,v in pairs(respheader) do
		print(k,v)
	end
	print("[body] =====>", status)
	print(body)

	local respheader = {}
	local ip = dns.resolve "baidu.com"
	print(string.format("GET %s (baidu.com)", ip))
	local status, body = httpc.get(host, "/", respheader, { host = "baidu.com" })
	print(status)
end

local function http_stream_test()
	for resp, stream in httpc.request_stream("GET", "https://baidu.com", "/") do
		print("STATUS", stream.status)
		for k,v in pairs(stream.header) do
			print("HEADER",k,v)
		end
		print("BODY", resp)
	end
end

local function http_head_test()
	httpc.timeout = 100
	local respheader = {}
	local status = httpc.head("https://baidu.com", "/", respheader)
	for k,v in pairs(respheader) do
		print("HEAD", k, v)
	end
end

local function test_image_recognition()
    print("test_image_recognition --------------------------")
    local host = "https://aip.baidubce.com"
    local request_url = "https://aip.baidubce.com/rest/2.0/image-classify/v2/advanced_general?access_token=24.d91720d70804543a9bbab5848a7a1401.2592000.1701581074.282335-42280315"
    local form = {
        image = image_to_url.imageToUrl("flower.jpg"),
    }
    local respheader = {}
    local status, body = httpc.post(host, request_url, form, respheader)
    print("[header] =====>")
    for k,v in pairs(respheader) do
        print(k,v)
    end
    print("[body] =====>", status)
    local res = json.decode(body)
    print(string.format("%s", stringify(res)))
    print("test_image_recognition --------------------------")
end

local function main()
    --dns.server()

	-- http_stream_test()
	-- http_head_test()
    --
	-- http_test("http")
	-- if not pcall(require,"ltls.c") then
	--     print "No ltls module, https is not supported"
	-- else
	--     http_test("https")
	-- end

    test_image_recognition()
end

skynet.start(function()
	print(pcall(main))
	skynet.exit()
end)

