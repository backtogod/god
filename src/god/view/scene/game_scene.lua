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
Scene:DeclareListenEvent("CHESS.WAIT_ROUND_CHANGED", "OnChessWaitRoundChanged")
Scene:DeclareListenEvent("CHESS.LIFE_CHANGED", "OnChessLifeChanged")

Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")
Scene:DeclareListenEvent("ENEMY_CHESS.REMOVE", "OnEnemyChessRemove")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_POSITION", "OnEnemyChessSetPosition")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_DISPLAY_POSITION", "OnEnemyChessSetDisplayPosition")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_TEMPLATE", "OnEnemyChessSetTemplate")
Scene:DeclareListenEvent("ENEMY_CHESS.WAIT_ROUND_CHANGED", "OnEnemyChessWaitRoundChanged")
Scene:DeclareListenEvent("ENEMY_CHESS.LIFE_CHANGED", "OnEnemyChessLifeChanged")

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
	CommandCenter:Uninit()
	Mover:Uninit()
	TouchInput:Uninit()

	for _, wait_helper in pairs(self.slave_wait_helper_list) do
		wait_helper:Uninit()
	end
	self.slave_wait_helper_list = nil

	if self.master_wait_helper then
		self.master_wait_helper:Uninit()
		self.master_wait_helper = nil
	end

	return 1
end

function Scene:_Init()
	self.master_wait_helper = nil
	self.slave_wait_helper_list = {}

	assert(self:InitUI() == 1)
	assert(Mover:Init() == 1)
	assert(CommandCenter:Init() == 1)
	assert(TouchInput:Init() == 1)
	assert(GameStateMachine:Init(GameStateMachine.STATE_ENEMY_WATCH) == 1)
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

	self:SetBackGroundImage({"god/map.png"}, 0)

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

	local label_round_tip = cc.Label:createWithSystemFont("ROUND X", "Arial", 100)
	label_round_tip:setVisible(false)
	Ui:AddElement(ui_frame, "LABEL", "round_tip", visible_size.width / 2, visible_size.height / 2, label_round_tip)
	-- self:DrawGrip()

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

function Scene:OnTouchBegan(x, y)
	return TouchInput:OnTouchBegan(x, y)
end

function Scene:OnTouchMoved(x, y)
	return TouchInput:OnTouchMoved(x, y)
end

function Scene:OnTouchEnded(x, y)
	return TouchInput:OnTouchEnded(x, y)
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
	local chess = ChessPool:GetById(id)
	local x, y = SelfMap:Logic2Pixel(logic_x, logic_y)
	return self:MoveChessToPosition(chess, x, y)
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

	local chess = EnemyChessPool:GetById(id)
	local x, y = EnemyMap:Logic2Pixel(logic_x, logic_y)
	return self:MoveChessToPosition(chess, x, y)
end

function Scene:OnChessRemove(id)
	local chess_sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	self:RemoveObj("main", SelfMap:GetClassName(), id)
end

function Scene:OnEnemyChessRemove(id)
	local chess_sprite = self:GetObj("main", EnemyMap:GetClassName(), id)
	self:RemoveObj("main", EnemyMap:GetClassName(), id)
end

function Scene:OnChessSetPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	local x, y = SelfMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnEnemyChessSetPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", EnemyMap:GetClassName(), id)
	local x, y = EnemyMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnChessSetDisplayPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", SelfMap:GetClassName(), id)
	local x, y = SelfMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end

function Scene:OnEnemyChessSetDisplayPosition(id, logic_x, logic_y)
	local chess = self:GetObj("main", EnemyMap:GetClassName(), id)
	local x, y = EnemyMap:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
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

function Scene:OnEnemyChessSetTemplate(id, template_id)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local old_sprite = self:GetObj("main", EnemyMap:GetClassName(), id)
	local x, y = old_sprite:getPosition()
	self:RemoveObj("main", EnemyMap:GetClassName(), id)

	local sprite = self:GenerateChessSprite(config.image)
	sprite:setPosition(x, y)
	sprite:setLocalZOrder(visible_size.height - y)
	self:AddObj("main", EnemyMap:GetClassName(), id, sprite)
end

function Scene:OnChessWaitRoundChanged(id, round)
	local chess_sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	chess_sprite:setColor(cc.c3b(0, 255 - round * 20))
end

function Scene:OnEnemyChessWaitRoundChanged(id, round)
	local chess_sprite = self:GetObj("main", EnemyMap:GetClassName(), id)
	chess_sprite:setColor(cc.c3b(0, 255 - round * 50))
