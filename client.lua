-- Filename: Client
-- Author: Luke Perkin
-- Date: 2010-03-15
require 'shared'

Client = class('client')
function Client:initialize( host, port, socketType, dns, handshake )
	super.initialize(self)
	-- Create client object.
	self.obj = lube.client( socketType )
	self.obj.parent = self
	self.obj:setHandshake( handshake )
	self.obj:setCallback( self.dataReceived )
	self.obj:connect( host, port, dns )
end

function Client:update(dt)
	self.obj:update(dt)
end

function Client:dataReceived( data )
	Shared:dataReceived( data )
end

function Client:send( data )
	self.obj:send( data )
end