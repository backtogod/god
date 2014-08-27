--=======================================================================
-- File Name    : map.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 21:39:46 2014
-- Description  :
-- Modify       :
--=======================================================================

if not Map then
	Map = NewLogicNode("MAP")
end

if not SelfMap then
	SelfMap = Class:New(Map, "SELF_MAP")
end
SelfMap:DeclareListenEvent("CHESS.ADD", "OnChessAdd")
SelfMap:DeclareListenEvent("CHESS.REMOVE", "OnChessRemove")
SelfMap:DeclareListenEvent("CHESS.SET_POSITION", "OnChessSetPosition")


if not EnemyMap then
	EnemyMap = Class:New(Map, "ENEMY_MAP")
end
EnemyMap:DeclareListenEvent("ENEMY_CHESS.ADD", "OnChessAdd")
EnemyMap:DeclareListenEvent("ENEMY_CHESS.REMOVE", "OnChessRemove")

function Map:_Init(width, height)
	self.cell_pool = {}
	for i = 1, width do
		self.cell_pool[i] = {}
		for j = 1, height do
			self.cell_pool[i][j] = 0
		end
	end
	self.width = width
	self.height = height
	self.cell_list = {}
	return 1
end

function Map:_Uninit( ... )
	self.cell_list = nil
	self.cell_pool = nil
	return 1
end

function Map:IsValid(x, y)
	if not self.cell_pool[x] then
		return 0
	end

	if not self.cell_pool[x][y] then
		return 0
	end
	return 1
end

function Map:RemoveCell(x, y)
	if self:IsValid(x, y) ~= 1 then
		return
	end
	local id = self.cell_pool[x][y]
	self.cell_list[id] = nil
	self.cell_pool[x][y] = 0
end

function Map:SetCell(x, y, value, param)
	if self:IsValid(x, y) ~= 1 then
		return
	end
	self.cell_pool[x][y] = value
	if value then
		if not self.cell_list[value] then
			self.cell_list[value] = {x = -1, y = -1}
		end
		self.cell_list[value].x = x
		self.cell_list[value].y = y
		self.cell_list[value].param = param
	end
	return 1
end

function Map:GetCell(x, y)
	if self:IsValid(x, y) ~= 1 then
		return
	end
	return self.cell_pool[x][y]
end

function Map:GetCellInfo(id)
	return self.cell_list[id]
end

function Map:OnChessAdd(id, template_id, logic_x, logic_y)
	self:SetCell(logic_x, logic_y, id, template_id)
end

function Map:OnChessRemove(id)
	local position = self:GetCellInfo(id)
	self:RemoveCell(position.x, position.y)
end

function Map:Debug()
	Lib:Show2DTB(self.cell_pool, Def.MAP_WIDTH, Def.MAP_HEIGHT)

	Lib:ShowTB(self.cell_list)
end

function Map:Logic2PixelSelf(logic_x, logic_y)
	local real_x, real_y = (logic_x - 0.5) * Def.MAP_CELL_WIDTH, (0.5 - logic_y) * Def.MAP_CELL_HEIGHT
	local offset_x, offset_y = self:GetMapOffsetPoint()

	return real_x + offset_x, real_y + offset_y
end

function Map:Pixel2LogicSelf(pixel_x, pixel_y)
	local offset_x, offset_y = self:GetMapOffsetPoint()
	local real_x, real_y = pixel_x - offset_x, offset_y - pixel_y

	return math.ceil(real_x / Def.MAP_CELL_WIDTH), math.ceil(real_y / Def.MAP_CELL_HEIGHT)
end

function Map:Mirror(x, y)
	return x, visible_size.height - y
end

function Map:Logic2PixelEnemy(logic_x, logic_y)
	local pixel_x, pixel_y = self:Logic2PixelSelf(logic_x, logic_y)
	return self:Mirror(pixel_x, pixel_y)
end

function Map:Pixel2LogicEnemy(pixel_x, pixel_y)
	local real_x, real_y = self:Mirror(pixel_x, pixel_y)
	return self:Pixel2LogicSelf(real_x, real_y)
end

function Map:GetMapOffsetPoint()
	local offset_x = (visible_size.width - math.floor(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH)) * 0.5
	local offset_y = (visible_size.height * 0.5 - Def.MAP_OFFSET_Y)

	return offset_x, offset_y
end

function Map:OnChessSetPosition(id, x, y, old_x, old_y)
	local info = self:GetCellInfo(id)
	self:RemoveCell(info.x, info.y)
	self:SetCell(x, y, id, info.param)

	local list_horizontal = self:CheckHorizontalCombine(id)
	if #list_horizontal >= 3 then
		self:GenerateWall(list_horizontal)
	end

	local list_vertical = self:CheckVerticalCombine(id)
	local list_horizontal = self:CheckHorizontalCombine(id)
	if #list_vertical >= 3 then
		self:GenerateArmy(list_vertical)
	end
end

function Map:CheckVerticalCombine(id)
	local info = self:GetCellInfo(id)
	local template_id = info.param
	local combine_list = {id,}
	for y = info.y + 1 , self.height do
		local check_id = self:GetCell(info.x, y)
		if not check_id or check_id <= 0 then
			break
		end
		local check_info = self:GetCellInfo(check_id)
		assert(check_info)
		if check_info.param ~= template_id then
			break
		end
		combine_list[#combine_list + 1] = check_id
	end
	for y = info.y - 1 , 0, -1 do
		local check_id = self:GetCell(info.x, y)
		if not check_id or check_id <= 0 then
			break
		end
		local check_info = self:GetCellInfo(check_id)
		assert(check_info)
		if check_info.param ~= template_id then
			break
		end
		combine_list[#combine_list + 1] = check_id
	end
	return combine_list
end

function Map:CheckHorizontalCombine(id)
	local info = self:GetCellInfo(id)
	local template_id = info.param
	local combine_list = {id,}
	for x = info.x + 1 , self.width do
		local check_id = self:GetCell(x, info.y)
		if not check_id or check_id <= 0 then
			break
		end
		local check_info = self:GetCellInfo(check_id)
		assert(check_info)
		if check_info.param ~= template_id then
			break
		end

		combine_list[#combine_list + 1] = check_id
	end
	for x = info.x - 1 , 0, -1 do
		local check_id = self:GetCell(x, info.y)
		if not check_id or check_id <= 0 then
			break
		end
		local check_info = self:GetCellInfo(check_id)
		assert(check_info)
		if check_info.param ~= template_id then
			break
		end
		combine_list[#combine_list + 1] = check_id
	end
	return combine_list
end

function Map:GenerateWall(list)
	if not list then
		assert(false)
		return
	end
	for _, id in ipairs(list) do
		local info = self:GetCellInfo(id)
		local x = info.x
		local check_id = self:GetCell(x, self.height)

	end
end

function Map:GenerateArmy(list)
	-- body
end