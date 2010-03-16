---------------
-- CARD FUNCS
---------------
card = class('card',StatefulObject)
card.drag = card:addState('drag')
card.selected = card:addState('selected')
card.selected.drag = card:addState('selected drag', card.selected)
card.hidden = card:addState('hidden')
card.newid = newCounter()

function card.create( send, id, ... )
	local _card = card:new(...)
	
	if id and id > 0 then
		_card.id = id
		card.newid = newCounter(id+1)
	else
		_card.id = card.newid()
	end
	
	if send then
		local data = lube.bin:pack{ mid = 1, id = _card.id, ... }
		game.netObj:send( data )
	end
	
	return _card
end
function card:initialize( id, x, y, z, scale, rotation )
	super.initialize(self)
	game.cardlist[#game.cardlist+1] = self
	if self.class.name == 'chip' then return end
	
	self.card_id = id
	self.x = x or 0
	self.y = y or 0
	self.scale = scale or 0.5
	self.rotation = rotation or 0
	self.z = z or 0
	self.flipped = false
	self.inHand = false
	self.alpha = 255
	self:updateSize()
end
function card:destroy()
	-- Remove card from card list.
	for i,v in ipairs(game.cardlist) do
		if v == self then table.remove( game.cardlist, i ) end
	end
	self = nil
	collectgarbage()
end
function card:update(dt)
	if self.x < 0 then self.x = 0 end
	if self.x > love.graphics.getWidth()-80 then self.x = love.graphics.getWidth()-80 end
	if self.y < 0 then self.y = 0 end
	if self.y > love.graphics.getHeight()-130 then self.y = love.graphics.getHeight()-130 end
end
function card:updateSize()
	local img = cards[self.card_id].img
	self.width = img:getWidth() * self.scale
	self.height = img:getHeight() * self.scale
end
function card:draw()
	love.graphics.setColor(0,0,0,self.alpha)
	love.graphics.rectangle( 'fill', self.x-3, self.y-3, self.width+6, self.height+6)
	love.graphics.setColor(255,255,255,self.alpha)
	if self.flipped then
		love.graphics.draw( cards.BACK, self.x, self.y, self.rotation, self.scale )
	else
		love.graphics.draw( cards[self.card_id].img, self.x, self.y, self.rotation, self.scale )
	end
end
function card:mousepressed(x,y,button)
	if button == 'l' then
		self:selectState( 'drag' )
	elseif button == 'r' then
		self.flipped = not self.flipped
		game:flipCard( self )
	elseif button == 'm' then
		-- Middle button
	end
end
function card:mousereleased(x,y,button)
	self:selectState(nil)
end
function card:mouseOver(x,y)
	if x >= self.x and x <= self.x+self.width and y >= self.y and y <= self.y+self.height then
		return true
	else
		return false
	end
end
function card:bringToTop( no_network )
	for i,v in ipairs(game.cardlist) do
		if v == self then
			table.remove(game.cardlist,i)
		end
	end
	table.insert(game.cardlist,self)
	if not no_network then game:updateCard(self) end
end
function card:checkInHand()
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
function card:selectState(state)
	self:gotoState(state)
end

-------------------------------------------------------------
------ DRAG.
-------------------------------------------------------------
function card.drag:enterState()
	self.mouseXOffset = love.mouse.getX() - self.x
	self.mouseYOffset = love.mouse.getY() - self.y
	self:bringToTop()
	self.timer = 0
end
function card.drag:update(dt)
	self.x, self.y = love.mouse.getX() - self.mouseXOffset, love.mouse.getY() - self.mouseYOffset
	
	self.timer = self.timer + dt
	if self.timer > 0.5 and not self.inHand then
		self.timer = 0
		game:updateCard(self)
	end
	
	-- Is it in the players hand?
	self:checkInHand()
end
function card.drag:mousereleased(x,y,button)
	if not self.inHand then
		game:updateCard(self)
	end
	self:selectState(nil)
end

-------------------------------------------------------------
------ SELECTED.
-------------------------------------------------------------
function card.selected:enterState()
end
function card.selected:draw()
	love.graphics.setColor(200,0,0,255)
	love.graphics.rectangle( 'fill', self.x-3, self.y-3, self.width+6, self.height+6)
	love.graphics.setColor(255,255,255,255)
	if self.flipped then
		love.graphics.draw( cards.BACK, self.x, self.y, self.rotation, self.scale )
	else
		love.graphics.draw( cards[self.card_id].img, self.x, self.y, self.rotation, self.scale )
	end
end
function card.selected:mousepressed(x,y,button)
	if button == 'l' then
		self:gotoState('selected drag')
	end
end
function card.selected:mousereleased(x,y,button)
	for i,v in ipairs(game.canvas.foundCards) do
		game:updateCard(v)
	end
	game.canvas.foundCards = {}
end

-------------------------------------------------------------
------ SELECTED & DRAG.
-------------------------------------------------------------
function card.selected.drag:enterState()
	for i,v in ipairs(game.canvas.foundCards) do
		v.mouseXOffset = love.mouse.getX() - v.x
		v.mouseYOffset = love.mouse.getY() - v.y
	end
	self.timer = 0
end
function card.selected.drag:update(dt)
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
------ HIDDEN.
-------------------------------------------------------------
function card.hidden:enterState()
	local alpha_anim = goo.animation:new{
		table	=	self,
		key		=	'alpha',
		start	=	255,
		finish	=	0,
		time	=	0.3
	}
	alpha_anim:play()
end
function card.hidden:exitState()
	local alpha_anim = goo.animation:new{
		table	=	self,
		key		=	'alpha',
		start	=	0,
		finish	=	255,
		time	=	0.3
	}
	alpha_anim:play()
end
function card.hidden:update()
end
function card.hidden:draw()
	if self.alpha > 0 then
		self.class.draw(self)
	end
end
function card.hidden:mousepressed()
end
function card.hidden:mousereleased()
end
function card.hidden:keypressed()
end
function card.hidden:keyreleased()
end
function card.hidden:selectState(state)
end