pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- pond | by zapp

--draw series of circles
--p=pos, o=off, n=cnt, r=rad
function chainfill(p,o,n,r)
 local v=cpy(p)
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

//todo:
//clean up movement code
// prevent hold l and r
// relate force w/ rot
// friction vec to acc only

function step_fish(p)
 local l,r,z
 --handle input
 if(btn(⬅️)) p.rot+=0.03
 if(btn(➡️)) p.rot-=0.03
 l=btnp(⬅️) and p.lr!=0
 r=btnp(➡️) and p.lr!=1
 if(l) p.acc+=0.1 p.lr=0
 if(r) p.acc+=0.1 p.lr=1
 --apply forces
 p.vel+=dir(p.rot,p.acc)
 p.pos+=p.vel
 p.acc*=0.965
 p.vel*=0.85
end

//todo:
//genericize draw shadow
// offset/fill draw fn?

function draw_fish(p)
 local pos,off
 --draw shadow
 pos=cpy(p.pos)+vec(0,16)
 off=dir(p.rot,1)
 color(0) fillp(▥)
 chainfill(pos,off,3,2)
 --draw body
 pos={x=p.pos.x,y=p.pos.y}
 pos.y+=sin(t()/2)*2 --bob
 off=dir(p.rot,1)
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
 //print("cpu:"..stat(1))
end
-->8
//vectors

//todo:
//operator overloads

vc={}

--make from coordinate
function vec(x,y)
 if(y==nil) y=x
 local v={x=x,y=y}
 setmetatable(v,vc)
 return v
end

--make from vector
function cpy(v)
 return vec(v.x,v.y)
end

--make in direction
function dir(t,m)
 local v=vec(cos(t),sin(t))
 return nor(v)*m
end

--get normal
function nor(v)
 local m=mag(v)
 return v*(1/mag(v))
end

--get magnitude
function mag(v)
 local x,y=v.x,v.y
 return sqrt(x*x+y*y)
end

--get sum
function vc.__add(a,b)
 return vec(a.x+b.x,a.y+b.y)
end

--get difference
function vc.__sub(a,b)
 return a+(-1*b)
end

--get dot/vector product
function vc.__mul(a,b)
 if type(a)=="number" then
  return vec(a*b.x,a*b.y)
 end
 if type(b)=="number" then
  return vec(a.x*b,a.y*b)
 end
 return a.x*b.x+a.y*b.y
end
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

--[[
--draw line w/ circfill
function linefill(a,b,n,r)
 --o is (a-b)/n
 local o=div(dif(a,b),vec(n))
 local v=cpy(a)
 for i=1,n do
  circfill(v.x,v.y,r)
  v=sum(v,o)
 end
end
]]
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
