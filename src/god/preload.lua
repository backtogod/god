--Sample
AddProjectScript("define")

--Load Model Script
AddProjectScript("model/base/map")
AddProjectScript("model/base/chess")
AddProjectScript("model/base/player")

AddProjectScript("model/rule/combine")
AddProjectScript("model/rule/pick_rule")

AddProjectScript("model/module/game_state_machine")
AddProjectScript("model/module/action_mgr")
AddProjectScript("model/module/chess_spawner")
AddProjectScript("model/module/mover")
AddProjectScript("model/module/command_center")
AddProjectScript("model/module/battle")

AddProjectScript("model/ai/boss_robot")
AddProjectScript("model/ai/vs_robot")

--Load Controller Script
AddProjectScript("controller/touch_input")

--Load View Script
AddProjectScript("view/view_interface")
AddProjectScript("view/scene/main_menu_scene")
AddProjectScript("view/scene/vs_scene")
AddProjectScript("view/scene/boss_scene")
AddProjectScript("view/scene/character_info")

--Load Game Config
AddProjectScript("config/chess_config")
AddProjectScript("config/vs_stage_config")

--$(SRCROOT)/../../../../external/lua/luajit/prebuilt/ios

