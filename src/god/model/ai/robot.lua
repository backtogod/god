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

Robot:DeclareListenEvent("GAME_STATE.CHANGE", "OnGameState")

function Robot:_Uninit()
	return 1
end

function Robot:_Init()
	return 1
end

function Robot:OnGameState(state)
	if state ~= GameStateMachine.STATE_ENEMY_OPERATE then
		return
	end
	local can_move_list = {}
	local can_pick_list = {}
	for logic_x = 1, Def.MAP_WIDTH do
		if EnemyMap:GetCell(logic_x, 1) >= 0 then
			can_pick_list[#can_pick_list + 1] = logic_x
		end
		if EnemyMap:GetCell(logic_x, Def.MAP_HEIGHT) <= 0 then
			can_move_list[#can_move_list + 1] = logic_x
		end
	end

	local pick_x = math.random(1, #can_pick_list)
	print("Robot pick", pick_x)
	-- local ret_code, result = CommandCenter:ReceiveCommand({"PickChess", pick_x})
end