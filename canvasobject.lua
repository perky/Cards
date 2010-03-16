-- Filename: CanvasObject
-- Author: Luke Perkin
-- Date: 2010-03-16

CanvasObject = class('canvasobject', StatefulObject)
function CanvasObject:initialize()
	super.initialize(self)
	self.x = x or 0
	self.y = y or 0
	self.image = image or nil
	self.color = color or {255,255,255,255}
	self.scale = scale or 1
	self.rotation = rotation or 0
end
function CanvasObject:update(dt)
end
function CanvasObject:draw()
	if self.image then
		love.graphics.setColor( unpack( self.color ) )
		love.graphics.draw( self.image, self.x, self.y, self.rotation, self.scale )
	end
end