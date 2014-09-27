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

VSStageConfig.data = {
	["quick_play"] = {
		self_wave_count = 3,
		enemy_wave_count = 3,
		init_state = GameStateMachine.STATE_ENEMY_WATCH,
	},
	
}
VSStageConfig.test_stage_data = {
	["test_base_combine"] = {
		case_name = "Base Combine",
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
}

for k, v in pairs(VSStageConfig.test_stage_data) do
	VSStageConfig.data[k] = v
end

function VSStageConfig:GetConfig(name)
	if not self.data[name] then
		assert(false, "No Stage[%s] config", tostring(name))
		return
	end
	return self.data[name]
end