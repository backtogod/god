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

CombineMgr:DeclareListenEvent("CHESS.SET_POSITION", OnChessSetPostion)

function CombineMgr:_Init( ... )
	-- body
end

function CombineMgr:_Uninit( ... )
	-- body
end

function CombineMgr:CheckCombine(id)
	-- body
end

function CombineMgr:OnChessChangePostion(id, x, y)
	local list_horizontal = self:CheckHorizontalCombine(id)
	if #list_horizontal >= 3 then
		self:GenerateWall(list_horizontal)
		return
	end
	local list_vertical = self:CheckVerticalCombine(id)
	if #list_vertical >= 3 then
		self:GenerateArmy(list_vertical)
		return
	end
end

function CombineMgr:CheckCanCombine(template_id, x, y, combine_list)
	local check_id = SelfMap:GetCell(x, y)
	if not check_id or check_id <= 0 then
		return 0
	end
	local check_chess = ChessPool:GetById(check_id)
	assert(check_chess)
	if check_chess:GetTemplateId() ~= template_id then
		return 0
	end
	combine_list[#combine_list + 1] = check_id
	return 1
end

function CombineMgr:CheckVerticalCombine(id)
	local chess = ChessPool:GetById(id)
	local template_id = chess:GetTemplateId()
	local combine_list = {id,}
	local state = chess:TryCall("GetState")
	if state == Def.STATE_WALL or state == Def.STATE_ARMY then
		return combine_list
	end

	for y = chess.y + 1 , SelfMap.height do
		if self:CheckCanCombine(template_id, chess.x, y, combine_list) == 0 then
			break
		end
	end
	for y = chess.y - 1 , 0, -1 do
		if self:CheckCanCombine(template_id, chess.x, y, combine_list) == 0 then
			break
		end
	end
	return combine_list
end

function CombineMgr:CheckHorizontalCombine(id)
	local chess = ChessPool:GetById(id)
	local template_id = chess:GetTemplateId()
	local combine_list = {id,}
	local state = chess:TryCall("GetState")
	if state == Def.STATE_WALL or state == Def.STATE_ARMY then
		return combine_list
	end
	for x = chess.x + 1, SelfMap.width do
		if self:CheckCanCombine(template_id, x, chess.y, combine_list) == 0 then
			break
		end
	end
	for x = chess.x - 1, 0, -1 do
		if self:CheckCanCombine(template_id, x, chess.y, combine_list) == 0 then
			break
		end
	end
	return combine_list
end

function CombineMgr:GenerateWall(list)
	if not list then
		assert(false)
		return
	end

	for _, check_id in ipairs(list) do
		local chess = ChessPool:GetById(check_id)
		if chess:TryCall("SetState", Def.STATE_WALL) ~= 1 then
			assert(false)
			return
		end
		self:MoveToTop(check_id)
	end
end

function CombineMgr:GenerateArmy(list)
	if not list then
		assert(false)
		return
	end

	for _, check_id in ipairs(list) do
		local chess = ChessPool:GetById(check_id)
		if chess:TryCall("SetState", Def.STATE_ARMY) ~= 1 then
			assert(false)
			return
		end
		self:MoveToTop(check_id)
	end
end

function CombineMgr:CanMoveTo(x_src, y_src, x_dest, y_dest)
	local id_src = SelfMap:GetCell(x_src, y_src)
	if id_src <= 0 then
		return 0
	end

	local id_dest = SelfMap:GetCell(x_dest, y_dest)
	if id_dest <= 0 then
		return 1
	end

	local chess_src = ChessPool:GetById(id_src)
	local chess_dest = ChessPool:GetById(id_dest)
	local dest_state = chess_dest:TryCall("GetState")
	if dest_state == Def.STATE_WALL then
		return 0
	elseif dest_state == Def.STATE_ARMY then
		if chess_src:TryCall("GetState") ~= Def.STATE_WALL then
			return 0
		end
	end
	return 1
end

function CombineMgr:MoveToTop(id)
	local chess = ChessPool:GetById(id)
	local x, y = chess.x, chess.y
	local target_y = 1
	while self:CanMoveTo(x, y, x, target_y) ~= 1 and target_y < y do
		target_y = target_y + 1
	end
	if target_y >= y then
		return
	end
	Mover:MoveUp(SelfMap, x, y, target_y)
end