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

function VSRobot:OnAIActive()
	local state = GameStateMachine:GetState()
	if state ~= GameStateMachine.STATE_ENEMY_OPERATE then
		return
	end
	self:RegistLogicTimer(10, {self.ThinkAndOperate, self})
end

function VSRobot:OnActive(frame)
	if frame % 2 == 0 then
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
	assert(not self.pick_id)

	local pick_x, drop_x = self:SelectPick(map)
	local ret_code, pick_id = CommandCenter:ReceiveCommand({"PickChess", pick_x})

	self.pick_x = pick_x
	self.pick_id = pick_id
	self.move_x = pick_x
	self.drop_x = drop_x
	print("............Think Result", pick_id, "Move", pick_x, drop_x)
end

function VSRobot:FindChessByTemplate(map, template_id, except_x)
	local width, height = map:GetSize()
	for x = 1, width do
		if not except_x[x] then
			local top_id, top_y = PickRule:GetCanPick(map, x)
			if top_id then
				local top_chess = map.obj_pool:GetById(top_id)
				if top_chess:GetTemplateId() == template_id then
					return x, top_id, top_y
				end
			end
		end
	end
end

local strategy_list = {
	"FindCanCombineArmy",
	"FindCanCombieWall",
	"FindCanNextToArmy",
	"FindCanMergeArmy",
	"RandomAction",
}

function VSRobot:SelectPick(map)
	local pick_id = nil
	local pick_x = nil
	local move_x = nil

	for _, strategy_name in ipairs(strategy_list) do
		local strategy_func = self[strategy_name]
		assert(strategy_func)
		pick_x, move_x = strategy_func(self, map)
		if pick_x and move_x then
			return pick_x, move_x
		end
	end
end

function VSRobot:FindCanCombineArmy(map)
	local width, height = map:GetSize()
	for logic_x = 1, width do
		local top_id, top_y = PickRule:GetCanPick(map, logic_x)
		if top_id then
			local next_id = map:GetCell(logic_x, top_y - 1)
			if next_id and next_id > 0 then
				local top_chess = map.obj_pool:GetById(top_id)
				local template_id = top_chess:GetTemplateId()
				local next_chess = map.obj_pool:GetById(next_id)
				if next_chess:TryCall("GetState") == Def.STATE_NORMAL and template_id == next_chess:GetTemplateId() then
					local find_x, find_id = self:FindChessByTemplate(map, template_id, {[logic_x] = 1})
					if find_x and find_id then
						return find_x, logic_x
					end
				end
			end
		end
	end
end

function VSRobot:FindCanNextToArmy(map)
	local width, height = map:GetSize()
	for logic_x = 1, width do
		local top_id, top_y = PickRule:GetCanPick(map, logic_x)
		if top_id then
			local top_chess = map.obj_pool:GetById(top_id)
			local template_id = top_chess:GetTemplateId()		
			local find_x, find_id = self:FindChessByTemplate(map, template_id, {[logic_x] = 1})
			if find_x and find_id then
				return find_x, logic_x
			end
		end
	end
end

function VSRobot:FindCanCombieWall(map)
	local width, height = map:GetSize()
	local top_info = {}
	for logic_x = 1, width do
		local top_id, top_y = PickRule:GetCanPick(map, logic_x)
		if top_id and top_y then
			if not top_info[top_y] then
				top_info[top_y] = {}
			end
			local chess = map.obj_pool:GetById(top_id)
			table.insert(top_info[top_y], {x = logic_x, id = chess:GetTemplateId()})
		end
	end

	local function findCanMergeWall(y, info_list)
		local valid_count = #info_list
		if valid_count < 2 then
			return
		end
		local index = 1
		while index < valid_count do
			local top_info = info_list[index]
			local cur_x, cur_id = top_info.x, top_info.id

			local next_info = info_list[index + 1]
			local next_x, next_id = next_info.x, next_info.id
			if cur_id == next_id then
				if next_x == cur_x + 1 then
					local left_top_id, left_top_y = map:GetTopCell(cur_x - 1)
					if left_top_y and left_top_y == (y - 1) then
						local find_x, find_id = self:FindChessByTemplate(map, cur_id, {[cur_x - 1] = 1, [cur_x] = 1, [next_x] = 1})
						if find_x and find_id then
							return find_x, cur_x - 1
						end
					end
					local right_top_id, rigth_top_y = map:GetTopCell(next_x + 1)
					if rigth_top_y and rigth_top_y == (y - 1) then
						local find_x, find_id = self:FindChessByTemplate(map, cur_id, {[next_x + 1] = 1, [cur_x] = 1, [next_x] = 1})
						if find_x and find_id then
							return find_x, next_x + 1
						end
					end
				elseif next_x == cur_x + 2 then
					local center_top_id, center_top_y = map:GetTopCell(cur_x + 1)
					if center_top_y and center_top_y == (y - 1) then
						local find_x, find_id = self:FindChessByTemplate(map, cur_id, {[cur_x + 1] = 1, [cur_x] = 1, [next_x] = 1})
						if find_x and find_id then
							return find_x, cur_x - 1
						end
					end
				end
			end
			index = index + 1
		end
	end
	for y, info_list in pairs(top_info) do
		local find_x, move_x = findCanMergeWall(y, info_list)
		if find_x and move_x then
			return find_x, move_x
		end
	end
end

function VSRobot:FindCanMergeArmy(map)
	local width, height = map:GetSize()
	for logic_x = 1, width do
		local top_id, top_y = map:GetTopCell(logic_x)
		if top_id then
			local top_chess = map.obj_pool:GetById(top_id)
			if top_chess:TryCall("GetState") == Def.STATE_ARMY then
				local template_id = top_chess:GetTemplateId()		
				local find_x, find_id = self:FindChessByTemplate(map, template_id, {[logic_x] = 1})
				if find_x and find_id then
					return find_x, logic_x
				end
			end
		end
	end
end

function VSRobot:RandomAction(map)
	local can_move_list = {}
	local can_pick_list = {}
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

	local drop_x = can_move_list[math.random(1, #can_move_list)]
	local loop_count = 1
	while drop_x == pick_x and loop_count < 64 do
		drop_x = can_move_list[math.random(1, #can_move_list)]
		loop_count = loop_count + 1
	end
	return pick_x, drop_x
end