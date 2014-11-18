--=======================================================================
-- File Name    : command_center.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/3 12:36:06
-- Description  : handle command
-- Modify       : 
--=======================================================================

if not CommandCenter then
	CommandCenter = ModuleMgr:NewModule("CommandCenter")
end

function CommandCenter:_Uninit( ... )
	-- body
	return 1
end

function CommandCenter:_Init( ... )
	self:AddLogNode(Log.LOG_DEBUG)
	return 1
end

function CommandCenter:Log(log_level, fmt, ...)
	local log_node = self:GetChild("log")
	return log_node:Print(log_level, fmt, ...)
end

function CommandCenter:ReceiveCommand(command)
	local state = GameStateMachine:GetState()
	local command_name = command[1]
	self:Log(Log.LOG_DEBUG, "ReceiveCommand [%s] command(%s %s %s %s %s)",
		GameStateMachine.DEBUG_DISPLAY[state], command_name, tostring(command[2]), tostring(command[3]), tostring(command[4]), tostring(command[5]))
	local ret_code, result = Lib:SafeCall({self.ExecuteCommand, self, state, command})
	Event:FireEvent("COMMAND.EXECUTE_COMPLETE", command_name, ret_code, result)
	return ret_code, result
end

function CommandCenter:ExecuteCommand(state, command)
	local map = GameStateMachine:GetActiveMap()
	local command_name = command[1]
	local exec_fun = self.COMMAND_LIST[command_name]
	if not exec_fun then
		assert(false)
		return
	end
	return exec_fun(self, map, unpack(command, 2))
end

function CommandCenter:_PickChess(map, logic_x, logic_y)
	local chess_id, pick_y = PickRule:GetCanPick(map, logic_x)
	if logic_y and pick_y > logic_y then
		return
	end
	if chess_id then
		local logic_chess = map.obj_pool:GetById(chess_id)
		PickHelper:Pick(chess_id, logic_x, pick_y)
		return chess_id
	end
end

function CommandCenter:_DestoryChesss(map, logic_x, logic_y)
	local chess_id = map:GetCell(logic_x, logic_y)
	if chess_id and chess_id > 0 then
		local logic_chess = map.obj_pool:GetById(chess_id)
		assert(logic_chess)
		map.obj_pool:Remove(chess_id)
		ActionMgr:ResetCombo()
		ActionMgr:OnCombo()
		ActionMgr:ChangeRestRoundNum(-1)
		ViewInterface:WaitWatchEnd(0.5, 
			function()
				if ActionMgr:GetRestRoundNum() > 0 then
					Event:FireEvent("GAME.AI_ACTIVE")
				else
					ActionMgr:NextRound()
				end
			end
		)
		Mover:RemoveMapHole(map)
		return 1
	end
end

function CommandCenter:_CancelPickChess(map, id)
	PickHelper:CancelAll()
end

function CommandCenter:_TryMovePickChess(map, id, logic_x)
	local logic_y = Mover:GetMoveablePosition(map, logic_x, 
		function(check_chess_id)
			if (check_chess_id and check_chess_id <= 0) or check_chess_id == id then
				return 1
			end
			return 0
		end
	)
	local logic_chess = map.obj_pool:GetById(id)
	local event_name = logic_chess:GetClassName() .. ".SET_DISPLAY_POSITION"
	if logic_y > 0 then
		Event:FireEvent(event_name, id, logic_x, logic_y)
		return 1
	else
		Event:FireEvent(event_name, id, logic_chess.x, logic_chess.y)
		return 0
	end
end

function CommandCenter:_TryDropChess(map, id, logic_x)
	local logic_y = Mover:GetMoveablePosition(map, logic_x,
		function(check_chess_id)
			if (check_chess_id and check_chess_id <= 0) or check_chess_id == id then
				return 1
			end
			return 0
		end
	)
	if logic_y <= 0 then
		return 0
	end
	PickHelper:DropAll(logic_x, logic_y)
	return 1
end

function CommandCenter:_SpawnChess(map, id_list)
	ActionMgr:ResetCombo()
	ActionMgr:ChangeRestRoundNum(-1)
	ViewInterface:WaitWatchEnd(0.5, 
		function()
			if ActionMgr:GetRestRoundNum() > 0 then
				Event:FireEvent("GAME.AI_ACTIVE")
			else
				ActionMgr:NextRound()
			end
		end
	)
	ChessSpawner:SpawnChess(map, id_list)
end
function CommandCenter:_UseSkill(map)
	-- body
end
function CommandCenter:_EndAction(map)
	--TODO 
	ActionMgr:NextRound()
end

CommandCenter.COMMAND_LIST = {
	PickChess = CommandCenter._PickChess,
	DestoryChess = CommandCenter._DestoryChesss,
	CancelPickChess = CommandCenter._CancelPickChess,
	TryMovePickChess = CommandCenter._TryMovePickChess,
	TryDropChess = CommandCenter._TryDropChess,
	SpawnChess = CommandCenter._SpawnChess,
	UseSkill = CommandCenter._UseSkill,
	EndAction = CommandCenter._EndAction,
}