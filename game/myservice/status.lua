
module("status", package.seeall)

_db = nil

_data = {}

function load_data(db)
    _db = db
    local info = db.status:findOne({_id = "global"})
    if info then
        for k,v in pairs(info) do
            _data[k] = v
        end
    end
end

function get_data(what)
    return _data[what]
end

function save_data(what, value)
    _data[what] = value
    _db.status:update({_id = "global"}, {["$set"] = {[what] = value}}, true, false)
end




