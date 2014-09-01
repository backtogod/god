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
		if chess_id > 0 then
			if y ~= index then
				map:RemoveCell(x, y)
				map:SetCell(x, index, chess_id)
			end
			index = index + 1
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

function Mover:MoveWall(map)
	for x = 1, Def.MAP_WIDTH do
		for y = 2, Def.MAP_HEIGHT do
			local check_id = map:GetCell(x, y)
			if check_id > 0 then
				local chess = map.obj_pool:GetById(check_id)
				if chess:TryCall("GetState") == Def.STATE_WALL then
					self:MoveToTop(map, check_id)
				end
			end
		end
		self:RemoveHole(map, x)
	end
	self:CoordinatePosition(map)
end

function Mover:MoveArmy(map)
	for x = 1, Def.MAP_WIDTH do
		for y = 2, Def.MAP_HEIGHT do
			local check_id = map:GetCell(x, y)
			if check_id > 0 then
				local chess = map.obj_pool:GetById(check_id)
				if chess:TryCall("GetState") == Def.STATE_ARMY then
					self:MoveToTop(map, check_id)
				end
			end
		end
		self:RemoveHole(map, x)
	end
	self:CoordinatePosition(map)
end

function Mover:CoordinatePosition(map)
	for chess_id, info in pairs(map.cell_list) do
		local chess = map.obj_pool:GetById(chess_id)
		if chess then
			chess:SetPosition(info.x, info.y)
		end
	end
end

function Mover:CanMoveTo(map, x_src, y_src, x_dest, y_dest)
	local id_src = map:GetCell(x_src, y_src)
	if id_src <= 0 then
		return 0
	end

	local id_dest = map:GetCell(x_dest, y_dest)
	if id_dest <= 0 then
		return 1
	end

	local chess_src = map.obj_pool:GetById(id_src)
	local chess_dest = map.obj_pool:GetById(id_dest)
	local src_state = chess_src:TryCall("GetState")
	local dest_state = chess_dest:TryCall("GetState")
	if (dest_state == Def.STATE_WALL and src_state ~= Def.STATE_WALL)
		or (dest_state == Def.STATE_ARMY and src_state == Def.STATE_NORMAL) then

		return 0
	end
	return 1
end

function Mover:MoveToTop(map, id)
	local chess = map:GetCellInfo(id)
	local x, y = chess.x, chess.y
	local target_y = 1
	while self:CanMoveTo(map, x, y, x, target_y) ~= 1 and target_y < y do
		target_y = target_y + 1
	end
	if target_y >= y then
		return
	end
	self:MoveUp(map, x, y, target_y)
end

function Mover:MoveUp(map, x, y, target_y)
	if y <= target_y then
		return
	end
	local id = map:GetCell(x, y)
	if id <= 0 then
		return
	end
	
	map:RemoveCell(x, y)
	local target_id = map:GetCell(x, target_y)
	local chess_src = map.obj_pool:GetById(id)
	local chess_dest = map.obj_pool:GetById(target_id)
	if CombineMgr:CanMerge(chess_src, chess_dest) ~= 1 then
		for index = y - 1, target_y, -1 do
			local move_id = map:GetCell(x, index)
			local move_chess = map.obj_pool:GetById(move_id)
			if move_chess then
				map:SetCell(x, index + 1, move_id)
			end
		end
	end
	map:SetCell(x, target_y, id)
end