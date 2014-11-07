--=======================================================================
-- File Name    : chess_spawner.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 14:07:18 2014
-- Description  : spawn chess helper
-- Modify       :
--=======================================================================

if not ChessSpawner then
	ChessSpawner = ModuleMgr:NewModule("ChessSpawner")
end

function ChessSpawner:_Uninit( ... )
	return 1
end

function ChessSpawner:_Init( ... )
	return 1
end

function ChessSpawner:SpawnChess(map, id_list)
	local last_logic_y = nil
	local last_generate_id = nil
	for logic_x = 1, Def.MAP_WIDTH do
		local logic_y = Mover:GetMoveablePosition(map, logic_x)
		local generate_id = nil
		if logic_y > 0 then
			if id_list and id_list[logic_x] then
				generate_id = id_list[logic_x]
			else
				local except_list = {}
				if last_generate_id and logic_y == last_logic_y then
					except_list[last_generate_id] = 1
				end
				
				local id_top = map:GetTopCell(logic_x)
				local id_second = map:GetTopCell(logic_x, 2)
				if id_top and id_second then
					local chess_top = map.obj_pool:GetById(id_top)
					local chess_second = map.obj_pool:GetById(id_second)
					local state_top = chess_top:TryCall("GetState")
					local state_second = chess_second:TryCall("GetState")

					local template_top = chess_top:GetTemplateId()
					local template_second = chess_second:GetTemplateId()
					if state_top == Def.STATE_NORMAL and state_second == Def.STATE_NORMAL and template_top == template_second then
						except_list[template_top] = 1
					end
				end
				local generate_list = {}
				for i = 1, 6 do
					if not except_list[i] then
						generate_list[#generate_list + 1] = i
					end
				end
				generate_id = generate_list[math.random(1, #generate_list)]
			end
			local chess, id = map.obj_pool:Add(Chess, generate_id, logic_x, Def.MAP_HEIGHT)
			chess:MoveTo(logic_x, logic_y)
		end
		last_logic_y = logic_y
		last_generate_id = generate_id
	end
end