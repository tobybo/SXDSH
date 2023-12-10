
module("player_base_t", package.seeall)

_template = {
    _id = "",
    name = "",
    lv = 1,
    exp = 0,
    stone = 0,
    items = {},
    tm_create = 0,
    book = "",
    tm_book = 0,
    task_need = "",
    tm_card = 0,
}

module_class(player_base_t, NIL._base)

has_book = function(self)
    local now = get_time()
    return self.book ~= "" and self.tm_book + resmng.CFG_BOOK_CD > now
end

has_task = function(self)
    return self.task_need ~= ""
end

get_card_rest = function(self)
    return self.tm_card > 0 and resmng.CFG_CARD_CD - (get_time() - self.tm_card) or 0
end





