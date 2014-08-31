--=======================================================================
-- File Name    : action_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 10:33:54 2014
-- Description  : manage action and round
-- Modify       :
--=======================================================================
if not ActionMgr then
	ActionMgr = ModuleMgr:NewModule("ActionMgr")
end

ActionMgr:DeclareListenEvent("GAME.END_WATCH", "OnEndWatch")

function ActionMgr:_Uninit( ... )
	self.raw_round_num = nil
	self.rest_round_num = nil

	return 1
end

function ActionMgr:_Init(raw_round_num)
	self.round_count = 1
	self.raw_round_num = raw_round_num
	self.rest_round_num = raw_round_num

	Event:FireEvent("Game.ACTION_START", self.round_count)
	Event:FireEvent("GAME.ROUND_REST_NUM_CHANGED", self.rest_round_num)
	return 1
end

function ActionMgr:ChangeRestRoundNum(change_value)
	self.rest_round_num = self.rest_round_num + change_value
	Event:FireEvent("GAME.ROUND_REST_NUM_CHANGED", self.rest_round_num)
end

function ActionMgr:GetRestRoundNum()
	return self.rest_round_num
end

function ActionMgr:OperateChess(id, logic_x, logic_y, old_x, old_y)
	local logic_chess = ChessPool:GetById(id)
	assert(logic_chess)
	logic_chess:SetPosition(logic_x, logic_y)
	CombineMgr:OnChessChangePostion(SelfMap, id, logic_x, logic_y)
	
	self:ChangeRestRoundNum(-1)
end

function ActionMgr:OnEndWatch()
	if self:GetRestRoundNum() > 0 then
		GameStateMachine:OnEndWatch()
		return
	end
	Event:FireEvent("GAME.ACTION_OVER")
	GameStateMachine:OnActionOver()

	self.rest_round_num = self.raw_round_num
	self.round_count = self.round_count + 1
	Event:FireEvent("Game.ACTION_START", self.round_count)
end
