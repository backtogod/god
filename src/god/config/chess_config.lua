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
	},
	[2] = {
		image = "god/2.png",
	},
	[3] = {
		image = "god/3.png",
	},
	[4] = {
		image = "god/4.png",
	},
	[5] = {
		image = "god/5.png",
	},
	[6] = {
		image = "god/6.png",
	},
	["wall"] = {
		image = "god/7.png",
	},
}


function ChessConfig:GetData(template_id)
	return self.template[template_id]
end
