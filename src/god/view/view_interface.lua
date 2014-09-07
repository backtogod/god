--=======================================================================
-- File Name    : view_interface.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Sep  7 10:52:37 2014
-- Description  : view interface to model
-- Modify       :
--=======================================================================
if not ViewInterface then
	ViewInterface = {}
end

function ViewInterface:WaitRoundStartFinish(call_back)
	-- body
end

function ViewInterface:WaitWatchEnd(call_back)
	
end

function ViewInterface:WaitMoveComplete(chess, logic_x, logic_y, call_back)
	local map = GameStateMachine:GetActiveMap()
	local view_scene = SceneMgr:GetCurrentScene()
	view_scene:MoveChessToPosition(map, chess:GetId(), logic_x, logic_y, call_back)
end

function ViewInterface:WaitTransformComplete(call_back)
	-- body
end

function ViewInterface:WaitBattleFinish(call_back)
	-- body
end