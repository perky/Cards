---------------
-- CARD FUNCS
---------------
card = class('card', CanvasObject)
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
function card:initialize( id, x, y, scale, rotation )
	local image = cards[id].img
	super.initialize(self, x, y, 0.5, 0, image)
	
	self.card_id = id
	self.flipped = false
	self.alpha = 255
end
function card:draw()
	love.graphics.setColor(0,0,0,self.alpha)
	love.graphics.rectangle( 'fill', self.x-3, self.y-3, self.width+6, self.height+6)
	love.graphics.setColor(255,255,255,self.alpha)
	if self.flipped then
		love.graphics.draw( cards.BACK, self.x, self.y, self.rotation, self.scale )
	else
		love.graphics.draw( self.image, self.x, self.y, self.rotation, self.scale )
	end
end
function card:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	if button == 'r' then
		self.flipped = not self.flipped
		game:flipCard( self )
	end
end

-------------------------------------------------------------
------ SELECTED.
-------------------------------------------------------------
function card.states.selected:draw()
	love.graphics.setColor(200,0,0,255)
	love.graphics.rectangle( 'fill', self.x-3, self.y-3, self.width+6, self.height+6)
	love.graphics.setColor(255,255,255,255)
	if self.flipped then
		love.graphics.draw( cards.BACK, self.x, self.y, self.rotation, self.scale )
	else
		love.graphics.draw( cards[self.card_id].img, self.x, self.y, self.rotation, self.scale )
	end
end