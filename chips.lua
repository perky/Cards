-- Filename: CHIPS
-- Author: Luke Perkin
-- Date: 2010-03-16

Chip = class('chip',card)
Chip.image = {}
Chip.image.pink = love.graphics.newImage('Chips/chippink.png')
function Chip.create( send, id, ... )
	local _chip = Chip:new(...)
	
	if id and id > 0 then
		_chip.id = id
		card.newid = newCounter(id+1)
	else
		_chip.id = card.newid()
	end
	
	if send then
		local data = lube.bin:pack{ mid = 8, id = _chip.id, ... }
		game.netObj:send( data )
	end
	
	return _chip
end
function Chip:initialize(id,x,y)
	super.initialize(self)
	self.img = Chip.image.pink
	self.card_id = 1
	self.x = x or 0
	self.y = y or 0
	self.scale = scale or 1
	self.rotation = rotation or 0
	self.z = z or 0
	self.inHand = false
	self.alpha = 255
	self:updateSize()
end
function Chip:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw( self.img, self.x, self.y, 0, self.scale)
end
function Chip:updateSize()
	local img = self.img
	self.width = img:getWidth() * self.scale
	self.height = img:getHeight() * self.scale
end

function Chip.selected:draw()
	if not self.img then return end
	love.graphics.setColor(0,0,0,150)
	love.graphics.draw( self.img, self.x-2, self.y+2, 0, self.scale)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw( self.img, self.x, self.y, 0, self.scale)
end