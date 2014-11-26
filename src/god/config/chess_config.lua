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
		image = "god/duduniao.png",
		life = 2,
		base_life = 3,
		step_life = 3,
		wait_round = 1,
	},
	[2] = {
		image = "god/xiaoshuiguai.png",
		life = 2,
		base_life = 6,
		step_life = 2,
		wait_round = 2,
	},
	[3] = {
		image = "god/wenxiangwa.png",
		life = 1,
		base_life = 4,
		step_life = 3,
		wait_round = 2,
	},
	[4] = {
		image = "god/miaowazhongzi.png",
		life = 2,
		base_life = 2,
		step_life = 4,
		wait_round = 2,
	},
	[5] = {
		image = "god/xiaohuolong.png",
		life = 2,
		base_life = 6,
		step_life = 3,
		wait_round = 3,
	},
	[6] = {
		image = "god/abaishe.png",
		life = 3,
		base_life = 10,
		step_life = 1,
		wait_round = 3,
	},
	["wall_1"] = {
		image = "god/wall_1.png",
	},
	["wall_2"] = {
		image = "god/wall_2.png",
	},
	["wall_3"] = {
		image = "god/wall_3.png",
	},
}


function ChessConfig:GetData(template_id)
	return self.template[template_id]
end
