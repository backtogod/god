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
Scene:DeclareListenEvent("CHESS.REMOVE", "OnChessRemove")
Scene:DeclareListenEvent("CHESS.SET_POSITION", "OnChessSetPosition")
Scene:DeclareListenEvent("CHESS.SET_DISPLAY_POSITION", "OnChessSetDisplayPosition")
Scene:DeclareListenEvent("CHESS.SET_TEMPLATE", "OnChessSetTemplate")
Scene:DeclareListenEvent("CHESS.CHANGE_STATE", "OnChessChangeState")
Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")

Scene:DeclareListenEvent("PICKHELPER.PICK", "OnPickChess")
Scene:DeclareListenEvent("PICKHELPER.CANCEL_PICK", "OnCancelPickChess")
Scene:DeclareListenEvent("PICKHELPER.DROP", "OnDropChess")

Scene:DeclareListenEvent("GAME.ACTION_START", "OnActionStart")
Scene:DeclareListenEvent("GAME.ROUND_REST_NUM_CHANGED", "OnRoundRestNumChanged")
Scene:DeclareListenEvent("GAME_STATE.CHANGE", "OnGameStateChanged")
Scene:DeclareListenEvent("GAME.COMBO_CHANGED", "OnComboChanged")

function Scene:_Uninit( ... )
	Robot:Uninit()
	EnemyMap:Uninit()
	SelfMap:Uninit()
	PickHelper:Uninit()
	GameStateMachine:Uninit()
	TouchInput:Uninit()

	return 1
end

function Scene:_Init()
	assert(self:InitUI() == 1)
	assert(TouchInput:Init() == 1)
	assert(GameStateMachine:Init(GameStateMachine.STATE_SELF_WATCH) == 1)
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(PickHelper:Init(1) == 1)
	assert(Robot:Init() == 1)

	-- SelfMap:Debug()
	-- EnemyMap:Debug()
	return 1
end

function Scene:InitUI()
	self:AddReturnMenu()
	self:AddReloadMenu()

	local ui_frame = self:GetUI()

	local label_round = cc.Label:createWithSystemFont("Round X", "Arial", 40)
	label_round:setTextColor(cc.c4b(100, 200, 255, 255))
	label_round:setAnchorPoint(cc.p(0, 0.5))
	-- label_round:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RoundTitle", 50, visible_size.height - 50, label_round)

	local label_state = cc.Label:createWithSystemFont("UNKNOWN", "Arial", 40)
	label_state:setTextColor(cc.c4b(100, 200, 255, 255))
	label_state:setAnchorPoint(cc.p(0, 0.5))
	-- label_state:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "State", visible_size.width / 2 - 50 , visible_size.height - 50, label_state)

	local label_rest_num_title = cc.Label:createWithSystemFont("剩余可行动次数:", nil, 40)
	label_rest_num_title:setTextColor(cc.c4b(100, 200, 255, 255))
	label_rest_num_title:setAnchorPoint(cc.p(0, 0.5))
	-- label_rest_num_title:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNumTitle", 50, visible_size.height - 120 , label_rest_num_title)

	local rect = label_rest_num_title:getBoundingBox()
	local label_rest_num = cc.Label:createWithSystemFont("0", "Arial", 40)
	label_rest_num:setTextColor(cc.c4b(100, 200, 255, 255))
	label_rest_num:setAnchorPoint(cc.p(0, 0.5))
	-- label_rest_num:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNum", rect.x + rect.width + 10, visible_size.height - 120 , label_rest_num)

	local label_combo = cc.Label:createWithSystemFont("COMBO X", "Arial", 100)
	label_combo:setVisible(false)
	Ui:AddElement(ui_frame, "LABEL", "combo", visible_size.width / 2, visible_size.height / 2, label_combo)

	self:DrawGrip()

	return 1
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

