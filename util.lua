-- Filename: UTILITY
-- Author: Luke Perkin
-- Date: 2010-03-15

function point_in_polygon(x,y,polygon)
    local inside,n,i,poly_x,poly_y,x1,x2,y1,y2,m,b,ix,iy
    inside = false
	poly_x = {}
	poly_y = {}
 
    n = #polygon / 2
 
    for i=1,n do
        poly_x[i] = polygon[(2*i)-1]
        poly_y[i] = polygon[2*i]
    end
    poly_x[n+1] = poly_x[1]
    poly_y[n+1] = poly_y[1]
 
    for i=1, n do
        x1 = poly_x[i]
        y1 = poly_y[i]
        x2 = poly_x[i+1]
        y2 = poly_y[i+1]
        if (((y1 <= y) and (y2 > y)) or ((y1 > y) and (y2 <= y))) then
            if (x1 == x2) then
                if (x1 > x) then inside = not inside end
            else
                m = (y2 - y1) / (x2 - x1)
                b = y1 - m * x1
                ix = (y - b) / m
                iy = y
                if (ix > x) then inside = not inside end
            end
        end
    end
    return inside
end

function love.graphics.drawAlign( alignx, aligny, img, x, y, ... )
	local scrW, scrH = love.graphics.getWidth(), love.graphics.getHeight()
	local w, h = img:getWidth(), img:getHeight()
	local xx, yy
	
	if alignx == 'right' then
		xx = scrW - w - x
	elseif alignx == 'center' then
		xx = (scrW / 2) - (w / 2) - x
	else
		xx = x
	end
	
	if aligny == 'bottom' then
		yy = scrH - h - y
	elseif aligny == 'center' then
		yy = (scrH / 2) - (h / 2) - y
	else
		yy = y
	end
	
	love.graphics.draw( img, xx, yy, ... )
end

function table.reverse(t)
    local count = #t
    for i=1,count do
        table.insert(t, i, t[count])
        table.remove(t, count)
    end

    return t
end

function explode ( seperator, str ) 
 	local pos, arr = 0, {}
	for st, sp in function() return string.find( str, seperator, pos, true ) end do -- for each divider found
			table.insert( arr, string.sub( str, pos, st-1 ) ) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	if string.len(string.sub( str, pos )) > 0 then
		table.insert( arr, string.sub( str, pos ) ) -- Attach chars right of last divider
	end
	return arr
end

function newCounter( n )
	local id = n or 0
	return function ()
		id = id + 1
		return id
	end
end