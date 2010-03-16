-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
goo = {}
require 'MiddleClass'
require 'MindState'
require 'goo.animation.animation'

goo.skin = 'goo/skins/default/'
goo.style = require( goo.skin .. 'style')

goo.object = class('goo object')
goo.objects = {}
function goo.object:initialize(parent)
	table.insert(goo.objects, self)
	if parent then
		table.insert(parent.children,self)
		self.parent = parent
	end
	if goo.style[self.class.name] then
		self.style = goo.style[self.class.name]
	end
	self.x = 0
	self.y = 0
	self.h = 0
	self.w = 0
	self.lastX = 0
	self.lastY = 0
	self.bounds = {x1=0,y1=0,x2=0,y2=0}
	self.color  = {255,255,255,255}
	self.children = {}
	self.visible = true
	self.hoverState = true
end
function goo.object:update(dt)
	if self:isMouseHover() then
		if not self.hoverState then self:enterHover() end
		self.hoverState = true
	else
		if self.hoverState then self:exitHover() end
		self.hoverState = false
	end
	
	if love.mouse.isDown('l') then
		
	else
		if self.dragState then
			self.dragState = false
			self:recurse('children', self.updateBounds)
		end
	end
	
	if not self.dragState and (self.lastX ~= self.x or self.lastY ~= self.y) then
		self:recurse('children', self.updateBounds)
	end
	self.lastX = self.x
	self.lastY = self.y
end
function goo.object:draw()
end
function goo.object:mousepressed()
end
function goo.object:mousereleased(x,y,button)
	if self.hoverState and button == 'l' then
		if self.onClick then
			self:onClick()
		end
	end
end
function goo.object:keypressed()
end
function goo.object:keyreleased()
end
function goo.object:setPos( x, y )
	self.x = x or 0
	self.y = y or 0
	self:updateBounds()
end
function goo.object:setSize( w, h )
	self.w = w or 0
	self.h = h or 0
	self:updateBounds()
end
function goo.object:setVisible( bool )
	self.visible = bool
end
function goo.object:setColor(r,g,b,a)
	self.color = {r or self.color[1], g or self.color[2], b or self.color[3], a or self.color[4]}
end
function goo.object:getRelativePos( x, y )
	local _x, _y
	local x, y = self.x or x, self.y or y
	if self.parent then
		_x, _y = self.parent.x, self.parent.y
	else
		_x, _y = 0, 0
	end
	return _x+x, _y+y
end
function goo.object:isMouseHover()
	if not self.bounds then return false end
	local x, y = love.mouse.getPosition()
	local x1, y1, x2, y2 = self.bounds.x1, self.bounds.y1, self.bounds.x2, self.bounds.y2
	if x > x1 and x < x2 and y > y1 and y < y2 then
		return true
	else
		return false
	end
end
function goo.object:enterHover()
end
function goo.object:exitHover()
end
function goo.object:updateBounds()
	local x, y = self:getRelativePos()
	local xoff, yoff = self.xoffset or 0, self.yoffset or 0
	self.bounds.x1 = x + xoff
	self.bounds.y1 = y + yoff
	self.bounds.x2 = x + self.w + xoff
	self.bounds.y2 = y + self.h + yoff
end
function goo.object:recurse(key,func,...)
	local _tbl = arg or {}
	func(self, unpack(_tbl))
	for k,v in pairs(self[key]) do
		v:recurse(key,func,...)
	end
end
function goo.object:setText( text )
	self.text = text
	self:updateBounds()
end
function goo.object:sizeToContents()
	local _font = love.graphics.getFont()
	self.w = _font:getWidth(self.text) + (self.spacing or 0)
	self.h = _font:getHeight() + (self.spacing or 0)
	self.yoffset = -self.h
	self:updateBounds()
end
function goo.object:setStyle(style)
	for k,v in pairs(style) do
		self.style[k] = v
	end
end
function goo.object:destroy()
	for k,v in pairs( goo.objects ) do
		if v == self then
			table.remove(goo.objects, k)
			self = nil
			return
		end
	end
end

-- NULL OBJECT
goo.null = class('goo null', goo.object)
function goo.null:initialize( parent )
	super.initialize(self)
end

