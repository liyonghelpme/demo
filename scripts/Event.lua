EVENT_TYPE = {
    INITDATA=1, RECEIVE_MSG=2, BUY_HERO = 3, UPDATE_HERO=4, DO_MOVE=5, FINISH_MOVE=6, LEVEL_UP=7, UPDATE_EXP=8, CALL_SOL=9, UPDATE_RESOURCE=10, 
    PLAN_BUILDING=11, MOVE_TO_FARM=12,
    MOVE_TO_CAMP=13,
    ADD_SOLDIER=14,
    HARVEST_SOLDIER=15,
    KILL_SOLDIER=16, --从经营页面杀死某个士兵
    INIT_BATTLE=17, 
    FINISH_INIT_BUILD=18,
    CHANGE_NAME=19,
    ROAD_CHANGED=20, --建筑替换道路 道路铺设 道路拆除 桥梁铺设 桥梁拆除

    SHOW_DIALOG=21,
    CLOSE_DIALOG=22,
    SELECT_ME=23,

    PAUSE_GAME=24,
    CONTINUE_GAME=25,

}
Event = {}
Event.callbacks = {}
function Event:registerEvent(name, obj)
    if Event.callbacks[name] == nil then
        Event.callbacks[name] = {}
    end
    Event.callbacks[name][obj] = true
end
function Event:unregisterEvent(name, obj)
    if Event.callbacks[name] ~= nil then
        Event.callbacks[name][obj] = nil
    end
end

function Event:sendMsg(name, msg)
    if Event.callbacks[name] ~= nil then
        for k, v in pairs(Event.callbacks[name]) do
            k:receiveMsg(name, msg)
        end
    end
end
