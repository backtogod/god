--=======================================================================
-- File Name    : chess_config.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 23:28:18 2014
-- Description  :
-- Modify       :
--=======================================================================

if not ChessConfig then
	ChessConfig = {}
end

ChessConfig.template = {
	[1] = {
		image = "god/1.png",
		base_life = 1,
		wait_round = 1,
		attack_time = 3,
	},
	[2] = {
		image = "god/2.png",
		base_life = 1,
		wait_round = 1,
	},
	[3] = {
		image = "god/3.png",
		base_life = 1,
		wait_round = 2,
	},
	[4] = {
		image = "god/4.png",
		base_life = 1,
		wait_round = 2,
	},
	[5] = {
		image = "god/5.png",
		base_life = 1,
		wait_round = 2,
	},
	[6] = {
		image = "god/6.png",
		base_life = 1,
		wait_round = 2,
	},
	["wall_1"] = {
		image = "god/wall_1.png",
		base_life = 3,
	},
	["wall_2"] = {
		image = "god/wall_2.png",
		base_life = 7,
	},
	["wall_3"] = {
		image = "god/wall_3.png",
		base_life = 15,
	},
}


function ChessConfig:GetData(template_id)
	return self.template[template_id]
end