-- PANEL
goo.panel = class('goo panel', goo.object)
goo.panel.image = {}
goo.panel.image.corner = love.graphics.newImage(goo.skin..'box_corner.png')
goo.panel.image.edge = love.graphics.newImage(goo.skin..'box_edge.png')
function goo.panel:initialize()
	super.initialize(self)
	self.title = "title"
	self.close = goo.close:new(self)
	self.dragState = false
end
function goo.panel:update(dt)
	super.update(self,dt)
	if self.dragState then
		self.x = love.mouse.getX() - self.dragOffsetX
		self.y = love.mouse.getY() - self.dragOffsetY
		self:updateBounds()
	end
end
function goo.panel:draw()
	local x,y = self:getRelativePos()
	love.graphics.setColor(80,80,80,255)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print( self.title, self.x + 10, self.y + 15 )
	
	
	local cornerH = self.image.corner:getHeight()
	local cornerW = self.image.corner:getWidth()
	local edgeH	  = self.image.edge:getHeight()
	local edgeW	  = self.image.edge:getWidth()
	
	love.graphics.draw( self.image.corner, x-cornerH, y-cornerH )
	love.graphics.draw( self.image.corner, x+self.w+cornerH, y-cornerH, math.pi/2 )
	love.graphics.draw( self.image.corner, x+self.w+cornerH, y+self.h+cornerH, math.pi )
	love.graphics.draw( self.image.corner, x-cornerH, y+self.h+cornerH, 3*math.pi/2 )
	
	love.graphics.draw( self.image.edge, x, y-edgeH, 0, self.w, 1)
	love.graphics.draw( self.image.edge, x+self.w+edgeH, y, math.pi/2, self.h, 1)
	love.graphics.draw( self.image.edge, x+self.w, y+self.h+edgeH, math.pi, self.w, 1)
	love.graphics.draw( self.image.edge, x-edgeH, y+self.h, 3*math.pi/2, self.h, 1)
	
	love.graphics.rectangle('fill', x, y, self.w, self.h)
	love.graphics.setColor(220, 220, 220, 255)
	love.graphics.setLine(1, 'smooth')
	love.graphics.line( x, y+8, x + self.w, y+8)
	love.graphics.print( self.title, x, y + 5)
end
function goo.panel:mousepressed(x,y,button)
	if x > self.bounds.x1 and x < self.bounds.x2 and y > self.bounds.y1 and y < self.bounds.y2 then
		if not self.dragState then
			self.dragOffsetX = x - self.x
			self.dragOffsetY = y - self.y
		end
		self.dragState = true
	end
end
function goo.panel:mousereleased(x,y,button)
end
function goo.panel:setTitle( title )
	self.title = title
end
function goo.panel:setPos( x, y )
	super.setPos(self, x, y)
	self:setClosePos()
	self:updateBounds()
end
function goo.panel:setSize( w, h )
	super.setSize(self, w, h)
	self:setClosePos()
	self:updateBounds()
end
function goo.panel:setClosePos()
	local a = self.image.edge:getHeight()/2
	self.close:setPos( self.w - 4, -a + 2 )
end
function goo.panel:updateBounds()
	local edgeH	  = goo.panel.image.edge:getHeight()/2
	local x, y = self:getRelativePos()
	self.bounds.x1 = x - edgeH
	self.bounds.y1 = y - edgeH
	self.bounds.x2 = x + self.w + edgeH
	self.bounds.y2 = y + self.h + edgeH
end
function goo.panel:destroy()
	for k,v in pairs(self.children) do
		v:destroy()
	end
	super.destroy(self)
end

-- STATIC TEXT
goo.text = class('goo static text', goo.object)
function goo.text:initialize( parent )
	super.initialize(self,parent)
	self.text = "no text"
end
function goo.text:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.print( self.text, x, y )
end
function goo.text:setText( text )
	self.text = text or ""
end

-- CLOSE BUTTON
goo.close = class('goo close button', goo.object)
goo.close.image = {}
goo.close.image.button = love.graphics.newImage(goo.skin..'closebutton.png')
function goo.close:initialize( parent )
	super.initialize(self,parent)
	self.w = self.image.button:getWidth()
	self.h = self.image.button:getHeight()
end
function goo.close:enterHover()
	self.color = {255,200,200,255}
end
function goo.close:exitHover()
	self.color = {255,255,255,255}
