--=======================================================================
-- File Name    : game_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 21:31:32 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("GameScene", 1)
Scene.property = {
	can_touch = 1,
	-- can_drag = 1,
}

Scene:DeclareListenEvent("CHESS.ADD", "OnChessAdd")
Scene:DeclareListenEvent("CHESS.SET_POSITION", "OnChessSetPosition")
Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")

Scene:DeclareListenEvent("PICKHELPER.PICK", "OnPickChess")
Scene:DeclareListenEvent("PICKHELPER.CANCEL_PICK", "OnCancelPickChess")
Scene:DeclareListenEvent("PICKHELPER.DROP", "OnDropChess")

function Scene:_Uninit( ... )
	EnemyMap:Uninit()
	SelfMap:Uninit()
	PickHelper:Uninit()

	return 1
end

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()

	ChessPool:Init("CHESS")
	EnemyChessPool:Init("ENEMY_CHESS")
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)

	self:DrawGrip()
	PickHelper:Init(1)

	ChessPool:Add(Chess, 1, 1, 1)
	ChessPool:Add(Chess, 2, 2, 2)
	ChessPool:Add(Chess, 3, 3, 3)
	ChessPool:Add(Chess, 4, 4, 4)
	ChessPool:Add(Chess, 5, 5, 5)
	ChessPool:Add(Chess, 6, 6, 6)

	ChessPool:Add(Chess, 1, 2, 5)
	ChessPool:Add(Chess, 2, 3, 4)
	ChessPool:Add(Chess, 3, 4, 3)
	ChessPool:Add(Chess, 4, 5, 2)
	ChessPool:Add(Chess, 5, 6, 1)
	ChessPool:Add(Chess, 6, 1, 6)

	ChessPool:Add(Chess, 1, 3, 5)

	EnemyChessPool:Add(Chess, 1, 1, 1)
	EnemyChessPool:Add(Chess, 2, 2, 1)
	EnemyChessPool:Add(Chess, 3, 3, 1)
	EnemyChessPool:Add(Chess, 4, 4, 1)
	EnemyChessPool:Add(Chess, 5, 5, 1)
	EnemyChessPool:Add(Chess, 6, 6, 1)

	SelfMap:Debug()
	EnemyMap:Debug()
	
	return 1
end

function Scene:OnChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local sprite = cc.Sprite:create(config.image)
	local x, y = Map:Logic2PixelSelf(logic_x, logic_y)
	sprite:setPosition(x, y)
	local rect = sprite:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	local scale_y = Def.MAP_CELL_HEIGHT / rect.height
	sprite:setScaleX(scale_x)
	sprite:setScaleY(scale_y)
	self:AddObj("main", "chess", id, sprite)
end

function Scene:OnEnemyChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local sprite = cc.Sprite:create(config.image)
	local x, y = Map:Logic2PixelEnemy(logic_x, logic_y)
	sprite:setPosition(x, y)
	local rect = sprite:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	local scale_y = Def.MAP_CELL_HEIGHT / rect.height
	sprite:setScaleX(scale_x)
	sprite:setScaleY(scale_y)
	self:AddObj("main", "enemy_chess", id, sprite)
end

function Scene:DrawGrip( ... )
	local offset_x, offset_y = Map:GetMapOffsetPoint()
	local draw_node = cc.DrawNode:create()
	for row = 1, Def.MAP_HEIGHT + 1 do
		draw_node:drawSegment(
			cc.p(offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y),
			cc.p(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y),
			1, cc.c4f(0, 1, 0, 1))

		--enemy
		draw_node:drawSegment(
			cc.p(Map:Mirror(offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y)),
			cc.p(Map:Mirror(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y)),
			1, cc.c4f(0, 0, 1, 1))
	end

	for column = 1, Def.MAP_WIDTH + 1 do
		draw_node:drawSegment(
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x,  offset_y),
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x, - Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_y),
			1, cc.c4f(0, 1, 0, 1))
		--enemy
		draw_node:drawSegment(
			cc.p(Map:Mirror((column - 1) * Def.MAP_CELL_WIDTH + offset_x,  offset_y)),
			cc.p(Map:Mirror((column - 1) * Def.MAP_CELL_WIDTH + offset_x, - Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_y)),
			1, cc.c4f(0, 0, 1, 1))
	end
	self:AddObj("main", "draw", "grid", draw_node)
end

function Scene:OnTouchEnded(x, y)
	if self:IsMove() == 1 then
		return
	end

	local logic_x, logic_y = SelfMap:Pixel2LogicSelf(x, y)
	local chess_id = SelfMap:GetCell(logic_x, logic_y)
	if not chess_id then
		return
	end

	if chess_id <= 0 then
		PickHelper:DropAll(logic_x, logic_y)
	else
		if PickHelper:CanPick() ~= 1 then
			PickHelper:CancelAll()
		end
		PickHelper:Pick(chess_id, logic_x, logic_y)
	end
end

function Scene:OnChessSetPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	local x, y = SelfMap:Logic2PixelSelf(logic_x, logic_y)
	chess:setPosition(x, y)
end

function Scene:OnPickChess(id, logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	chess:setColor(cc.c3b(0, 255, 0))
end

function Scene:OnCancelPickChess(id, logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	chess:setColor(cc.c3b(255, 255, 255))
end

function Scene:OnDropChess(id, logic_x, logic_y, old_x, old_y)
	local logic_chess = ChessPool:GetById(id)
	assert(logic_chess)
	logic_chess:SetPosition(logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	assert(chess)
	chess:setColor(cc.c3b(255, 255, 255))
end
