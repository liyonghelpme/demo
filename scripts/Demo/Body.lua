Body = class()
function Body:ctor(s, hid)
    self.scene = s
    self.bg = CCNode:create()

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("userDogface_%d_3/userDogface_%d_3.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("userDogface_%d_3/userDogface_%d_3.json", hid, hid)
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("userDogface_"..hid.."_3")
    addChild(self.bg, self.changeDirNode)
    
end