end
function goo.close:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.draw(self.image.button,x,y)
end
function goo.close:mousepressed(x,y,button)
	if button == 'l' then self.parent:destroy() end
end

-- BASE BUTTON
goo.baseButton = class('goo base button', goo.object)
function goo.baseButton:initialize( parent )
	super.initialize(self,parent)
end
function goo.baseButton:mousepressed(x,y,button)
	if self.onClick then self:onClick(button) end
end


-- BUTTON
goo.button = class('goo button', goo.object)
function goo.button:initialize( parent )
	super.initialize(self,parent)
	self.text = "button"
	self.borderStyle = 'line'
	self.backgroundColor = {0,0,0,255}
	self.borderColor = {255,255,255,255}
	self.textColor = {255,255,255,255}
	self.spacing = 5
end
function goo.button:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.backgroundColor) )
	love.graphics.rectangle( 'fill', x-2, y, self.w, self.h)
	love.graphics.setColor( unpack(self.borderColor) )
	love.graphics.rectangle( 'line', x-2, y, self.w, self.h)
	love.graphics.setColor( unpack(self.textColor) )
	love.graphics.print( self.text, x, y+self.h-self.spacing)
end
function goo.button:enterHover()
	self.backgroundColor = {0,200,50,255}
end
function goo.button:exitHover()
	self.backgroundColor = {0,0,0,255}
end
function goo.button:mousepressed(x,y,button)
	if self.onClick then self:onClick(button) end
end
goo.button:getterSetter('backgroundColor')
goo.button:getterSetter('borderColor')
goo.button:getterSetter('textColor')

-- BIG BUTTON
goo.bigbutton = class('goo big button', goo.object)
goo.bigbutton.image = {}
goo.bigbutton.image.right = love.graphics.newImage(goo.skin..'bigbutton_left.png')
goo.bigbutton.image.middle = love.graphics.newImage(goo.skin..'bigbutton_middle.png')
goo.bigbutton.image.left = love.graphics.newImage(goo.skin..'bigbutton_right.png')
function goo.bigbutton:initialize(parent)
	super.initialize(self,parent)
	self.checkState = 'unchecked'
	self:exitHover()
end
function goo.bigbutton:enterHover()
	self.buttonColor = self.style.buttonColorHover
	self.textColor = self.style.textColorHover
end
function goo.bigbutton:exitHover()
	self.buttonColor = self.style.buttonColor
	self.textColor = self.style.textColor
end
function goo.bigbutton:draw()
	local x,y = self:getRelativePos()
	local w = self.image.left:getWidth() - 5
	
	love.graphics.setColor( unpack(self.buttonColor) )
	love.graphics.draw( self.image.right, x, y )
	love.graphics.draw( self.image.middle, x+w, y, 0, self.w, 1)
	love.graphics.draw( self.image.left, x+self.w+w, y )
	
	love.graphics.setColor( unpack(self.textColor) )
	love.graphics.setFont( unpack(self.style.font) )
	love.graphics.printf( self.text, x+(self.w/2)-250+17, y+30, 500, "center" )
end
function goo.bigbutton:updateBounds()
	local imgH	  = goo.bigbutton.image.left:getHeight()
	local imgW	  = goo.bigbutton.image.left:getWidth()
	local x, y = self:getRelativePos()
	self.bounds.x1 = x
	self.bounds.y1 = y
	self.bounds.x2 = x + self.w + (imgW*2)
	self.bounds.y2 = y + imgH
end

-- CHECKBOX
goo.checkbox = class('goo checkbox', goo.object)
goo.checkbox.image = {}
goo.checkbox.image.unchecked = love.graphics.newImage( goo.skin..'checkbox_unchecked.png' )
goo.checkbox.image.checked = love.graphics.newImage( goo.skin..'checkbox_checked.png' )
function goo.checkbox:initialize(parent)
	super.initialize(self,parent)
	self.checkState = 'unchecked'
	self.w = 16
	self.h = 16
end
function goo.checkbox:draw()
	local x,y = self:getRelativePos()
	love.graphics.draw(self.image[self.checkState], x, y)
end
function goo.checkbox:mousepressed(x,y,button)
	if self.checkState == 'checked' then
		self.checkState = 'unchecked'
	else
		self.checkState = 'checked'
	end
end
function goo.checkbox:isChecked()
	if self.checkState == 'checked' then return true else return false end
