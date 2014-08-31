--=======================================================================
-- File Name    : chess_spawner.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 14:07:18 2014
-- Description  : spawn chess
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

function ChessSpawner:SpawnChess(map, obj_pool)
	for logic_x = 1, Def.MAP_WIDTH do
		local logic_y = Mover:GetMoveablePosition(map, logic_x)
		if logic_y > 0 then
			obj_pool:Add(Chess, math.random(1, 6), logic_x, logic_y)
		end
	end
end