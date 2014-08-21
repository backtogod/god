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
	["test"] = {
		image = "god/1.png",
	}
}


function ChessConfig:GetData(template_id)
	return self.template[template_id]
end
