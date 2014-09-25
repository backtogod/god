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

function Map:_Init(width, height)
	self.cell_pool = {}
	self.height_list = {}
	for i = 1, width do
		self.height_list[i] = 0
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

function Map:GetSize()
	return self.width, self.height
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

function Map:SetCell(x, y, value)
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
	end
	-- if not self:IsValid(x, y + 1) or self.cell_pool[x][y + 1] == 0 then
	-- 	self:SetValidHeight(x, y)
	-- end
	return 1
end

function Map:GetCell(x, y)
	if self:IsValid(x, y) ~= 1 then
		return 0
	end
	return self.cell_pool[x][y]
end

function Map:GetCellInfo(id)
	return self.cell_list[id]
end

function Map:OnChessSetPosition(id, x, y, old_x, old_y)
	if self:GetCell(old_x, old_y) == id then
		self:RemoveCell(old_x, old_y)
	end
	self:SetCell(x, y, id)
end

function Map:OnChessAdd(id, template_id, x, y)
	self:SetCell(x, y, id)
end

function Map:OnChessRemove(id)
	local position = self:GetCellInfo(id)
	if self:GetCell(position.x, position.y) == id then
		self:RemoveCell(position.x, position.y)
	end
	self.cell_list[id] = nil
end

function Map:GetArmyList()
	local result = {}
	for id, _ in pairs(self.cell_list) do
		local chess = self.obj_pool:GetById(id)
		if chess and chess:TryCall("GetState") == Def.STATE_ARMY then
			result[#result + 1] = chess
		end
	end
	return result
end

function Map:Debug(is_detail)
	Lib:Show2DTB(self.cell_pool, Def.MAP_WIDTH, Def.MAP_HEIGHT, 1)
	if is_detail == 1 then
		Lib:ShowTB(self.cell_list)
	end
end

function Map:Mirror(x, y)
	return x, visible_size.height - y
end

function Map:GetMapOffsetPoint()
	local offset_x = (visible_size.width - math.floor(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH)) * 0.5
	local offset_y = (visible_size.height * 0.5 - Def.MAP_OFFSET_Y)

	return offset_x, offset_y
end

function Map:InitChess(max_wave, spec_list)
	if not spec_list then
		spec_list = {}
	end
	local delay_frame = 0
	local add_frame = max_wave
	for wave = 1, max_wave do
		delay_frame = delay_frame + add_frame
		add_frame = add_frame - 1
		self:RegistLogicTimer(delay_frame, {ChessSpawner.SpawnChess, ChessSpawner, self, spec_list[wave]})		
	end
end

function Map:SetValidHeight(x, height)
	self.height_list[x] = height
end

function Map:GetValidHeight(x)
	return self.height_list[x]
end

function Map:GetTopCell(x)
	if not self.cell_pool[x] then
		return
	end
	local ret_id = nil
	local ret_y = 0
	for i = 1, self.height do
		local value = self:GetCell(x, i)
		if value <= 0 then
			break
		end
		ret_id = value
		ret_y = i
	end

	return ret_id, ret_y
end

if not SelfMap then
	SelfMap = Class:New(Map, "SELF_MAP")
end
SelfMap:DeclareListenEvent("CHESS.ADD", "OnChessAdd")
SelfMap:DeclareListenEvent("CHESS.REMOVE", "OnChessRemove")
SelfMap:DeclareListenEvent("CHESS.SET_POSITION", "OnChessSetPosition")

function SelfMap:_Uninit()
	ChessPool:Uninit()
	return 1
end

function SelfMap:_Init()
	ChessPool:Init("CHESS")
	self.obj_pool = ChessPool

	local spec_list = {
		{2,2,1,4,4,},
		{1,3,2,6,6,4},
		{3,2,3,3,2,6},
	}
	self:InitChess(3, spec_list)

	-- local function wave_1()
	-- 	ChessSpawner:SpawnChess(self, {2,2,1,4,4,})
	-- end

	-- local function wave_2()
	-- 	ChessSpawner:SpawnChess(self, {1,1,2,6,6,4})
	-- end

	-- local function wave_3()
	-- 	ChessSpawner:SpawnChess(self, {3,2,3,3,2,6})
	-- end

	-- wave_1()
	-- self:RegistLogicTimer(5, {wave_2})
	-- self:RegistLogicTimer(10, {wave_3})

	return 1
end

function SelfMap:Logic2Pixel(logic_x, logic_y)
	local real_x, real_y = (logic_x - 0.5) * Def.MAP_CELL_WIDTH, -logic_y * Def.MAP_CELL_HEIGHT
	local offset_x, offset_y = self:GetMapOffsetPoint()

	return real_x + offset_x, real_y + offset_y
end

function SelfMap:Pixel2Logic(pixel_x, pixel_y)
	local offset_x, offset_y = self:GetMapOffsetPoint()
	local real_x, real_y = pixel_x - offset_x, offset_y - pixel_y

	return math.ceil(real_x / Def.MAP_CELL_WIDTH), math.ceil(real_y / Def.MAP_CELL_HEIGHT)
end


if not EnemyMap then
	EnemyMap = Class:New(Map, "ENEMY_MAP")
end
EnemyMap:DeclareListenEvent("ENEMY_CHESS.ADD", "OnChessAdd")
EnemyMap:DeclareListenEvent("ENEMY_CHESS.REMOVE", "OnChessRemove")
EnemyMap:DeclareListenEvent("ENEMY_CHESS.SET_POSITION", "OnChessSetPosition")

function EnemyMap:_Uninit()
	EnemyChessPool:Uninit()

	return 1
end

function EnemyMap:_Init()
	EnemyChessPool:Init("ENEMY_CHESS")
	self.obj_pool = EnemyChessPool

	local spec_list = {
		{2,1,2,3,4,5},
		{1,2,3,6,1,6},
		{4,3,3,4,4,5},
	}
	self:InitChess(3, spec_list)

	return 1
end

function EnemyMap:Logic2Pixel(logic_x, logic_y)
	local real_x, real_y = (logic_x - 0.5) * Def.MAP_CELL_WIDTH, -logic_y * Def.MAP_CELL_HEIGHT
	local offset_x, offset_y = self:GetMapOffsetPoint()

	local mirro_x, mirror_y = self:Mirror(real_x + offset_x, real_y + offset_y)
	return mirro_x, mirror_y - Def.MAP_CELL_HEIGHT
end

function EnemyMap:Pixel2Logic(pixel_x, pixel_y)
	pixel_x, pixel_y = self:Mirror(pixel_x, pixel_y + Def.MAP_CELL_HEIGHT)

	local offset_x, offset_y = self:GetMapOffsetPoint()
	local real_x, real_y = pixel_x - offset_x, offset_y - pixel_y

	return math.ceil(real_x / Def.MAP_CELL_WIDTH), math.ceil(real_y / Def.MAP_CELL_HEIGHT)
end
