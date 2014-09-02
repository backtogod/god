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
					local check_result = self:CanCombineWall(check_chess, chess)
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

function CombineMgr:CanCombineWall(chess_a, chess_b)
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

function CombineMgr:OnChessChangePostion(map, id, x, y)
	local list_horizontal = self:CheckHorizontalCombine(map, id)
	if #list_horizontal >= 3 then
		self:GenerateWall(map, list_horizontal, y)
		return
	end
	local list_vertical = self:CheckVerticalCombine(map, id)
	if #list_vertical >= 3 then
		self:GenerateArmy(map, list_vertical, x)
		return
	end
end

function CombineMgr:CheckCanCombine(map, template_id, x, y, combine_list)
	local check_id = map:GetCell(x, y)
	if not check_id or check_id <= 0 then
		return 0
	end
	local check_chess = map.obj_pool:GetById(check_id)
	assert(check_chess)
	if check_chess:TryCall("GetState") ~= Def.STATE_NORMAL then
		return 0
	end
	if check_chess:GetTemplateId() ~= template_id then
		return 0
	end
	combine_list[#combine_list + 1] = check_id
	return 1
end

function CombineMgr:CheckVerticalCombine(map, id)
	local chess = map.obj_pool:GetById(id)
	local template_id = chess:GetTemplateId()
	local combine_list = {id,}
	local state = chess:TryCall("GetState")
	if state == Def.STATE_WALL or state == Def.STATE_ARMY then
		return combine_list
	end

	for y = chess.y + 1 , SelfMap.height do
		if self:CheckCanCombine(map, template_id, chess.x, y, combine_list) == 0 then
			break
		end
	end
	for y = chess.y - 1 , 0, -1 do
		if self:CheckCanCombine(map, template_id, chess.x, y, combine_list) == 0 then
			break
		end
	end
	return combine_list
end

function CombineMgr:CheckHorizontalCombine(map, id)
	local chess = map.obj_pool:GetById(id)
	local template_id = chess:GetTemplateId()
	local combine_list = {id,}
	local state = chess:TryCall("GetState")
	if state == Def.STATE_WALL or state == Def.STATE_ARMY then
		return combine_list
	end
	for x = chess.x + 1, SelfMap.width do
		if self:CheckCanCombine(map, template_id, x, chess.y, combine_list) == 0 then
			break
		end
	end
	for x = chess.x - 1, 0, -1 do
		if self:CheckCanCombine(map, template_id, x, chess.y, combine_list) == 0 then
			break
		end
	end
	return combine_list
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
	if chess_src and chess_dest and chess_src:TryCall("GetState") ~= chess_dest:TryCall("GetState") then
		return 0
	end

	return 1
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