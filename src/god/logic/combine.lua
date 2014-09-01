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

function CombineMgr:CheckCombine(id)
	-- body
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
	local check_id = SelfMap:GetCell(x, y)
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
		if chess:TryCall("SetState", Def.STATE_WALL) ~= 1 then
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