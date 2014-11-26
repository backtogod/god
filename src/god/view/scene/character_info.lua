--=======================================================================
-- File Name    : character_info.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Nov 23 16:53:00 2014
-- Description  : description
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("CharacterInfo", 1)
Scene.property = {
	can_touch = 1,
}

function Scene:_Uninit( ... )
	-- body
	return 1
end

function Scene:_Init( ... )
	self:AddReloadMenu(50)
	self:AddReturnMenu(50)

	local layer = self:CreateLayer("info")
	local index = 0
	for id, config in ipairs(ChessConfig.template) do
		local image = config.image
		local sprite = cc.Sprite:create(config.image)
		sprite:setAnchorPoint(cc.p(0, 0.5))
		local rect = sprite:getBoundingBox()
		local scale_x = Def.MAP_CELL_WIDTH / rect.width
		local scale_y = Def.MAP_CELL_HEIGHT / rect.height
		sprite:setScaleX(scale_x)
		if scale_y < 1 then
			sprite:setScaleY(scale_y)
		end
		index = index + 1
		local x = 80
		local y = visible_size.height - index * (Def.MAP_CELL_HEIGHT + 40) - 50
		sprite:setPosition(x, y)
		self:AddObj("info", "icon", id, sprite)

		x = x + Def.MAP_CELL_WIDTH + 50
		local msg = string.format("life:%d base:%d\nstep:%d wait:%d", config.life, config.base_life, config.step_life, config.wait_round)
		local label = cc.Label:createWithSystemFont(msg, nil, 40)
		label:setPosition(x, y)
		label:setAnchorPoint(cc.p(0, 0.5))
		self:AddObj("info", "label", id, label)
	end

	return 1
end