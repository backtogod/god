--=======================================================================
-- File Name    : touch_input.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 00:18:57 2014
-- Description  : handle user touch input
-- Modify       :
--=======================================================================
if not TouchInput then
	TouchInput = ModuleMgr:NewModule("TouchInput")
end

function TouchInput:_Uninit( ... )
	return 1
end

function TouchInput:_Init( ... )
	return 1
end

function TouchInput:OnDoubleTouch(logic_x, logic_y)
	print("OnDoubleTouch", logic_x, logic_y)
	local ret_code, result = CommandCenter:ReceiveCommand({"DestoryChess", logic_x, logic_y})
	return result
end

function TouchInput:OnTouchBegan(x, y)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, logic_y = map:Pixel2Logic(x, y)
	if logic_y < 1 then
		return
	end
	if logic_x < 1 then
		logic_x = 1
	elseif logic_x > Def.MAP_WIDTH then
		logic_x = Def.MAP_WIDTH
	end
	local ret_code, pick_id = CommandCenter:ReceiveCommand({"PickChess",  logic_x, logic_y})
	if ret_code and pick_id then
		self.pick_id = pick_id
		self.last_logic_x = logic_x
		self.pick_logic_x = logic_x
		return 1
	end
end

function TouchInput:OnTouchMoved(x, y)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	if not self.pick_logic_x then
		return
	end
	local id = self.pick_id
	if not id then
		return
	end

	local map = GameStateMachine:GetActiveMap()
	local logic_x, logic_y = map:Pixel2Logic(x, y)
	if logic_x < 1 then
		logic_x = 1
	elseif logic_x > Def.MAP_WIDTH then
		logic_x = Def.MAP_WIDTH
	end
	if logic_x == self.last_logic_x then
		return
	end
	self.last_logic_x = logic_x

	local ret_code, result = CommandCenter:ReceiveCommand({"TryMovePickChess", id, logic_x})
	return result
end

function TouchInput:OnTouchEnded(x, y, is_move)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, logic_y = map:Pixel2Logic(x, y)

	local id = self.pick_id
	if id then
		if logic_x < 1 then
			logic_x = 1
		elseif logic_x > Def.MAP_WIDTH then
			logic_x = Def.MAP_WIDTH
		end
		local is_success = 0
		if self.pick_logic_x ~= logic_x then
			local ret_code, result = CommandCenter:ReceiveCommand({"TryDropChess", id, logic_x})
			if ret_code and result == 1 then
				is_success = 1
			end
		end
		if is_success == 0 then
			local ret_code, result = CommandCenter:ReceiveCommand({"CancelPickChess", id})
		end
		self.pick_id = nil
		self.last_logic_x = nil
		self.pick_logic_x = nil
	end
	if is_move == 1 then
		self.last_touch_end_frame = nil
	else
		local current_frame = GameMgr:GetCurrentFrame()
		if self.last_touch_end_frame and self.last_begin_x == logic_x and self.last_begin_y == logic_y then
			local seconds = (current_frame - self.last_touch_end_frame) / GameMgr:GetFPS()
			if seconds < 0.4 then
				self:OnDoubleTouch(logic_x, logic_y)
			end
		end
		self.last_touch_end_frame = current_frame
		self.last_begin_x , self.last_begin_y = logic_x, logic_y
	end
	return 1
end
