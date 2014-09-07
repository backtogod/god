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

function ViewInterface:WaitRoundStartFinish(min_wait_time, round, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	print("wait round start display")
	return view_scene:RoundStart(min_wait_time, round, call_back)
end

function ViewInterface:WaitWatchEnd(min_wait_time, call_back)
	Event:FireEvent("GAME.START_WATCH")
	local view_scene = SceneMgr:GetCurrentScene()
	view_scene:StartWatch(
		min_wait_time,
		function()
			Event:FireEvent("GAME.END_WATCH")
			if call_back then
				call_back()
			end
		end
	)
end

function ViewInterface:WaitMoveComplete(chess, logic_x, logic_y, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:MoveChessToPosition(chess, logic_x, logic_y, call_back)
end

function ViewInterface:WaitChangeStateComplete(chess, state, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:ChangeChessState(chess, state, call_back)
end

function ViewInterface:WaitBattleFinish(min_wait_time, call_back)
	local view_scene = SceneMgr:GetCurrentScene()
	print("wait battle finish")
	return view_scene:StartBattle(min_wait_time, call_back)
end