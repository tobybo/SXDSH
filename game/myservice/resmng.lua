
module("resmng", package.seeall)

local skynet = require "skynet"

ITEM = 1
RESOURCE = 2

local idx = 0
local nextIdx = function()
    idx = idx + 1
    return idx
end

ITEM_CHUXINZHILU = nextIdx()
ITEM_MINGWUZHISHI = nextIdx()
ITEM_LINGDONGZHIFENG = nextIdx()
ITEM_SHENMIZHIGUANG = nextIdx()
ITEM_SHENGJIZHIQUAN = nextIdx()
ITEM_WUJINZHIHUO = nextIdx()
ITEM_XINGCHENZHIGUANG = nextIdx()
ITEM_YUZHOUZHIXIN = nextIdx()
ITEM_TIANMINGZHIHUN = nextIdx()

ITEM_MINE_1 = nextIdx()
ITEM_MINE_2 = nextIdx()
ITEM_MINE_3 = nextIdx()
ITEM_MINE_4 = nextIdx()

prop_item = {
    ITEM_CHUXINZHILU = { Name = "初心之露" },
    ITEM_MINGWUZHISHI = { Name = "明悟之石" },
    ITEM_LINGDONGZHIFENG = { Name = "灵动之风" },
    ITEM_SHENMIZHIGUANG = { Name = "神秘之光" },
    ITEM_SHENGJIZHIQUAN = { Name = "生机之泉" },
    ITEM_WUJINZHIHUO = { Name = "无尽之火" },
    ITEM_XINGCHENZHIGUANG = { Name = "星辰之尘" },
    ITEM_YUZHOUZHIXIN = { Name = "宇宙之心" },
    ITEM_TIANMINGZHIHUN = { Name = "天命之魂" },

    ITEM_MINE_1 = { Name = "火晶石", Sell = 10 },
    ITEM_MINE_2 = { Name = "水晶石", Sell = 10 },
    ITEM_MINE_3 = { Name = "木晶石", Sell = 10 },
    ITEM_MINE_4 = { Name = "雷晶石", Sell = 100 },
}

prop_level = {
    [1] = { Name = "炼气期一层", BreakExp = 100, BaseSpeed = 1, Pow = 10, BreakCons = {{ITEM, ITEM_CHUXINZHILU, 1}, {RESOURCE, RES_STONE, 20}}},
    [2] = { Name = "炼气期二层", BreakExp = 300, BaseSpeed = 2, Pow = 50, BreakCons = {{ITEM, ITEM_MINGWUZHISHI, 1}, {RESOURCE, RES_STONE, 30}}},
    [3] = { Name = "炼气期三层", BreakExp = 700, BaseSpeed = 3, Pow = 100, BreakCons = {{ITEM, ITEM_LINGDONGZHIFENG, 1}, {RESOURCE, RES_STONE, 40}}},
    [4] = { Name = "炼气期四层", BreakExp = 2000, BaseSpeed = 4, Pow = 300, BreakCons = {{ITEM, ITEM_SHENMIZHIGUANG, 1}, {RESOURCE, RES_STONE, 50}}},
    [5] = { Name = "炼气期五层", BreakExp = 5000, BaseSpeed = 5, Pow = 700, BreakCons = {{ITEM, ITEM_SHENGJIZHIQUAN, 1}, {RESOURCE, RES_STONE, 60}}},
    [6] = { Name = "炼气期六层", BreakExp = 10000, BaseSpeed = 6, Pow = 1200, BreakCons = {{ITEM, ITEM_WUJINZHIHUO, 1}, {RESOURCE, RES_STONE, 70}}},
    [7] = { Name = "炼气期七层", BreakExp = 20000, BaseSpeed = 7, Pow = 2000, BreakCons = {{ITEM, ITEM_XINGCHENZHIGUANG, 1}, {RESOURCE, RES_STONE, 80}}},
    [8] = { Name = "炼气期八层", BreakExp = 40000, BaseSpeed = 8, Pow = 5000, BreakCons = {{ITEM, ITEM_YUZHOUZHIXIN, 1}, {RESOURCE, RES_STONE, 90}}},
    [9] = { Name = "炼气期九层", BreakExp = 100000, BaseSpeed = 10, Pow = 20000, BreakCons = {{ITEM, ITEM_TIANMINGZHIHUN, 1}, {RESOURCE, RES_STONE, 10000}}},
}

CFG_MINE = {
    cd = 10,
}

CFG_CARD_CD = 30 * 86400
CFG_BOOK_CD = 30 * 86400

INIT_STONE_NUM = 100

