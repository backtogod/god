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
        if CAssert and __platform == cc.PLATFORM_OS_WINDOWS then
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
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end

function GameMgr:_Init()
	SceneMgr:FirstLoadScene("GameScene")
	return 1
end

