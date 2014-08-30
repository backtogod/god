--=======================================================================
-- File Name    : Mover.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug 30 11:47:44 2014
-- Description  : clean the map
-- Modify       :
--=======================================================================

if not Mover then
	Mover = {}
end

function Mover:RemoveHole(map, x)
	local index = 1
	for y = 1, map.height do
		local chess_id = map:GetCell(x, y)
		if chess_id >= 0 then
			local move_chess = ChessPool:GetById(chess_id)
			if move_chess then
				if y ~= index then
					move_chess:SetPosition(x, index)
				end
				index = index + 1
			end
		end
	end
end

function Mover:GetMoveablePosition(map, id, x)
	local ret_y = -1
	for y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = map:GetCell(x, y)
		if (chess_id and chess_id <= 0) or chess_id == id then
			ret_y = y
		else
			break
		end
	end
	return ret_y
end

function Mover:MoveUp(map, x, y, target_y)
	if y <= target_y then
		return
	end
	local id = map:GetCell(x, y)
	if id <= 0 then
		return
	end
	local chess = ChessPool:GetById(id)
	map:RemoveCell(x, y)
	for index = y - 1, target_y, -1 do
		local move_id = map:GetCell(x, index)
		local move_chess = ChessPool:GetById(move_id)
		if move_chess then
			move_chess:SetPosition(x, index + 1)
		end
	end
	chess:SetPosition(x, target_y)
end