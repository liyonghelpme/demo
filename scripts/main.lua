
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end
require "util"
--require("GameConfig")
require("Event")
--require("app.BattleEx")
local function main()
	require("framework.init")
	require("Global.INCLUDE")
	print("before init ", class)
	--require("app.MyApp").new():run()
	require "Demo.BattleScene"
	CCFileUtils:sharedFileUtils():addSearchPath("res/")
	
	local director = CCDirector:sharedDirector()

	local sc = BattleScene.new()
	--director:runWithScene(sc)
	global.director:runWithScene(sc)
end


--xpcall 可以保存 错误发生时候的 堆栈信息
xpcall(main, __G__TRACKBACK__)
