
-- 占位用
NIL = {}
table.set_readonly(NIL)

TRUE = setmetatable({},{__index = function()
    return true
end})
table.add_readonly(TRUE)

FALSE = setmetatable({},{__index = function()
    return false
end})
table.add_readonly(FALSE)

TABLE = setmetatable({},{__index = function()
    return {}
end})
table.add_readonly(TABLE)

-- read_only empty table
EMPTY_TABLE_READONLY = {}
table.set_readonly(EMPTY_TABLE_READONLY)

PLY_STATE = {
    NORMAL = 1,
    MINE = 2,
    TALK = 3,
    SELL = 4,
    BUY  = 5,
}

HELP_TIPS = "h: 帮助 a: 老城主 b: 雾影 m: 进山采矿 s: 显示当前状态"

COMMANDS = {
    h = "help", -- help
    s = "show", -- show
    m = "mine", -- mine
    n = "break_lv",
    j = "sell",
    k = "look"
    -------------
    -- others is talking
}

NPC_NAMES = {
    a = "chengzhu",
    b = "wuying",
    c = "tiewan",
    d = "mingwu",
}

NPC_SHOW_NAMES = {
    a = "老城主",
    b = "雾影大叔",
    c = "铁腕守护者",
    d = "明悟师父",
}

MIN_SECS = 60
HOUR_SECS = 60*60
DAY_SECS = 24*60*60

