
package.path = "../game/myservice/?.lua;"..package.path

require("table_ext")

require("tool")
require("common")

require("define")
require("resmng")

require("player_base_t")
require("player_t")
require("player_handler")
require("player_mng")

require("npc_t")
require("npc_chengzhu_t")
require("npc_wuying_t")
require("npc_tiewan_t")
require("npc_mine_t")
require("npc_mingwu_t")
require("npc_guess_t")

require("status")

require("city_t")

-- require("cmd_base")
-- require("cmd_chengzhu")
-- require("cmd_wuying")
-- require("cmd_help")
-- require("cmd_mine")
-- require("cmd_quit")
-- require("cmd_show")