end

function Scene:OnPickChess(id, logic_x, logic_y)
	local map = GameStateMachine:GetActiveMap()
	local map_name = map:GetClassName()
	local chess = self:GetObj("main", map_name, id)
	chess:setOpacity(200)
	local copy_chess = cc.Sprite:createWithTexture(chess:getTexture())
	copy_chess:setAnchorPoint(cc.p(0.5, 0))
	copy_chess:setOpacity(100)
	local rect = copy_chess:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	copy_chess:setScale(scale_x)
	self:AddObj("main", map_name, "copy", copy_chess)
	self:SetMapChessPosition(map, "copy", logic_x, logic_y)
end

function Scene:OnCancelPickChess(id)
	local map = GameStateMachine:GetActiveMap()

	local map = GameStateMachine:GetActiveMap()
	local map_name = map:GetClassName()
	local chess = self:GetObj("main", map_name, id)
	local logic_chess = map.obj_pool:GetById(id)
	self:SetMapChessPosition(map, id, logic_chess.x, logic_chess.y)
	chess:setOpacity(255)
	self:RemoveObj("main", map_name, "copy")
end

function Scene:OnDropChess(id, logic_x, logic_y, old_x, old_y)
	local map = GameStateMachine:GetActiveMap()
	local chess = self:GetObj("main", map:GetClassName(), id)
	assert(chess)
	chess:setOpacity(255)
	self:RemoveObj("main", map:GetClassName(), "copy")
	ActionMgr:OperateChess(map, id, logic_x, logic_y, old_x, old_y)
end

function Scene:StartWatch(min_wait_time, call_back)
	assert(not self.master_wait_helper)
	self.master_wait_helper = Class:New(WaitHelper, "WatchWaiter")
	self.master_wait_helper:Init({self.EndWatch, self, call_back})
	-- self.master_wait_helper:EnableDebug()

	self.master_wait_helper:WaitJob(min_wait_time)
end

function Scene:EndWatch(call_back)
	self.master_wait_helper:Uninit()
	self.master_wait_helper = nil
	assert(call_back and type(call_back) == "function")
	call_back()
end

function Scene:GetMasterWatchWaiter()
	return self.master_wait_helper
end

function Scene:NewSlaveWatchWaiter(waiter_name, min_wait_time, max_wait_time, call_back)
	local master_waiter = self:GetMasterWatchWaiter()
	assert(master_waiter)
	assert(not self.slave_wait_helper_list[waiter_name])

	print("new", waiter_name, min_wait_time, max_wait_time, call_back)

	local job_id = master_waiter:WaitJob(max_wait_time)
	local slave_waite_helper = Class:New(WaitHelper, waiter_name)
	
	slave_waite_helper:Init({self.OnSlaveWaiterComplete, self, waiter_name, job_id, call_back})
	slave_waite_helper:WaitJob(min_wait_time)

	self.slave_wait_helper_list[waiter_name] = slave_waite_helper

	return slave_waite_helper
end

function Scene:GetSlaveWatchWaiter(waiter_name)
	return self.slave_wait_helper_list[waiter_name]
end

function Scene:OnSlaveWaiterComplete(waiter_name, job_id, call_back)
	local master_waiter = self:GetMasterWatchWaiter()
	assert(master_waiter)
	print("complete", waiter_name, min_wait_time, max_wait_time, call_back)
	self.slave_wait_helper_list[waiter_name]:Uninit()
	self.slave_wait_helper_list[waiter_name] = nil
	if call_back then
		assert(type(call_back) == "function")
		call_back()
	end
	master_waiter:JobComplete(job_id)
end

