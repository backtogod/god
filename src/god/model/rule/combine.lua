--=======================================================================
-- File Name    : combine.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 24 20:47:37 2014
-- Description  : combine rule
-- Modify       :
--=======================================================================

if not CombineMgr then
	CombineMgr = ModuleMgr:NewModule("COMBINE")
end

function CombineMgr:_Init( ... )
	-- body
end

function CombineMgr:_Uninit( ... )
	-- body
end

function CombineMgr:CheckCombine(map)
	-- print("Start Check Map for Combine")
	-- map:Debug()
	local result = 0
	self:TryMerge(map)
	local wall_list = self:CheckCombineForWall(map)
	local army_list = self:CheckCombineForArmy(map)

	for _, combine_list in ipairs(wall_list) do
		for _, tb in ipairs(combine_list) do
			local check_id = tb.id
			if map.obj_pool:GetById(check_id) then
				map.obj_pool:Remove(check_id)
			end
		end
	end

	for _, combine_list in ipairs(army_list) do
		for _, tb in ipairs(combine_list) do
			local check_id = tb.id
			local chess = map.obj_pool:GetById(check_id)
			if chess then
				map.obj_pool:Remove(check_id)
			end
		end
	end

	for _, combine_list in ipairs(wall_list) do
		self:GenerateWall(map, combine_list)
		result = 1
	end

	for _, combine_list in ipairs(army_list) do
		self:GenerateArmy(map, combine_list)
		result = 1
	end

	return result
end

function CombineMgr:GetCanCombine(map, id_list, ret_list)
	local start_index = 1
	local end_index = 1
	local count = #id_list
	while start_index < count do
		local check_id = id_list[start_index]
		local check_chess = map.obj_pool:GetById(check_id)
		if check_chess then
			local combine_list = {{id = check_id, template_id = check_chess:GetTemplateId(), x = check_chess.x, y = check_chess.y},}
			end_index = start_index + 1
			while end_index <= count do
				local chess_id = id_list[end_index]
				local chess = map.obj_pool:GetById(chess_id)
				local check_result = self:CanCombine(check_chess, chess)

				if check_result <= 0 then
					start_index = end_index
					if check_result < 0 then
						start_index = start_index + 1
					end
					break
				end
				combine_list[#combine_list + 1] = {id = chess_id, template_id = chess:GetTemplateId(), x = chess.x, y = chess.y}
				if #combine_list >= 3 then
					table.insert(ret_list, combine_list)
					start_index = end_index + 1
					break
				end
				end_index = end_index + 1
			end
			if start_index < end_index then
				break
			end
		else
			start_index = start_index + 1
		end
	end
end

function CombineMgr:CheckCombineForWall(map)
	local wall_list = {}
	for y = 1, Def.MAP_HEIGHT do
		local id_list = {}
		for x = 1, Def.MAP_WIDTH do
			id_list[x] = map:GetCell(x, y)
		end
		self:GetCanCombine(map, id_list, wall_list)
	end
	
	return wall_list
end

function CombineMgr:CheckCombineForArmy(map)
	local army_list = {}
	for x = 1, Def.MAP_WIDTH do
		local id_list = {}
		for y = 1, Def.MAP_HEIGHT do
			id_list[y] = map:GetCell(x, y)
		end
		self:GetCanCombine(map, id_list, army_list)
	end
	
	return army_list
end

function CombineMgr:CanCombine(chess_a, chess_b)
	if not chess_a or not chess_b then
		return -1
	end

	if chess_a:TryCall("GetState") ~= Def.STATE_NORMAL then
		return 0
	end

	if chess_b:TryCall("GetState") ~= Def.STATE_NORMAL then
		return -1
	end
	if chess_a:GetTemplateId() ~= chess_b:GetTemplateId() then
		return 0
	end

	return 1
end

function CombineMgr:GenerateWall(map, list)
	if not list then
		assert(false)
		return
	end

	for _, tb in ipairs(list) do
		local template_id = tb.template_id
		local x, y = tb.x, tb.y
		local new_chess, id = map.obj_pool:Add(Chess, template_id, x, y)
		if new_chess:TransformtToWall() ~= 1 then
			assert(false)
			return
		end
	end
	Event:FireEvent("COMBINE.WALL")
end

function CombineMgr:GenerateArmy(map, list, x)
	if not list then
		assert(false)
		return
	end

	local x = nil
	local y = nil
	local template_id = nil
	local y_list = {}
	for _, tb in ipairs(list) do
		if not x then
			x = tb.x
		end
		table.insert(y_list, tb.y)
		if not template_id then
			template_id = tb.template_id
		end
		assert(x == tb.x)
		assert(template_id == tb.template_id)
	end
	table.sort(y_list, function(a, b) return a < b end)
	for _, test_y in ipairs(y_list) do
		if map:GetCell(x, test_y) == 0 then
			y = test_y
			break
		end
	end
	local new_chess, id = map.obj_pool:Add(Chess, template_id, x, y)
	if new_chess:TransformtToArmy() ~= 1 then
		assert(false)
		return
	end
	Event:FireEvent("COMBINE.ARMY")
end

function CombineMgr:CanMerge(chess_src, chess_dest)
	if not chess_src or not chess_dest then
		return 1
	end
	local src_state = chess_src:TryCall("GetState")
	local dest_state = chess_dest:TryCall("GetState")
	if src_state == Def.STATE_WALL and dest_state == Def.STATE_WALL then
		return 1
	end
	
	if src_state == Def.STATE_ARMY and dest_state == Def.STATE_ARMY 
		and chess_src:GetTemplateId() == chess_dest:GetTemplateId() then
		return 1
	end

	return 0
end

function CombineMgr:TryMerge(map)
	for id, info in pairs(map.cell_list) do
		local x, y = info.x, info.y
		local map_id = map:GetCell(x, y)
		if map_id ~= id then
			local chess_map = map.obj_pool:GetById(map_id)
			local chess_merged = map.obj_pool:GetById(id)
			if self:CanMerge(chess_map, chess_merged) == 1 then
				print(x, y, "map: "..map_id, "merged: "..id)
				self:Merge(map, chess_map, chess_merged)
			end
		end
	end
end

function CombineMgr:Merge(map, chess_map, chess_merged, x, y)
	chess_map:Evolution(chess_merged)
	map.obj_pool:Remove(chess_merged:GetId())
end