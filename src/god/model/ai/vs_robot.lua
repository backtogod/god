--=======================================================================
-- File Name    : vs_robot.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/2 20:31:45
-- Description  : ai robot
-- Modify       : 
--=======================================================================
if not VSRobot then
	VSRobot = ModuleMgr:NewModule("vs_robot")
end

VSRobot:DeclareListenEvent("GAME.AI_ACTIVE", "OnAIActive")
VSRobot:DeclareListenEvent("GAME.ACTION_OVER", "OnActionEnd")
VSRobot:DeclareListenEvent("GAME.ACTION_START", "OnActionStart")

function VSRobot:_Uninit()
	ModuleMgr:UnregisterUpdate(self:GetClassName())
	return 1
end

function VSRobot:_Init()
	return 1
end

function VSRobot:CanWork()
	if GameStateMachine:IsInEnemyAction() == 1 then
		return 1
	end
end

function VSRobot:OnActionStart()
	if self:CanWork() == 1 then
		ModuleMgr:RegisterUpdate(self:GetClassName(), "OnActive")
	end
end

function VSRobot:OnActionEnd()
	if self:CanWork() == 1 then
		ModuleMgr:UnregisterUpdate(self:GetClassName())
	end
end

function VSRobot:OnActive(frame)
	if frame % 1 == 0 then
		if self.pick_id then
			if self.drop_x == self.move_x then
				local pick_id = self.pick_id
				local drop_x = self.drop_x
				local pick_x = self.pick_x
				self.pick_x = nil
				self.pick_id = nil
				self.drop_x = nil
				self.move_x = nil
				if drop_x == pick_x then
					local ret_code, result = CommandCenter:ReceiveCommand({"CancelPickChess", pick_id})
					return self:OnAIActive()
				else
					local ret_code, result = CommandCenter:ReceiveCommand({"TryDropChess", pick_id, drop_x})
				end
			elseif self.drop_x > self.move_x then
				self.move_x = self.move_x + 1
				local ret_code, result = CommandCenter:ReceiveCommand({"TryMovePickChess", self.pick_id, self.move_x})
			elseif self.drop_x < self.move_x then
				self.move_x = self.move_x - 1
				local ret_code, result = CommandCenter:ReceiveCommand({"TryMovePickChess", self.pick_id, self.move_x})
			end
		end
	end
end

function VSRobot:ThinkAndOperate()
	if ActionMgr:GetRestRoundNum() <= 0 then
		return
	end
	if GameStateMachine:IsWatching() == 1 then
		return
	end
	print("............Start Think")
	local map = GameStateMachine:GetActiveMap()
	local can_move_list = {}
	local can_pick_list = {}
	assert(not self.pick_id)
	for logic_x = 1, Def.MAP_WIDTH do
		local chess_id = PickRule:GetCanPick(map, logic_x)
		if chess_id then
			can_pick_list[#can_pick_list + 1] = logic_x
		end
		if PickRule:CanDrop(map, logic_x, logic_y) == 1 then
			can_move_list[#can_move_list + 1] = logic_x
		end
	end

	local pick_x = can_pick_list[math.random(1, #can_pick_list)]
	local ret_code, pick_id = CommandCenter:ReceiveCommand({"PickChess", pick_x})

	local drop_x = can_move_list[math.random(1, #can_move_list)]
	local loop_count = 1
	while drop_x == pick_x and loop_count < 64 do
		drop_x = can_move_list[math.random(1, #can_move_list)]
		loop_count = loop_count + 1
	end
	self.pick_x = pick_x
	self.pick_id = pick_id
	self.move_x = pick_x
	self.drop_x = drop_x
	print("............Think Result", pick_id, "Move", pick_x, drop_x)
end

function VSRobot:OnAIActive()
	local state = GameStateMachine:GetState()
	if state ~= GameStateMachine.STATE_ENEMY_OPERATE then
		return
	end
	self:RegistLogicTimer(10, {self.ThinkAndOperate, self})
end