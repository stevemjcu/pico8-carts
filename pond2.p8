pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- pond | by zapphique

-- draw series of circles
-- p=pos, o=off, n=cnt, r=rad
function chainfill(p,o,n,r)
	local v=v2:new(p)
	for i=1,n do
		circfill(v.x,v.y,r)
		v+=o
	end
end

function init_fish(p)
	p=p or {}
	p.pos={x=64,y=64}
	p.vel={x=0,y=0}
	p.acc,p.rot=0,0
	p.lr=0 --left/right
	return p
end

--[[
todo:
	clean up movement code
	prevent hold l and r
	relate force w/ rot
	friction vec to acc only
]]

function step_fish(p)
	local l,r
	-- handle input
	if(btn(⬅️)) p.rot+=0.03
	if(btn(➡️)) p.rot-=0.03
	l=btnp(⬅️) and p.lr!=0
	r=btnp(➡️) and p.lr!=1
	if(l) p.acc+=0.1 p.lr=0
	if(r) p.acc+=0.1 p.lr=1
	-- apply forces
	p.acc*=0.965
	p.vel+=v2:dir(p.rot,p.acc)
	p.vel*=0.85
	p.pos+=p.vel
end

--[[
todo:
  genericize draw shadow
  offset/fill draw fn?
  or draw to mask first?
]]

function draw_fish(p)
	local pos,off
	-- draw shadow
	pos=p.pos+v2:new(0,16)
	off=v2:dir(p.rot,1)
	color(0) fillp(▥)
	chainfill(pos,off,3,2)
	-- draw body
	pos=v2:new(p.pos)
	pos.y+=sin(t()/2)*1.5 --bob
	off=v2:dir(p.rot,1)
	color(13) fillp()
	chainfill(pos,off,3,2)
end

function _init()
	p=init_fish()
end

function _update()
	step_fish(p)
end

function _draw()
	cls(1)
	draw_fish(p)
	--print("cpu:"..stat(1))
end

-->8

-- region vectors

v2={}

-- make vector
function v2:new(x,y)
	local v
	if type(x)=="table" then
		v={x=x.x,y=x.y}
	else
	if(y==nil) y=x
		v={x=x,y=y}
	end
	setmetatable(v,v2)
	return v
end

-- make in direction
function v2:dir(t,m)
	local v=v2:new(cos(t),sin(t))
	return v2:nor(v)*m
end

-- get normal
function v2:nor(v)
	return v*(1/v2:mag(v))
end

-- get magnitude
function v2:mag(v)
	local x,y=v.x,v.y
	return sqrt(x*x+y*y)
end

-- get sum
function v2.__add(a,b)
	return v2:new(a.x+b.x,a.y+b.y)
end

-- get difference
function v2.__sub(a,b)
	return a+(-1*b)
end

-- get dot/vector product
function v2.__mul(a,b)
	if type(a)=="number" then
		return v2:new(a*b.x,a*b.y)
	end
	if type(b)=="number" then
		return v2:new(a.x*b,a.y*b)
	end
	return a.x*b.x+a.y*b.y
end

-- endregion

-->8

--[[
offscreen hint
	show orientation
food
	float down
	can eat
	flash on timeout
	extend timer
particles
	bubbles
environment
	seagrass or seaweed
	circfill moss
	polyfill rocks
	shadow by elevation
		clipping/mask?
	react to current
smaller fish (boids)
	avoid player
]]

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
