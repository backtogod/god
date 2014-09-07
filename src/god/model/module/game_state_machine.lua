--=======================================================================
-- File Name    : game_sate_machine.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 00:02:45 2014
-- Description  : manage game state 
-- Modify       :
--=======================================================================
if not GameStateMachine then
	GameStateMachine = ModuleMgr:NewModule("GameStateMachine")
end

GameStateMachine.STATE_SELF_ACTION_START = 1
GameStateMachine.STATE_SELF_OPERATE = 2
GameStateMachine.STATE_SELF_WATCH = 3
GameStateMachine.STATE_SELF_ACTION_END = 10

GameStateMachine.STATE_ENEMY_ACTION_START = 11
GameStateMachine.STATE_ENEMY_OPERATE = 12
GameStateMachine.STATE_ENEMY_WATCH = 13
GameStateMachine.STATE_ENEMY_ACTION_END = 20

GameStateMachine.DEBUG_DISPLAY = {
	[GameStateMachine.STATE_SELF_OPERATE ] = "SELF_OPERATE",
	[GameStateMachine.STATE_SELF_WATCH   ] = "SELF_WATCH",
	[GameStateMachine.STATE_ENEMY_OPERATE] = "ENEMY_OPERATE",
	[GameStateMachine.STATE_ENEMY_WATCH  ] = "ENEMY_WATCH",
}

GameStateMachine:DeclareListenEvent("GAME.START_WATCH", "OnStartWatch")
GameStateMachine:DeclareListenEvent("GAME.END_WATCH", "OnEndWatch")

function GameStateMachine:_Uninit( ... )
	ChessSpawner:Uninit()
	ActionMgr:Uninit()
	return 1
end

function GameStateMachine:_Init(raw_state)
	self.state = raw_state
	ActionMgr:Init(Def.DEFAULT_ROUND_NUM)
	ChessSpawner:Init()
	return 1
end

function GameStateMachine:SetState(state)
	self.state = state
	Event:FireEvent("GAME_STATE.CHANGE", state)
end

function GameStateMachine:GetState()
	return self.state
end

function GameStateMachine:IsInSelfAction()
	if self.state < self.STATE_SELF_ACTION_START or self.state > self.STATE_SELF_ACTION_END then
		return 0
	end
	return 1
end

function GameStateMachine:IsInEnemyAction()
	if self:GetState() < self.STATE_ENEMY_ACTION_START or self.state > self.STATE_ENEMY_ACTION_END then
		return 0
	end
	return 1
end

function GameStateMachine:IsWatching()
	if self:GetState() == self.STATE_SELF_WATCH or self:GetState() == self.STATE_ENEMY_WATCH then
		return 1
	end
	return 0
end

function GameStateMachine:CanOperate()
	if self:GetState() ~= self.STATE_SELF_OPERATE then
		return 0
	end
	return 1
end

function GameStateMachine:OnStartWatch()
	local state = self:GetState()
	if state == self.STATE_SELF_OPERATE then
		self:SetState(self.STATE_SELF_WATCH)
	elseif state == self.STATE_ENEMY_OPERATE then
		self:SetState(self.STATE_ENEMY_WATCH)
	end
end

function GameStateMachine:OnEndWatch( ... )
	local state = self:GetState()
	if state == self.STATE_SELF_WATCH then
		self:SetState(self.STATE_SELF_OPERATE)
	elseif state == self.STATE_ENEMY_WATCH then
		self:SetState(self.STATE_ENEMY_OPERATE)
	end
end

function GameStateMachine:OnActionOver()
	if self:IsInEnemyAction() == 1 then
		self:SetState(self.STATE_SELF_WATCH)
	elseif self:IsInSelfAction() == 1 then
		self:SetState(self.STATE_ENEMY_WATCH)
	end
end

function GameStateMachine:OnActionStart()
	if self:IsInEnemyAction() == 1 then
		self:SetState(self.STATE_ENEMY_OPERATE)
	elseif self:IsInSelfAction() == 1 then
		self:SetState(self.STATE_SELF_OPERATE)
	end
end

function GameStateMachine:GetActiveMap()
	if self:IsInSelfAction() == 1 then
		return SelfMap
	elseif self:IsInEnemyAction() == 1 then
		return EnemyMap
	end
end