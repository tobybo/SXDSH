
module("player_mng", package.seeall)

function load_player(name, db)
    local ply
    --TODO(toby@2023-12-09): 检查是否登录中
    local info = db.player:findOne({_id = name})
    if info then
        printf("从数据库加载[%s]: %s", name, stringify(info))
        ply = player_t.wrap(info, name)
    else
        ply = player_t.create(name, db)
	end
    return ply
end
