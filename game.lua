-- Filename: Menu
-- Author: Luke Perkin
-- Date: 2010-03-15
Game = class('game',StatefulObject)
Game.menu = Game:addState('menu')
Game.serverbrowser = Game:addState('serverbrowser')
Game.play = Game:addState('play')
Game.startserver = Game:addState('startserver',Game.play)
Game.startclient = Game:addState('startclient',Game.play)

local Play = Game.play
local Menu = Game.menu

Game.settings = {}
Game.settings.host			= "127.0.0.1"
Game.settings.port 			= 1234
Game.settings.socketType 	= "udp"
Game.settings.handshake		= "cards"
Game.settings.dns			= false
Game.settings.serverDatabase = "http://locofilm.co.uk/love/"

function Game:initialize()
	super.initialize(self)
	--Load font
	self.CooperFont = love.graphics.newFont( 'fonts/CooperBlackStd.otf', '52' )
	love.graphics.setFont( self.CooperFont )
	math.randomseed( os.time() )
end
function Game:update()
end
function Game:draw()
end
function Game:mousepressed()
end
function Game:mousereleased()
end
function Game:keypressed()
end
function Game:keyreleased()
end
function Game:quit()
end

-- Initialization
function Menu:enterState()
	--Load images
	self.Title = love.graphics.newImage( 'images/menutitle.png' )
	self.Cardslogo = love.graphics.newImage( 'images/menucards.png' )
	self.Poweredlogo = love.graphics.newImage( 'images/powerbylove.png' )
	self.alpha = 255
	--Create buttons
	self.buttons = {}
	self.frame = goo.null:new()
	self.frame:setPos( 50, 200 )
	self.buttons[1] = Game.button:new( self.frame, -400, 0, "Make game")
	self.buttons[2] = Game.button:new( self.frame, -400, 55, "Join game")
	self.buttons[3] = Game.button:new( self.frame, -400, 110, "Settings")
	self.buttons[4] = Game.button:new( self.frame, -400, 165, "Help?")
	--Grey out unused buttons.
	self.buttons[3].enterHover = function(self) self:setColor(200,200,200,255) end
	self.buttons[3].exitHover = function(self) self:setColor(200,200,200,255) end
	self.buttons[4].enterHover = function(self) self:setColor(200,200,200,255) end
	self.buttons[4].exitHover = function(self) self:setColor(200,200,200,255) end
	--Add button callbacks.
	self.buttons[1].onClick = function() self:nextState('startserver') end
	self.buttons[2].onClick = function() self:nextState('serverbrowser') end
	--Animate buttons.
	self.buttons[1].anim = goo.animation:new{
		table = self.buttons[1],
		key		= 'x',
		start	= -400,
		finish	= 0,
		time	= 2,
		style 	= goo.animation.style.expoInOut
	}
	self.buttons[2].anim = goo.animation:new{
		table = self.buttons[2],
		key		= 'x',
		start	= -400,
		finish	= 0,
		time	= 2,
		style 	= goo.animation.style.expoInOut,
		delay	= 0.2
	}
	self.buttons[3].anim = goo.animation:new{
		table = self.buttons[3],
		key		= 'x',
		start	= -400,
		finish	= 0,
		time	= 2,
		style 	= goo.animation.style.expoInOut,
		delay	= 0.4
	}
	self.buttons[4].anim = goo.animation:new{
		table = self.buttons[4],
		key		= 'x',
		start	= -400,
		finish	= 0,
		time	= 2,
		style 	= goo.animation.style.expoInOut,
		delay	= 0.6
	}
	self.buttons[1].anim:play()
	self.buttons[2].anim:play()
	self.buttons[3].anim:play()
	self.buttons[4].anim:play()
end

function Menu:nextState(state)
	self.alphaanim = goo.animation:new{
		table	= self,
		key		= 'alpha',
		start	= 255,
		finish	= 0,
		time	= 1.2
	}
	self.buttons[1].anim:reverse()
	self.buttons[2].anim:reverse()
	self.buttons[3].anim:reverse()
	self.buttons[4].anim:reverse()
	self.buttons[1].anim:play()
	self.buttons[2].anim:play()
	self.buttons[3].anim:play()
	self.buttons[4].anim:play()
	self.buttons[4].anim.onFinish = function() self:gotoState( state ) end
	self.alphaanim:play()
end

-- Logic
function Menu:update(dt)
	goo.update(dt)
end

-- Scene Drawing
function Menu:draw()
	love.graphics.setColor(255,255,255,self.alpha)
	love.graphics.draw( self.Title, 50, 50 )
	love.graphics.draw( self.Cardslogo, 500, 190 )
	love.graphics.drawAlign( 'left', 'bottom', self.Poweredlogo, 10, 10 )
	goo.draw()
end

-- Input
function Menu:keypressed(key,unicode)

end

function Menu:keyreleased(key,unicode)

end

function Menu:mousepressed(x,y,button)

end

function Menu:mousereleased(x,y,button)
	for i,v in ipairs(goo.objects) do
		v:mousereleased(x,y,button)
	end
end

