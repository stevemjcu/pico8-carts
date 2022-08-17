pico-8 cartridge // http://www.pico-8.com
version 35
__lua__

--

pal(1,1+128,1)
poke(24365,1)

--

function _init()
	ll={
		{x=48,y=48},
		{x=80,y=80}
	}
	m={x=0,y=0,p=0,l=nil}
end

function _update()
	m.x,m.y,m.p=mouse()
	for l in all(ll) do
		if m.l==nil and m.p==1 then
			if isclose(m.x,m.y,l.x,l.y,3) then
				m.l,m.x,m.y=l,l.x,l.y
			end
		elseif m.p==0 then
			m.l=nil
		end
		if m.l!=nil then
			m.l.x,m.l.y=m.x,m.y
		end
	end
end

function _draw()
	cls()
	for l in all(ll) do
		circfillp(l.x,l.y,14,1,▥)
	end
	for l in all(ll) do
		circfillp(l.x,l.y,8,0)
	end
	for l in all(ll) do
		circfillp(l.x,l.y,8,5,▥)
	end
	for l in all(ll) do
		circfillp(l.x,l.y,2,7)
	end
	pset(m.x,m.y)
	debug()
end

function debug()
	color(11)
	print("m.x:"..m.x)
	print("m.y:"..m.y)
	print("m.p:"..tonum(m.p))
	print("fps:"..stat(7))
end

--

function circfillp(x,y,w,c,p)
	fillp(p)
	circfill(x,y,w,c,p)
end

function mouse()
	return 
		stat(32),
		stat(33),
		stat(34)
end

--

function isclose(x1,y1,x2,y2,d)
	local dx=abs(x1-x2)
	local dy=abs(y1-y2)
	return sqrt(dx*dx+dy*dy)<=d
end

--

vec2={x=0,y=0}

function vec2:new(o,x,y)
	o=o or {}
	setmetatable(o,self)
	self.__index=self
	self.x=x or 0
	self.y=y or 0
	return o
end

function vec2:mag()
	return sqrt(x*x+y*y)
end

function vec2:nor()
 local m=self.mag()
	local v=self.new()
 if(m==0) then
		v.x,v.y=0,0
	else 
		v.x,v.y=x/m,y/m
	end
 return v
end

--

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
