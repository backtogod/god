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
	if info then
		self:RemoveCell(info.x, info.y)
	end
	self:SetCell(x, y, id)
	CombineMgr:OnChessChangePostion(id, x, y)
end

function Map:OnChessAdd(id, template_id, x, y)
	self:SetCell(x, y, id)
	CombineMgr:OnChessChangePostion(id, x, y)
	Mover:RemoveHole(self, x)
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

	ChessPool:Add(Chess, 1, 1, 6)
	ChessPool:Add(Chess, 2, 2, 6)
	ChessPool:Add(Chess, 3, 3, 6)
	ChessPool:Add(Chess, 4, 4, 6)
	ChessPool:Add(Chess, 5, 5, 6)
	ChessPool:Add(Chess, 6, 6, 6)

	ChessPool:Add(Chess, 1, 2, 6)
	ChessPool:Add(Chess, 2, 3, 6)
	ChessPool:Add(Chess, 3, 4, 6)
	ChessPool:Add(Chess, 4, 5, 6)
	ChessPool:Add(Chess, 5, 6, 6)
	ChessPool:Add(Chess, 6, 1, 6)

	ChessPool:Add(Chess, 1, 3, 6)
	ChessPool:Add(Chess, 2, 4, 6)

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

	EnemyChessPool:Add(Chess, 1, 1, 1)
	EnemyChessPool:Add(Chess, 2, 2, 1)
	EnemyChessPool:Add(Chess, 3, 3, 1)
	EnemyChessPool:Add(Chess, 4, 4, 1)
	EnemyChessPool:Add(Chess, 5, 5, 1)
	EnemyChessPool:Add(Chess, 6, 6, 1)
	
	return 1
end

