--=======================================================================
-- File Name    : player.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Sep 11 22:32:36 2014
-- Description  : manage player in game
-- Modify       :
--=======================================================================
if not Player then
	Player = NewLogicNode("PLAYER")
end

function Player:Uninit()
	self.max_self_hp = nil
	self.cur_self_hp = nil

	self.max_enemy_hp = nil
	self.cur_enemy_hp = nil

	return 1
end

function Player:Init(self_max_hp, self_hp, enmey_max_hp, enemy_hp)
	self:InitSelfHP(self_max_hp, self_hp)
	self:InitEnemyHP(enmey_max_hp, enemy_hp)

	return 1
end

function Player:InitSelfHP(max_hp, hp)
	self.max_self_hp = max_hp or Def.DEFAULT_PLAYER_HP
	self.cur_self_hp = hp or self.max_self_hp

	Event:FireEvent("PLAYER.SET_SELF_HP", self.cur_self_hp, self.cur_self_hp)
end

function Player:SetCurSelfHP(hp)
	local old_hp = self.cur_self_hp
	if old_hp == hp then
		return
	end
	self.cur_self_hp = hp
	Event:FireEvent("PLAYER.SET_SELF_HP", hp, old_hp)

	if hp <= 0 then
		ViewInterface:WaitPlayTipFinish(
			0.5, 100, "Defeat!",
			function ()
				SceneMgr:UnLoadCurrentScene()
			end
		)
	end
end

function Player:GetCurSelfHP()
	return self.cur_self_hp
end

function Player:GetMaxSelfHP()
	return self.max_self_hp
end

function Player:ChangeCurSelfHP(change_value)
	local hp = self:GetCurSelfHP()
	local new_hp = hp + change_value
	if new_hp < 0 then
		new_hp = 0
	end

	self:SetCurSelfHP(new_hp)
end

function Player:InitEnemyHP(max_hp, hp)
	self.max_enemy_hp = max_hp or Def.DEFAULT_PLAYER_HP
	self.cur_enemy_hp = hp or self.max_enemy_hp

	Event:FireEvent("PLAYER.SET_ENEMY_HP", self.cur_enemy_hp, self.cur_enemy_hp)
end

function Player:SetCurEnemyHP(hp)
	local old_hp = self.cur_enemy_hp
	if old_hp == hp then
		return
	end
	self.cur_enemy_hp = hp
	Event:FireEvent("PLAYER.SET_ENEMY_HP", hp, old_hp)

	if hp <= 0 then
		ViewInterface:WaitPlayTipFinish(
			0.5, 100, "Victory!",
			function ()
				SceneMgr:UnLoadCurrentScene()
			end
		)
	end
end

function Player:GetCurEnemyHP()
	return self.cur_enemy_hp
end

function Player:GetMaxEnemyHP()
	return self.max_enemy_hp
end

function Player:ChangeCurEnemyHP(change_value)
	local hp = self:GetCurEnemyHP()
	local new_hp = hp + change_value
	if new_hp < 0 then
		new_hp = 0
	end

	self:SetCurEnemyHP(new_hp)
end


