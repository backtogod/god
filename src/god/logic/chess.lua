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
	return 1
end

function Chess:SetPosition(x, y)
	local event_name = self:GetClassName() .. ".SET_POSITION"
	Event:FireEvent(event_name, self:GetId(), x, y, self.x, self.y)
	self.x = x
	self.y = y
end