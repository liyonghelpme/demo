ui = {}
function ui.newEditBox(params)
    local imageNormal = params.image
    local imagePressed = params.imagePressed or params.image
    local imageDisabled = params.imageDisabled or params.image
    local listener = params.listener
    local listenerType = type(listener)
    local tag = params.tag
    local x = params.x
    local y = params.y
    local size = params.size
    local delegate = params.delegate
    if type(size) == "table" then
        size = CCSizeMake(size[1], size[2])
    end

    if type(imageNormal) == "string" then
        imageNormal = display.newScale9Sprite(imageNormal)
    end
    if type(imagePressed) == "string" then
        imagePressed = display.newScale9Sprite(imagePressed)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newScale9Sprite(imageDisabled)
    end

    local editbox = CCEditBox:create(size, imageNormal, imagePressed, imageDisabled)

    if editbox then
        editbox:registerScriptEditBoxHandler(function(event, object)
            --print("editBox", event)
            if listenerType == "table" or listenerType == "userdata" then
                if event == "began" then
                    listener:onEditBoxBegan(object)
                elseif event == "ended" then
                    listener:onEditBoxEnded(object)
                elseif event == "return" then
                    listener:onEditBoxReturn(object)
                elseif event == "changed" then
                    listener:onEditBoxChanged(object)
                end
            elseif listenerType == "function" then
                if delegate ~= nil then
                    listener(delegate, event, object)
                else
                    listener(event, object)
                end
            end
        end)
        if x and y then editbox:setPosition(x, y) end
    end
    editbox:setTouchPriority(kCCMenuHandlerPriority)

    return editbox
end
ui.DEFAULT_TTF_FONT      = "Arial"
ui.DEFAULT_TTF_FONT_SIZE = 24

ui.TEXT_ALIGN_LEFT    = kCCTextAlignmentLeft
ui.TEXT_ALIGN_CENTER  = kCCTextAlignmentCenter
ui.TEXT_ALIGN_RIGHT   = kCCTextAlignmentRight
ui.TEXT_VALIGN_TOP    = kCCVerticalTextAlignmentTop
ui.TEXT_VALIGN_CENTER = kCCVerticalTextAlignmentCenter
ui.TEXT_VALIGN_BOTTOM = kCCVerticalTextAlignmentBottom


