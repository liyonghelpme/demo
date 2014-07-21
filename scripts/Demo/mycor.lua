--MOVE_SPEED = 50

function waitForTime(self, t)
    local passTime = 0
    while passTime < t do
        passTime = passTime+self.diff
        coroutine.yield()
    end
end

function setZord(self)
    local p = getPos(self.bg)
    self.bg:setZOrder(10000-p[2])
end
