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
	local view_scene = SceneMgr:GetCurrentScene()
	view_scene:StartWatch(call_back)
end

function ViewInterface:WaitMoveComplete(chess, logic_x, logic_y, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:MoveChessToPosition(chess, logic_x, logic_y, call_back)
end

function ViewInterface:WaitChangeStateComplete(chess, state, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:ChangeChessState(chess, state, call_back)
end

function ViewInterface:WaitBattleFinish(call_back)
	-- body
end