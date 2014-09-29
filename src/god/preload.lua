--Sample
AddProjectScript("define.lua")

--Load Model Script
AddProjectScript("model/base/map.lua")
AddProjectScript("model/base/chess.lua")
AddProjectScript("model/base/player.lua")

AddProjectScript("model/rule/combine.lua")
AddProjectScript("model/rule/pick_rule.lua")

AddProjectScript("model/module/game_state_machine.lua")
AddProjectScript("model/module/action_mgr.lua")
AddProjectScript("model/module/chess_spawner.lua")
AddProjectScript("model/module/mover.lua")
AddProjectScript("model/module/command_center.lua")
AddProjectScript("model/module/battle.lua")

AddProjectScript("model/ai/boss_robot.lua")
AddProjectScript("model/ai/vs_robot.lua")

--Load Controller Script
AddProjectScript("controller/touch_input.lua")

--Load View Script
AddProjectScript("view/view_interface.lua")
AddProjectScript("view/scene/main_menu_scene.lua")
AddProjectScript("view/scene/vs_scene.lua")
AddProjectScript("view/scene/boss_scene.lua")

--Load Game Config
AddProjectScript("config/chess_config.lua")
AddProjectScript("config/vs_stage_config.lua")

--$(SRCROOT)/../../../../external/lua/luajit/prebuilt/ios

