-- Filename: SERVER
-- Author: Luke Perkin
-- Date: 2010-03-15
require 'shared'

Server = class('server')
function Server:initialize( port, socketType, handshake )
	super.initialize(self)
	
	-- Create the server object.
	self.port, self.socketType = port, socketType
	self.obj = lube.server( port, socketType )
	self.obj.parent = self
	self.obj:setCallback( self.dataReceived, self.clientConnected, self.clientDisconnected )
	self.obj:setHandshake( handshake )
	
	self.clientList = {}
end

function Server:update(dt)
	self.obj:update(dt)
end

function Server:dataReceived( data, client )
	-- Peform shared networking functions.
	if Shared:dataReceived( data, client ) then
		-- Forward data to other clients.
		if data then self:forwardData( data, client ) end
	end
end

function Server:clientConnected( client )
	game.canvas:addMessage('Client connected.')
	-- Add client to the list.
	table.insert( self.clientList, client )
	-- Send the new client all the current objects (cards etc).
	self:sendSnapshot( client )
	-- Tell other clients about the new client.
	local data = lube.bin:pack{ mid=6, client }
	self:forwardData( data, client )
end

function Server:clientDisconnected( client )
	game.canvas:addMessage('Client disconnected.')
	-- Remove disconntected client from the list.
	for i,v in ipairs(self.clientList) do
		if client == v then
			table.remove( self.clientList, i )
		end
	end
	-- Tell other clients about the disconnected client.
	local data = lube.bin:pack{ mid=7, client }
	self:forwardData( data, client )
end

function Server:send( data, client )
	self.obj:send( data, client )
end

function Server:forwardData( data, client )
	-- Send data to all clients but the one it came from.
	for i,v in ipairs(self.clientList) do
		if v ~= client then
			self:send( data, v )
		end
	end
end

function Server:sendSnapshot( client )
	for i,v in ipairs(CanvasObject.list) do
		local data = lube.bin:pack{ mid = 1, id = v.id, v.card_id, v.x, v.y }
		self:send( data, client )
		data = lube.bin:pack{ mid = 3, id = v.id, v.flipped }
		self:send( data, client )
	end
end