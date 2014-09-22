--=======================================================================
-- File Name    : vs_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 21:31:32 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("VSScene", 1)
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

Scene:DeclareListenEvent("PLAYER.SET_SELF_HP", "OnSetSelfPlayerHP")
Scene:DeclareListenEvent("PLAYER.SET_ENEMY_HP", "OnSetEnemyPlayerHP")

function Scene:_Uninit( ... )
	
	VSRobot:Uninit()
	EnemyMap:Uninit()
	SelfMap:Uninit()
	PickHelper:Uninit()
	Player:Uninit()
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
	assert(Player:Init(100, 100) == 1)
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT) == 1)
	assert(PickHelper:Init(1) == 1)
	assert(VSRobot:Init() == 1)

	-- SelfMap:Debug()
	-- EnemyMap:Debug()
	return 1
end

function Scene:InitUI()
	self:AddReturnMenu()
	self:AddReloadMenu() 

	self:SetBackGroundImage({"god/map.png"}, 0)

	local highlight_green = cc.DrawNode:create()
	local height = Def.MAP_OFFSET_Y + Def.MAP_CELL_HEIGHT * Def.MAP_HEIGHT
	highlight_green:drawPolygon(
		{cc.p(-Def.MAP_CELL_WIDTH * 0.5, -height), cc.p(-Def.MAP_CELL_WIDTH * 0.5, height), 
		cc.p(Def.MAP_CELL_WIDTH * 0.5, height), cc.p(Def.MAP_CELL_WIDTH * 0.5, -height),},
		4, 
		cc.c4b(0, 1, 0, 0.2),
		1,
		cc.c4b(0, 0, 0, 0)
	)
	highlight_green:setVisible(false)
	self:AddObj("main", "draw", "highlight_green", highlight_green)

	local highlight_red = cc.DrawNode:create()
	local height = Def.MAP_OFFSET_Y + Def.MAP_CELL_HEIGHT * Def.MAP_HEIGHT
	highlight_red:drawPolygon(
		{cc.p(-Def.MAP_CELL_WIDTH * 0.5, -height), cc.p(-Def.MAP_CELL_WIDTH * 0.5, height), 
		cc.p(Def.MAP_CELL_WIDTH * 0.5, height), cc.p(Def.MAP_CELL_WIDTH * 0.5, -height),},
		4, 
		cc.c4b(1, 0, 0, 0.2),
		1,
		cc.c4b(0, 0, 0, 0)
	)
	highlight_red:setVisible(false)
	self:AddObj("main", "draw", "highlight_red", highlight_red)

	self:InitDebugUI()	
	-- self:DrawGrip()	
	self:InitButtonMenu()
	self:InitPlayerHPUI()

	local ui_frame = self:GetUI()
	local label_combo = cc.Label:createWithSystemFont("COMBO X", "Arial", 100)
	label_combo:setVisible(false)
	Ui:AddElement(ui_frame, "LABEL", "combo", visible_size.width / 2, visible_size.height / 2, label_combo)

	local label_round_tip = cc.Label:createWithSystemFont("ROUND X", "Arial", 100)
	label_round_tip:setVisible(false)
	Ui:AddElement(ui_frame, "LABEL", "round_tip", visible_size.width / 2, visible_size.height / 2, label_round_tip)

	return 1
end

function Scene:InitDebugUI()
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

	local label_rest_num_title = cc.Label:createWithSystemFont("可行动次数:", nil, 40)
	label_rest_num_title:setTextColor(cc.c4b(100, 200, 255, 255))
	label_rest_num_title:setAnchorPoint(cc.p(0, 0.5))
	-- label_rest_num_title:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNumTitle", 50, visible_size.height / 2, label_rest_num_title)

	local rect = label_rest_num_title:getBoundingBox()
	local label_rest_num = cc.Label:createWithSystemFont("0", "Arial", 40)
	label_rest_num:setTextColor(cc.c4b(100, 200, 255, 255))
	label_rest_num:setAnchorPoint(cc.p(0, 0))
	-- label_rest_num:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNum", rect.x + rect.width + 10, rect.y , label_rest_num)
end

