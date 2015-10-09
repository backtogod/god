--=======================================================================
-- File Name    : vs_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 21:31:32 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("VSScene", 1)

Scene:DeclareListenEvent("CHESS.ADD", "OnSelfChessAdd")
Scene:DeclareListenEvent("CHESS.REMOVE", "OnSelfChessRemove")
Scene:DeclareListenEvent("CHESS.SET_POSITION", "OnSelfChessSetPosition")
Scene:DeclareListenEvent("CHESS.SET_DISPLAY_POSITION", "OnSelfChessSetDisplayPosition")
Scene:DeclareListenEvent("CHESS.SET_TEMPLATE", "OnSelfChessSetTemplate")
Scene:DeclareListenEvent("CHESS.WAIT_ROUND_CHANGED", "OnSelfChessWaitRoundChanged")
Scene:DeclareListenEvent("CHESS.LIFE_CHANGED", "OnSelfChessLifeChanged")
Scene:DeclareListenEvent("CHESS.LIFE_UPDATED", "OnSelfChessLifeUpdated")

Scene:DeclareListenEvent("ENEMY_CHESS.ADD", "OnEnemyChessAdd")
Scene:DeclareListenEvent("ENEMY_CHESS.REMOVE", "OnEnemyChessRemove")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_POSITION", "OnEnemyChessSetPosition")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_DISPLAY_POSITION", "OnEnemyChessSetDisplayPosition")
Scene:DeclareListenEvent("ENEMY_CHESS.SET_TEMPLATE", "OnEnemyChessSetTemplate")
Scene:DeclareListenEvent("ENEMY_CHESS.WAIT_ROUND_CHANGED", "OnEnemyChessWaitRoundChanged")
Scene:DeclareListenEvent("ENEMY_CHESS.LIFE_CHANGED", "OnEnemyChessLifeChanged")
Scene:DeclareListenEvent("ENEMY_CHESS.LIFE_UPDATED", "OnEnemyChessLifeUpdated")


Scene:DeclareListenEvent("PICKHELPER.PICK", "OnPickChess")
Scene:DeclareListenEvent("PICKHELPER.CANCEL_PICK", "OnCancelPickChess")
Scene:DeclareListenEvent("PICKHELPER.DROP", "OnDropChess")

Scene:DeclareListenEvent("GAME.ACTION_START", "OnActionStart")
Scene:DeclareListenEvent("GAME.ROUND_REST_NUM_CHANGED", "OnRoundRestNumChanged")
Scene:DeclareListenEvent("GAME_STATE.CHANGE", "OnGameStateChanged")
Scene:DeclareListenEvent("GAME.COMBO_CHANGED", "OnComboChanged")

Scene:DeclareListenEvent("PLAYER.SET_SELF_HP", "OnSetSelfPlayerHP")
Scene:DeclareListenEvent("PLAYER.SET_ENEMY_HP", "OnSetEnemyPlayerHP")

function Scene:_Preload()
	self:EnableTouch(1)
end

function Scene:_Uninit( ... )

	Battle:Uninit()
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

	local stage_config = VSStageConfig:GetConfig(self:GetName())
	if not stage_config then
		return
	end
	assert(self:InitUI() == 1)
	assert(Mover:Init() == 1)
	assert(CommandCenter:Init() == 1)
	assert(TouchInput:Init() == 1)
	assert(GameStateMachine:Init(stage_config.init_state) == 1)
	assert(Player:Init(stage_config.self_max_hp, stage_config.self_hp, stage_config.enemy_max_np, stage_config.enemy_np) == 1)
	assert(SelfMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT, stage_config.self_map_data, stage_config.self_spec, stage_config.self_wave_count) == 1)
	assert(EnemyMap:Init(Def.MAP_WIDTH, Def.MAP_HEIGHT, stage_config.enemy_map_data, stage_config.enemy_spec, stage_config.enemy_wave_count) == 1)
	assert(PickHelper:Init(1) == 1)
	assert(VSRobot:Init() == 1)
	assert(Battle:Init() == 1)

	-- SelfMap:Debug()
	-- EnemyMap:Debug()
	return 1
