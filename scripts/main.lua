
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end
require "util"
require("GameConfig")
require("Event")
require("app.BattleEx")
local function main()
	require("app.MyApp").new():run()
end

--xpcall 可以保存 错误发生时候的 堆栈信息
xpcall(main, __G__TRACKBACK__)
