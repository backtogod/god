--=======================================================================
-- File Name    : main_menu_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 18:07:07 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("MainMenu", 1)
Scene.property = {
	can_touch = 1,
}

function Scene:MainSample()
	local ui_frame = self:GetUI()
	local element_list = {
		{
			{
				item_name = "移动模式",
		    	callback_function = function()
		    		SceneMgr:LoadScene("VSScene", "move_mode")
		    	end,
		    },
		    {
				item_name = "放置模式",
		    	callback_function = function()
		    		SceneMgr:LoadScene("VSScene", "put_mode")
		    	end,
		    },
		},
 		{
	    	{
				item_name = "Test Cases",
	        	callback_function = function()
		        	local scene = SceneMgr:LoadScene("SceneList", "test_cases")
		        	scene:ShowSceneList(VSStageConfig.test_stage_data)
	        	end,
	        },
	    },
	    {
	    	{
				item_name = "Bug issue",
	        	callback_function = function()
	        		local scene = SceneMgr:LoadScene("SceneList", "bug_issue")
	        		scene:ShowSceneList(VSStageConfig.bugs_data)
	        	end,
	        },
	    },
	}
	

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 60, align_type = "center", interval_x = 50, interval_y = 60}
    )
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "Welcome")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "Welcome")
    end
    local x, y = visible_size.width / 2, visible_size.height / 2 + height / 2
    if height > visible_size.height - 50 then
    	y = visible_size.height - 50
    end
    Ui:AddElement(ui_frame, "MENU", "Welcome", x, y, menu_tools)
     self.menu_welcom_height = height
    return 1
end

function Scene:_Init()
	self:AddReloadMenu(50)
	self:MainSample()
    return 1
end