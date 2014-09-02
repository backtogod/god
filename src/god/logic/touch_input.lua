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

TouchInput:DeclareListenEvent("SCREEN.ON_TOUCH_BEGAN", "OnTouchBegan")
TouchInput:DeclareListenEvent("SCREEN.ON_TOUCH_MOVED", "OnTouchMoved")
TouchInput:DeclareListenEvent("SCREEN.ON_TOUCH_ENDED", "OnTouchEnded")

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
	local logic_x, _ = SelfMap:Pixel2Logic(x, y)
	for logic_y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = SelfMap:GetCell(logic_x, logic_y)
		if chess_id and chess_id > 0 then
			local logic_chess = ChessPool:GetById(chess_id)
			if logic_chess:TryCall("GetState") == Def.STATE_NORMAL then
				PickHelper:Pick(chess_id, logic_x, logic_y)
				self.pick_id = chess_id
				self.last_logic_x = logic_x
				self.pick_logic_x = logic_x
			end
			return
		end
	end
end

function TouchInput:OnTouchMoved(x, y)
	local id = self.pick_id
	if not id then
		return
	end
	local logic_x, _ = SelfMap:Pixel2Logic(x, y)
	if logic_x == self.last_logic_x then
		return
	end
	self.last_logic_x = logic_x
	local logic_y = Mover:GetMoveablePosition(SelfMap, logic_x, 
		function(check_chess_id)
			if (check_chess_id and check_chess_id <= 0) or check_chess_id == id then
				return 1
			end
			return 0
		end
	)
	if logic_y > 0 then
		Event:FireEvent("CHESS.SET_DISPLAY_POSITION", id, logic_x, logic_y)
	end
end

function TouchInput:OnTouchEnded(x, y)
	local id = self.pick_id
	if not id then
		return
	end
	local logic_x, _ = SelfMap:Pixel2Logic(x, y)
	local logic_y = Mover:GetMoveablePosition(SelfMap, logic_x,
		function(check_chess_id)
			if (check_chess_id and check_chess_id <= 0) or check_chess_id == id then
				return 1
			end
			return 0
		end
	)
	if logic_y > 0 and self.pick_logic_x ~= logic_x then
		PickHelper:DropAll(logic_x, logic_y)
	else
		PickHelper:CancelAll()
	end
	self.pick_id = nil
	self.last_logic_x = nil
	self.pick_logic_x = nil
end