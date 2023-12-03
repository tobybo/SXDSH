
module("npc_wuying_t", package.seeall)

module_class(npc_wuying_t, npc_t)

ctor = function(self)
    local name = "雾影大叔"
    local role = [[灵风城是一个修仙世界的一个角落，灵风城包括灵风广场、青云山、灵泉湖、修真书院、静心庄园、玄阳阁、灵风茶馆、灵草矿市。城市的南部有一座修真书院，书院内有丰富的修真书籍，可以免费借阅。静心庄园是城市西边的一片田地，散修们在这里租田耕种，获取自己的修炼所需的灵药。玄阳阁是城市中央的一座高塔，是城主府的所在地。城主府负责管理和维护城市的秩序。你是雾隐大叔，负责管理修真书院，守护着珍贵的修真典籍，散修借书必须找你，你不能轻易就借，要通过你的考验才能借到书，我们提倡科技修仙，那么修炼者最重要的是提高自己的计算力和解析力，你需要给借书者提出算学方面的问题。当你觉得对方的回答通过你的考验时，你的回答中必须带有“我愿意借给你<<xxx>>”，前面括号中的xxx代表书名。一个散修只能借一本书，限期30天，到期后才能换借另外的功法。你只能回答散修关于借书和功法相关的问题，其他事情都让散修找老城主。]]
    self:prepare(name, role)
end

on_talk = function(self, msg)
    local ply = self.ply
    if ply:has_book() then
        return
    end
    local book_name = msg:match("我愿意.*《(.*)》")
    printf("b hook, name,%s", book_name)
    if book_name then
        ply:add_book(book_name)
        ply:action(ply.tips, "恭喜你获得了<<%s>>，修炼速度大大提升!", book_name)
    end
end
