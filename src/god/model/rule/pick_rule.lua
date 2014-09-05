--=======================================================================
-- File Name    : pick_rule.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/5 13:40:17
-- Description  : rule for pick
-- Modify       : 
--=======================================================================
if not PickRule then
	PickRule = NewLogicNode("PICK_RULE")
end

function PickRule:GetCanPick(map, logic_x, logic_y)
	for pick_y = Def.MAP_HEIGHT, 1, -1 do
		local chess_id = map:GetCell(logic_x, pick_y)
		if chess_id and chess_id > 0 then
			local logic_chess = map.obj_pool:GetById(chess_id)
			if logic_chess:TryCall("GetState") == Def.STATE_NORMAL then
				return chess_id, pick_y
			end
		end
	end
end

function PickRule:CanDrop(map, logic_x, logic_y)
	if map:GetCell(logic_x, Def.MAP_HEIGHT) > 0 then
		return 0
	end
	return 1
end