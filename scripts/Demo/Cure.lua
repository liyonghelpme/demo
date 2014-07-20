Cure = class()
function Cure:ctor(tar)
    self.target = tar
    self.bg = CCNode:create()
    
    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    spc:addSpriteFramesWithFile("skill_6.plist")
    local ani = createAnimation("cure", "gxyuanjian-hd_%d.png", 1, 6, 1, 0.5, true) 

    self.changeDirNode = createSprite("gxyuanjian-hd_1.png") 
    self.changeDirNode:runAction(CCAnimate:create(ani))
    addChild(self.bg, self.changeDirNode)

    local function doCure()
        self.target:doCure()
    end
    --register function functionIndex in stack and functionID global register table
    --rid to function handler
    --never clear function handler? for once
    self.bg:runAction(sequence({delaytime(0.5), callfunc(nil, doCure), callfunc(nil, removeSelf, self.bg)}))
    
    setScale(self.changeDirNode, 0.5)
end
