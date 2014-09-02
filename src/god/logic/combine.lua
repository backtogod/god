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
	print("Start Check Map for Combine")
	map:Debug()
	self:TryMerge(map)
	self:CheckCombineForWall(map)	
	self:CheckCombineForArmy(map)
end

function CombineMgr:CheckCombineForWall(map)
	--WALL
	local wall_list = {}
	for y = 1, Def.MAP_HEIGHT do
		local index = 1		
		while index < Def.MAP_WIDTH do
			local check_id = map:GetCell(index, y)
			local check_chess = map.obj_pool:GetById(check_id)
			if check_chess then
				local combine_list = {check_id}
				for x = index + 1, Def.MAP_WIDTH do
					local chess_id = map:GetCell(x, y)
					local chess = map.obj_pool:GetById(chess_id)
					local check_result = self:CanCombine(check_chess, chess)
					if check_result <= 0 then
						index = x
						if check_result < 0 then
							index = index + 1
						end
						break
					end
					combine_list[#combine_list + 1] = chess_id
					if #combine_list >= 3 then
						table.insert(wall_list, combine_list)
						index = x + 1
						break
					end
				end
			else
				index = index + 1
			end
		end		
	end
	for _, combine_list in ipairs(wall_list) do
		self:GenerateWall(map, combine_list)
	end
end

function CombineMgr:CheckCombineForArmy(map)
	--ARMY
	local army_list = {}
	for x = 1, Def.MAP_WIDTH do
		local start_index = 1
		local end_index = 1
		while start_index < Def.MAP_HEIGHT do
			local check_id = map:GetCell(x, start_index)
			local check_chess = map.obj_pool:GetById(check_id)
			if check_chess then
				local combine_list = {check_id}
				end_index = start_index + 1
				while end_index <= Def.MAP_HEIGHT do
					local chess_id = map:GetCell(x, end_index)
					local chess = map.obj_pool:GetById(chess_id)
					local check_result = self:CanCombine(check_chess, chess)

					if check_result <= 0 then
						start_index = end_index
						if check_result < 0 then
							start_index = start_index + 1
						end
						break
					end
					combine_list[#combine_list + 1] = chess_id
					if #combine_list >= 3 then
						table.insert(army_list, combine_list)
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
	for _, combine_list in ipairs(army_list) do
		self:GenerateArmy(map, combine_list)
	end
end

function CombineMgr:CanCombine(chess_a, chess_b)
	if not chess_a or not chess_b then
		return -1
	end

	if chess_a:TryCall("GetState") ~= Def.STATE_NORMAL or chess_b:TryCall("GetState") ~= Def.STATE_NORMAL then
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

	for _, check_id in ipairs(list) do
		local chess = map.obj_pool:GetById(check_id)
		if chess:TransformtToWall() ~= 1 then
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

	for _, check_id in ipairs(list) do
		local chess = map.obj_pool:GetById(check_id)
		if chess:TryCall("SetState", Def.STATE_ARMY) ~= 1 then
			assert(false)
			return
		end
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