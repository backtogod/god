--=======================================================================
-- File Name    : define.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Wed Aug 13 21:51:25 2014
-- Description  : 
-- Modify       :
--=======================================================================

Def.MAP_WIDTH = 6
Def.MAP_HEIGHT = 4
Def.MAP_CELL_WIDTH = 90
Def.MAP_CELL_HEIGHT = 80

Def.MAP_OFFSET_Y = 50

Def.STATE_NORMAL = "normal"
Def.STATE_WALL = "wall"
Def.STATE_ARMY = "army"


Def.ALLOW_STATE_RULE = {
	[Def.STATE_NORMAL] = {Def.STATE_WALL, Def.STATE_ARMY},
	[Def.STATE_WALL] = {},
	[Def.STATE_ARMY] = {},
}

Def.DEFAULT_ROUND_NUM = 1
Def.CHESS_MOVE_SPEED = 1000
Def.TRANSPORT_TIME = 0.5