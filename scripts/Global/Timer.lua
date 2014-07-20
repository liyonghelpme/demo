Timer = {}
Timer.now = 0
--bug 游戏退出之后 就不会计时 了
--now 就存在问题
function Timer.update(diff)
    Timer.now = Timer.now+diff
end

Timer.updateFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(Timer.update, 0, false)