function Scene:InitButtonMenu()
	local ui_frame = self:GetUI()
	local element_list = {
 		{
	    	{
				item_name = "Spawn",
	        	callback_function = function()
	        		if GameStateMachine:CanOperate() ~= 1 then
	        			return
	        		end
	        		ActionMgr:ChangeRestRoundNum(-1)
	        		ViewInterface:WaitWatchEnd(0.5, 
	        			function()
	        				if ActionMgr:GetRestRoundNum() > 0 then
								Event:FireEvent("GAME.AI_ACTIVE")
							else
								ActionMgr:NextRound()
							end
	        			end
	        		)
	        		CommandCenter:ReceiveCommand({"SpawnChess"})	        		
	        	end,
	        },
	    },
	    {
	        {
				item_name = "End",
	        	callback_function = function()
	        		if GameStateMachine:CanOperate() ~= 1 then
	        			return
	        		end
	        		CommandCenter:ReceiveCommand({"EndAction"})
	        	end,
	        },
	    },
	}
	

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 40, align_type = "center", interval_x = 50, interval_y = 30}
    )
    if height > visible_size.height then
    	self:SetHeight(height)
    end
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "operate")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "operate")
    end
    Ui:AddElement(ui_frame, "MENU", "operate", visible_size.width - width / 2 - 20, 130, menu_tools)
end

function Scene:InitPlayerHPUI()
	local ui_frame = self:GetUI()

	local x, y = SelfMap:Logic2Pixel(0, Def.MAP_HEIGHT + 1.5)
	local progress_self_bg = cc.Sprite:create("god/xuetiao-di.png")
	progress_self_bg:setScale(4)
	progress_self_bg:setAnchorPoint(cc.p(0, 0.5))
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "self_bg", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_self_bg)

	local progress_self = ProgressBar:GenerateByFile("god/xuetiao-hong.png", 100)	
	progress_self:setScale(4)
	progress_self:setAnchorPoint(cc.p(0, 0.5))
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "self", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_self)

	local rect = progress_self:getBoundingBox()
	local label_self_hp = cc.Label:createWithSystemFont(string.format("%3d / %3d", 100, 100), "Arial", 40)
	label_self_hp:setTextColor(cc.c4b(100, 200, 255, 255))
	Ui:AddElement(ui_frame, "LABEL", "self_hp", rect.x + rect.width / 2, rect.y + rect.height / 2, label_self_hp)

	x, y = EnemyMap:Logic2Pixel(0, Def.MAP_HEIGHT + 1.5)

	local progress_enemy_bg = cc.Sprite:create("god/xuetiao-di.png")
	progress_enemy_bg:setScale(4)
	progress_enemy_bg:setAnchorPoint(cc.p(0, 0.5))
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "enemy_bg", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_enemy_bg)

	local progress_enemy = ProgressBar:GenerateByFile("god/xuetiao-hong.png", 100)
	progress_enemy:setScale(4)
	progress_enemy:setAnchorPoint(cc.p(0, 0.5))
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "enemy", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_enemy)

	local rect = progress_enemy:getBoundingBox()
	local label_enemy_hp = cc.Label:createWithSystemFont(string.format("%3d / %3d", 100, 100), "Arial", 40)
	label_enemy_hp:setTextColor(cc.c4b(100, 200, 255, 255))
	Ui:AddElement(ui_frame, "LABEL", "enemy_hp", rect.x + rect.width / 2, rect.y + rect.height / 2, label_enemy_hp)
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
	local result = TouchInput:OnTouchBegan(x, y)
	if result == 1 then
		local map = GameStateMachine:GetActiveMap()
		local logic_x, logic_y = map:Pixel2Logic(x, y)
		if logic_x < 1 then
			logic_x = 1
		elseif logic_x > Def.MAP_WIDTH then
			logic_x = Def.MAP_WIDTH
		end
		local highlight_x, highlight_y = map:Logic2Pixel(logic_x, logic_y)
		local highlight_green = self:GetObj("main", "draw", "highlight_green")
		highlight_green:setPosition(highlight_x, visible_size.height * 0.5)
		highlight_green:setVisible(true)
	end
end