end
function goo.checkbox:setChecked(bool)
	if bool then self.checkState = 'checked' else self.checkState = 'unchecked' end
end

function goo.load()
	goo.graphics = {}
	goo.graphics.roundrect = require 'goo.graphics.roundrect'
end

--  TEXT INPUT
goo.textinput = class('goo text input', goo.object)
function goo.textinput:initialize( parent )
	super.initialize(self,parent)
	self.text = ''
	self.textXoffset = 0
	self.blink = false
	self.blinkRate = 0.5
	self.blinkTime = love.timer.getTime() + self.blinkRate
	self.font = love.graphics.getFont()
	self.fontH = self.font:getHeight()
	self.caretPos = 1
	self.lines = {}
	self.lines[1] = ''
	self.linePos = 1
	self.leading = 35
	self.multiline = true
	love.keyboard.setKeyRepeat( 500, 50 )
end
function goo.textinput:update(dt)
	if love.timer.getTime() > self.blinkTime then
		self.blink = not self.blink
		self.blinkTime = love.timer.getTime() + self.blinkRate
	end
	self.textXoffset = self.font:getWidth( self.lines[self.linePos]:sub(1,self.caretPos) ) - self.w + 15
	if self.textXoffset < 0 then self.textXoffset = 0 end
	if self.caretPos < 1 then self.caretPos = 1 end
end
function goo.textinput:draw()
	local x,y = self:getRelativePos()
	love.graphics.setScissor( x-1, y-1, self.w, self.h+1 )
	love.graphics.setLine(1,'rough')
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle('line',x,y,self.w,self.h)
	for i,txt in ipairs(self.lines) do
		love.graphics.print( txt, x+5-self.textXoffset, (y+self.fontH)+(self.leading*(i-1)))
	end
	if self.blink then
		love.graphics.setColor(100,100,100,255)
		local w = self.font:getWidth( self.lines[self.linePos]:sub(1,self.caretPos-1) )
		w = math.min( w, self.w - 15 )
		love.graphics.rectangle('fill', x+w+5, (self.y+5)+(self.leading*(self.linePos-1)), 2, self.fontH)
	end
	love.graphics.setScissor()
end
function goo.textinput:keypressed(key,unicode)
	if key == 'backspace' then
		self:keyBackspace()
	elseif key == 'return' then
		self:keyReturn()
	elseif key == 'left' then
		self:keyLeft()
	elseif key == 'right' then
		self:keyRight()
	elseif key == 'up' then
		self:keyUp()
	elseif key == 'down' then
		self:keyDown()
	elseif unicode ~= 0 and unicode < 1000 then
		self:keyText(key,unicode)
	end
end
function goo.textinput:keyText(key,unicode)
	self:insert(string.char(unicode), self.caretPos)
	self.caretPos = self.caretPos + 1
end
function goo.textinput:keyReturn()
	if not self.multiline then return end
	if self.caretPos > self.lines[self.linePos]:len() then
		self.linePos = self.linePos + 1
		self.caretPos = 1
		self:newline( self.linePos )
	else
		self:newlineWithText( self.caretPos, self.linePos )
	end
end
function goo.textinput:keyBackspace()
	if self.caretPos == 1 and self.linePos > 1 then
		if not self.multiline then return end
		self:backspaceLine( self.linePos )
	else
		self:remove(self.caretPos,1)
		self.caretPos = self.caretPos - 1
	end
end
function goo.textinput:keyLeft()
	if self.caretPos > 1 then
		self.caretPos = self.caretPos - 1
		if self.caretPos < 1 then self.caretPos = 1 end
	else
		if self.linePos > 1 then
			if not self.multiline then return end
			self.linePos = self.linePos - 1
			self.caretPos = self.lines[self.linePos]:len()+1
		end
	end
end
function goo.textinput:keyRight()
	if self.caretPos <= self.lines[self.linePos]:len() then
		self.caretPos = self.caretPos + 1
	else
		if not self.multiline then return end
		if self.linePos < #self.lines then
			self.linePos = self.linePos+1
			self.caretPos = 1
		end
	end
end
function goo.textinput:keyUp()
	if not self.multiline then return end
	if self.linePos == 1 then return end
	self.linePos = self.linePos - 1
