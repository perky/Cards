-- Filename: loadcards.lua
-- Author: Luke Perkin
-- Date: 2009-07-03

cards = {}
cards.img = {}
cards.BLACK = 1
cards.RED   = 2
cards.SPADES   = 1
cards.CLUBS    = 2
cards.HEARTS   = 3
cards.DIAMONDS = 4

cards.BACK = love.graphics.newImage( "cards/back.png" )

for i = 1, 13 do
	local card = {}
	table.insert(cards,card)
	card.img = love.graphics.newImage( "cards/s"..i..".png" )
	card.suit = cards.SPADES
	card.color = cards.BLACK
	card.rank  = i
end
for i = 1, 13 do
	local card = {}
	table.insert(cards,card)
	card.img = love.graphics.newImage( "cards/c"..i..".png" )
	card.suit = cards.CLUBS
	card.color = cards.BLACK
	card.rank  = i
end
for i = 1, 13 do
	local card = {}
	table.insert(cards,card)
	card.img = love.graphics.newImage( "cards/h"..i..".png" )
	card.suit = cards.HEARTS
	card.color = cards.RED
	card.rank  = i
end
for i = 1, 13 do
	local card = {}
	table.insert(cards,card)
	card.img = love.graphics.newImage( "cards/d"..i..".png" )
	card.suit = cards.DIAMONS
	card.color = cards.RED
	card.rank  = i
end
