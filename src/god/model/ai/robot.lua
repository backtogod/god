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

Robot:DeclareListenEvent("GAME.OPERATE_END", "OnGameOperateEnd")
Robot:DeclareListenEvent("GAME.ACTION_OVER", "OnActionEnd")
Robot:DeclareListenEvent("GAME.ACTION_START", "OnActionStart")

function Robot:_Uninit()
	return 1
end

function Robot:_Init()
	return 1
end

function Robot:OnActionStart()
	-- if GameStateMachine:IsInEnemyAction() == 1 then
	-- 	ModuleMgr:RegisterUpdate(self:GetClassName(), "OnActive")
	-- 	self:ThinkAndOperate()
	-- end
	ModuleMgr:RegisterUpdate(self:GetClassName(), "OnActive")
	self:ThinkAndOperate()
end

function Robot:OnActionEnd()
	-- if GameStateMachine:IsInEnemyAction() == 1 then
	-- 	ModuleMgr:UnregisterUpdate(self:GetClassName())
	-- end
	ModuleMgr:UnregisterUpdate(self:GetClassName())
end

function Robot:OnActive(frame)
	if frame % 3 == 0 then
		if self.pick_id then
			if self.drop_x == self.move_x then
				local pick_id = self.pick_id
				local drop_x = self.drop_x
				self.pick_id = nil
				self.drop_x = nil
				self.move_x = nil
				local ret_code, result = CommandCenter:ReceiveCommand({"TryDropChess", pick_id, drop_x})				
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

function Robot:ThinkAndOperate()
	if ActionMgr:GetRestRoundNum() <= 0 then
		return
	end
	local can_move_list = {}
	local can_pick_list = {}
	for logic_x = 1, Def.MAP_WIDTH do
		if EnemyMap:GetCell(logic_x, 1) > 0 then
			can_pick_list[#can_pick_list + 1] = logic_x
		end
		if EnemyMap:GetCell(logic_x, Def.MAP_HEIGHT) <= 0 then
			can_move_list[#can_move_list + 1] = logic_x
		end
	end

	local pick_x = can_pick_list[math.random(1, #can_pick_list)]
	local ret_code, pick_id = CommandCenter:ReceiveCommand({"PickChess", pick_x})

	local drop_x = can_move_list[math.random(1, #can_move_list)]
	while drop_x == pick_x do
		drop_x = can_move_list[math.random(1, #can_move_list)]
	end
	self.pick_id = pick_id
	self.move_x = pick_x
	self.drop_x = drop_x
end

function Robot:OnGameOperateEnd()
	-- local state = GameStateMachine:GetState()
	-- if state ~= GameStateMachine.STATE_ENEMY_OPERATE then
	-- 	return
	-- end
	self:RegistLogicTimer(20, {self.ThinkAndOperate, self})
end