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

Def.DEFAULT_ROUND_NUM = 5
Def.CHESS_MOVE_SPEED = 1000
Def.CHESS_BATTLE_MOVE_SPEED = 400
Def.TRANSFORM_TIME = 0.5
Def.DEFAULT_ATTACK_TIME = 10
Def.WALL_DEFAULT_HP = 5
Def.WALL_MAX_HP = 30