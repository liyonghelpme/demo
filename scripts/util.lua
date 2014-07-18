function registerUpdate(obj)
	local function update(diff)
		obj:update(diff)
	end
	obj:scheduleUpdate(update)
end

function getVS()
    return CCDirector:sharedDirector():getVisibleSize()
end

function registerAniEvent(obj, tar)
    local function aniEvent(me, t, s)
	   obj:onAniEvent(me, t, s)
    end
    tar:getAnimation():setMovementEventCallFunc(aniEvent)
end
function getDS()
    return {CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT}
end

function midLayer(l)
    local ds = getDS()
    local vs = getVS()
    print("midLayer", json.encode(ds), vs.width, vs.height)
    local cx, cy = ds[1]/2, ds[2]/2
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    l:scale(sca):pos(nx, ny)
end

function createSequence(act)
    local arr = CCArray:create()
    for k, v in ipairs(act) do
        arr:addObject(v)
    end
    return CCSequence:create(arr)
end

function registerEnterOrExit(obj)
    local function onEnterOrExit(event)
        local tag = event.name
        if tag == 'enter' then
            if obj.enterScene ~= nil then
                obj:enterScene()
            end
            if obj.needUpdate then
                registerUpdate(obj)
            end
            regEvent(obj)
        elseif tag == 'exit' then
            if obj.updateFunc ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(obj.updateFunc)
            end
            clearEvent(obj)
            if obj.exitScene ~= nil then
                obj:exitScene()
            end
        end
    end
    obj:setNodeEventEnabled(true, onEnterOrExit)
end

function regEvent(s)
    if s.events ~= nil then
        for k, v in ipairs(s.events) do
            Event:registerEvent(v, s)
        end
    end
end
function clearEvent(s)
    if s.events ~= nil then
        for k, v in ipairs(s.events) do
            Event:unregisterEvent(v, s)
        end
    end
end


--[[
function registerEnterOrExit(obj)
    local function onEnterOrExit(tag)
        if tag == 'enter' then
            if obj.enterScene ~= nil then
                obj:enterScene()
            end
            if obj.needUpdate then
                registerUpdate(obj)
            end
            --regEvent(obj)
        elseif tag == 'exit' then
            if obj.updateFunc ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(obj.updateFunc)
            end
            --clearEvent(obj)
            if obj.exitScene ~= nil then
                obj:exitScene()
            end
        end
    end
    obj.bg:registerScriptHandler(onEnterOrExit)
end
--]]