function Scene:GenerateChessSprite(image_name)
	local sprite = cc.Sprite:create(image_name)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	local rect = sprite:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	sprite:setScale(scale_x)
	return sprite
end

function Scene:SetMapChessPosition(map, id, logic_x, logic_y)
	local chess = self:GetObj("main", map:GetClassName(), id)
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local chess_sprite = self:GenerateChessSprite(config.image)
	self:AddObj("main", SelfMap:GetClassName(), id, chess_sprite)
	self:SetMapChessPosition(SelfMap, id, logic_x, Def.MAP_HEIGHT)
	self:MoveChessToPosition(SelfMap, id, logic_x, logic_y)
end

function Scene:OnChessRemove(id)
	local chess_sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	self:RemoveObj("main", SelfMap:GetClassName(), id)
end

function Scene:OnEnemyChessAdd(id, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local chess_sprite = self:GenerateChessSprite(config.image)
	self:AddObj("main", EnemyMap:GetClassName(), id, chess_sprite)
	self:SetMapChessPosition(EnemyMap, id, logic_x, Def.MAP_HEIGHT)
	self:MoveChessToPosition(EnemyMap, id, logic_x, logic_y)
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
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	local x, y = SelfMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnChessSetDisplayPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	local x, y = SelfMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnPickChess(id, logic_x, logic_y)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	chess:setOpacity(200)
	local copy_chess = cc.Sprite:createWithTexture(chess:getTexture())
	copy_chess:setAnchorPoint(cc.p(0.5, 0))
	copy_chess:setOpacity(100)
	local rect = copy_chess:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	copy_chess:setScale(scale_x)
	self:AddObj("main", SelfMap:GetClassName(), "copy", copy_chess)
	self:SetMapChessPosition(SelfMap, "copy", logic_x, logic_y)
end

function Scene:OnCancelPickChess(id)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	local logic_chess = ChessPool:GetById(id)
	self:SetMapChessPosition(SelfMap, id, logic_chess.x, logic_chess.y)
	chess:setOpacity(255)
	self:RemoveObj("main", SelfMap:GetClassName(), "copy")
end

function Scene:OnDropChess(id, logic_x, logic_y, old_x, old_y)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	assert(chess)
	chess:setOpacity(255)
	self:SetMapChessPosition(SelfMap, id, logic_x, logic_y)
	self:RemoveObj("main", SelfMap:GetClassName(), "copy")
	ActionMgr:OperateChess(SelfMap, id, logic_x, logic_y, old_x, old_y)
end

function Scene:OnChessSetTemplate(id, template_id)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local old_sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	local x, y = old_sprite:getPosition()
	self:RemoveObj("main", SelfMap:GetClassName(), id)

	local sprite = self:GenerateChessSprite(config.image)
	sprite:setPosition(x, y)
	sprite:setLocalZOrder(visible_size.height - y)
	self:AddObj("main", SelfMap:GetClassName(), id, sprite)
end

function Scene:MoveChessToPosition(map, chess_id, logic_x, logic_y)
	local chess_sprite = self:GetObj("main", map:GetClassName(), chess_id)
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	if not self.wait_move_helper then
		self.wait_move_helper = Class:New(WaitHelper, "Waiter")
		if GameStateMachine:IsWatching() ~= 1 then
			Event:FireEvent("GAME.START_WATCH")
		end
		self.wait_move_helper:Init({self.OnMoveComplete, self, map})
	end
	chess_sprite:setLocalZOrder(visible_size.height - y)
	local waiter = self.wait_move_helper
	local function func_time_over(id)
		chess_sprite:setPosition(x, y)
	end
	local start_x, start_y = chess_sprite:getPosition()
	local time = math.abs(y - start_y) / Def.CHESS_MOVE_SPEED
	if time <= 0 then
		time = 0.1
	end
	local job_id = waiter:WaitJob(time + 1, func_time_over)	
	local move_action = cc.MoveTo:create(time, cc.p(x, y))
	local callback_action = cc.CallFunc:create(
		function()
			local logic_chess = map.obj_pool:GetById(chess_id)
			if logic_chess then
				logic_chess:SetPosition(logic_x, logic_y)
			end
			waiter:JobComplete(job_id)
		end
	)
	local delay_action = cc.DelayTime:create(0.2)
	chess_sprite:runAction(cc.Sequence:create(move_action, callback_action, delay_action))
end

function Scene:OnMoveComplete(map)
	self.wait_move_helper:Uninit()
	self.wait_move_helper = nil
	CombineMgr:CheckCombine(map)
	if not self.wait_transform_helper then
		Event:FireEvent("GAME.END_WATCH")
	end
end

function Scene:OnChessChangeState(id, old_state, state)
	local transform = nil
	local chess_sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	if state == Def.STATE_WALL then
		--TODO wall template get
		local config = ChessConfig:GetData("wall_1")
		if not config then
			assert(false)
			return
		end
		transform = function()
			local logic_chess = ChessPool:GetById(id)
			logic_chess:SetTemplateId("wall_1")
		end
	elseif state == Def.STATE_ARMY then
		transform = function()
			chess_sprite:setColor(cc.c3b(0, 255, 0))
		end
	end

	if not self.wait_transform_helper then
		self.wait_transform_helper = Class:New(WaitHelper, "Waiter")
		if GameStateMachine:IsWatching() ~= 1 then
			Event:FireEvent("GAME.START_WATCH")
		end
		self.wait_transform_helper:Init({self.OnTransformComplete, self})
	end

	local waiter = self.wait_transform_helper
	local job_id = waiter:WaitJob(Def.TRANSPORT_TIME + 1, transform)

	local blink_action = cc.Blink:create(Def.TRANSPORT_TIME, 5)
	local callback_action = cc.CallFunc:create(
		function()
			transform()
			waiter:JobComplete(job_id)
		end
	)
	local delay_action = cc.DelayTime:create(0.2)
	chess_sprite:runAction(cc.Sequence:create(blink_action, callback_action, delay_action))
end

function Scene:OnTransformComplete()
	self.wait_transform_helper:Uninit()
	self.wait_transform_helper = nil
	Mover:MoveWallArmy(SelfMap)

	if not self.wait_move_helper then
		Event:FireEvent("GAME.END_WATCH")
	end
end

function Scene:OnActionStart(round)
	local label = Ui:GetElement(self:GetUI(), "LABEL", "RoundTitle")
	label:setString(string.format("Round %d", round))

	local label = Ui:GetElement(self:GetUI(), "LABEL", "RestRoundNum")
	local rest_num = ActionMgr:GetRestRoundNum()
	label:setString(tostring(rest_num))
end

function Scene:OnRoundRestNumChanged(rest_num)
	local label = Ui:GetElement(self:GetUI(), "LABEL", "RestRoundNum")
	label:setString(tostring(rest_num))
end

function Scene:OnGameStateChanged(state)
	local label = Ui:GetElement(self:GetUI(), "LABEL", "State")
	label:setString(GameStateMachine.DEBUG_DISPLAY[state] or "UNKNOWN")
end

function Scene:OnComboChanged(combo_count)
	if combo_count <= 1 then
		return
	end

	local ui_frame = self:GetUI()
	local label = Ui:GetElement(ui_frame, "LABEL", "combo")
	if not label then
		assert(false)
		return
	end
	label:setVisible(true)
	label:setString(string.format("COMBO %d", combo_count))
	label:setScale(0.1)

	local scale_to = cc.ScaleTo:create(0.5, 1)
	local delay = cc.DelayTime:create(1)
	local call_back = cc.CallFunc:create(
		function()
			label:setVisible(false)
		end
	)
	label:stopAllActions()
	label:runAction(cc.Sequence:create(scale_to, delay, call_back))
end