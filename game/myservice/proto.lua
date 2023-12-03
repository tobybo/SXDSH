local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.item {
    name 0 : string
    num 1 : integer
}

.info {
    name 0 : string
    tm_create 1 : integer
    lv 2 : integer
    stone 3 : integer
    exp 4 : integer
    book 5 : string
    tm_book 6 : integer
    items 7 : *item()
    tm_card 8 : integer
    task_need 9 : string
}

handshake 1 {
    request {
        name 0 : string
    }
	response info
}

help 2 {}

talk 3 {
	request {
        npc_name 0 : string
        clear 1 : integer
        question 2 : string
	}
	response {
		msg 0 : string
	}
}

mine 4 {}
show 5 {}
break_lv 6 {}
sell 7 {}
look 8 {}
buy 9 {
    request {
        city_fname 0 : string
        name 1 : string
        item 2 : string
        num  3 : integer
    }
    response {
		ret 0 : boolean
	}
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.item {
    name 0 : string
    num 1 : integer
}

heartbeat 1 {}

baseinfo 2 {
    request {
		name 0 : string
		tm_create 1 : integer
        lv 2 : integer
        stone 3 : integer
        exp 4 : integer
        book 5 : string
        tm_book 6 : integer
        items 7 : *item()
        tm_card 8 : integer
        task_need 9 : string
	}
}

tips 3 {
    request {
        tips 0 : string
    }
}
]]

return proto
