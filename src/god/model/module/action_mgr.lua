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

ActionMgr:DeclareListenEvent("COMBINE.WALL", "OnCombo")
ActionMgr:DeclareListenEvent("COMBINE.ARMY", "OnCombo")

function ActionMgr:_Uninit( ... )
	self.raw_round_num = nil
	self.rest_round_num = nil

	return 1
end

function ActionMgr:_Init(raw_round_num)
	self.round_count = 0
	self.raw_round_num = raw_round_num
	self.rest_round_num = 0
	self.combo_count = 0
	Event:FireEvent("GAME.START_WATCH")
	ViewInterface:WaitWatchEnd( 
		function()
			Event:FireEvent("GAME.END_WATCH")
			if self:GetRestRoundNum() > 0 then
				Event:FireEvent("GAME.AI_ACTIVE")
			else
				self:NextRound()
			end
		end
	)

	return 1
end

function ActionMgr:OnCombo()
	self.combo_count = self.combo_count + 1
	if self.combo_count > 1 then
		self:ChangeRestRoundNum(1)
	end
	Event:FireEvent("GAME.COMBO_CHANGED", self.combo_count)
end

function ActionMgr:SetRestRoundNum(num)
	self.rest_round_num = num
	Event:FireEvent("GAME.ROUND_REST_NUM_CHANGED", self.rest_round_num)
end

function ActionMgr:ChangeRestRoundNum(change_value)
	self:SetRestRoundNum(self.rest_round_num + change_value)
end

function ActionMgr:GetRestRoundNum()
	return self.rest_round_num
end

function ActionMgr:OperateChess(map, id, logic_x, logic_y, old_x, old_y)
	self.combo_count = 0
	self:ChangeRestRoundNum(-1)
	Event:FireEvent("GAME.START_WATCH")
	ViewInterface:WaitWatchEnd( 
		function()
			Event:FireEvent("GAME.END_WATCH")
			if self:GetRestRoundNum() > 0 then
				Event:FireEvent("GAME.AI_ACTIVE")
			else
				self:NextRound()
			end
		end
	)
	local chess = map.obj_pool:GetById(id)
	chess:MoveTo(logic_x, logic_y)
end

function ActionMgr:NextRound()
	Event:FireEvent("GAME.ACTION_OVER")
	GameStateMachine:OnActionOver()

	self.combo_count = 0
	self.rest_round_num = self.raw_round_num
	self.round_count = self.round_count + 1
	local function call_back()
		Event:FireEvent("GAME.ACTION_START", self.round_count)
		Event:FireEvent("GAME.AI_ACTIVE")
	end
	Battle:BattleStart(call_back)
end

ActionMgr.IS_COST_STEP = {
	TryDropChess = 1,
	SpawnChess = 1,
}
