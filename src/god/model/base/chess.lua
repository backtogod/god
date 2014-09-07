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
	self.max_life = data.base_life
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

function Chess:SetLife(life)
	self.life = life
	local event_name = self:GetClassName() .. ".LIFE_CHANGED"
	Event:FireEvent(event_name, self:GetId(), life)
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

function Chess:MoveTo(x, y)
	if self.x == x and self.y == y then
		return
	end
	ViewInterface:WaitMoveComplete(self, x, y, 
		function()
			self:SetPosition(x, y)
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
	
	return 1
end

function Chess:TransformtToArmy()
	if self:TryCall("SetState", Def.STATE_ARMY) ~= 1 then
		assert(false)
		return 0
	end
	local data = ChessConfig:GetData(self.template_id)
	assert(data.wait_round)
	self:SetWaitRound(data.wait_round)
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

function Chess:Attack()
	local event_name = self:GetClassName() .. ".ATTACK"
	Event:FireEvent(event_name, self:GetId())
end