--=======================================================================
-- File Name    : robot.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/2 20:31:45
-- Description  : ai robot
-- Modify       : 
--=======================================================================
if not Robot then
	Robot = ModuleMgr:NewModule("robot")
end

Robot:DeclareListenEvent("GAME.ACTION_START", "OnActionStart")
Robot:DeclareListenEvent("GAME.END_WATCH", "OnEndWatch")

function Robot:_Uninit()
	return 1
end

function Robot:_Init()
	return 1
end

function Robot:OnActionStart(round)
	-- body
end

function Robot:OnEndWatch()
	-- body
end