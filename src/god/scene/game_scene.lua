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

	ChessPool:Add(Chess, 1, 1, 6)
	ChessPool:Add(Chess, 2, 2, 6)
	ChessPool:Add(Chess, 3, 3, 6)
	ChessPool:Add(Chess, 4, 4, 6)
	ChessPool:Add(Chess, 5, 5, 6)
	ChessPool:Add(Chess, 6, 6, 6)

	ChessPool:Add(Chess, 1, 2, 6)
	ChessPool:Add(Chess, 2, 3, 6)
	ChessPool:Add(Chess, 3, 4, 6)
	ChessPool:Add(Chess, 4, 5, 6)
	ChessPool:Add(Chess, 5, 6, 6)
	ChessPool:Add(Chess, 6, 1, 6)

	ChessPool:Add(Chess, 1, 3, 6)
	ChessPool:Add(Chess, 2, 4, 6)

	EnemyChessPool:Add(Chess, 1, 1, 1)
	EnemyChessPool:Add(Chess, 2, 2, 1)
	EnemyChessPool:Add(Chess, 3, 3, 1)
	EnemyChessPool:Add(Chess, 4, 4, 1)
	EnemyChessPool:Add(Chess, 5, 5, 1)
	EnemyChessPool:Add(Chess, 6, 6, 1)

	-- SelfMap:Debug()
	-- EnemyMap:Debug()
	
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

	local logic_x, _ = SelfMap:Pixel2LogicSelf(x, y)
	for logic_y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = SelfMap:GetCell(logic_x, logic_y)
		if chess_id and chess_id > 0 then
			local logic_chess = ChessPool:GetById(chess_id)
			if logic_chess:TryCall("GetState") == Def.STATE_NORMAL then
				PickHelper:Pick(chess_id, logic_x, logic_y)
				self.pick_id = chess_id
			end
			return
		end
	end
end

function Scene:OnTouchMoved(x, y)
	local id = self.pick_id
	if not id then
		return
	end
	local logic_x, _ = SelfMap:Pixel2LogicSelf(x, y)
	local logic_y = Mover:GetMoveablePosition(SelfMap, id, logic_x)
	if logic_y > 0 then
		self:SetSelfChessPosition(id, logic_x, logic_y)
	end
end

function Scene:OnTouchEnded(x, y)
	local id = self.pick_id
	if not id then
		return
	end
	local logic_x, _ = SelfMap:Pixel2LogicSelf(x, y)
	local logic_y = Mover:GetMoveablePosition(SelfMap, id, logic_x)
	if logic_y > 0 then
		PickHelper:DropAll(logic_x, logic_y)
	else
		PickHelper:CancelAll()
	end
	self.pick_id = nil
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
