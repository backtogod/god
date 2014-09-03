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
	self:Log(Log.LOG_INFO, "ReceiveCommand [%s] command(%s %s %s %s %s)",
		GameStateMachine.DEBUG_DISPLAY[state], command[1], tostring(command[2]), tostring(command[3]), tostring(command[4]), tostring(command[5]))
	return Lib:SafeCall({self.ExecuteCommand, self, state, command})
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

function CommandCenter:_PickChess(map, logic_x)
	for logic_y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = map:GetCell(logic_x, logic_y)
		if chess_id and chess_id > 0 then
			local logic_chess = map.obj_pool:GetById(chess_id)
			if logic_chess:TryCall("GetState") == Def.STATE_NORMAL then
				PickHelper:Pick(chess_id, logic_x, logic_y)
				return chess_id
			end
		end
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
	if logic_y <= 0 then
		return 0
	end
	local logic_chess = map.obj_pool:GetById(id)
	local event_name = logic_chess:GetClassName() .. ".SET_DISPLAY_POSITION"
	Event:FireEvent(event_name, id, logic_x, logic_y)
	return 1
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

function CommandCenter:_SpawnChess( ... )
	-- body
end
function CommandCenter:_UseSkill( ... )
	-- body
end
function CommandCenter:_EndAction( ... )
	-- body
end

CommandCenter.COMMAND_LIST = {
	PickChess = CommandCenter._PickChess,
	CancelPickChess = CommandCenter._CancelPickChess,
	TryMovePickChess = CommandCenter._TryMovePickChess,
	TryDropChess = CommandCenter._TryDropChess,
	SpawnChess = CommandCenter._SpawnChess,
	UseSkill = CommandCenter._UseSkill,
	EndAction = CommandCenter._EndAction,
}