end

function Scene:InitUI()
	self:AddReturnMenu(50)
	self:AddReloadMenu(50)

	-- self:SetBackGroundImage({"god/map.png"}, 0)

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
	self:DrawGrip()
	self:InitButtonMenu()
	self:InitPlayerHPUI()

	local ui_frame = self:GetUI()

	local layer_gray = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), visible_size.width, visible_size.height)
	layer_gray:setVisible(false)
	Ui:AddElement(ui_frame, "MASK", "gray", 0, 0, layer_gray)

	local label_combo = cc.Label:createWithSystemFont("COMBO X", "Arial", 100)
	label_combo:setVisible(false)
	Ui:AddElement(ui_frame, "LABEL", "combo", visible_size.width / 2, visible_size.height / 2, label_combo)

	local label_round_tip = cc.Label:createWithSystemFont("ROUND X", "Arial", 100)
	label_round_tip:setVisible(false)
	label_round_tip:enableOutline(cc.c4b(0, 0, 100, 255), 5)
	Ui:AddElement(ui_frame, "LABEL", "round_tip", visible_size.width / 2, visible_size.height / 2, label_round_tip)

	return 1
end

function Scene:OnCocosButtonEvent(ui_name, button_name, event)
	if event == Ui.TOUCH_EVENT_ENDED then
		if ui_name == "GodUI" then
			if button_name == "Spawn" then
				if GameStateMachine:CanOperate() ~= 1 then
        			return
        		end
        		CommandCenter:ReceiveCommand({"SpawnChess"})
			elseif button_name == "End" then
				if GameStateMachine:CanOperate() ~= 1 then
        			return
        		end
        		CommandCenter:ReceiveCommand({"EndAction"})
			elseif button_name == "Return" then
				SceneMgr:UnLoadCurrentScene()
			end
		end
	end
end
function Scene:InitDebugUI()
	local ui_frame = self:GetUI()

	local label_round = cc.Label:createWithSystemFont("Round 1", "Arial", 40)
	label_round:setTextColor(cc.c4b(100, 200, 255, 255))
	label_round:setAnchorPoint(cc.p(0, 0.5))
	-- label_round:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RoundTitle", 10, visible_size.height - 75, label_round)

	local label_state = cc.Label:createWithSystemFont("UNKNOWN", "Arial", 30)
	label_state:setTextColor(cc.c4b(100, 200, 255, 255))
	label_state:setAnchorPoint(cc.p(0, 0.5))
	-- label_state:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "State", visible_size.width / 2, visible_size.height * 0.5, label_state)

	local label_rest_num_title = cc.Label:createWithSystemFont("可行动次数:", nil, 30)
	label_rest_num_title:setTextColor(cc.c4b(255, 255, 255, 255))
	label_rest_num_title:setAnchorPoint(cc.p(0, 0.5))
	-- label_rest_num_title:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(10, 10), 10)
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNumTitle", 10, visible_size.height / 2, label_rest_num_title)

	local rect = label_rest_num_title:getBoundingBox()
	local label_rest_num = cc.Label:createWithSystemFont("0", "Arial", 70)
	label_rest_num:setTextColor(cc.c4b(100, 200, 255, 255))
	label_rest_num:setAnchorPoint(cc.p(0, 0.5))
	label_rest_num:enableShadow(cc.c4b(100, 100, 100, 255), cc.size(3, -3))
	Ui:AddElement(ui_frame, "LABEL", "RestRoundNum", rect.x + rect.width + 20, visible_size.height / 2 , label_rest_num)
end

