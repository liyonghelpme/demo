function dict(arr)
    local temp = {}
    if arr ~= nil then
        for k, v in ipairs(arr) do
            temp[v[1]] = v[2]
        end
    end
    return temp
end
--require "data.String"
--local simple = json
function registerMultiTouch(obj)
    --x y id x y id  x y id
    local function onTouch(eventType, touches)
        --print("onTouch multi", eventType, touches, simple:encode(touches))
        --print("onMultiple", eventType, simple:encode(touches))
        print("onMultiple", eventType)
        for k, v in ipairs(touches) do
            print(k, v)
        end

        --[[
        table.insert(touches, 400)
        table.insert(touches, 200)
        table.insert(touches, 1)
        --]]
        print()
        if eventType == "began" then   
            return obj:touchesBegan(touches)
        elseif eventType == "moved" then
            return obj:touchesMoved(touches)
        elseif eventType == "ended" then
            return obj:touchesEnded(touches)
        elseif eventType == "cancelled" then
            if obj.touchesCanceled ~= nil then
                return obj:touchesCanceled(touches)
            end
        end
    end
    --single Touch
    print("register multiple touch", obj.name)
    obj.bg:setTouchPriority(kCCMenuHandlerPriority)
    obj.bg:setTouchSwallowEnabled(true)

    obj.bg:registerScriptTouchHandler(onTouch, true, kCCMenuHandlerPriority, true)
    
    --bug 这个导致问题么?
    obj.bg:setTouchEnabled(true)
    --obj.bg:setTouchMode(kCCTouchesAllAtOnce)
end
--function registerTouch(obj, pri)
--end


function registerTouch(obj, pri)
    local function onTouch(eventType, x, y)
        print("onTouch single", eventType, x, y)
        if eventType == "began" then   
            return obj:touchBegan(x, y)
        elseif eventType == "moved" then
            return obj:touchMoved(x, y)
        else
            return obj:touchEnded(x, y)
        end
    end
    if pri == nil then
        pri = kCCMenuHandlerPriority
    end
    print("register single touch", obj.name)
    --single Touch
    
    obj.bg:registerScriptTouchHandler(onTouch, false, pri, true)
    obj.bg:setTouchEnabled(true)
end



--注册更新通常需要注册enter和exitScene 这样在退出场景的时候自动关闭更新
--registerEnterOrExit must!!
function registerUpdate(obj, interval)
    if not interval then
        interval = 0
    end
    local function update(diff)
        --print("update who", obj.name)
        obj:update(diff)
    end
    obj.updateFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, interval, false)
end
function registerEnterOrExit(obj)
    local function onEnterOrExit(tag)
        print("node event", tag)
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
    obj.bg:registerScriptHandler(onEnterOrExit)
end

function round(x)
    local t
    if x >= 0.0 then
        t = math.ceil(x)
        if t-x > 0.50000000001 then
            t = t - 1
        end
    else
        t = math.ceil(-x)
        if t+x > 0.50000000001 then
            t = t - 1
        end
        t = -t
    end
    return t
end

function roundGridPos(x, y)
    return {round(x/16)*16, round(y/16)*16}
end

function getGrid(x, y)
    return {round(x/16), round(y/16)}
