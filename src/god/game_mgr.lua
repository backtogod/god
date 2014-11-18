--=======================================================================
-- File Name    : game_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 19:01:05 2014
-- Description  : sample game mgr
-- Modify       :
--=======================================================================

lua_assert = assert

assert = function(expression, fmt, ...)
    if not expression then
        local log_system = Log
        if fmt then
            log_system:Print(log_system.LOG_ERROR, fmt, ...)
        end
        log_system:Print(log_system.LOG_ERROR, debug.traceback())
        if CAssert --[[and __platform == cc.PLATFORM_OS_WINDOWS]] then
            CAssert(false)
        end
    end
    return expression
end

function GameMgr:Preset()
	local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLView:createWithRect("god", cc.rect(0, 0, 320, 568))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.SHOW_ALL)
    -- turn on display FPS
    director:setDisplayStats(false)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end

function GameMgr:_Init()

    Log:Init(Log.LOG_DEBUG, Log.LOG_INFO)
   
    -- Debug:AddWhiteEvent("PICKHELPER.PICK", Log.LOG_INFO)
    -- Debug:AddWhiteEvent("PICKHELPER.CANCEL_PICK", Log.LOG_INFO)
    -- Debug:AddWhiteEvent("PICKHELPER.DROP", Log.LOG_INFO)

    -- Debug:AddBlackEvent("GAME_STATE.CHANGE")
    Debug:AddBlackEvent("GAME.ROUND_REST_NUM_CHANGED")
    Debug:AddBlackEvent("CHESS.LIFE_CHANGED")
    Debug:AddBlackEvent("CHESS.SET_TEMPLATE")

    -- Debug:ChangeMode(Debug.MODE_WHITE_LIST)
    -- Def.MAP_CELL_WIDTH = visible_size.width / Def.MAP_WIDTH
    local action_node = ComponentMgr:GetComponent("ACTION")
    for state, allow_state_list in pairs(Def.ALLOW_STATE_RULE) do
        for _, allow_state in ipairs(allow_state_list) do
            action_node:AddAllowRule(state, allow_state)
        end
    end
	SceneMgr:FirstLoadScene("MainMenu")
	return 1
end