function Scene:OnTouchMoved(x, y)
	local result = TouchInput:OnTouchMoved(x, y)
	if not result then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, logic_y = map:Pixel2Logic(x, y)
	if logic_x < 1 then
		logic_x = 1
	elseif logic_x > Def.MAP_WIDTH then
		logic_x = Def.MAP_WIDTH
	end
	local highlight_x, highlight_y = map:Logic2Pixel(logic_x, logic_y)
	if result == 1 then
		local highlight_green = self:GetObj("main", "draw", "highlight_green")
		highlight_green:setPosition(highlight_x, visible_size.height * 0.5)
		highlight_green:setVisible(true)

		local highlight_red = self:GetObj("main", "draw", "highlight_red")
		highlight_red:setVisible(false)
	elseif result == 0 then
		local highlight_red = self:GetObj("main", "draw", "highlight_red")
		highlight_red:setPosition(highlight_x, visible_size.height * 0.5)
		highlight_red:setVisible(true)

		local highlight_green = self:GetObj("main", "draw", "highlight_green")
		highlight_green:setVisible(false)
	end
end

function Scene:OnTouchEnded(x, y)
	local result = TouchInput:OnTouchEnded(x, y)
	if result == 1 then
		local highlight_green = self:GetObj("main", "draw", "highlight_green")
		highlight_green:setVisible(false)

		local highlight_red = self:GetObj("main", "draw", "highlight_red")
		highlight_red:setVisible(false)
	end
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
	return self:MoveChessToPosition(chess, x, y, Def.CHESS_MOVE_SPEED)
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
	return self:MoveChessToPosition(chess, x, y, Def.CHESS_MOVE_SPEED)
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
	local label = self:GetObj("chess", "wait_round", id)
	if round > 0 then
		if not label then
			label = cc.LabelBMFont:create(tostring(round), "fonts/img_font.fnt")
			local rect = chess_sprite:getBoundingBox()
			local scale = chess_sprite:getScale()
			label:setPosition(rect.width * 0.5 / scale, rect.height * 0.5 / scale)
			self:AddObj("chess", "wait_round", id, label)
			chess_sprite:addChild(label)
		end
		label:setString(tostring(round))
	else
		if label then
			chess_sprite:removeChild(label, true)
			self:RemoveObj("chess", "wait_round", id)
		end
	end
end

function Scene:OnEnemyChessWaitRoundChanged(id, round)
	local chess_sprite = self:GetObj("main", EnemyMap:GetClassName(), id)
	local label = self:GetObj("enemy_chess", "wait_round", id)
	if round > 0 then
		if not label then
			label = cc.LabelBMFont:create(tostring(round), "fonts/img_font.fnt")
			label:setAnchorPoint(cc.p(0.5, 0.5))
			local rect = chess_sprite:getBoundingBox()
			local scale = chess_sprite:getScale()
			label:setPosition(rect.width * 0.5 / scale, rect.height * 0.5 / scale)
			self:AddObj("enemy_chess", "wait_round", id, label)
			chess_sprite:addChild(label)
		end
		label:setString(tostring(round))
	else
		if label then
			chess_sprite:removeChild(label, true)
			self:RemoveObj("enemy_chess", "wait_round", id)
		end
	end
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
	local x, y = map:Logic2Pixel(logic_x, Def.MAP_HEIGHT)
	chess:setPosition(x, y)
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

function Scene:MoveChessToPosition(chess, x, y, speed, call_back)
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
	local time = math.abs(y - start_y) / speed
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
	chess_sprite:runAction(cc.Sequence:create(move_action, callback_action))
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

function Scene:ChessAttack(chess, target_chess, call_back)
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
	local job_id = slave_waite_helper:WaitJob(10, func_time_over)
	local function func_time_over(id)
		call_back()
	end
	local battle_waiter_helper = self:GetSlaveWatchWaiter("battle")
	local battle_job_id = nil
	if battle_waiter_helper then
		battle_job_id = battle_waiter_helper:WaitJob(11)
	end
	local callback_action = cc.CallFunc:create(
		function()
			if call_back and type(call_back) == "function" then
				call_back(
)			end
			slave_waite_helper:JobComplete(job_id)
			if battle_waiter_helper and battle_job_id then
				battle_waiter_helper:JobComplete(battle_job_id)
			end
		end
	)
	local delay_action = cc.DelayTime:create(0.5)
	chess_sprite:runAction(cc.Sequence:create(delay_action, callback_action))
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
	local chess = ChessPool:GetById(id)
	if not chess then
		asset(false)
		return
	end
	return self:_OnChessLifeChanged(chess, new_life, old_life)