function Scene:MoveChessToPosition(chess, x, y, call_back)
	local chess_id = chess:GetId()
	local map = SelfMap
	if chess:GetClassName() == "ENEMY_CHESS" then
		map = EnemyMap
	else
		map = SelfMap
	end
	local chess_sprite = self:GetObj("main", map:GetClassName(), chess_id)
	assert(self.master_wait_helper)
	local slave_waite_helper = self:GetSlaveWatchWaiter("move")
	if not slave_waite_helper then
		slave_waite_helper = self:NewSlaveWatchWaiter("move", 0.1, 100, 
			function()
				CombineMgr:CheckCombine(SelfMap)
				CombineMgr:CheckCombine(EnemyMap)
			end
		)
		-- slave_waite_helper:EnableDebug()
	end
	chess_sprite:setLocalZOrder(visible_size.height - y)
	local function func_time_over(id)
		call_back()
	end
	local start_x, start_y = chess_sprite:getPosition()
	local time = math.abs(y - start_y) / Def.CHESS_MOVE_SPEED
	if time <= 0 then
		time = 0.1
	end
	local job_id = slave_waite_helper:WaitJob(time + 1, func_time_over)
	local battle_waiter_helper = self:GetSlaveWatchWaiter("battle")
	local battle_job_id = nil
	if battle_waiter_helper then
		battle_job_id = battle_waiter_helper:WaitJob(time + 2)
	end
	local move_action = cc.MoveTo:create(time, cc.p(x, y))
	local callback_action = cc.CallFunc:create(
		function()
			if call_back and type(call_back) == "function" then
				call_back()
			end
			slave_waite_helper:JobComplete(job_id)
			if battle_waiter_helper and battle_job_id then
				battle_waiter_helper:JobComplete(battle_job_id)
			end
		end
	)
	local delay_action = cc.DelayTime:create(0.2)
	chess_sprite:runAction(cc.Sequence:create(move_action, callback_action, delay_action))
end

function Scene:ChangeChessState(chess, state, call_back)
	local id = chess:GetId()
	local map = SelfMap
	if chess:GetClassName() == "ENEMY_CHESS" then
		map = EnemyMap
	end

	local chess_sprite = self:GetObj("main", map:GetClassName(), id)

	assert(self.master_wait_helper)
	local slave_waite_helper = self:GetSlaveWatchWaiter("transform")
	if not slave_waite_helper then
		slave_waite_helper = self:NewSlaveWatchWaiter("transform", 0.1, 100, 
			function()
				Mover:MoveWallArmy(SelfMap)
				Mover:MoveWallArmy(EnemyMap)
			end
		)
		-- slave_waite_helper:EnableDebug()
	end

	local job_id = slave_waite_helper:WaitJob(Def.TRANSFORM_TIME + 1, call_back)

	local blink_action = cc.Blink:create(Def.TRANSFORM_TIME, 5)
	local callback_action = cc.CallFunc:create(
		function()
			if call_back and type(call_back) == "function" then
				call_back()
			end
			slave_waite_helper:JobComplete(job_id)
		end
	)
	local delay_action = cc.DelayTime:create(0.2)
	chess_sprite:runAction(cc.Sequence:create(blink_action, callback_action, delay_action))
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

function Scene:StartRoundStart(min_wait_time, max_wait_time, call_back)
	local round_waiter = self:NewSlaveWatchWaiter("round_start", min_wait_time, max_wait_time, call_back)
	local job_id = round_waiter:WaitJob(max_wait_time)

	local ui_frame = self:GetUI()
	local label = Ui:GetElement(ui_frame, "LABEL", "round_tip")
	if not label then
		assert(false)
		return
	end
	label:setVisible(true)
	if GameStateMachine:IsInEnemyAction() == 1 then
		label:setString("对方回合")
	else
		label:setString("轮到你行动了")		
	end
	label:setScale(0.1)

	local scale_to = cc.ScaleTo:create(0.8, 1)
	local delay = cc.DelayTime:create(1)
	local call_back = cc.CallFunc:create(
		function()
			label:setVisible(false)
			round_waiter:JobComplete(job_id)
		end
	)
	label:stopAllActions()
	label:runAction(cc.Sequence:create(scale_to, delay, call_back))
end

function Scene:StartBattle(min_wait_time, max_wait_time, call_back)
	return self:NewSlaveWatchWaiter("battle", min_wait_time, max_wait_time, call_back)
end

function Scene:OnChessLifeChanged(id, new_life, old_life)
	local sprite = self:GetObj("main", SelfMap:GetClassName(), id)
	return self:_OnLifeChanged(sprite, new_life - old_life)
end

function Scene:OnEnemyChessLifeChanged(id, new_life, old_life)
	local sprite = self:GetObj("main", EnemyMap:GetClassName(), id)
	return self:_OnLifeChanged(sprite, new_life - old_life)
end

function Scene:_OnLifeChanged(sprite, change_value)
	local layer_main = self:GetLayer("main")
	local text = tostring(change_value)
	local param = {
		color     = "red",
		percent_x = 0,
		percent_y = 0.5,
		up_time   = 1,
		up_y      = 40,
		fade_time = 0.5,
		zorder	  = 1000,
		-- fade_up_y = 10,
		text_scale = 1.2,
	}
	if change_value > 0 then
		param.color = "green"
		text = "+"..text
	end
	FlyText:VerticalShake(layer_main, sprite, "fonts/img_font.fnt", text, param)
end