function ui.newBMFontLabel(params)
    assert(type(params) == "table",
           "[framework.client.ui] newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or ui.TEXT_ALIGN_CENTER
    local color      = params.color or display.COLOR_WHITE
    if type(color) == "table" then
        color = toCol(color)
    end
    if font == nil then
        font = "bound.fnt"
    end
    local x, y      = params.x, params.y
    local size      = params.size or 20
    assert(font ~= nil, "ui.newBMFontLabel() - not set font")
    local baseSize = 35
    local k = size/baseSize
    local label = CCLabelBMFont:create(text, font, kCCLabelAutomaticWidth, textAlign)
    label:setScale(k)
    if not label then return end
    label:setColor(color)
    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end

    return label
end

function ui.newTTFLabel(params)
    local text       = tostring(params.text)
    local font       = params.font or ui.DEFAULT_TTF_FONT
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    if type(color) == "table" then
        color = toCol(color)
    end
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local x, y       = params.x, params.y
    local dimensions = params.dimensions
    if type(dimensions) == 'table' then
        dimensions = CCSizeMake(dimensions[1], dimensions[2])
    end
    local edgeWidth = params.edgeWidth
    local shadowColor = params.shadowColor or {0, 0, 0}
    --print("shadow Color is", simple.encode(shadowColor))

    local label
    --android ios 平台字体处理方法不同
    --[[
    local fontName = 'fonts/fang.ttf'
    if not ANDROID then
        --fontName = 'FZDHTJW--GB1-0'
        fontName = 'fang'
    end
    --]]
    local fontName = ''
    if dimensions then
        label = CCLabelTTF:create(text, fontName, size, dimensions, textAlign, textValign)
    else
        label = CCLabelTTF:create(text, fontName, size)
    end
    local shadowWord
    if font == 'f2' then
        if edgeWidth == nil then
            edgeWidth = 2
        end
        --调整阴影的padding 就可以改变切割了  padding＋5
        --label:enableStroke(ccc3(0, 0, 0), edgeWidth, true)
        local update = true
        --if color == nil then
        --    update = true
        --end
        --设定特殊的阴影颜色
        if shadowColor[1] > 0 or shadowColor[2] > 0 or shadowColor[3] > 0 then
            local lab = ui.newTTFLabel({text=text, color=shadowColor, size=size})
            --enableShadow(lab, CCSizeMake(1, 2), 1, 1, true, shadowColor[1], shadowColor[2], shadowColor[3])
            label:addChild(lab, -1)
            setAnchor(setPos(lab, {1, -2}), {0, 0})
            ----print("set shadow Color")
            shadowWord = lab
        else
            if ANDROID == true then 
                enableShadow(label, CCSizeMake(1, -2), 1, 1, update, shadowColor[1], shadowColor[2], shadowColor[3])
            else
                enableShadow(label, CCSizeMake(1, -2), 1, 1, true, shadowColor[1], shadowColor[2], shadowColor[3])
                --不支持
                --enableShadow(label, CCSizeMake(1, 2), 1, 1, update)
            end
            ----print("set normal shadow color")
        end
    end

    --文字的FillColor 和ShadowColor 不同
    if label then
        label:setColor(color)
        --setFontFillColor(label, color, true)
        function label:realign(x, y)
            if textAlign == ui.TEXT_ALIGN_LEFT then
                label:setPosition(math.round(x + label:getContentSize().width / 2), y)
            elseif textAlign == ui.TEXT_ALIGN_RIGHT then
                label:setPosition(x - math.round(label:getContentSize().width / 2), y)
            else
                label:setPosition(x, y)
            end
        end

        if x and y then label:realign(x, y) end
    end
    --替换旧的setS函数tring
    if shadowWord ~= nil then
        local oldSet = label.setString
        function label:setString(s)
            oldSet(label, s)
            shadowWord:setString(s)
        end
    end

    return label, shadowWord
end
--text
--delegate
--callback
--size
--image
--conSize button size

--{image=, conSize={}, delegate=self, callback=self.xxx, param=?}
function ui.newButton(params)
    local obj = {}
    local lay = CCLayer:create()
    local sprOr9 = params.spr or true
    local sp
    if sprOr9 then
        sp = CCSprite:create(params.image)
    else
        sp = display.newScale9Sprite(params.image)
    end
    lay:addChild(sp)
    --lay:ignoreAnchorPointForPosition(true)
    obj.bg = lay
    local sz = sp:getContentSize()
    lay:setContentSize(sz)
    lay:setAnchorPoint(ccp(0, 0))
    sp:setAnchorPoint(ccp(0.5, 0.5))
    local text = params.text
    local size = params.size or 18
    local conSize = params.conSize
    local priority = params.priority
    local col = params.color
    local font = params.font
    local needScale = true
    if params.needScale ~= nil then
        needScale = params.needScale
    end
    local touchColor = params.touchColor
    local shadowColor = params.shadowColor

    local spSize = {sz.width, sz.height}


    function obj:touchBegan(x, y)
        local p = sp:convertToNodeSpace(ccp(x, y))
        local ret = checkIn(p.x, p.y, sz)

        if ret then
            local scaX = getScaleX(lay)
            local scaY = getScaleY(lay)
            self.scaX = scaX
            self.scaY = scaY
            if needScale then
                setScaleY(setScaleX(lay, 0.8), 0.8)
            end
            if touchColor ~= nil then
                setColor(obj.text, touchColor)
            end

            if params.touchBegan ~= nil then
                params.touchBegan(params.delegate, params.param)
            else
                if needScale then
                else
                    local tempSp = CCSprite:create(params.image)
                    lay:addChild(tempSp)
                    local function removeTemp()
                        removeSelf(tempSp)
                    end
                    local anchor = sp:getAnchorPoint()
                    tempSp:setAnchorPoint(anchor)
                    setSize(tempSp, spSize)
                    tempSp:runAction(sequence({spawn({scaleby(0.5, 1.2, 1.2), fadeout(0.5)}), callfunc(nil, removeTemp)}))
                end
            end
        end
        return ret
    end
    function obj:touchMoved(x, y)
    end
    
    function obj:setParam(p)
        params.param = p
    end

    function obj:touchEnded(x, y)
        if needScale then
            setScaleY(setScaleX(lay, 1), 1)
        end
        if touchColor ~= nil then
            setColor(obj.text, col)
        end
        if params.callback ~= nil then
            params.callback(params.delegate, params.param)
        end
    end
    function obj:setCallback(cb)
        params.callback = cb
    end
    function obj:setAnchor(x, y)
        --lay 不能AnchorPoint 否则scale的时候就有问题
        --lay:setAnchorPoint(ccp(x, y))
        sp:setAnchorPoint(ccp(x, y))
        return obj
    end
    function obj:setContentSize(w, h)
        spSize = {w, h}
        lay:setContentSize(CCSizeMake(w, h))
        if sprOr9 then
            setSize(sp, {w, h})
        else
            setContentSize(sp, {w, h})
        end
    end
    obj.sp = sp
    registerTouch(obj, priority)
    if conSize ~= nil then
        obj:setContentSize(conSize[1], conSize[2])
    end
    if text ~= nil then
        obj.text, obj.shadowWord = ui.newTTFLabel({text=text, font=font, size=size, color=col, shadowColor=shadowColor})
        setAnchor(addChild(obj.bg, obj.text), {0.5, 0.5})
    end
    obj:setAnchor(0.5, 0.5)
    return obj
end

function ui.newTouchLayer(params)
    local obj = {}
    local lay = CCLayer:create()
    obj.bg = lay
    lay:setAnchorPoint(ccp(0, 0))
    lay:setContentSize(CCSizeMake(params.size[1], params.size[2]))
    local sz = lay:getContentSize()
    function obj:touchBegan(x, y)
        local xy = lay:convertToNodeSpace(ccp(x, y))
        if checkIn(xy.x, xy.y, sz) then
            params.touchBegan(params.delegate, x, y)
            return true
        end
        return false
    end
    function obj:touchMoved(x, y)
        params.touchMoved(params.delegate, x, y)
    end
    function obj:touchEnded(x, y)
        params.touchEnded(params.delegate, x, y)
    end
    registerTouch(obj)
    return obj
end
