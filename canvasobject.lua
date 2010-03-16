-- Filename: CanvasObject
-- Author: Luke Perkin
-- Date: 2010-03-16

CanvasObject = class('canvasobject', StatefulObject)
CanvasObject.list = {}
CanvasObject.drag = CanvasObject:addState('drag')
CanvasObject.selected = CanvasObject:addState('selected')
CanvasObject.selected.drag = CanvasObject:addState('selected drag',CanvasObject.selected)
CanvasObject.hidden = CanvasObject:addState('hidden')
CanvasObject.newid = newCounter()
function CanvasObject:initialize( x,y,scale,rotation,image )
	super.initialize(self)
	self.x = x or 0
	self.y = y or 0
	self.image = image or nil
	self.color = color or {255,255,255,255}
	self.scale = scale or 1
	self.rotation = rotation or 0
	self.inHand = false
	self:updateSize()
	table.insert( CanvasObject.list, self )
end
function CanvasObject:destroy()
	-- Remove card from card list.
	for i,v in ipairs(CanvasObject.list) do
		if v == self then table.remove( CanvasObject.list, i ) end
	end
	self = nil
	collectgarbage()
end
function CanvasObject:update(dt)
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	if self.x < 0 then self.x = 0 end
	if self.x > sw-80 then self.x = sw-80 end
	if self.y < 0 then self.y = 0 end
	if self.y > sh-130 then self.y = sh-130 end
end
function CanvasObject:draw()
	if self.image then
		love.graphics.setColor( unpack( self.color ) )
		love.graphics.draw( self.image, self.x, self.y, self.rotation, self.scale )
	end
end
function CanvasObject:mousepressed(x,y,button)
	if button == 'l' then
		-- If left clicked drag the object with mouse.
		self:selectState( 'drag' )
	end
end
function CanvasObject:mousereleased(x,y,button)
	-- Return to normal state after dragging.
	self:selectState( nil )
end
function CanvasObject:mouseOver( x, y )
	if x >= self.x and x <= self.x+self.width and y >= self.y and y <= self.y+self.height then
		return true
	else
		return false
	end
end
function CanvasObject:bringToTop( no_network )
	for i,v in ipairs( CanvasObject.list )  do
		if v == self then
			table.remove( CanvasObject.list, i )
		end
	end
	table.insert( CanvasObject.list, self )
	if not no_network then game:updateCard( self ) end
end
function CanvasObject:updateSize()
	if self.image and self.image.getWidth then
		self.width = self.image:getWidth() * self.scale
		self.height = self.image:getHeight() * self.scale
	else
		self.width = 50
		self.height = 50
	end
end
function CanvasObject:checkInHand()
	-- Is it in the players hand?
	if self.y > love.graphics.getHeight()-170 then
		if not self.inHand then
			self.inHand = true
			-- Tell other clients to hide the card.
			game:hideCard( self, true )
		end
	elseif self.inHand then
		self.inHand = false
		-- Sync all changed card variables now that it's out of your hand.
		game:hideCard( self, false )
		game:flipCard( self )
	end
end
function CanvasObject:selectState( state )
	self:gotoState( state )
end

-------------------------------------------------------------
------ Drag.
-------------------------------------------------------------
function CanvasObject.drag:enterState()
	self.mouseXOffset = love.mouse.getX() - self.x
	self.mouseYOffset = love.mouse.getY() - self.y
	self:bringToTop()
	self.timer = 0
	if self.mouseXOffset then print(self.mouseXOffset) end
end
function CanvasObject.drag:update(dt)
	self.x, self.y = love.mouse.getX() - self.mouseXOffset, love.mouse.getY() - self.mouseYOffset
	
	self.timer = self.timer + dt
	if self.timer > 0.5 and not self.inHand then
		self.timer = 0
		game:updateCard( self )
	end
	
	-- Is it in the players hand?
	self:checkInHand()
end
function CanvasObject.drag:mousereleased(x,y,button)
	if not self.inHand then
		game:updateCard(self)
	end
	self:selectState(nil)
end

-------------------------------------------------------------
------ Object selected.
-------------------------------------------------------------
function CanvasObject.selected:enterState()
end
function CanvasObject.selected:mousepressed(x,y,button)
	if button == 'l' then
		self:selectState('selected drag')
	end
end
function CanvasObject.selected:mousereleased(x,y,button)
	for i,v in ipairs(game.canvas.foundCards) do
		game:updateCard( v )
	end
	game.canvas.foundCards = {}
end

-------------------------------------------------------------
------ Object selected & dragging.
-------------------------------------------------------------
function CanvasObject.selected.drag:enterState()
	for i,v in ipairs(game.canvas.foundCards) do
		v.mouseXOffset = love.mouse.getX() - v.x
		v.mouseYOffset = love.mouse.getY() - v.y
	end
	self.timer = 0
end
function CanvasObject.selected.drag:update(dt)
	self.timer = self.timer + dt
	for i,v in ipairs(game.canvas.foundCards) do
		v.x, v.y = love.mouse.getX() - v.mouseXOffset, love.mouse.getY() - v.mouseYOffset
		-- Is it in the players hand?
		v:checkInHand()
		if self.timer > 1 and not v.inHand then
			game:updateCard(v)
		end
	end
	if self.timer > 1 then self.timer = 0 end
end

-------------------------------------------------------------
------ Object Hidden.
-------------------------------------------------------------
function CanvasObject.hidden:enterState()
	local alpha_anim = goo.animation:new{
		table	=	self,
		key		=	'alpha',
		start	=	255,
		finish	=	0,
		time	=	0.3
	}
	alpha_anim:play()
end
function CanvasObject.hidden:exitState()
	local alpha_anim = goo.animation:new{
		table	=	self,
		key		=	'alpha',
		start	=	0,
		finish	=	255,
		time	=	0.3
	}
	alpha_anim:play()
end
function CanvasObject.hidden:update()
end
function CanvasObject.hidden:draw()
	if self.alpha > 0 then
		self.class.draw(self)
	end
end
function CanvasObject.hidden:mousepressed()
end
function CanvasObject.hidden:mousereleased()
end
function CanvasObject.hidden:keypressed()
end
function CanvasObject.hidden:keyreleased()
end
function CanvasObject.hidden:selectState()
end