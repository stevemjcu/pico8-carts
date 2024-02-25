pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- pond.p8
-- by zapp

function nor(x,y)
	local m=mag(x,y)
	return x/m,y/m
end

function mag(x,y)
	return sqrt(x*x+y*y)
end

function look(r,m)
 if(m==nil) m=1
	local x,y=nor(cos(r),sin(r))
	return x*m,y*m
end

fish={}

function fish.init(p)
	p=p or {}
	p.x,p.y=64,64
	p.dx,p.dy=0,0
	p.a,p.r=0,0
	p.j=2
	return p
end

function fish.step(p)
	-- input
	if(btn(⬅️)) p.r+=0.03
	if(btn(➡️)) p.r-=0.03
	local c1=btnp(⬅️) and p.j!=0
	local c2=btnp(➡️) and p.j!=1
	if(c1) p.a+=0.1 p.j=0
	if(c2) p.a+=0.1 p.j=1
	-- force
	local lx,ly=look(p.r,p.a)
	p.dx+=lx p.dy+=ly
	p.x+=p.dx p.y+=p.dy
	p.a*=0.965
	p.dx*=0.85 p.dy*=0.85
end

function fish.draw(p)
	local sy=p.y+16
	local fy=p.y+sin(t()/2)*2
	local lx1,ly1=look(p.r,1)
	local lx2,ly2=look(p.r,2)
	-- shadow
	color(0) fillp(▥)
	circfill(p.x,sy,2)
	circfill(p.x-lx1,sy-ly1,2)
	circfill(p.x-lx2,sy-ly2,2)
	-- body
	color(13) fillp()
	circfill(p.x,fy,2)
	circfill(p.x-lx1,fy-ly1,2)
	circfill(p.x-lx2,fy-ly2,2)
end

::init::
	local f = fish.init()
::step::
	fish.step(f)
::draw::
	cls(1)
	fish.draw(f)
	print("cpu:"..stat(1))
	flip()
goto step
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