end
function goo.textinput:keyDown()
	if not self.multiline then return end
	if self.linePos == #self.lines then return end
	self.linePos = self.linePos + 1
end
function goo.textinput:insert(text,pos)
	local txt = self.lines[self.linePos]
	local part1 = txt:sub(1,pos-1)
	local part2 = txt:sub(pos)
	self.lines[self.linePos] = part1 .. text .. part2
end
function goo.textinput:remove(pos,length)
	if pos == 1 then return end
	local txt = self.lines[self.linePos]
	local part1 = txt:sub(1,pos-2)
	local part2 = txt:sub(pos+length-1)
	self.lines[self.linePos] = part1 .. part2
end
function goo.textinput:newline(pos)
	local pos = pos or nil
	table.insert(self.lines,pos,'')
end
function goo.textinput:removeline(pos)
	local pos = pos or #self.lines
	table.remove(self.lines,pos)
end
function goo.textinput:backspaceLine()
	local _line = self.lines[self.linePos]
	self:removeline( self.linePos )
	self.linePos = self.linePos - 1
	self.caretPos = self.lines[self.linePos]:len()+1
	self.lines[self.linePos] = self.lines[self.linePos] .. _line
end
function goo.textinput:newlineWithText(pos,pos2)
	local part1 = self.lines[self.linePos]:sub(1,pos-1)
	local part2 = self.lines[self.linePos]:sub(pos)
	self.lines[pos2] = part1
	self:newline(self.linePos+1)
	self.linePos = self.linePos + 1
	self.caretPos = 1
	self.lines[self.linePos] = part2
end

-------------------------------------------------------------
------ COLOR PICKER.
-------------------------------------------------------------
goo.colorpick = class('goo color picker', goo.object)
goo.colorpick.image = {}
goo.colorpick.image.colorboxData = love.image.newImageData( goo.skin..'colorbox.png' )
goo.colorpick.image.colorbox = love.graphics.newImage( goo.colorpick.image.colorboxData )
function goo.colorpick:initialize(parent)
	super.initialize(self,parent)
	self.w = goo.colorpick.image.colorbox:getWidth()
	self.h = goo.colorpick.image.colorbox:getHeight()
	self.selectedColor = {r=0,g=0,b=0}
	self:updateBounds()
end
function goo.colorpick:draw()
	local x,y = self:getRelativePos()
	local mx,my = love.mouse.getX(), love.mouse.getY()
	love.graphics.setColor(50,50,50)
	love.graphics.rectangle( 'fill', x-5, y-5, self.w+10, self.h+10)
	love.graphics.setColor(255,255,255)
	love.graphics.draw( self.image.colorbox, x, y )
	if mx >= x and mx <= x+self.w and my >= y and my <= y+self.h then
		local r,g,b,a = self.image.colorboxData:getPixel( mx-x, my-y )
		love.graphics.setColor(50,50,50)
		love.graphics.rectangle( 'fill', mx-22, my-22, 24, 24)
		love.graphics.setColor(r,g,b,255)
		love.graphics.rectangle( 'fill', mx-20, my-20, 20, 20)
	end
end
function goo.colorpick:mousepressed(x,y,button)
	if not self.hoverState then return end
	local sx,sy = self:getRelativePos()
	local r,g,b = self.image.colorboxData:getPixel( x-sx, y-sy )
	self.selectedColor = {r=r,g=g,b=b}
end

-- Logic
function goo.update(dt)
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:update(dt) end
	end
	
	for k,v in ipairs( goo.animation.list ) do
		v:update(dt)
	end
end

-- Scene Drawing
function goo.draw()
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:draw() end
	end
end

-- Input
function goo.keypressed( key, unicode )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:keypressed(key, unicode) end
	end
end

function goo.keyreleased( key, unicode )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:keypressed(key, unicode) end
	end
end

function goo.mousepressed( x, y, button )
	for i=#goo.objects, 1, -1 do
		local v = goo.objects[i]
		if not v then return false end
		if v.visible and v.hoverState then 
			v:mousepressed(x, y, button)
			break
		end
	end
end

function goo.mousereleased( x, y, button )
	for i=#goo.objects, 1, -1 do
		local v = goo.objects[i]
		if not v then return false end
		if v.visible and v.hoverState then 
			v:mousereleased(x, y, button)
			break
		end
	end
end
