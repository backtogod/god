--=======================================================================
-- File Name    : vs_stage_config.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Sep 27 23:04:29 2014
-- Description  : stage config
-- Modify       :
--=======================================================================

if not VSStageConfig then
	VSStageConfig = {}
end

VSStageConfig.stage_data = {
	["move_mode"] = {
		template_scene = "VSScene",
		self_wave_count = 3,
		enemy_wave_count = 3,
		init_state = GameStateMachine.STATE_ENEMY_WATCH,
	},

	["put_mode"] = {
		template_scene = "BossScene",
		self_wave_count = 0,
		enemy_wave_count = 0,
		init_state = GameStateMachine.STATE_ENEMY_WATCH,
	},
}

VSStageConfig.stage_list = {
	{
		case_name = "1-1",
		stage_name = "1-1",
		data = {
			template_scene = "VSScene",			
			self_map_data = {
				{2,1,1,2,2,1,2,},
				{3,2,1,3,3,2,1,},
				{nil, nil, nil, 1, nil, nil},
			},
			enemy_map_data = {
				{1,2,1,3,3,2,3,},
				{2,1,2,3,nil,3,1,},
				{3,2,2,nil,nil,2,1,},
			},
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
}

for k, v in pairs(VSStageConfig.stage_list) do
	VSStageConfig.stage_data[v.stage_name] = v.data
end

VSStageConfig.test_stage_data = {
	{
		case_name = "Base Combine",
		stage_name = "test_base_combine",
		data = {
			template_scene = "VSScene",			
			self_spec = {
				{3,2,2,4,5,6,},
				{1,1,1,5,4,4,},
				{3,5,3,1,5,6,},
				{3,2,3,1,5,6,},
			},
			self_wave_count = 4,
			enemy_spec = {
				{1,2,1,3,3,6,},
				{6,5,2,2,2,3,},
				{2,2,1,4,5,4,},
				{3,2,1,4,5,4,},
			},
			enemy_wave_count = 4,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
	{
		case_name = "Cross Combine",
		stage_name = "test_cross_combine",
		data = {
			template_scene = "VSScene",
			self_spec = {
				{1,1,1,5,4,4,},
				{3,1,3,3,5,6,},
				{3,1,3,3,5,6,},
			},
			self_wave_count = 3,
			enemy_spec = {},
			enemy_wave_count = 3,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
	{
		case_name = "Victory",
		stage_name = "test_victory",
		data = {
			template_scene = "VSScene",			
			self_spec = {
				{6,5,6,5,6,5,},
				{6,5,6,5,6,5,},
				{6,5,6,5,6,5,},
				{6,5,6,5,6,5,},
			},
			self_wave_count = 4,
			enemy_spec = {
				{1,2,1,3,3,6,},
				{6,5,2,2,2,3,},
				{2,2,1,4,5,4,},
				{3,2,1,4,5,4,},
			},
			enemy_wave_count = 4,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},	
	{
		case_name = "Destory Chess",
		stage_name = "test_destroy",
		data = {
			template_scene = "VSScene",			
			self_spec = {
				{1,2,1,3,3,6,},
				{6,5,2,3,2,3,},
				{2,2,1,4,5,4,},
				{3,2,1,4,5,4,},
			},
			self_wave_count = 4,
			enemy_spec = {
				{1,2,1,3,3,6,},
				{6,5,2,3,2,3,},
			},
			enemy_wave_count = 2,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
	{
		case_name = "Preset Map Data",
		stage_name = "test_map_data",
		data = {
			template_scene = "VSScene",			
			self_map_data = {
				{{5, Def.STATE_ARMY, 6, 4,}, nil, {1, Def.STATE_WALL, 10}, 2},
			},
			enemy_map_data = {
				{{1, Def.STATE_WALL, 10,}, {1, Def.STATE_WALL, 10}, {1, Def.STATE_WALL, 10},},
			},
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
}

for k, v in pairs(VSStageConfig.test_stage_data) do
	VSStageConfig.stage_data[v.stage_name] = v.data
end

VSStageConfig.bugs_data = {
	{
		case_name = "Bug#3 AI Dead",
		stage_name = "Bug",
		data = {
			template_scene = "VSScene",			
			self_map_data = {
				{{5, Def.STATE_ARMY, 6, 4,}, nil, {1, Def.STATE_WALL, 10}, 2},
			},
			enemy_map_data = {
				{4, {5, Def.STATE_ARMY, 6, 5}, 5, {6, Def.STATE_ARMY, 14, 5}, 2, 5, 3},
				{3, 2, 2, 1, nil, 1, 6},
				{1, nil, 3},
				{4, nil, 1},
			},
			init_state = GameStateMachine.STATE_SELF_WATCH,
		},
	},
	{
		case_name = "Bug#2 Mulit Attack same time",
		stage_name = "BugMultiAttack",
		data = {
			template_scene = "VSScene",			
			self_spec = {
				{2,2,1,3,3,6,},
				{2,5,2,3,2,3,},
				{2,2,1,4,5,4,},
				{1,2,1,4,5,4,},
			},
			self_wave_count = 4,
			enemy_spec = {
				{2,2,1,3,3,6,},
				{3,5,2,3,2,3,},
				{2,2,1,4,5,4,},
			},
			enemy_wave_count = 3,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
	{
		case_name = "Bug#1 Can't End",
		stage_name = "BugEnd",
		data = {
			template_scene = "VSScene",			
			self_spec = {
				{3,2,2,4,5,6,},
				{1,1,1,2,4,4,},
				{3,5,3,3,5,6,},
				{3,2,3,3,5,6,},
			},
			self_wave_count = 4,
			enemy_spec = {
				{1,2,1,3,3,6,},
				{6,5,2,2,2,3,},
				{2,2,1,4,5,4,},
				{3,2,1,4,5,4,},
			},
			enemy_wave_count = 4,
			init_state = GameStateMachine.STATE_ENEMY_WATCH,
		},
	},
	
}

for k, v in pairs(VSStageConfig.bugs_data) do
	VSStageConfig.stage_data[v.stage_name] = v.data
end

function VSStageConfig:GetConfig(name)
	if not self.stage_data[name] then
		assert(false, "No Stage[%s] config", tostring(name))
		return
	end
	return self.stage_data[name]
end