
package.path = "./game/myclient/?.lua;".."./game/myservice/?.lua;"..package.path

require("table_ext")

require("tool")
require("common")

require("define")
require("resmng")

require("player_client_t")

require("cmd_base_t")
require("cmd_buy_t")
