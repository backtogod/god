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

	self:AddComponent("action", "ACTION")
	return 1
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

function Chess:SetTemplateId(template_id)
	self.template_id = template_id
	local event_name = self:GetClassName() .. ".SET_TEMPLATE"
	Event:FireEvent(event_name, self:GetId(), template_id)
end

function Chess:GetTemplateId()
	return self.template_id
end