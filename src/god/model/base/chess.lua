--=======================================================================
-- File Name    : chess.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 23:17:32 2014
-- Description  :
-- Modify       :
--=======================================================================

if not ChessPool then
	ChessPool = Class:New(ObjPool, "ChessPool")
end

if not EnemyChessPool then
	EnemyChessPool = Class:New(ObjPool, "EnemyChessPool")
end

if not Chess then
	Chess = Class:New(ObjBase, "Chess")
end

function Chess:_Uninit( ... )
	return 1
end

function Chess:_Init(id, template_id, x, y)
	self.template_id = template_id
	self.x = x
	self.y = y

	local data = ChessConfig:GetData(template_id)
	self.life = data.base_life
	self.step_life = data.base_life * 3
	self.max_life =self.step_life * (data.wait_round + 1)
	self:AddComponent("action", "ACTION")
	self.wait_round = -1
	return 1
end

function Chess:GetLife()
	return self.life
end

function Chess:GetMaxLife()
	return self.max_life
end

function Chess:GetStepLife()
	return self.step_life
end

function Chess:SetLife(life)
	local old_life = self.life
	self.life = life
	local event_name = self:GetClassName() .. ".LIFE_CHANGED"
	Event:FireEvent(event_name, self:GetId(), life, old_life)
end

function Chess:ChangeLife(change_value)
	local new_value = self.life + change_value
	if new_value > self.max_life then
		new_value = self.max_life
	elseif new_value <= 0 then
		new_value = 0
	end
	self:SetLife(new_value)
end

function Chess:GetWaitRound()
	if self:GetChild("action"):GetState() ~= Def.STATE_ARMY then
		return -1
	end
	return self.wait_round
end

function Chess:SetWaitRound(round)
	if self:GetChild("action"):GetState() ~= Def.STATE_ARMY then
		return 0
	end
	self.wait_round = round
	local event_name = self:GetClassName() .. ".WAIT_ROUND_CHANGED"
	Event:FireEvent(event_name, self:GetId(), round)
	return 1
end

function Chess:ChangeWaitRound(change_value)
	local round = self:GetWaitRound()
	local new_value = round + change_value
	self:SetWaitRound(new_value)
	if new_value <= 0 then
		self:Attack()
	end
end

function Chess:SetPosition(x, y)
	if self.x == x and self.y == y then
		return
	end
	local old_x = self.x
	local old_y = self.y
	self.x = x
	self.y = y
	local event_name = self:GetClassName() .. ".SET_POSITION"
	Event:FireEvent(event_name, self:GetId(), x, y, old_x, old_y)
end

function Chess:MoveTo(logic_x, logic_y)
	if self.x == x and self.y == y then
		return
	end
	local map = self:GetMap()
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	ViewInterface:WaitMoveComplete(self, x, y, 
		function()
			self:SetPosition(logic_x, logic_y)
		end
	)
end

function Chess:SetTemplateId(template_id)
	self.template_id = template_id
	local data = ChessConfig:GetData(template_id)
	self.max_life = data.base_life
	self:SetLife(data.base_life)
	local event_name = self:GetClassName() .. ".SET_TEMPLATE"
	Event:FireEvent(event_name, self:GetId(), template_id)
end

function Chess:GetTemplateId()
	return self.template_id
end

function Chess:TransformtToWall()
	if self:TryCall("SetState", Def.STATE_WALL) ~= 1 then
		return 0
	end
	local config = ChessConfig:GetData("wall_1")
	if not config then
		assert(false)
		return
	end
	ViewInterface:WaitChangeStateComplete(self, Def.STATE_ARMY, 
		function()
			self:SetTemplateId("wall_1")
		end
	)
	return 1
end

function Chess:TransformtToArmy()
	if self:TryCall("SetState", Def.STATE_ARMY) ~= 1 then
		assert(false)
		return 0
	end
	ViewInterface:WaitChangeStateComplete(self, Def.STATE_ARMY, 
		function()
			local data = ChessConfig:GetData(self.template_id)
			assert(data.wait_round)
			self:SetWaitRound(data.wait_round)
		end
	)
	return 1
end

function Chess:GetWallLevel()
	if self.template_id == "wall_1" then
		return 1
	elseif self.template_id == "wall_2" then
		return 2
	elseif self.template_id == "wall_3" then
		return 3
	end
	return 0
end

function Chess:Evolution(chess_food)
	local state = self:TryCall("GetState")
	if state == Def.STATE_WALL then
		local level = self:GetWallLevel()
		local food_level = chess_food:GetWallLevel()
		local final_level = level + food_level
		if final_level > 3 then
			final_level = 3
		end
		self:SetTemplateId("wall_"..final_level)
	elseif state == Def.STATE_ARMY then
		self:ChangeLife(chess_food:GetLife())
		local min_round = self:GetWaitRound()
		local food_round = chess_food:GetWaitRound()
		if food_round < min_round then
			self:SetWaitRound(food_round)
		end
	end
	return 1
end

function Chess:GetOppositeMap()
	if self:GetClassName() == "CHESS" then
		return EnemyMap
	else
		return SelfMap
	end
end

function Chess:GetMap()
	if self:GetClassName() == "CHESS" then
		return SelfMap
	else
		return EnemyMap
	end
end

function Chess:Attack()
	local opposite_map = self:GetOppositeMap()
	local self_map = self:GetMap()
	local target_id = nil
	local target_x, target_y = nil, nil
	for i = 1, Def.MAP_HEIGHT do
		target_id = opposite_map:GetCell(self.x, i)
		if target_id > 0 then
			target_x, target_y = opposite_map:Logic2Pixel(self.x, i - 1)
			break
		end
	end
	if not target_x or not target_y then
		target_x, target_y = opposite_map:Logic2Pixel(self.x, Def.MAP_HEIGHT + 2)
	end
	ViewInterface:WaitMoveComplete(self, target_x, target_y, 
		function()
			if target_id <= 0 then
				--TODO attack player
				self_map.obj_pool:Remove(self:GetId())
				return
			end
			local target_chess = opposite_map.obj_pool:GetById(target_id)
			ViewInterface:WaitChessAttack(self, target_chess, 
				function()
					self:AttackEnemy(target_id)
					if self:GetLife() <= 0 then
						self_map.obj_pool:Remove(self:GetId())
						return
					end
					return self:Attack()
				end
			)
			
		end
	)
end

function Chess:AttackEnemy(target_id)
	local opposite_map = self:GetOppositeMap()
	local target_chess = opposite_map.obj_pool:GetById(target_id)
	local attack_damage = self:GetLife()
	local defence_damage = target_chess:GetLife()
	target_chess:ChangeLife(-attack_damage)
	self:ChangeLife(-defence_damage)
	if target_chess:TryCall("GetState") == Def.STATE_NORMAL or target_chess:GetLife() <= 0 then
		opposite_map.obj_pool:Remove(target_id)
	end	
end