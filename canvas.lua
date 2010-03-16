-- Filename: CANVAS
-- Author: Luke Perkin
-- Date: 2010-03-16
----------------
-- CANVAS FUNCS
----------------
canvas = class('canvas',StatefulObject)
canvas.lasso = canvas:addState('lasso')
canvas.menu  = canvas:addState('menu')
canvas.context  = canvas:addState('context')
canvas.font1 = love.graphics.newFont( 'fonts/CooperBlackStd.otf', '15' )

function canvas:initialize()
	super.initialize(self)
	self.foundCards = {}
	self.flipped = false
	self.messages = {}
end
function canvas:update(dt)
	goo.update(dt)
end
function canvas:draw()
	if self.lastMouseX then
		love.graphics.setColor( 136, 194, 250, 100 )
		love.graphics.rectangle( 'fill', self.lastMouseX, self.lastMouseY, love.mouse.getX()-self.lastMouseX, love.mouse.getY()-self.lastMouseY )
	end
	
	-- Player private line.
	love.graphics.setColor(0,0,0,150)
	love.graphics.setFont( self.font1 )
	love.graphics.print( 'Your hand', 10, love.graphics.getHeight()-172 )
	love.graphics.setColor(0,0,0,255)
	love.graphics.line( 0,love.graphics.getHeight()-170,love.graphics.getWidth(),love.graphics.getHeight()-170 )
	
	-- How many cards selected?
	if self.foundCards and #self.foundCards > 3 then
		local x,y = self.foundCards[#self.foundCards].x,self.foundCards[#self.foundCards].y
		
		love.graphics.setFont( game.CooperFont, 55)
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(#self.foundCards, x-17,y+12 )
		love.graphics.setFont( game.CooperFont, 52 )
		love.graphics.setColor(0,255,0,255)
		love.graphics.print(#self.foundCards, x-14,y+9 )
	end
	
	self:drawMessage()
end
function canvas:mousepressed(x,y,button)
	if button == 'l' then
		if love.keyboard.isDown( 'lctrl' ) then
			self:gotoState('lasso')
		else
			self.lastMouseX = x
			self.lastMouseY = y
		end
	end
end
function canvas:mousereleased(x,y,button)	
	if button == 'l' then
		for i,v in ipairs(CanvasObject.list) do
			v:selectState(nil)
		end
		if self.lastMouseX then
			self:findCardsInRect( self.lastMouseX, self.lastMouseY, x, y )
			self.lastMouseX = nil
			if #self.foundCards > 0 then self:gotoState('menu') else self:gotoState(nil) end
		else
			self:gotoState(nil)
		end
	elseif button == 'r' then
		local a = true
		for i,v in ipairs(CanvasObject.list) do
			if v:mouseOver(x,y) then a = false end
		end
		self:gotoState(nil)
		if a then self:gotoState('context') end
	end
end
function canvas:keypressed(key,unicode)
	if key == 'lctrl' then return end
end
function canvas:stackCards( list )
	local _x,_y = 0,0
	for i,v in ipairs(list) do
		_x = _x + v.x
		_y = _y + v.y
	end
	
	_x = _x / #list
	_y = _y / #list
	for i,v in ipairs(list) do
		v.x = _x + (i*4) - 17
		v.y = _y + (i*4) - 17
	end
end
function canvas:findCardsInRect( x1, y1, x2, y2 )
	if x1 > x2 then x1,x2 = x2,x1 end
	if y1 > y2 then y1,y2 = y2,y1 end
	local pad = 10
	self.foundCards = {}
	for i,v in ipairs(CanvasObject.list) do
		local cx,cy,cx2,cy2 = v.x+pad, v.y+pad, v.x+v.width-pad, v.y+v.height-pad
		if cx > x1 and cx2 < x2 and cy > y1 and cy2 < y2 and not v:inState('hidden') then
			table.insert( self.foundCards, v )
			v:selectState('selected')
		end
	end
	for i,v in ipairs(self.foundCards) do
		v:bringToTop()
	end
end
function canvas:drawMessage()
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.setFont( self.font1 )
	for i,v in ipairs(self.messages) do
		love.graphics.setColor(0,0,0,v.a)
		love.graphics.print( v.msg, sw/2, 20+((i-1)*20))
	end
end
function canvas:addMessage( message )
	local t = {msg=message,a=255}
	t.anim = goo.animation:new{
		table	=	t,
		key		=	'a',
		start	=	255,
		finish	=	0,
		time	=	3,
		delay	=	3
	}
	t.anim.onFinish = function ()
		for i,v in ipairs(self.messages) do
			if v == t then table.remove( self.messages, i ) end
		end
	end
	t.anim:play()
	table.insert( self.messages, t )
end

-------------------------------------------------------------
------ LASSO.
-------------------------------------------------------------
function canvas.lasso:enterState()
	self._t = 0.5
	local _x, _y = love.mouse.getX(), love.mouse.getY()
	self._lasso = {_x,_y}
end
function canvas.lasso:update(dt)
	self.class.update(self,dt)
	self._t = self._t + dt
	if self._t > 0.1 then
		self._t = 0
		local _x, _y = love.mouse.getX(), love.mouse.getY()
		self._lasso[#self._lasso+1] = _x
		self._lasso[#self._lasso+1] = _y
	end
end
function canvas.lasso:draw()
	self.class.draw(self)
	local _x, _y = love.mouse.getX(), love.mouse.getY()
	if #self._lasso > 6 then
		love.graphics.polygon( 'line', unpack(self._lasso) )
	end
end
function canvas.lasso:mousereleased( x,y,button )
	if button == 'l' then
		self.foundCards = {}
		for i,v in ipairs(CanvasObject.list) do
			if point_in_polygon( v.x, v.y, self._lasso ) then
				table.insert( self.foundCards, v )
				v:selectState('selected')
				v:bringToTop()
			end
		end
		self:stackCards( self.foundCards )
		self:gotoState( nil )
	end
end

-------------------------------------------------------------
------ MENU.
-------------------------------------------------------------
function canvas.menu:enterState()
	goo.objects = {}
	self.buttons = {}
	local b = self.buttons
	local p = goo.null:new()
	p:setPos( love.mouse.getX(), love.mouse.getY() )
	
	b[1] = Game.button:new( p, 0, 0, 'Pile.' )
	b[1].mousepressed = function()
		self:stackCards( self.foundCards )
	end
	
	b[2] = Game.button:new( p, 0, 20, 'Grid.' )
	b[2].mousepressed = function()
		local _x,_y = 0,0
		for i,v in ipairs(self.foundCards) do
			_x = _x + v.x
			_y = _y + v.y
		end
		_x = _x / #self.foundCards
		_y = _y / #self.foundCards
		
		for i,v in ipairs(self.foundCards) do
			local a = (i-1) % 5
			local b = math.floor((i-1)/5)
			local c = #self.foundCards/5
			v.x = _x + (a*90) - 145
			v.y = _y + (b*140) - (c*46)
		end
	end
	
	b[3] = Game.button:new( p, 0, 40, 'Shuffle.' )
	b[3].mousepressed = function()
		for i=1,#self.foundCards do
			local _r = math.floor(math.random(i,#self.foundCards))
			self.foundCards[i],self.foundCards[_r] = self.foundCards[_r],self.foundCards[i]
			self.foundCards[i]:bringToTop()
		end
		self:stackCards( self.foundCards )
	end
	
	b[4] = Game.button:new( p, 0, 60, 'Sort.' )
	b[4].mousepressed = function()
		table.sort( self.foundCards, function(a,b) return a.card_id < b.card_id end)
		for i,v in ipairs(self.foundCards) do
			v:bringToTop()
		end
		self:stackCards( self.foundCards )
	end
	
	b[5] = Game.button:new( p, 0, 80, 'Flip.' )
	b[5].mousepressed = function()
		self.flipped = not self.foundCards[#self.foundCards].flipped
		for i=#self.foundCards,1,-1 do
			self.foundCards[i]:bringToTop()
			self.foundCards[i].flipped = self.flipped
			game:flipCard(self.foundCards[i])
		end
		self.foundCards = table.reverse( self.foundCards )
	end
	
	b[6] = Game.button:new( p, 0, 100, 'Remove.' )
	b[6].mousepressed = function()
		for i,v in ipairs(self.foundCards) do
			game:destroyCard(v)
			v:destroy()
			self.foundCards = {}
		end
	end
end
function canvas.menu:exitState()
	self.buttons = nil
	collectgarbage()
end
function canvas.menu:draw()
	self.class.draw(self)
	love.graphics.setFont( self.font1 )
	goo.draw()
end
function canvas.menu:mousepressed(x,y,button)
	goo.mousepressed(x,y,button)
end
function canvas.menu:mousereleased(x,y,button)
	goo.mousereleased(x,y,button)
	--self.class.mousereleased(x,y,button)
	self:gotoState(nil)
	for i,v in ipairs(CanvasObject.list) do
		v:selectState(nil)
	end
end

-------------------------------------------------------------
------ CONTEXT MENU.
-------------------------------------------------------------
function canvas.context:enterState()
	goo.objects = {}
	self.buttons = {}
	local b = self.buttons
	local p = goo.null:new()
	p:setPos( love.mouse.getX(), love.mouse.getY() )
	
	b[1] = Game.button:new( p, 0, 0, 'New deck.' )
	b[1].mousepressed = function()
		local tbl = {}
		local _c
		for i=1,52 do
			tbl[i] = i
		end
		for i=1,52 do
			local _r = math.floor(math.random(i,52))
			tbl[i],tbl[_r] = tbl[_r],tbl[i]
		end
		for i=1,52 do
			_c = card.create( true, nil, tbl[i], 10, 10+(i*4) )
			_c.flipped = true
			game:flipCard( _c )
		end
	end
	
	b[2] = Game.button:new( p, 0, 20, 'New chips.' )
	b[2].mousepressed = function()
		local _x = 100
		for i=1,5 do
			Chip.create( true, nil, 0, 50+_x, 10+(i-1)*20, 'black' )
		end
		for i=1,5 do
			Chip.create( true, nil, 0, 130+_x, 10+(i-1)*20, 'blue' )
		end
		for i=1,5 do
			Chip.create( true, nil, 0, 210+_x, 10+(i-1)*20, 'green' )
		end
		for i=1,5 do
			Chip.create( true, nil, 0, 290+_x, 10+(i-1)*20, 'pink' )
		end
	end
end
function canvas.context:exitState()
	self.buttons = nil
	collectgarbage()
end
function canvas.context:draw()
	self.class.draw(self)
	love.graphics.setFont( self.font1 )
	goo.draw()
end
function canvas.context:mousepressed(x,y,button)
	goo.mousepressed(x,y,button)
end