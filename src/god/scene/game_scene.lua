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
Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")


function Scene:_Uninit( ... )
	EnemyMap:Uninit()
	SelfMap:Uninit()
end

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()

	ChessPool:Init("CHESS")
	EnemyChessPool:Init("ENEMY_CHESS")
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)

	self:DrawGrip()

	ChessPool:Add(Chess, 1, 1, 1)
	ChessPool:Add(Chess, 2, 2, 2)
	ChessPool:Add(Chess, 3, 3, 3)
	ChessPool:Add(Chess, 4, 4, 4)
	ChessPool:Add(Chess, 5, 5, 5)
	ChessPool:Add(Chess, 6, 6, 6)

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
	local sprite = cc.Sprite:create(string.format("god/%d.png", template_id))
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
	local sprite = cc.Sprite:create(string.format("god/%d.png", template_id))
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
			cc.p(offset_x, (row - 1) * Def.MAP_CELL_HEIGHT + offset_y),
			cc.p(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_x, (row - 1) * Def.MAP_CELL_HEIGHT + offset_y),
			1, cc.c4f(0, 1, 0, 1))
	end

	for column = 1, Def.MAP_WIDTH + 1 do
		draw_node:drawSegment(
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x,  offset_y),
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x, Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_y),
			1, cc.c4f(0, 1, 0, 1))
	end

	local offset_enemy_x, offset_enemy_y = Map:GetEnemyMapOffsetPoint()
	for row = 1, Def.MAP_HEIGHT + 1 do
		draw_node:drawSegment(
			cc.p(offset_enemy_x, (row - 1) * Def.MAP_CELL_HEIGHT + offset_enemy_y),
			cc.p(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_enemy_x, (row - 1) * Def.MAP_CELL_HEIGHT + offset_enemy_y),
			1, cc.c4f(0, 0, 1, 1))
	end

	for column = 1, Def.MAP_WIDTH + 1 do
		draw_node:drawSegment(
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_enemy_x,  offset_enemy_y),
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_enemy_x, Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_enemy_y),
			1, cc.c4f(0, 0, 1, 1))
	end
	self:AddObj("main", "draw", "grid", draw_node)
end