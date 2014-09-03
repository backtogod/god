--=======================================================================
-- File Name    : chess_spawner.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 14:07:18 2014
-- Description  : spawn chess helper
-- Modify       :
--=======================================================================

if not ChessSpawner then
	ChessSpawner = ModuleMgr:NewModule("ChessSpawner")
end

function ChessSpawner:_Uninit( ... )
	return 1
end

function ChessSpawner:_Init( ... )
	return 1
end

function ChessSpawner:SpawnChess(map, id_list)
	for logic_x = 1, Def.MAP_WIDTH do
		local logic_y = Mover:GetMoveablePosition(map, logic_x)
		if logic_y > 0 then
			local id = id_list and id_list[logic_x] or math.random(1, 6)
			map.obj_pool:Add(Chess, id, logic_x, logic_y)
		end
	end
end