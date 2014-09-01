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

function Map:OnChessSetPosition(id, x, y, old_x, old_y)
	local info = self:GetCellInfo(id)
	if info and info.x == old_x and info.y == old_y then
		self:RemoveCell(info.x, info.y)
	end
	self:SetCell(x, y, id)
	CombineMgr:OnChessChangePostion(self, id, logic_x, logic_y)
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

function Map:Debug(is_detail)
	Lib:Show2DTB(self.cell_pool, Def.MAP_WIDTH, Def.MAP_HEIGHT, 1)
	if is_detail == 1 then
		Lib:ShowTB(self.cell_list)
	end
end

function Map:Logic2PixelSelf(logic_x, logic_y)
	local real_x, real_y = (logic_x - 0.5) * Def.MAP_CELL_WIDTH, -logic_y * Def.MAP_CELL_HEIGHT
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
	local mirro_x, mirror_y = self:Mirror(pixel_x, pixel_y)
	return mirro_x, mirror_y - Def.MAP_CELL_HEIGHT
end

function Map:Pixel2LogicEnemy(pixel_x, pixel_y)
	local real_x, real_y = self:Mirror(pixel_x, pixel_y + Def.MAP_CELL_HEIGHT)
	return self:Pixel2LogicSelf(real_x, real_y)
end

function Map:GetMapOffsetPoint()
	local offset_x = (visible_size.width - math.floor(Def.MAP_WIDTH * Def.MAP_CELL_WIDTH)) * 0.5
	local offset_y = (visible_size.height * 0.5 - Def.MAP_OFFSET_Y)

	return offset_x, offset_y
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

	-- local random_list = {}
	-- local max_wave = 0
	-- for i = 1, 14 do
	-- 	local n = math.random(1, 6)
	-- 	if not random_list[n] then
	-- 		random_list[n] = {}
	-- 	end
	-- 	table.insert(random_list[n], 1)
	-- 	if #random_list[n] > max_wave then
	-- 		max_wave = #random_list[n]
	-- 	end
	-- end
	-- local function wave(wave_count, count)
	-- 	for i = 1, count do
	-- 		ChessPool:Add(Chess, math.random(1, 6), math.random(1, 6), 6)
	-- 	end
	-- end

	-- local delay_frame = 0
	-- local add_frame = 5
	-- for i = 1, max_wave do
	-- 	delay_frame = delay_frame + add_frame
	-- 	add_frame = add_frame - 1
	-- 	local count = 0
	-- 	for j = 1, 6 do
	-- 		if random_list[j] and #random_list[j] > 0 then
	-- 			table.remove(random_list[j], #random_list[j])
	-- 			count = count + 1
	-- 		end
	-- 	end
	-- 	self:RegistLogicTimer(delay_frame, {wave, i, count})
		
	-- end

	local function wave_1()
		ChessSpawner:SpawnChess(self, {2,2,1,4,4,})
	end

	local function wave_2()
		ChessSpawner:SpawnChess(self, {1,1,2,6,6,4})
	end

	local function wave_3()
		ChessSpawner:SpawnChess(self, {3,2,3,3,2,6})
	end

	wave_1()
	self:RegistLogicTimer(5, {wave_2})
	self:RegistLogicTimer(10, {wave_3})

	return 1
end

if not EnemyMap then
	EnemyMap = Class:New(Map, "ENEMY_MAP")
end
EnemyMap:DeclareListenEvent("ENEMY_CHESS.ADD", "OnChessAdd")
EnemyMap:DeclareListenEvent("ENEMY_CHESS.REMOVE", "OnChessRemove")

function EnemyMap:_Uninit()
	EnemyChessPool:Uninit()

	return 1
end
function EnemyMap:_Init()
	EnemyChessPool:Init("ENEMY_CHESS")
	self.obj_pool = EnemyChessPool

	ChessSpawner:SpawnChess(self, self.obj_pool)

	return 1
end