end

function Scene:OnEnemyChessLifeChanged(id, new_life, old_life)
	local enemy_chess = EnemyChessPool:GetById(id)
	if not enemy_chess then
		asset(false)
		return
	end
	return self:_OnChessLifeChanged(enemy_chess, new_life, old_life)
end

function Scene:_OnChessLifeChanged(chess, new_life, old_life)
	local map = chess:GetMap()
	local id = chess:GetId()
	local sprite = self:GetObj("main", map:GetClassName(), id)
	self:_OnLifeChanged(sprite, new_life - old_life)

	if chess:TryCall("GetState") == Def.STATE_NORMAL then
		return
	end
	local progress_hp = self:GetObj(map:GetClassName(), "hp", id)
	if not progress_hp then
		progress_hp = ProgressBar:GenerateByFile("god/xuetiao-lv.png", 100)
		local rect = sprite:getBoundingBox()
		local scale = sprite:getScale()

		local progress_hp_rect = progress_hp:getBoundingBox()
		progress_hp:setScaleX((rect.width - 4) / progress_hp_rect.width)

		local progress_bg = cc.Sprite:create("god/xuetiao-di.png")
		local progress_bg_rect = progress_bg:getBoundingBox()
		progress_bg:setScaleX(rect.width / progress_hp_rect.width)

		local x, y = rect.width * 0.5 / scale, (rect.height + progress_bg_rect.height * 0.5) / scale
		progress_hp:setPosition(x, y)
		self:AddObj(map:GetClassName(), "hp", id, progress_hp)
			
		progress_bg:setPosition(x, y)
		sprite:addChild(progress_bg)
		sprite:addChild(progress_hp)
	end
	local life = chess:GetLife()
	local max_life = chess:GetMaxLife()
	progress_hp:setPercentage((life / max_life) * 100)
end

function Scene:_OnLifeChanged(sprite, change_value, percent_x, percent_y, text_scale)
	local layer_main = self:GetLayer("main")
	local text = tostring(change_value)
	local param = {
		color     = "red",
		percent_x = percent_x or 0,
		percent_y = percent_y or 0.5,
		up_time   = 1,
		up_y      = 40,
		fade_time = 0.5,
		zorder	  = 1000,
		-- fade_up_y = 10,
		text_scale = text_scale or 1.2,
	}
	if change_value > 0 then
		param.color = "green"
		text = "+"..text
	end
	FlyText:VerticalShake(layer_main, sprite, "fonts/img_font.fnt", text, param)
end

function Scene:OnSetSelfPlayerHP(new_life, old_life)
	local change_value = new_life - old_life
	local ui_frame = self:GetUI()
	local progress_bar = Ui:GetElement(ui_frame, "PROGRESS_BAR", "self")
	local max_life = Player:GetMaxSelfHP()
	local percentage = (new_life / max_life) * 100
	progress_bar:setPercentage(percentage)
	self:_OnLifeChanged(progress_bar, change_value, 0.5, 0.5, 3)

	local label = Ui:GetElement(ui_frame, "LABEL", "self_hp")
	label:setString(string.format("%3d / %3d", new_life, max_life))
end

function Scene:OnSetEnemyPlayerHP(new_life, old_life)
	local change_value = new_life - old_life
	local ui_frame = self:GetUI()
	local progress_bar = Ui:GetElement(ui_frame, "PROGRESS_BAR", "enemy")
	local max_life = Player:GetMaxEnemyHP()
	local percentage = (new_life / max_life) * 100
	progress_bar:setPercentage(percentage)
	self:_OnLifeChanged(progress_bar, change_value, 0.5, 0.5, 3)

	local label = Ui:GetElement(ui_frame, "LABEL", "enemy_hp")
	label:setString(string.format("%3d / %3d", new_life, max_life))
end