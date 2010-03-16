-- Filename: SHARED NETWORKING
-- Author: Luke Perkin
-- Date: 2010-03-16

Shared = {}
function Shared:dataReceived( data, client )
	print('data:',data,client)
	data = lube.bin:unpack(data)
	-- Perform functions based on Message ID (mid).
		if data.mid == 1 then self:createCard(data)
	elseif data.mid == 2 then self:updateCard(data)
	elseif data.mid == 3 then self:flipCard(data)
	elseif data.mid == 4 then self:hideCard(data)
	elseif data.mid == 5 then self:destroyCard(data)
	elseif data.mid == 6 then self:clientConnected(data)
	elseif data.mid == 7 then self:clientDisconnected(data)
	end
end

function Shared:createCard( data )
	local _card = card.create( false, data.id, data[1], data[2], data[3] )
end

function Shared:updateCard( data )
	for i,v in ipairs(game.cardlist) do
		if v.id == data.id then
			v:bringToTop(true)
			local animx = goo.animation:new{
				table	=	v,
				key		=	'x',
				finish	=	data[1],
				time	=	0.4,
				style	=	goo.animation.style.quadInOut
			}
			local animy = goo.animation:new{
				table	=	v,
				key		=	'y',
				finish	=	data[2],
				time	=	0.4,
				style	=	goo.animation.style.quadInOut
			}
			animx:play()
			animy:play()
			return
		end
	end
end

function Shared:flipCard( data )
	for i,v in ipairs(game.cardlist) do
		if v.id == data.id then
			v.flipped = data[1]
		end
	end
end

function Shared:hideCard( data )
	for i,v in ipairs(game.cardlist) do
		if v.id == data.id then
			if data[1] == true then
				v:gotoState('hidden')
			else
				v:gotoState(nil)
			end
		end
	end
end

function Shared:destroyCard( data )
	for i,v in ipairs(game.cardlist) do
		if v.id == data.id then
			v:destroy()
		end
	end
end

function Shared:clientConnected( data )
	game.canvas:addMessage('Client connected.')
end

function Shared:clientDisconnected( data )
	game.canvas:addMessage('Client disconnected.')
end