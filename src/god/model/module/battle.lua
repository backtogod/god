--=======================================================================
-- File Name    : battle.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Fri Sep  5 22:43:23 2014
-- Description  : Manage battle in game
-- Modify       :
--=======================================================================
if not Battle then
	Battle = ModuleMgr:NewModule("BATTLE")
end

function Battle:_Uninit( ... )
	-- body
	return 1
end

function Battle:_Init( ... )
	-- body
	return 1
end

function Battle:BattleStart(call_back)
	local map = GameStateMachine:GetActiveMap()
	ViewInterface:WaitBattleFinish(0.5, 100, call_back)
	local army_list = map:GetArmyList()
	for _, chess in pairs(army_list) do
		chess:ChangeLife(chess:GetStepLife())
		chess:ChangeWaitRound(-1)
	end
	return 1
end