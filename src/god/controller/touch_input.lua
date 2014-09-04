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

function TouchInput:OnTouchBegan(x, y)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, check_y = map:Pixel2Logic(x, y)
	if check_y < 1 or check_y > Def.MAP_HEIGHT then
		return
	end
	local ret_code, pick_id = CommandCenter:ReceiveCommand({"PickChess", logic_x})
	if ret_code and pick_id then
		self.pick_id = pick_id
		self.last_logic_x = logic_x
		self.pick_logic_x = logic_x
	end
end

function TouchInput:OnTouchMoved(x, y)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	local id = self.pick_id
	if not id then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, _ = map:Pixel2Logic(x, y)
	if logic_x == self.last_logic_x then
		return
	end
	self.last_logic_x = logic_x

	local ret_code, result = CommandCenter:ReceiveCommand({"TryMovePickChess", id, logic_x})
end

function TouchInput:OnTouchEnded(x, y)
	if GameStateMachine:CanOperate() ~= 1 then
		return
	end
	local id = self.pick_id
	if not id then
		return
	end
	local map = GameStateMachine:GetActiveMap()
	local logic_x, _ = map:Pixel2Logic(x, y)
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