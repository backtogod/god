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
			local move_chess = map.obj_pool:GetById(chess_id)
			if move_chess then
				if y ~= index then
					move_chess:SetPosition(x, index)
				end
				index = index + 1
			end
		end
	end
end

function Mover:GetMoveablePosition(map, x, judge_fun)
	local ret_y = -1
	for y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = map:GetCell(x, y)
		if (judge_fun and judge_fun(chess_id) == 1) or (chess_id and chess_id <= 0) then
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
	local chess = map.obj_pool:GetById(id)
	map:RemoveCell(x, y)
	for index = y - 1, target_y, -1 do
		local move_id = map:GetCell(x, index)
		local move_chess = map.obj_pool:GetById(move_id)
		if move_chess then
			map:SetCell(x, index + 1, move_id)
		end
	end
	map:SetCell(x, target_y, id)
end