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
	SceneMgr:GetCurrentScene():MoveChess(map, id, logic_x, logic_y)
	local event_name = self:GetClassName() .. ".MOVE_TO"
	Event:FireEvent(event_name, self:GetId(), x, y, self.x, self.y)
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

function Chess:GetWallLevel()
	if self.template_id == "wall_1" then
		return 1
	elseif self.template_id == "wall_2" then
		return 2
	end
	return 0
end

function Chess:Evolution(chess_food)
	local level = self:GetWallLevel()
	local food_level = chess_food:GetWallLevel()
	local final_level = level + food_level
	if final_level > 3 then
		final_level = 3
	end
	self:SetTemplateId("wall_"..final_level)
	return 1
end