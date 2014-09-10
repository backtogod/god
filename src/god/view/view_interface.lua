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

function ViewInterface:WaitMoveComplete(chess, x, y, call_back)
	assert(GameStateMachine:IsWatching() == 1)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:MoveChessToPosition(chess, x, y, call_back)
end

function ViewInterface:WaitChangeStateComplete(chess, state, call_back)
	assert(GameStateMachine:IsWatching() == 1)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:ChangeChessState(chess, state, call_back)
end

function ViewInterface:WaitRoundStartFinish(min_wait_time, max_wait_time, call_back)
	assert(GameStateMachine:IsWatching() == 1)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:StartRoundStart(min_wait_time, max_wait_time, call_back)
end

function ViewInterface:WaitBattleFinish(min_wait_time, max_wait_time, call_back)
	assert(GameStateMachine:IsWatching() == 1)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:StartBattle(min_wait_time, max_wait_time, call_back)
end

function ViewInterface:WaitChessAttack(chess, target_chess, call_back)
	assert(GameStateMachine:IsWatching() == 1)
	local view_scene = SceneMgr:GetCurrentScene()
	return view_scene:ChessAttack(chess, target_chess, call_back)
end