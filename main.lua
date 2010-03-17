--####################################################--
--##### CARD ENGINE. By Luke Perkin, March 2010 ######--
--####################################################--
------- Tab Size 4. Newline \n -------------------------
--------------------------------------------------------
socket = require 'socket'
http   = require 'socket.http'
require 'middleclass'
require 'mindstate'
require 'goo/goo'
require 'loadcards'
require 'util'
require 'lube'
require 'server'
require 'client'
require 'game'
require 'canvasobject'
require 'card'
require 'chips'
require 'canvas'

---------------
-- LOVE FUNCS
---------------
function love.load()
	love.graphics.setFont(24)
	love.graphics.setLine( 1, 'smooth' )
	love.graphics.setPoint( 1, 'smooth' )
	love.graphics.setBackgroundColor( 255,255,255 )
	
	game = Game:new()
	game:gotoState('menu')
end
function love.update(dt)
	game:update(dt)
end
function love.draw()
	game:draw()
end
function love.mousepressed( x, y, button )
	game:mousepressed(x,y,button)
end
function love.mousereleased( x, y, button )
	game:mousereleased(x,y,button)
end
function love.keypressed(key,unicode)
	game:keypressed(key,unicode)
end
function love.quit()
	game:quit()
end

---------------
-- MAIN LOOP
---------------
function love.run()
    if love.load then love.load(arg) end
    local dt = 0
    -- Main loop time.
    while true do
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics then
            love.graphics.clear()
            if love.draw then love.draw() end
        end
        -- Process events.
        if love.event then
            for e,a,b,c in love.event.poll() do
                if e == "q" then
					love.quit()
                    if love.audio then
                        love.audio.stop()
                    end
                    return
                end
                love.handlers[e](a,b,c)
            end
        end
        if love.timer then love.timer.sleep(1) end
        if love.graphics then love.graphics.present() end
    end
end