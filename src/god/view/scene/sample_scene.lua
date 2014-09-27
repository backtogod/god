--=======================================================================
-- File Name    : sample_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 18:07:07 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("Sample", 1)
Scene.property = {
	can_touch = 1,
	can_drag = 1,
	limit_drag = 1,
}

function Scene:MainSample()
	local element_list = {
		{
	    	{
				item_name = "Quick Play",
	        	callback_function = function()
	        		SceneMgr:LoadScene("VSScene", "quick_play")
	        	end,
	        },
	    },
 		{
	    	{
				item_name = "Test Cases",
	        	callback_function = function()
	        		self:TestCase()
	        	end,
	        },
	    },
	}
	

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 40, align_type = "center", interval_x = 50, interval_y = 30}
    )
    if height > visible_size.height then
    	self:SetHeight(height)
    end
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "Welcome")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "Welcome")
    end
    Ui:AddElement(ui_frame, "MENU", "Welcome", visible_size.width / 2, visible_size.height / 2 + height / 2, menu_tools)
    return 1
end

function Scene:TestCase()
	local element_list = {}
	for stage_name, data in pairs(VSStageConfig.test_stage_data) do
		local element = {
			{
				item_name = data.case_name or stage_name .. "(forget?)",
				callback_function = function ()
					SceneMgr:LoadScene("VSScene", stage_name)
				end,
			},
		}
		element_list[#element_list + 1] = element
	end
	element_list[#element_list + 1] = {
    	{
			item_name =  "Return",
        	callback_function = function()
        		self:MainSample()
        	end,
        },
    }

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 40, align_type = "center", interval_x = 50, interval_y = 20}
    )
    if height > visible_size.height then
    	self:SetHeight(height)
    end
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "Welcome")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "Welcome")
    end
    Ui:AddElement(ui_frame, "MENU", "Welcome", visible_size.width / 2, visible_size.height / 2 + height / 2, menu_tools)
end

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()
	self:MainSample()
    return 1
end