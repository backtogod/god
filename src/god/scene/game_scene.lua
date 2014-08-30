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
Scene:DeclareListenEvent("CHESS.SET_TEMPLATE", "OnChessSetTemplate")
Scene:DeclareListenEvent("CHESS.CHANGE_STATE", "OnChessChangeState")
Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")

Scene:DeclareListenEvent("PICKHELPER.PICK", "OnPickChess")
Scene:DeclareListenEvent("PICKHELPER.CANCEL_PICK", "OnCancelPickChess")
Scene:DeclareListenEvent("PICKHELPER.DROP", "OnDropChess")

function Scene:_Uninit( ... )
	EnemyMap:Uninit()
	SelfMap:Uninit()
	PickHelper:Uninit()
	GameStateMachine:Uninit()
	TouchInput:Uninit()

	return 1
end

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()

	assert(TouchInput:Init() == 1)
	assert(GameStateMachine:Init(GameStateMachine.STATE_SELF_WATCH) == 1)
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(PickHelper:Init(1) == 1)
	self:DrawGrip()

	-- SelfMap:Debug()
	-- EnemyMap:Debug()
	
	Event:FireEvent("GAME.END_WATCH")
	return 1
end

function Scene:GenerateChessSprite(image_name)
	local sprite = cc.Sprite:create(image_name)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	local rect = sprite:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	sprite:setScale(scale_x)
	return sprite
end

function Scene:SetSelfChessPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	local x, y = Map:Logic2PixelSelf(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:SetEnemyChessPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", "enemy_chess", id)
	local x, y = Map:Logic2PixelEnemy(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local sprite = self:GenerateChessSprite(config.image)
	self:AddObj("main", "chess", id, sprite)
	self:SetSelfChessPosition(id, logic_x, logic_y)
end

function Scene:OnEnemyChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local sprite = self:GenerateChessSprite(config.image)
	self:AddObj("main", "enemy_chess", id, sprite)
	self:SetEnemyChessPosition(id, logic_x, logic_y)
end

function Scene:DrawGrip( ... )
	local offset_x, offset_y = Map:GetMapOffsetPoint()
	local draw_node = cc.DrawNode:create()
	for row = 1, Def.MAP_HEIGHT + 1 do
		draw_node:drawSegment(
			cc.p(offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y),
			cc.p(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y),
			1, cc.c4f(1, 1, 1, 0.3))
		--enemy
		draw_node:drawSegment(
			cc.p(Map:Mirror(offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y)),
			cc.p(Map:Mirror(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH + offset_x, (1 - row) * Def.MAP_CELL_HEIGHT + offset_y)),
			1, cc.c4f(1, 1, 1, 0.3))
	end

	for column = 1, Def.MAP_WIDTH + 1 do
		draw_node:drawSegment(
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x,  offset_y),
			cc.p((column - 1) * Def.MAP_CELL_WIDTH + offset_x, - Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_y),
			3, cc.c4f(0, 1, 0, 1))
		--enemy
		draw_node:drawSegment(
			cc.p(Map:Mirror((column - 1) * Def.MAP_CELL_WIDTH + offset_x,  offset_y)),
			cc.p(Map:Mirror((column - 1) * Def.MAP_CELL_WIDTH + offset_x, - Def.MAP_HEIGHT  * Def.MAP_CELL_HEIGHT  + offset_y)),
			3, cc.c4f(0, 0, 1, 1))
	end
	self:AddObj("main", "draw", "grid", draw_node)
end

function Scene:OnTouchBegan(x, y)
	return TouchInput:OnTouchBegan(x, y)
end

function Scene:OnTouchMoved(x, y)
	return TouchInput:OnTouchMoved(x, y)
end

function Scene:OnTouchEnded(x, y)
	return TouchInput:OnTouchEnded(x, y)
end

function Scene:OnChessSetPosition(id, logic_x, logic_y)
	return self:SetSelfChessPosition(id, logic_x, logic_y)
end

function Scene:OnPickChess(id, logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	chess:setOpacity(200)
	local copy_chess = cc.Sprite:createWithTexture(chess:getTexture())
	copy_chess:setAnchorPoint(cc.p(0.5, 0))
	copy_chess:setOpacity(100)
	local rect = copy_chess:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	copy_chess:setScale(scale_x)
	self:AddObj("main", "chess", "copy", copy_chess)
	self:SetSelfChessPosition("copy", logic_x, logic_y)
end

function Scene:OnCancelPickChess(id)
	local chess = self:GetObj("main", "chess", id)
	local logic_chess = ChessPool:GetById(id)
	self:SetSelfChessPosition(id, logic_chess.x, logic_chess.y)
	chess:setOpacity(255)
	self:RemoveObj("main", "chess", "copy")
end

function Scene:OnDropChess(id, logic_x, logic_y, old_x, old_y)
	local logic_chess = ChessPool:GetById(id)
	assert(logic_chess)
	logic_chess:SetPosition(logic_x, logic_y)
	local chess = self:GetObj("main", "chess", id)
	assert(chess)
	chess:setOpacity(255)
	self:RemoveObj("main", "chess", "copy")
	Mover:RemoveHole(SelfMap, logic_x)
	if old_x ~= logic_x then
		Mover:RemoveHole(SelfMap, old_x)
	end
end

function Scene:OnChessSetTemplate(id, template_id)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local old_sprite = self:GetObj("main", "chess", id)
	local x, y = old_sprite:getPosition()
	self:RemoveObj("main", "chess", id)

	local sprite = self:GenerateChessSprite(config.image)
	sprite:setPosition(x, y)
	sprite:setLocalZOrder(visible_size.height - y)
	self:AddObj("main", "chess", id, sprite)
end

function Scene:OnChessChangeState(id, old_state, state)
	if state == Def.STATE_WALL then
		local config = ChessConfig:GetData("wall")
		if not config then
			assert(false)
			return
		end
		local old_sprite = self:GetObj("main", "chess", id)
		local x, y = old_sprite:getPosition()
		self:RemoveObj("main", "chess", id)

		local sprite = self:GenerateChessSprite(config.image)
		sprite:setPosition(x, y)
		sprite:setLocalZOrder(visible_size.height - y)
		self:AddObj("main", "chess", id, sprite)
	elseif state == Def.STATE_ARMY then
		local sprite = self:GetObj("main", "chess", id)
		sprite:setColor(cc.c3b(0, 255, 0))
	end
end