-------------------------------------------------------------
------ SERVER BROWSER.
-------------------------------------------------------------
function Game.serverbrowser:enterState()
	local data,c,h = http.request( Game.settings.serverDatabase, 'mid=get' )
	self.serverList = explode(',',data)
	self.serverButton = {}
	local frame = goo.null:new()
	frame:setPos(50,50)
	-- Add localhost for LAN.
	local b = Game.button:new( frame, -500, 0, 'LAN' )
	b.onClick = function ()
		self.settings.host = '127.0.0.1'
		self:gotoState('startclient')
	end
	b.anim = goo.animation:new{
		table	= b,
		key		= 'x',
		start	= -500,
		finish	= 0,
		time	= 1,
		delay	= 0,
		style	= goo.animation.style.quadInOut
	}
	b.anim:play()
	table.insert( self.serverButton, b )
	-- Add all other servers.
	for i,v in ipairs( self.serverList ) do
		local b = Game.button:new( frame, -500, i*55, v )
		b.onClick = function ()
			self.settings.host = v
			self:gotoState('startclient')
		end
		b.anim = goo.animation:new{
			table	= b,
			key		= 'x',
			start	= -500,
			finish	= 0,
			time	= 1,
			delay	= i*0.2,
			style	= goo.animation.style.quadInOut
		}
		b.anim:play()
		table.insert( self.serverButton, b )
	end
end
function Game.serverbrowser:update(dt)
	goo.update(dt)
end
function Game.serverbrowser:draw()
	goo.draw()
end
function Game.serverbrowser:mousereleased(x,y,button)
	goo.mousereleased(x,y,button)
end

-------------------------------------------------------------
------ START SERVER.
-------------------------------------------------------------
function Game.startserver:enterState()
	self.server = Server:new( self.settings.port, self.settings.socketType, self.settings.handshake )
	--self.client = Client:new( self.settings.host, self.settings.port, self.settings.socketType, true, self.settings.handshake)
	self.netObj = self.server
	self.isServer = true
	
	-- Send your ip to the server list.
	http.request( self.settings.serverDatabase, 'mid=add' )
	super.enterState(self)
	self.canvas:addMessage('Server initialized')
end
function Game.startserver:update(dt)
	super.update(self,dt)
	self.server:update(dt)
	--if self.client then self.client:update(dt) end
end
function Game.startserver:exitState()
	self:quit()
end
function Game.startserver:keypressed(key,unicode)
	super.keypressed(self,key,unicode)
end
function Game.startserver:quit()
	-- Remove your ip from the list.
	http.request( self.settings.serverDatabase, 'mid=rem' )
end

-------------------------------------------------------------
------ START CLIENT.
-------------------------------------------------------------
function Game.startclient:enterState()
	self.client = Client:new( self.settings.host, self.settings.port, self.settings.socketType, self.settings.dns, self.settings.handshake)
	self.netObj = self.client
	self.isServer = false
	super.enterState(self)
	self.canvas:addMessage('Connected to server.')
end
function Game.startclient:exitState()
	self:quit()
end
function Game.startclient:update(dt)
	super.update(self,dt)
	self.client:update(dt)
end
function Game.startclient:keypressed(key,unicode)
	super.keypressed(self,key,unicode)
end
function Game.startclient:quit()
	self.client:send( self.settings.handshake )
	self.client.connected = false
end

-------------------------------------------------------------
------ SHARED NETWORKING.
-------------------------------------------------------------
function Play:updateCard( _card )
	local data = lube.bin:pack{ mid=2, id=_card.id, _card.x, _card.y }
	self.netObj:send( data )
end
function Play:flipCard( _card )
	local data = lube.bin:pack{ mid=3, id=_card.id, _card.flipped }
	self.netObj:send( data )
end
function Play:hideCard( _card, bool )
	local data = lube.bin:pack{ mid=4, id=_card.id, bool }
	self.netObj:send( data )
end
function Play:destroyCard( _card )
	local data = lube.bin:pack{ mid=5, id=_card.id }
	self.netObj:send( data )
end

-------------------------------------------------------------
------ PLAYING BOARD.
-------------------------------------------------------------
function Play:enterState()
	self.count = newCounter()
	self.canvas = canvas:new()
end
function Play:update(dt)
	-- Update all objects on canvas.
	for i,v in ipairs(CanvasObject.list) do
		v:update(dt)
	end
	self.canvas:update(dt)
end
function Play:draw()
	-- Draw all objects on canvas.
	for i,v in ipairs(CanvasObject.list) do
		v:draw()
	end
	self.canvas:draw()
end
function Play:mousepressed( x, y, button )
	for i=#CanvasObject.list,1,-1 do
		if CanvasObject.list[i]:mouseOver(x,y) and not CanvasObject.list[i]:inState('hidden') then
			CanvasObject.list[i]:mousepressed(x,y,button)
			return
		end
	end
	self.canvas:mousepressed(x,y,button)
end
function Play:mousereleased( x, y, button )
	for i=#CanvasObject.list,1,-1 do
		CanvasObject.list[i]:mousereleased(x,y,button)
	end
	self.canvas:mousereleased(x,y,button)
end
function Play:keypressed(key,unicode)
	self.canvas:keypressed(key,unicode)
end
function Play:keyreleased(key,unicode)
end






Game.button = class('menu button', goo.object)
function Game.button:initialize(parent,x,y,text)
	super.initialize(self,parent)
	self.x, self.y = x,y
	self.w, self.h = 500,500
	self.text = text
	self:sizeToContents()
end
function Game.button:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.print( self.text, x, y )
end
function Game.button:enterHover()
	self:setColor(210,0,0,255)
end
function Game.button:exitHover()
	self:setColor(0,0,0,255)
end