end
function getSign(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end
function runAction(obj, act)
    if obj.curAction ~= act then
        if obj.curAction ~= nil then
            obj.bg:stopAction(obj.curAction)
        end

        obj.curAction = act
        if act ~= nil then
            obj.bg:runAction(act)
        end
    end
end

function gridToSoldierPos(x, y)
    return {x*16+8, y*16+8}
end
function soldierPosToGrid(x, y)
    return getGrid(x-8, y-8)
end


function xyToKey(x, y)
    return x*100000+y
end
function keyToXY(key)
    return math.floor(key/100000), math.floor(key%100000)
end
function reverse(a)
    local temp = {}
    for i=#a, 1, -1 do
        table.insert(temp, a[i])
    end
    return temp
end

function magnitude(v)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    return len
end

function normalize(v)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    return {v[1]/len, v[2]/len}
end

function truncate(v, maxv)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    if len == 0 then
        return {v[1], v[2]}
    end
    local nv = math.min(len, maxv)
    local cof = nv/len
    return {v[1]*cof, v[2]*cof}
end

function distance2(a, b)
    local dx, dy = a[1]-b[1], a[2]-b[2]
    return dx*dx+dy*dy
end
function distance(a, b)
    local dx, dy = a[1]-b[1], a[2]-b[2]
    return math.sqrt(dx*dx+dy*dy)
end
function mdist(a, b)
    return math.abs(a[1]-b[1])+math.abs(a[2]-b[2])
end
function scaleBy(v, s)
    return {v[1]*s, v[2]*s}
end
--短方法链
function setSize(sp, size)
    local sz = sp:getContentSize()
    sp:setScaleX(size[1]/sz.width)
    sp:setScaleY(size[2]/sz.height)
    return sp
end
function setContentSize(sp, sz)
    sp:setContentSize(CCSizeMake(sz[1], sz[2]))
    return sp
end

function setAnchor(sp, anchor)
    sp:setAnchorPoint(ccp(anchor[1], anchor[2]))
    return sp
end
--相对局部坐标就不对了
function setPos(sp, pos)
    sp:setPosition(ccp(pos[1], pos[2]))
    return sp
end
function setColor(sp, color)
    sp:setColor(ccc3(color[1], color[2], color[3]))
    if #color == 4 then
        sp:setOpacity(color[4])
    end
    return sp
end
function setOpacity(sp, o)
    sp:setOpacity(o)
    return sp
end
function addSprite(bg, name)
    local sp
    if name == nil then
        sp = CCSprite:create()
    else
        --强制使用单张图片
        if string.sub(name, 1, 1) == '#' then
            sp = CCSprite:create(string.sub(name, 2))
        else
            local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
            local frame = spc:spriteFrameByName(name)
            if frame ~= nil then
                sp = CCSprite:createWithSpriteFrameName(name)
            else
                sp = CCSprite:create(name)
            end
        end
    end
    bg:addChild(sp)
    return sp
end
--如果anchorY 是 0.5 则不用修正 sy了
--背景高度 默认 global.director.disSize[2]
--y 原始位置
--sy 图片尺寸
--ay 图片的anchorPoint
function fixY(hei, y, sy, ay)
    if hei == nil then
        hei = global.director.disSize[2]
    end
    if sy == nil then
        sy = 0
    end
    if ay == nil then
        return hei-(y+sy)
    else
        return hei-(y)
    end
end
function addAction(bg, act)
    bg:runAction(act)
    return bg
end
function repeatForever(act)
    return CCRepeatForever:create(act)
end
function repeatN(act, n)
    return CCRepeat:create(act, n)
end
function rotateby(t, ang)
    return CCRotateBy:create(t, ang)
end
function moveto(d, x, y)
    local mov = CCMoveTo:create(d, ccp(x, y))
    return mov
end
function moveby(d, x, y)
    local mov = CCMoveBy:create(d, ccp(x, y))
    return mov
end
function expout(act)
    return CCEaseExponentialOut:create(act)
end
function expin(act)
    return CCEaseExponentialIn:create(act)
end
function fadein(t)
    return CCFadeIn:create(t)
end
function fadeout(t)
    return CCFadeOut:create(t)
end
function delaytime(t)
    return CCDelayTime:create(t)
end
function spawn(sp)
    local array = CCArray:create()
    for k, v in ipairs(sp) do
        array:addObject(v)
    end
    return CCSpawn:create(array)
end
function scaleto(t, sx, sy)
    return CCScaleTo:create(t, sx, sy)
end

function scaleby(t, sx, sy)
    return CCScaleBy:create(t, sx, sy)
end
function sizeto(t, sx, sy, sp)
    local sz = sp:getContentSize()
    local scax = sx/sz.width
    local scay = sy/sz.height
    return CCScaleTo:create(t, scax, scay)
end

function callfunc(delegate, cb, param)
    local function cm()
        if delegate ~= nil then
            cb(delegate, param)
        else
            cb(param)
        end
    end
    return CCCallFunc:create(cm)
end
function fadeto(d, o)
    return CCFadeTo:create(d, o)
end

function itintto(d, r, g, b)
    return CCTintTo:create(d, r, g, b)
end
function sequence(seq)
    local arr = CCArray:create()
    for k, v in ipairs(seq) do
        arr:addObject(v)
    end
    return CCSequence:create(arr)
end

function sinein(act)
    return CCEaseSineIn:create(act)
end
function purebezierby(t, x1, y1, x2, y2, x3, y3)
    local bezier = ccBezierConfig()
    bezier.controlPoint_1 = ccp(x1, y1)
    bezier.controlPoint_2 = ccp(x2, y2)
    bezier.endPosition = ccp(x3, y3)
    return CCBezierBy:create(t, bezier)
end
function bezierby(t, x0, y0, x1, y1, x2, y2, x3, y3)
    local b = purebezierby(t, x1, y1, x2, y2, x3, y3)
    return sequence({moveto(0, x0, y0), b})
end
--bezier 插值4 点
--当前坐标  x1 x2 x3 4点
function purebezierto(t, x1, y1, x2, y2, x3, y3)
    local bezier = ccBezierConfig()
    bezier.controlPoint_1 = ccp(x1, y1)
    bezier.controlPoint_2 = ccp(x2, y2)
    bezier.endPosition = ccp(x3, y3)
    return CCBezierTo:create(t, bezier)
end
function bezierto(t, x0, y0, x1, y1, x2, y2, x3, y3)
    local b = purebezierto(t, x1, y1, x2, y2, x3, y3)
    return sequence({moveto(0, x0, y0), b})
end
--数组中放着图片名字
function arrPicFrames(arr)
    local allFrame = CCArray:create()
    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()

    for k, v in ipairs(arr) do
        local fn = 'images/'..v
        local frame = spc:spriteFrameByName(fn)
        if frame == nil then
            local tex = CCTextureCache:sharedTextureCache():addImage(fn)
            local sz = tex:getContentSize()
            local rect = CCRectMake(0, 0, sz.width, sz.height) 
            local sf = CCSpriteFrame:createWithTexture(tex, rect)
            frame = sf
        end
        --print("frame", frame, fn)
        allFrame:addObject(frame)
    end
    return allFrame
end
function frames(pattern, begin, last)
    local allFrame = CCArray:create()
    --如果不是plist 文件则 spriteFrames 没有办法复用 addSpriteFrame
    --单个图片文件 只能使用 
    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    for i=begin, last, 1 do
        local fn = string.format(pattern, i)
        local frame = spc:spriteFrameByName(fn)
        if frame == nil then
            local tex = CCTextureCache:sharedTextureCache():addImage(fn)
            local sz = tex:getContentSize()
            local rect = CCRectMake(0, 0, sz.width, sz.height) 
            local sf = CCSpriteFrame:createWithTexture(tex, rect)
            frame = sf
        end
        print("frame", frame, fn)
        allFrame:addObject(frame)
    end
    return allFrame
end

function animate(t, arr)
    local count = arr:count() 
    local animation = CCAnimation:createWithSpriteFrames(arr, t/1000/count)
    local ani = CCAnimate:create(animation)
    return ani
end

--修正主picture 在images 文件夹
--修正key --->xxx.plist/x.png
--降低资源包
function addPlistSprite(name)
    --print("addPlistSprite", name)
    local dict = CCDictionary:createWithContentsOfFile('images/'..name)
    local metaData = tolua.cast(dict:objectForKey("metadata"), 'CCDictionary')
    local texturePath = metaData:valueForKey("textureFileName"):getCString()
    texturePath = 'images/'..texturePath
    local texture = CCTextureCache:sharedTextureCache():addImage(texturePath)
    local frames = tolua.cast(dict:objectForKey("frames"), "CCDictionary")
    local allKeys = frames:allKeys()
    local count = allKeys:count()
    local newFrames = CCDictionary:create()
    for i=0, count-1, 1 do
        local key = tolua.cast(allKeys:objectAtIndex(i), "CCString")
        local obj = frames:objectForKey(key:getCString())
        local cstr = key:getCString()
        local newName = name.."/"..cstr
        --print("newName", newName)
        newFrames:setObject(obj, newName)
    end
    --使用plist 文件名来区分不同的 frames
    dict:setObject(newFrames, "frames")

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithDictionary(dict, texture)
end

local initYet = false
function altasWord(c, s)
    local n = CCNode:create()
    local plist = c..'.plist'
    if not initYet then
        addPlistSprite("yellow.plist")
        addPlistSprite("red.plist")
        addPlistSprite("blue.plist")
        addPlistSprite("white.plist")
        addPlistSprite("bold.plist")
    end
    local offX = 0
    local hei = 0
    for i=1, #s, 1 do
        local w = s:sub(i,i)
        if w == "+" then
            w = 'plus'
        elseif w == '-' then
            w = 'minus'
        elseif w == '%' then
            w = 'percent'
        end
        local png = CCSprite:createWithSpriteFrameName(plist.."/"..w..'.png')   
        setAnchor(setPos(png, {offX, 0}), {0, 0})
        n:addChild(png)
        local si = png:getContentSize()
        offX = offX + si.width
        hei = si.height
    end
    n:setContentSize(CCSizeMake(offX, hei))
    return n
end

function removeSelf(obj)
    obj:removeFromParentAndCleanup(true)
end
function convertMultiToArr(touches)
    local lastPos = {}
    local ids = {}
    local x, y
    local count = 0
    --x y id
    for i, v in ipairs(touches) do
        if (i-1) % 3 == 0 then
            x = v
        elseif (i-1) % 3 == 1 then
            y = v
        --x y id
        else 
            lastPos[v] = {x, y, v}
            count = count+1
            table.insert(ids, v)
        end
    end 
    --从0 开始排序touch id
    table.sort(ids)
    local temp = {}
    for k, v in ipairs(ids) do
        temp[k-1] = lastPos[v]
    end
    temp.count = count
    return temp, lastPos
end

function setDesignScale(sp)
    sp:setScaleX(global.director.disSize[1]/global.director.designSize[1])
    sp:setScaleY(global.director.disSize[2]/global.director.designSize[2])
    return sp
end
function setScaleY(sp, s)
    sp:setScaleY(s)
    return sp
end

function setSca(sp, sca)
    return setScale(sp, sca)
end
function setScale(sp, sca)
    sp:setScale(sca)
    return sp
end
function adjustWidth(sp)
    sp:setScale(global.director.disSize[1]/global.director.designSize[1])
    return sp
end

function addLayer(s, c)
    s.bg:addChild(c.bg)
    return s
end

function addLabel(s, w, f, sz)
    local l = CCLabelTTF:create(w, f, sz)
    s:addChild(l)
    return l
end
function addNode(s)
    local n = CCNode:create()
    s:addChild(n)
    return n
end
function setVisible(s, v)
    s:setVisible(v)
    return s
end

function getStr(key, rep)
    local s = Strings[key]
    if s == nil then
        s = WORDS[key]
        if s == nil then
            return key
        end
    end
    --语言
    s = s[1]
    if rep == nil then
        return s
    end
    s = replaceStr(s, rep)
    return s
end

--可以参考nozomi MyWorld 网格 笛卡尔坐标 仿射坐标的转化
--从 笛卡尔坐标 到 左下角的normal 坐标
--转化成 normal 坐标
--Cartesian to normal
--return round(x/SIZEX), round(y/SIZEY)
--normal left 
function getPosMap(sx, sy, px, py)
    px = px - SIZEX
    px = round(px/SIZEX)
    py = round(py/SIZEY)
    return {sx, sy, px+1, py+1}
end

--得到位置对应的 坐标
--由坐标计算normalMap  normalizePos 
--根据 MapWidth/2 对应的网格的编号决定
--24 * 29 地图块
-- 0 0 菱形网格中心normal 奇数偶数性决定
--FIX_HEIGHT 170 = y = 2
--MapWidth/2  width height 29 
function getPosMapFloat(sx, sy, px, py)
    local np = normalizePos({px,py},sx, sy)
    px = np[1]
    py = np[2]
    px = px-SIZEX
    px = round(px/SIZEX)+1
    py = round(py/SIZEY)+1
    return {sx, sy, px, py}
end
function getMapKey(x, y)
    return x*10000+y
end
function getXY(k)
    return math.floor(k/10000), math.floor(k%10000)
end

function getDefault(t, k, def)
    local v = t[k]
    if v == nil then
        t[k]= def
        v = def
    end
    return v
end

--Cartesian to normal
function getBuildMap(build)
    local sx = build.sx
    local sy = build.sy
    local px, py = build.bg:getPosition()
    return getPosMap(sx, sy, px, py)
end
--用 normal To Cartesian 来实现的
--从寻路的normal 转化成 建筑物的normal 坐标
function cellNormalToMapNormal(x, y)
end
--这个替代了从normal 到Cartesian 坐标转化
--px py 是0.5 0 网格的normal位置
function setBuildMap(map)
    local sx = map[1]
    local sy = map[2]
    local px = map[3]
    local py = map[4]

    px = px-sx
    py = py-1
    px = px*SIZEX
    py = py*SIZEY
    px = px+(sx+sy)*SIZEX/2
    return {px, py}
end

function removeMapEle(arr, obj)
    for k, v in ipairs(arr) do
        if v[1] == obj then
            table.remove(arr, k)
            break
        end
    end
end
function getGoodsKey(kind, id)
    return kind*10000+id
end
local dataPool = {}
function getData(kind, id)
    local key = getGoodsKey(kind, id)
    local ret = dataPool[key]
    if ret == nil then
        local k = Keys[kind]
        local datas = CostData[kind][id]
        ret = {}

        for m, n in ipairs(k) do
            if n == "name" then
                ret[n] = getStr(datas[m], nil)
            else
                ret[n] = datas[m]
            end
        end
        dataPool[key] = ret
    end
    return ret
end
--使用右下角 规划格子 所以不用减去y方向的值
--Cartesian to Cartesian 
--getBuildMap ----> setBuildMap
--根据 nx = 0 ny = 0 的位置放置的网格 
--使用 0 0 网格的左下角作为对齐的标准

--Warning 不再使用了这里对齐坐标需要考虑 背景地图的大小来做normal网格对齐 但是normal网格已经和 当前的newAffine 网格只是坐标网格对齐但是
--奇数偶数 性不一定确定
--FIX_HEIGHT == 2
--MapWidth/2  == 29
function normalizePos(p, sx, sy)
    local x = p[1]
    local y = p[2]
    
    local ty = round(FIX_HEIGHT/SIZEY)
    local tx = round(MapWidth/2/SIZEX)
    local ty = ty%2
    local tx = tx%2
    local ba = tx == ty
    local q1 = round(x/SIZEX)
    local q2 = round(y/SIZEY)
    local bb = (q1)%2 == (q2)%2
    if ba ~= bb then
        q2 = q2+1
    end
    x = q1*SIZEX
    y = q2*SIZEY
    return {x, y}
end


--笛卡尔 正则  仿射坐标转化
--寻路算法中使用 正则坐标 
--neibor 
--x+1 y
--x-1 y
--x y+1
--x y-1
--x+1 y+1
--x-1 y+1
--x-1 y-1
--x+1 y-1
--cartesian  normal  affine
function cartesianToNormal(x, y)
    return round(x/SIZEX), round(y/SIZEY)
end
function normalToAffine(nx, ny)
    return round((ny-nx)/2), round((nx+ny)/2)
end
--仿射坐标 > 0 取下界 0.57 ---> 1  
--小于 0  -0.57 ---> -1 取下界
function normalToAffineFloor(nx, ny)
    return math.floor((ny-nx)/2), math.floor((nx+ny)/2)
end


--用于计算当前位置和攻击范围的关系
--返回浮点normal 网格坐标
function cartesianToNormalFloat(x, y)
    return (x/SIZEX), (y/SIZEY)
end
--将坐标基数 现有坐标奇数偶数相同 现有的建筑物坐标的要求
function sameOdd(x, y)
    if x%2 ~= y%2 then
        y = y+1
    end
    return x, y
end


--返回浮点affine 网格坐标  
function normalToAffineFloat(nx, ny)
    return (nx+ny)/2, (ny-nx)/2
end

function normalToCartesian(nx, ny)
    return nx*SIZEX, ny*SIZEY
end
function affineToNormal(dx, dy)
    return dy-dx, dx+dy
end
--加上坐标修正
--x y 修正
function affineToCartesian(ax, ay)
    ax, ay = MapGX-ax-1, MapGY-ay-1 
    local nx, ny = affineToNormal(ax, ay)
    local cx, cy = normalToCartesian(nx, ny)
    cx = cx+1472
    return fixToCarXY(cx, cy)
end

--大地图坐标被抬高了
function bigAffineToCartesian(ax, ay)
    ax, ay = BIG_MAPX-ax-1, BIG_MAPY-ay-1 
    local nx, ny = affineToNormal(ax, ay)
    local cx, cy = normalToCartesian(nx, ny)
    cx = cx+3200
    return fixToCarXY(cx, cy)
end

--修正要转化成affine 坐标的 笛卡尔坐标的xy值
function fixToAffXY(x, y)
    return x, y-FIX_HEIGHT
end
--修正从affine坐标转化来的car坐标的xy值
function fixToCarXY(x, y)
    return x, y+FIX_HEIGHT
end


function checkMiaoPoint(x, y, px, py, sx, sy)
    local nx, ny = cartesianToNormalFloat(x, y)
    local ax, ay = normalToAffineFloat(nx, ny)

    local npx, npy = cartesianToNormalFloat(px, py)
    local apx, apy = normalToAffineFloat(npx, npy)

    print("checkPointIn", x, y, px, py, sx, sy)
    print("nx ny ax ay", nx, ny, ax, ay)
    print("point", npx, npy, apx, apy)

    return ax >= apx-sx/2 and ay >= apy-sy/2 and ax < apx+sx/2 and ay < apy+sy/2
end

--转化成 affine 坐标进行比较
function checkPointIn(x, y, px, py, sx, sy)
    --点击对应的网格点
    local nxy = getPosMapFloat(1, 1, x, y)
    local ax, ay = normalToAffine(nxy[3], nxy[4]) 

    --建筑物 对应的affine 网格 中心点
    local npxy = getPosMapFloat(1, 1, px, py) 
    local apx, apy = normalToAffine(npxy[3], npxy[4])

    print("checkPointIn", x, y, px, py, sx, sy)
    print("nx ny ax ay", simple.encode(nxy), ax, ay)
    print("point", simple.encode(npxy), apx, apy)
    --网格坐标在其内部
    return ax >= apx and ay >= apy and ax < apx+sx and ay < apy+sy
end

function getPos(s)
    local x, y = s:getPosition()
    return {x, y}
end
function getSize(s)
    local sz = {}
    local t = s:getContentSize()
    sz = {t.width, t.height}
    return sz
end
function checkIn(x, y, sz)
    return x >= 0 and x < sz.width and y > 0 and y < sz.height
end
function getHeight(sp)
    return sp:getContentSize().height
end

--可以合并素材到一个renderTarget 里面用于静态显示 适合于静态组合的场景背景图片的显示 
function picNumWord(w, sz, col)
    local n = CCNode:create()
    local curX = 0
    local curY = 0
    local height = 0
    local over = split(w, "}")
    for i=1, #over, 1 do
        local begin = split(over[i], '{')
        if #begin[1] > 0 then
            local l = ui.newTTFLabel({text=begin[1], font="", size=sz})
            setPos(setColor(setAnchor(l, {0, 0}), col), {curX, curY})
            n:addChild(l)
            local lSize = l:getContentSize()
            curX = curX+lSize.width
            height = math.max(height, lSize.height)
            local shadow = ui.newTTFLabel({text=begin[1], font="", size=sz})
            setPos(setColor(setAnchor(shadow, {0, 0}), {0, 0, 0}), {1, -1})
            l:addChild(shadow, -1)
        end
        if #begin > 1 then
        end
    end
    n:setContentSize(CCSizeMake(curX, height))
    return n
end

function split(str, del)
    local fields = {}
    str:gsub("([^"..del.."]+)", function(c) table.insert(fields, c) end)
    return fields
end

--level == 0
function getLevelCost(kind, id, level)
    local build = getData(kind, id)
    local cost = {}
    for k, i in ipairs(costKey)do
        local v = getDefault(build, i, 0)
        if v > 0 then
            cost[i] = v
        end
    end

    --建筑物 需要根据数量 等级计算开销
    --普通建筑都是0级别购买 
    --水晶矿升级 是 另外的 方式
    --print(simple.encode(build))
    if kind == GOODS_KIND.BUILD then
        if build["hasNum"] == 1 then
            local curNum = getCurLevelBuildNum(id, level);
            --升级建筑物 建筑物的数量不变
            curNum = math.min(#build.numCost[level+1]-1, curNum)
            --购买建筑物建筑
            local c = build.numCost[level+1][curNum+1]
            for i = 1, #costKey, 1 do 
                v = getDefault(c, costKey[i], 0)
                if v > 0 then
                    cost[costKey[i]] = v
                end
            end
        end
    end
    return cost
end

function getCost(kind, id)
    return getLevelCost(kind, id, 0)
    --[[
    local build = getData(kind, id)
    local cost = {}
    for k, i in ipairs(costKey) do
        local v = getDefault(build, i, 0)
        if v > 0 then
            cost[i] = v
        end
    end
    return cost
    --]]
end
function getGain(kind, id)
    local build = getData(kind, id)
    local gain = {}
    for k, i in ipairs(addKey) do
        local v = getDefault(build, i, 0)
        if v > 0 then
            local newKey = string.gsub(i, "gain", "") 
            gain[newKey] = v
        end
    end
    return gain
end

function replaceStr(s, rep)
    local temp = {}
    for k, v in ipairs(rep) do
        if (k-1)%2 == 0 then
            v = string.gsub(v, '%[', '{')
            v = string.gsub(v, '%]', '}')
        end
        table.insert(temp, v)
    end
    rep = temp
    for i=1, #rep, 2 do
        s = string.gsub(s, rep[i], rep[i+1])
    end
    return s
end

function setBox(n, box)
    local sca = getSca(n, box)
    setScale(n, sca)
    return n
end
function getSca(n, box)
    local nSize = n:getContentSize()
    local sca
    if nSize.width > box[1] or nSize.height > box[2] then
        sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    else
        sca = 1
    end
    return sca
end
function adjustBox(sp, box)
    local sca = getSca(sp, box)
    setScale(sp, sca)
end

function checkInChild(bg, pos)
    local sub = bg:getChildren()
    local count = bg:getChildrenCount()
    for i=0, count-1, 1 do
        local child = tolua.cast(sub:objectAtIndex(i), 'CCNode')
        local np = child:convertToNodeSpace(ccp(pos[1], pos[2]))
        if checkIn(np.x, np.y, child:getContentSize()) then
            print('child', child:getTag(), child.id)
            return child
        end
    end
    return nil
end

function getParam(k)
    return getDefault(GameParam, k, 0)
end


function colorWordsNode(s, si, nc, sc)
    local n = CCNode:create()
    local over = split(s, "%]")

    local curX = 0
    local height = 0
    for i = 1, #over,  1 do
        if string.find(over[i], "%[") ~= nil then
            local p = split(over[i], "%[")
            if #p[1] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(p[1], "", si), nc), {curX, 0})
                n:addChild(l)
                setAnchor(l, {0, 0})
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end

            if #p[2] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(p[2], "", si), sc), {curX, 0})
                n:addChild(l)
                setAnchor(l, {0, 0})
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end
        else
            if #over[i] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(over[i], "", si), nc), {curX, 0})
                setAnchor(l, {0, 0})
                n:addChild(l)
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end
        end
    end
    n:setContentSize(CCSizeMake(curX, height))
    return n;
end
function getRealHeight(sp)
    local sz = sp:getContentSize()
    local sca = sp:getScale()
    return sz.height*sca
end


function cost2Minus(cost)
    local data = {}
    for k, v in pairs(cost) do
        data[k] = -v
    end
    return data;
end
function updateTable(a, b)
    for k, v in pairs(b) do
        a[k] = v
    end
    return a
end
function showMultiPopBanner(showData)
    for k, v in pairs(showData) do
        local w
        if v > 0 then
            w = getStr("opSuc", {"[NUM]", "+"..str(v), "[KIND]", getStr(k, null)})
            global.director.curScene.dialogController:addBanner(UpgradeBanner.new(w, {255, 255, 255}, nil, nil))
        end
    end
end
function strictSca(n, box)
    local nSize = n:getContentSize()
    local sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    return sca
end
function server2Client(t)
    return math.floor(t-global.user.serverTime+global.user.clientTime)
end
function client2Server(t)
    return math.floor(t-global.user.clientTime+global.user.serverTime)
end
--DisplayFrame 有trimedSize 导致 位置不对 改变这个trimmedSize
function setTexture(sp, tex)
    local t = CCTextureCache:sharedTextureCache():addImage(tex)
    --print('setTexture', sp, t)
    sp:setTexture(t)
    local sz = t:getContentSize()
    local r = CCRectMake(0, 0, sz.width, sz.height)
    sp:setContentSize(sz)
    sp:setTextureRect(r, false, sz)
    return sp
end
function linearInter(va, vb, ta, tb, cut)
    return va+(vb-va)*cut/(tb-ta)
end
function calAccCost(leftTime)
    for i = 1, i < #AccCost,  1 do
        if AccCost[i][1] > i then
            break
        end
    end
    i = i-1
    local beginTime = AccCost[i][1]
    local endTime = AccCost[i+1][1]
    local beginGold = AccCost[i][2]
    local endGold = AccCost[i+1][2]
    local needGold = linearInter(beginGold, endGold, beginTime, endTime, leftTime)
    return needGold
end

function getLevelUpNeedExp(level)
    return levelExp[math.min(#levelExp, level+1)]
end
function getAni(id)
    return buildAnimate[id]
end
function adjustZord(bg, z)
    bg:retain()
    local par = bg:getParent()
    removeSelf(bg)
    par:addChild(bg, z)
    bg:release()
    return bg
end

function getBuildFunc(id)
    return buildFunc[id]
end

function getWorkTime(t)
    local sec = math.floor(t%60)
    t = math.floor(t/60)
    local min = t%60
    local hour = math.floor(t/60)
    local res = hour..":"..min..":"..sec
    return res
end
function getTimeStr(t)
    local sec = t % 60
    t = math.floor(t / 60)
    local min = t % 60
    local hour = math.floor(t / 60)
    local res = ""
    if hour ~= 0 then
        res = res..hour.."h "
    end
    if min ~= 0 then
        res = res..min.."m "
    end
    if (hour == 0 or min == 0) and sec ~= 0 then
        res = res..sec.."s"
    end
    return res
end
function getLen(t)
    local count = 0
    for k, v in pairs(t) do
        count = count+1
    end
    return count
end
function fixColor(c)
    temp = {}
    for k, v in ipairs(c) do
        temp[k] = v*255/100
    end
    return temp
end

function getNodeSca(n, box)
    local nSize = n:getContentSize()
    local sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    sca = math.max(math.min(1.5, sca), 0.5)
    return sca
end
function str(v)
    if type(v) == 'table' then
        return 'table'
    end
    if v == nil then
        return "nil"
    end
    if v == true then
        return 'true'
    elseif v == false then
        return 'false'
    end
    return ""..v
end

function appear(obj) 
    local function cb()
        obj:setVisible(true)
    end
    return callfunc(nil, cb, nil)
end

function disappear(obj)
    local function cb()
        obj:setVisible(false)
    end
    return callfunc(nil, cb, nil)
end
function sendReq(url, postData, handler, param, delegate)
    global.httpController:addRequest(url, postData, handler, param, delegate)
end
function addFly(bg, gain, cb, delegate)
    global.director.curScene.bg:addChild(FlyObject.new(bg, gain, cb, delegate).bg)
end
function toCol(c)
    return ccc3(c[1], c[2], c[3])
end
function addBanner(w)
    global.director.curScene.dialogController:addBanner(UpgradeBanner.new(w, {255, 255, 255}, nil, nil))
end
function Sign(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end

--BMFontLabel 数字使用这个动画
function numAct(sp, curVal, tarVal)
    print("numAct", curVal, tarVal)
    if tarVal == nil then
        return
    end
    local delta = math.max(math.floor(math.abs(tarVal-curVal)/20), 1)
    local up = Sign(tarVal-curVal)
    delta = delta*up
    local function changeV()
        curVal = curVal+delta
        if up == 1 and curVal >= tarVal then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        elseif up == -1 and curVal <= tarVal then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        elseif up == 0 then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        end
        sp:setString(str(curVal))
    end
    sp.numAction = repeatForever(sequence({callfunc(nil, changeV), delaytime(0.05)}))
    sp:runAction(sp.numAction)
end

function getSca(n, box)
    local nSize = getSize(n)
    local sca = 1
    if nSize[1] > box[1] or nSize[2] > box[2] then
        sca = math.min(box[1]/nSize[1], box[2]/nSize[2])
    end
    return sca
end
function fixY2(y)
    return global.director.designSize[2]-y
end


function getAnimation(name)
    local animation = CCAnimationCache:sharedAnimationCache():animationByName(name)
    return animation
end
--动画名称
--动画名字pattern
--动画开始frame
--动画结束frame
--动画frame 之间的 间隔
--动画总时间
--是否是 SpriteFrame  还是普通的Image
function createAnimationWithNum(name, format, t, isFrame, num)
    local animation = CCAnimationCache:sharedAnimationCache():animationByName(name)
    if not animation then
        animation = CCAnimation:create()
        --从SpriteFrameCache 中获取动画Frame
        if isFrame then
            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
            for k, v in ipairs(num) do
                animation:addSpriteFrame(cache:spriteFrameByName(string.format(format, v)))
            end
        else
            for k, v in ipairs(num) do
                animation:addSpriteFrame(cache:spriteFrameByName(string.format(format, v)))
            end
        end
        animation:setDelayPerUnit(t/#num)
        animation:setRestoreOriginalFrame(true)
        CCAnimationCache:sharedAnimationCache():addAnimation(animation, name)
    end
    return animation
end
function createAnimation(name, format, a,b,c,t, isFrame)
    local animation = CCAnimationCache:sharedAnimationCache():animationByName(name)
    if not animation then
        animation = CCAnimation:create()
        --从SpriteFrameCache 中获取动画Frame
        if isFrame then
            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
            for i=a, b, c do
                animation:addSpriteFrame(cache:spriteFrameByName(string.format(format, i)))
            end
        else
            for i=a, b, c do
                animation:addSpriteFrameWithFileName(string.format(format, i))
            end
        end
        animation:setDelayPerUnit(t*c/(b-a+c))
        animation:setRestoreOriginalFrame(true)
        CCAnimationCache:sharedAnimationCache():addAnimation(animation, name)
    end
    return animation
end
function getVS()
    return CCDirector:sharedDirector():getVisibleSize()
end
function setRotation(p, ang)
    p:setRotation(ang)
    return p
end

function jumpBy(t, x, y, hei, n)
    return CCJumpBy:create(t, ccp(x, y), hei, n)
end
function jumpTo(t, x, y, hei, n)
    return CCJumpTo:create(t, ccp(x, y), hei, n)
end
function changeTable(t, k, v)
    if t[k] == nil then
        t[k] = 0
    end
    t[k] = t[k]+v
end

--4321
function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
  return x % (p + p) >= p       
end
-- setbit(x, bit(3))
function setbit(x, p)
  return hasbit(x, p) and x or x + p
end
function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end


function bitor(x, y)
  local p = 1
  while p < x do p = p + p end
  while p < y do p = p + p end
  local z = 0
  repeat
    if p <= x or p <= y then
      z = z + p
      if p <= x then x = x - p end
      if p <= y then y = y - p end
    end
    p = p * 0.5
  until p < 1
  return z
end

function bitand(x, y)
  local p = 1; local z = 0; local limit = x > y and x or y
  while p <= limit do
    if hasbit(x, p) and hasbit(y, p) then
      z = z + p
    end
    p = p + p
  end
  return z
end

function delayCall(t, cb, par)
    local handler
    local function cancel()
        cb(par)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
    end
    handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(cancel, t, false)
end
function addCLayer(b)
    local l = CCLayer:create()
    b:addChild(l)
    return l
end
function addChild(p, c)
    p:addChild(c)
    return c
end

function setScaleX(s, v)
    s:setScaleX(v)
    return s
end
function addCmd(c)
    print("addCmd", c)
    global.director.curScene.dialogController:addCmd(c)
end
function fixX(w, x)
    return w-x
end

function jumpBy(t, x, y, hei, n)
    return CCJumpBy:create(t, ccp(x, y), hei, n)
end
function jumpTo(t, x, y, hei, n)
    return CCJumpTo:create(t, ccp(x, y), hei, n)
end
function setBatchColor(sp, col)
    local ch = sp:getChildren()
    local n = sp:getChildrenCount()
    print("setBatchColor num!!!!!!!!!! ", n)
    for i=0, n-1, 1 do
        local c = ch:objectAtIndex(i)
        setColor(c, col)
    end
end
function hexToDec(h)
    local r = tonumber(string.sub(h, 1, 2), 16)
    local g = tonumber(string.sub(h, 3, 4), 16)
    local b = tonumber(string.sub(h, 5, 6), 16)
    return {r, g, b}
end

function colorWords(param)
    local s = param.text
    local col = param.color
    local si = param.size
    local n = CCNode:create()
    local font = param.font
    local over = split(s, '>')
    local curX = 0
    local height = 0
    local totalHeight = 0
    local width = param.width or 999999
    --print("curWord", s)
    for i=1, #over, 1 do
        --print("split", over[i])
        --print("word x y", curX, totalHeight)
        if string.find(over[i], '<') ~= nil then
            local p = split(over[i], '<')
            if #p == 1 then
                local cv = string.sub(p[1], 1, 6)
                local l = ui.newTTFLabel({text=string.sub(p[1], 7), font=font, color=hexToDec(cv), size=si})
                n:addChild(l)
                setPos(setAnchor(l, {0, 0}), {curX, -totalHeight})
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            else
                if #p[1] > 0 then
                    local l = ui.newTTFLabel({text=p[1], font=font, color=col, size=si})
                    n:addChild(l)
                    setPos(setAnchor(l, {0, 0}), {curX, -totalHeight})
                    local lSize = l:getContentSize()
                    height = lSize.height
                    curX = curX+lSize.width
                end
                if p[2] ~= nil and #p[2] > 0 then
                    local cv = string.sub(p[2], 1, 6)
                    local l = ui.newTTFLabel({text=string.sub(p[2], 7), font=font, color=hexToDec(cv), size=si})
                    n:addChild(l)
                    setPos(setAnchor(l, {0, 0}), {curX, -totalHeight})
                    local lSize = l:getContentSize()
                    curX = curX+lSize.width
                    height = lSize.height
                end
            end
        else
            local l = ui.newTTFLabel({text=over[i], font=font, color=col, size=si})
            n:addChild(l)
            setPos(setAnchor(l, {0, 0}), {curX, -totalHeight})
            local lSize = l:getContentSize()
            curX = curX+lSize.width
            height = lSize.height
        end
        if curX >= width and i < #over then
            totalHeight = totalHeight+height
            curX = 0
        end
    end
    totalHeight = totalHeight+height
    n:setContentSize(CCSizeMake(curX, totalHeight))
    return n
end

--anchor 0 1
--CCNode 设置Anchor 没有用为什么？
--anchor 0 0
--相对于node 的0 0 位置来做的所以没有用处 gimp 里面使用colorLine 来标注这个字体
function colorLine(param)
    local s = param.text
    local col = param.color
    local si = param.size
    local words = split(s, '\n')
    local n = CCNode:create()
    local curHeight = 0
    local curWidth = 0
    local anchor = param.anchor or {0, 1}
    for k, v in ipairs(words) do
        --print("colorLine", v)
        local temp = colorWords({text=v, color=col, size=si, width=param.width, font=param.font})
        n:addChild(temp)
        setPos(setAnchor(temp, anchor), {0, -curHeight})
        local sz = temp:getContentSize()
        curHeight = curHeight+sz.height
        curWidth = math.max(curWidth, sz.width)
    end
    n:setContentSize(CCSizeMake(curWidth, curHeight))
    return n
end

function setProNum(banner, n, max)
    if n <= 0 then
        banner:setVisible(false)
    else
        banner:setVisible(true)
        local wid = math.floor((n/max)*339)
        wid = math.max(0, wid)
        setContentSize(banner, {wid, 29})
    end
end
function newProNum(banner, n, max)
    if n <= 0 then
        banner:setVisible(false)
    else
        banner:setVisible(true)
        local wid = math.floor((n/max)*183)
        wid = math.max(0, wid)
        local r = CCRectMake(0, 0, wid, 20)
        banner:setTextureRect(r)
        --setContentSize(banner, {wid, 29})
    end
end

function setTexOrDis(sp, n)
    if string.sub(n, 1, 1) == '#' then
        setTexture(sp, string.sub(n, 2))
        return sp
    end

    local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(n)
    if tex then
        sp:setDisplayFrame(tex)
    else
        setTexture(sp, n)
    end
    return sp
end

function setDisplayFrame(sp, n)
    print("setDisplayFrame !!!!!", sp, n)
    local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(n)
    sp:setDisplayFrame(tex)
    return sp
end
function setFlipX(sp, f)
    sp:setFlipX(f)
    return sp
end
function getScaleY(sp)
    return sp:getScaleY()
end
function getScaleX(sp)
    return sp:getScaleX()
end

function getScale(s)
    return s:getScale()
end

--只考虑 0 1 两个touchId
function updateTouchTable(a, b)
    for k, v in pairs(b) do
        if k < 2 then
            if a[k] == nil then
                a.count = a.count+1
            end
            a[k] = v
        end
    end
end
function clearTouchTable(a, b)
    for k, v in pairs(b) do
        if a[k] ~= nil then
            a[k] = nil
            a.count = a.count-1
        end
    end
end
function copyTouchTable(a)
    local temp = {}
    for k, v in pairs(a) do
        temp[k] = v
    end
    return temp
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

function copyTable(b)
    local temp = {}
    for k, v in pairs(b) do
        temp[k] = v
    end
    return temp
end
function pauseNode(n)
    local director = CCDirector:sharedDirector()
    local act = director:getActionManager()
    act:pauseTarget(n)
end
function resumeNode(n)
    local director = CCDirector:sharedDirector()
    local act = director:getActionManager()
    act:resumeTarget(n)
end

function createSprite(n)
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    local f = sf:spriteFrameByName(n)
    if f ~= nil then
        return CCSprite:createWithSpriteFrameName(n)   
    else
        return CCSprite:create(n)
    end
end
function createSpriteFrame(tex, rect, name)
    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    local f = ca:spriteFrameByName(name)
    if f ~= nil then
        return f
    end
    local r = rect 
    local left = CCSpriteFrame:createWithTexture(tex, r)
    ca:addSpriteFrame(left, name)
    return left
end
function interSet(a, b)
    local temp = {}
    local count = 0
    for k, v in pairs(a) do
        if b[k] ~= nil then
            temp[k] = true
            count = count+1
        end
    end
    temp['count'] = count
    return temp
end
function setToArr(a)
    local temp = {}
    for k, v in pairs(a) do
        table.insert(temp, k)
    end
    return temp
end
function printTable(t)
    local s = ''
    for k, v in ipairs(t) do
        s = s..str(k)..','..str(v)..','
    end
    return s
end
function getContentSize(sp)
    local sz = sp:getContentSize()
    return {sz.width, sz.height}
end


function addEquipAttr(old, edata)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    for k, v in ipairs(allAtt) do
        old[v] = old[v]+edata[v]
    end
end

function calAttr(id, level, equip)
    local data = Logic.people[id]
    local temp = {health=data.health+data.healthAdd*level, labor=data.labor+data.laborAdd*level, attack=math.floor((data.brawn+data.brawnAdd*level)/2),
    defense=0, shoot=data.shoot+data.shootAdd*level, 
    brawn=data.brawn+data.brawnAdd*level}
    if equip ~= nil then
        if equip.weapon ~= nil then
            addEquipAttr(temp, Logic.equip[equip.weapon])
        end
        if equip.head ~= nil then
            addEquipAttr(temp, Logic.equip[equip.head])
        end
        if equip.body ~= nil then
            addEquipAttr(temp, Logic.equip[equip.body])
        end
    end
    local skill = getPeopleSkill(id, level)
    if skill == 0 then
    else
        local sdata = Logic.allSkill[skill]
        temp.attack = temp.attack+sdata.attack
        temp.defense = temp.defense+sdata.defense
        --print("skill attr")
    end
    return temp
end


function centerTemp(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local cx, cy = ds[1]/2, ds[2]/2
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca
    print("centerTemp", sca, nx, ny, vs.width, vs.height, ds[1], ds[2])

    setScale(sp, sca)
    setPos(sp, {nx, ny})
end

function centerUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local cx, cy = ds[1]/2, ds[2]/2
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(sp.bg, sca)
    setPos(sp.bg, {nx, ny})
    if sp.cl ~= nil then
        sp.cl:setContentSize(CCSizeMake(sp.listSize.width, sp.HEIGHT*sca))
    end
end

function centerTop(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local cx = ds[1]/2
    local nx = vs.width/2-cx*sca
    local ny = vs.height-ds[2]*sca
    setScale(sp, sca)
    setPos(sp, {nx, ny})
end
function rightBottomUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local nx = vs.width-ds[1]*sca
    setScale(sp, sca)
    setPos(sp, {nx, 0})
end
function leftBottomUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    setScale(sp, sca)
end
function leftCenterUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    setScale(sp, sca)

    local cy = ds[2]/2
    local ny = vs.height/2-cy*sca
    setPos(sp, {0, ny})
end

function leftTopUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    setScale(sp, sca)
    local ny = vs.height-ds[2]*sca
    setPos(sp, {0, ny})
end

--弹出的子菜单 显示向右侧
function rightTopUI(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local nx = vs.width-ds[1]*sca
    local ny = vs.height-ds[2]*sca
    setScale(sp, sca)
    setPos(sp, {nx, ny})
end
function centerBottom(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    setScale(sp, sca)
    local cx = ds[1]/2
    local nx = vs.width/2-cx*sca
    setPos(sp, {nx, 0})
end
--左右居中 bottom Y 比例
function centerYRate(sp)
    local vs = getVS()
    local ds = global.director.designSize
    local scaY = math.min(vs.width/ds[1], vs.height/ds[2])
    local scaX = 1
    setScaleY(sp, scaY)
    local cx = ds[1]/2
    local nx = vs.width/2-cx*scaX
    setPos(sp, {nx, 0})
end


function dictToTable(t)
    local temp = {}
    for k, v in pairs(t) do
        table.insert(temp, {k, v})
    end
    return temp
end
function tableToDict(t)
    local temp = {}
    for k, v in ipairs(t) do
        temp[v[1]] = v[2]
    end
    return temp
end

function concateTable(a, b)
    local temp = {}
    for k, v in ipairs(a) do
        table.insert(temp, v)
    end
    for k, v in ipairs(b) do
        table.insert(temp, v)
    end
    return temp
end

function lerp(a, b, wei)
    if type(a) == 'table' then
        local temp = {}
        for i=1, #a, 1 do
            temp[i] = a[i]*(1-wei)+b[i]*wei
        end
        return temp
    end
    return a*(1-wei)+b*wei
end

function dictKeyToNum(d)
    local temp = {}
    for k, v in pairs(d) do
        temp[tonumber(k)] = v
    end
    return temp
end
function closeDialog()
    global.director:popView()
end
function initPlist()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("buildOne.plist")
    sf:addSpriteFramesWithFile("buildTwo.plist")
    sf:addSpriteFramesWithFile("buildThree.plist")
    sf:addSpriteFramesWithFile("buildFour.plist")
    sf:addSpriteFramesWithFile("skillOne.plist")
    sf:addSpriteFramesWithFile("catOne.plist")
    sf:addSpriteFramesWithFile("goodsOne.plist")
    sf:addSpriteFramesWithFile("equipOne.plist")
    sf:addSpriteFramesWithFile("catCut.plist")
    sf:addSpriteFramesWithFile("catHeadOne.plist")
end

function getOrder(v)
    local ord = 0
    while v > 1 do
        v = math.floor(v/2)
        ord = ord+1
    end
    return ord
end

function createSequence(act)
    local arr = CCArray:create()
    for k, v in ipairs(act) do
        arr:addObject(v)
    end
    return CCSequence:create(arr)
end