function Scene:InitButtonMenu()
	local ui_frame = self:GetUI()
	local element_list = {
 		{
	    	{
				item_name = "召唤怪物",
	        	callback_function = function()
	        		if GameStateMachine:CanOperate() ~= 1 then
	        			return
	        		end
	        		CommandCenter:ReceiveCommand({"SpawnChess"})
	        	end,
	        },
	        {
				item_name = "结束本回合",
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
    	{font_size = 40, align_type = "center", interval_x = 100, interval_y = 30}
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
    Ui:AddElement(ui_frame, "MENU", "operate", visible_size.width  / 2 , 80, menu_tools)
end

function Scene:InitPlayerHPUI()
	local ui_frame = self:GetUI()

	local x, y = SelfMap:Logic2Pixel(1, Def.MAP_HEIGHT)
	y = y - 80
	local progress_self_bg = cc.Sprite:create("god/xuetiao-di.png")
	progress_self_bg:setScale(4)
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "self_bg", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_self_bg)

	local progress_self = ProgressBar:GenerateByFile("god/xuetiao-hong.png", 100)
	progress_self:setScale(4)
	progress_self:setAnchorPoint(cc.p(0, 0.5))
	Ui:AddElement(ui_frame, "PROGRESS_BAR", "self", x + 22, y + Def.MAP_CELL_HEIGHT * 0.5, progress_self)

	local rect = progress_self:getBoundingBox()
	local label_self_hp = cc.Label:createWithSystemFont(string.format("%3d / %3d", 100, 100), "Arial", 40)
	label_self_hp:setTextColor(cc.c4b(100, 200, 255, 255))
	Ui:AddElement(ui_frame, "LABEL", "self_hp", rect.x + rect.width / 2, rect.y + rect.height / 2, label_self_hp)

	x, y = EnemyMap:Logic2Pixel(1, Def.MAP_HEIGHT)
	y = y + 80

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

function Scene:GenerateChessSprite(image_name)
	local sprite = cc.Sprite:create(image_name)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	local rect = sprite:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	local scale_y = Def.MAP_CELL_HEIGHT / rect.height
	sprite:setScaleX(scale_x)
	if scale_y < 1 then
		sprite:setScaleY(scale_y)
	end
	return sprite
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

function Scene:SetMapChessPosition(map, id, logic_x, logic_y)
	local chess = self:GetObj("main", map:GetClassName(), id)
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	chess:setPosition(x, y)
	chess:setLocalZOrder(visible_size.height - y)
end


function Scene:StartBattle(min_wait_time, max_wait_time, call_back)
	local waiter = self:NewSlaveWatchWaiter("battle", min_wait_time, max_wait_time, call_back)
	print("new battle waiter")
	waiter:EnableDebug(1)
	return waiter
end

function Scene:PlayTip(min_wait_time, max_wait_time, text_msg, call_back)
	local round_waiter = self:NewSlaveWatchWaiter("round_start", min_wait_time, max_wait_time, call_back)
	local job_id = round_waiter:WaitJob(max_wait_time)

	local ui_frame = self:GetUI()
	local label = Ui:GetElement(ui_frame, "LABEL", "round_tip")
	if not label then
		assert(false)
		return
	end
	Ui:SetVisible(ui_frame, "MASK", "gray", true)
	label:setVisible(true)
	label:setString(text_msg)
	label:setScale(0.1)

	local action_scale_to = cc.ScaleTo:create(0.8, 1)
	local action_delay = cc.DelayTime:create(1)
	local action_call_back = cc.CallFunc:create(
		function()
			Ui:SetVisible(ui_frame, "MASK", "gray", false)
			label:setVisible(false)
			round_waiter:JobComplete(job_id)
		end
	)
	label:stopAllActions()
	label:runAction(cc.Sequence:create(action_scale_to, action_delay, action_call_back))
end


function Scene:OnTouchBegan(x, y)
	return TouchInput:OnTouchBegan(x, y)
end

function Scene:OnTouchMoved(x, y)
	return TouchInput:OnTouchMoved(x, y)
end

function Scene:OnTouchEnded(x, y)
	return TouchInput:OnTouchEnded(x, y, self:IsMove())
end

function Scene:OnSelfChessAdd(id, template_id, logic_x, logic_y)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessAdd(chess, template_id, logic_x, logic_y)
end

function Scene:OnEnemyChessAdd(id, template_id, logic_x, logic_y)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessAdd(chess, template_id, logic_x, logic_y)
end

function Scene:OnChessAdd(chess, template_id, logic_x, logic_y)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = NewPuppet(chess:GetClassName())
	local sprite = cc.Sprite:create()
	puppet:SetSprite(sprite)
	self:AddObj("puppet", map:GetClassName(), id, puppet)
	local chess_sprite = self:GenerateChessSprite(config.image)
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	puppet:AddChildElement("body", chess_sprite, 0, 0, 1, 10)
	self:AddObj("main", map:GetClassName(), id, puppet:GetSprite())
	self:SetMapChessPosition(map, id, logic_x, logic_y)
end

function Scene:OnSelfChessRemove(id)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessRemove(chess)
end

function Scene:OnEnemyChessRemove(id)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessRemove(chess)
end

function Scene:OnChessRemove(chess)
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = self:GetObj("puppet", map:GetClassName(), id)
	puppet:Uninit()
	self:RemoveObj("puppet", map:GetClassName(), id)
	self:RemoveObj("main", map:GetClassName(), id)
end

function Scene:OnSelfChessSetPosition(id, logic_x, logic_y)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetPosition(chess, logic_x, logic_y)
end

function Scene:OnEnemyChessSetPosition(id, logic_x, logic_y)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetPosition(chess, logic_x, logic_y)
end

function Scene:OnChessSetPosition(chess, logic_x, logic_y)
	local map = chess:GetMap()
	local id = chess:GetId()
	return self:SetMapChessPosition(map, id, logic_x, logic_y)
end

function Scene:OnSelfChessSetDisplayPosition(id, logic_x, logic_y)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetDisplayPosition(chess, logic_x, logic_y)
end

function Scene:OnEnemyChessSetDisplayPosition(id, logic_x, logic_y)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetDisplayPosition(chess, logic_x, logic_y)
end

function Scene:OnChessSetDisplayPosition(chess, logic_x, logic_y)
	local map = chess:GetMap()
	local id = chess:GetId()
	local chess_sprite = self:GetObj("main", map:GetClassName(), id)
	local x, y = map:Logic2Pixel(logic_x, logic_y)
	chess_sprite:setPosition(x, y)
	chess_sprite:setLocalZOrder(visible_size.height - y)

	local highlight_x, highlight_y = map:Logic2Pixel(logic_x, logic_y)
	local highlight_green = self:GetObj("main", "draw", "highlight_green")
	highlight_green:setPosition(highlight_x, visible_size.height * 0.5)
	highlight_green:setVisible(true)

	local highlight_red = self:GetObj("main", "draw", "highlight_red")
	highlight_red:setVisible(false)
end

function Scene:OnSelfChessSetTemplate(id, template_id)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetTemplate(chess, template_id)
end

function Scene:OnEnemyChessSetTemplate(id, template_id)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessSetTemplate(chess, template_id)
end

function Scene:OnChessSetTemplate(chess, template_id)
	local config = ChessConfig:GetData(template_id)
	if not config then
		assert(false)
		return
	end
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = self:GetObj("puppet", map:GetClassName(), id)
	puppet:RemoveChildElement("body")

	local sprite = self:GenerateChessSprite(config.image)
	puppet:AddChildElement("body", sprite, 0, 0, 1, 10)
end

function Scene:OnSelfChessWaitRoundChanged(id, round)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessWaitRoundChanged(chess, round)
end

function Scene:OnEnemyChessWaitRoundChanged(id, round)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessWaitRoundChanged(chess, round)
end

function Scene:OnChessWaitRoundChanged(chess, round)
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = self:GetObj("puppet", map:GetClassName(), id)
	local chess_sprite = puppet:GetChildElement("body")

	local label = puppet:GetChildElement("wait_round")
	if round > 0 then
		if not label then
			label = cc.LabelBMFont:create(tostring(round), "fonts/img_font.fnt")
			local rect = chess_sprite:getBoundingBox()
			label:setScale(1.5)
			puppet:AddChildElement("wait_round", label, 0, Def.MAP_CELL_HEIGHT * 0.5, 0, 11)
		end
		label:setString(tostring(round))
	else
		if label then
			puppet:RemoveChildElement("wait_round")
		end
	end
end

function Scene:OnSelfChessLifeUpdated(id, new_life)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessLifeUpated(chess, new_life)
end

function Scene:OnEnemyChessLifeUpdated(id, new_life)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessLifeUpated(chess, new_life)
end

function Scene:OnChessLifeUpated(chess, new_life)
	if chess:TryCall("GetState") == Def.STATE_NORMAL then
		return
	end
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = self:GetObj("puppet", map:GetClassName(), id)
	local sprite = puppet:GetChildElement("body")

	local progress_hp = puppet:GetChildElement("hp")
	if not progress_hp then
		progress_hp = ProgressBar:GenerateByFile("god/xuetiao-lv.png", 100)
		local rect = sprite:getBoundingBox()

		local progress_hp_rect = progress_hp:getBoundingBox()
		progress_hp:setScaleX((rect.width - 4) / progress_hp_rect.width)
		progress_hp:setScaleY(1.5)

		local progress_bg = cc.Sprite:create("god/xuetiao-di.png")
		local progress_bg_rect = progress_bg:getBoundingBox()
		progress_bg:setScaleX(rect.width / progress_hp_rect.width)

		local x, y = 0, progress_bg_rect.height * 0.5
		puppet:AddChildElement("hp", progress_hp, x, y, 0, 12)
		puppet:AddChildElement("hp_bg", progress_bg, x, y, 0, 11)

		local rect = sprite:getBoundingBox()
		label_hp = cc.Label:createWithSystemFont(tostring(life), nil, 25)
		label_hp:enableOutline(cc.c4b(1, 0, 0, 1), 2)
		puppet:AddChildElement("hp_num", label_hp, x, y, 0, 12)
	end

	local life = chess:GetLife()
	local max_life = chess:GetMaxLife()
	progress_hp:setPercentage((life / max_life) * 100)

	local label_hp = puppet:GetChildElement("hp_num")
	label_hp:setString(string.format("%d/%d", life, max_life))
end

function Scene:OnSelfChessLifeChanged(id, new_life, old_life)
	local chess = ChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessLifeChanged(chess, new_life, old_life)
end

function Scene:OnEnemyChessLifeChanged(id, new_life, old_life)
	local chess = EnemyChessPool:GetById(id)
	if not chess then
		assert(false)
		return
	end
	return self:OnChessLifeChanged(chess, new_life, old_life)
end

function Scene:OnChessLifeChanged(chess, new_life, old_life)
	local map = chess:GetMap()
	local id = chess:GetId()
	local puppet = self:GetObj("puppet", map:GetClassName(), id)

	local sprite = puppet:GetChildElement("body")
	self:_OnLifeChanged(puppet:GetSprite(), new_life - old_life, 0, 0)
end

function Scene:MoveChessToPosition(chess, start_x, start_y, x, y, speed, call_back)
	local chess_id = chess:GetId()
	local map = chess:GetMap()

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
	local function func_time_over(id)
		call_back()
	end
	if start_x and start_y then
		chess_sprite:setPosition(start_x, start_y)
	else
		start_x, start_y = chess_sprite:getPosition()
	end
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
			chess_sprite:setLocalZOrder(visible_size.height - y)
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
	local map = chess:GetMap()

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

	local action_list = {}
	if state == Def.STATE_WALL then
		action_list[#action_list + 1] = cc.Blink:create(Def.TRANSFORM_TIME, 5)
	elseif state == Def.STATE_ARMY then
		action_list[#action_list + 1] = cc.ScaleTo:create(Def.TRANSFORM_TIME * 0.5, 2)
		action_list[#action_list + 1] = cc.ScaleTo:create(Def.TRANSFORM_TIME * 0.5, 1)
	end
	action_list[#action_list + 1] = cc.CallFunc:create(
		function()
			if call_back and type(call_back) == "function" then
				call_back()
			end
			slave_waite_helper:JobComplete(job_id)
		end
	)
	chess_sprite:runAction(cc.Sequence:create(unpack(action_list)))
end

function Scene:ChessAttack(chess, target_chess, call_back)
	local chess_id = chess:GetId()
	local map = chess:GetMap()

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
				call_back()
			end
			slave_waite_helper:JobComplete(job_id)
			if battle_waiter_helper and battle_job_id then
				battle_waiter_helper:JobComplete(battle_job_id)
			end
		end
	)
	local delay_action = cc.DelayTime:create(0.1)
	chess_sprite:runAction(cc.Sequence:create(delay_action, callback_action))
end

function Scene:_OnLifeChanged(sprite, change_value, percent_x, percent_y, text_scale)
	if change_value == 0 then
		return
	end
	local layer_main = self:GetLayer("main")
	local text = tostring(change_value)
	local param = {
		color     = "red",
		percent_x = percent_x or 0,
		percent_y = percent_y or 0.5,
		offset_y = Def.MAP_CELL_HEIGHT * 0.5,
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


function Scene:OnPickChess(id, logic_x, logic_y)
	local map = GameStateMachine:GetActiveMap()
	local map_name = map:GetClassName()
	local chess = self:GetObj("main", map_name, id)
	local puppet = self:GetObj("puppet", map_name, id)
	local sprite = puppet:GetChildElement("body")
	sprite:setOpacity(100)

	local copy_chess = cc.Sprite:createWithTexture(chess:getTexture())
	copy_chess:setAnchorPoint(cc.p(0.5, 0))
	copy_chess:setOpacity(100)
	local rect = copy_chess:getBoundingBox()
	local scale_x = Def.MAP_CELL_WIDTH / rect.width
	copy_chess:setScale(scale_x)
	self:AddObj("main", map_name, "copy", copy_chess)
	self:SetMapChessPosition(map, "copy", logic_x, logic_y)

	local highlight_x, highlight_y = map:Logic2Pixel(logic_x, logic_y)
	local highlight_green = self:GetObj("main", "draw", "highlight_green")
	highlight_green:setPosition(highlight_x, visible_size.height * 0.5)
	highlight_green:setVisible(true)
end

function Scene:OnCancelPickChess(id)
	local map = GameStateMachine:GetActiveMap()
	local map_name = map:GetClassName()
	local chess = self:GetObj("main", map_name, id)
	local logic_chess = map.obj_pool:GetById(id)
	self:SetMapChessPosition(map, id, logic_chess.x, logic_chess.y)
	local puppet = self:GetObj("puppet", map_name, id)
	local sprite = puppet:GetChildElement("body")
	sprite:setOpacity(255)
	self:RemoveObj("main", map_name, "copy")

	local highlight_green = self:GetObj("main", "draw", "highlight_green")
	highlight_green:setVisible(false)

	local highlight_red = self:GetObj("main", "draw", "highlight_red")
	highlight_red:setVisible(false)
end

function Scene:OnDropChess(id, logic_x, logic_y, old_x, old_y)
	local map = GameStateMachine:GetActiveMap()
	local map_name = map:GetClassName()
	local chess = self:GetObj("main", map_name, id)
	assert(chess)
	local puppet = self:GetObj("puppet", map_name, id)
	local sprite = puppet:GetChildElement("body")
	sprite:setOpacity(255)
	self:RemoveObj("main", map_name, "copy")

	local highlight_green = self:GetObj("main", "draw", "highlight_green")
	highlight_green:setVisible(false)

	local highlight_red = self:GetObj("main", "draw", "highlight_red")
	highlight_red:setVisible(false)
	local x, y = map:Logic2Pixel(logic_x, Def.MAP_HEIGHT)
	chess:setPosition(x, y)
	ActionMgr:OperateChess(map, id, logic_x, logic_y, old_x, old_y)
end

function Scene:OnSlaveWaiterComplete(waiter_name, job_id, call_back)
	local master_waiter = self:GetMasterWatchWaiter()
	assert(master_waiter)
	self.slave_wait_helper_list[waiter_name]:Uninit()
	self.slave_wait_helper_list[waiter_name] = nil
	if call_back then
		assert(type(call_back) == "function")
		call_back()
	end
	master_waiter:JobComplete(job_id)
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
