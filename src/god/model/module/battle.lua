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
	local width, height = map:GetSize()
	local need_combat = 0
	local function ChangeWaitRound()
		local army_list = map:GetArmyList()
		for i = 1, height do
			if army_list[i] then
				for _, chess in pairs(army_list[i]) do
					chess:ChangeLife(chess:GetStepLife())
					local rest_round = chess:ChangeWaitRound(-1)
					if rest_round == 0 then
						need_combat = need_combat + 1
					end
				end
			end
		end
	end

	local function TryCombat()
		local army_list = map:GetArmyList()
		Lib:ShowTB(army_list, 2)
		for i = 1, height do
			local is_start_combat = 0
			if army_list[i] then			
				for _, chess in pairs(army_list[i]) do
					print(i," ddd ", chess:GetId())
					local rest_round = chess:GetWaitRound()
					if rest_round == 0 then
						is_start_combat = 1
						chess:Attack()
						need_combat = need_combat - 1
					end
				end
			end
			if is_start_combat == 1 then
				return 1
			end
		end
	end

	local function WaitBattle()
		if need_combat > 0 then
			ViewInterface:WaitBattleFinish(0.5, 100, WaitBattle)
			TryCombat()
		else
			call_back()
		end
	end
	
	ChangeWaitRound()
	WaitBattle()
	return 1
end
