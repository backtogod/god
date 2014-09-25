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

function PickRule:GetCanPick(map, logic_x)
	local top_id, top_y = map:GetTopCell(logic_x)
	if top_id and top_id > 0 then
		local logic_chess = map.obj_pool:GetById(top_id)
		if logic_chess:TryCall("GetState") == Def.STATE_NORMAL then
			return top_id, top_y
		end
	end

end

function PickRule:CanDrop(map, logic_x)
	if map:GetCell(logic_x, Def.MAP_HEIGHT) > 0 then
		return 0
	end
	return 1
end