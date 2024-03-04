pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--boid
--by zapphique

--region globals

db=true --debug

--factors
ft=0.4    --turn
fr=0.05   --repulse
fl=0.05   --align
fa=0.0005 --attract

--ranges
rp=8  --protected
rv=20 --visual

--limits
pf,pc=32,94 --position
sf,sc=1,3    --speed

--boids
bc=9  --count
br=2  --radius
bl={} --list

--endregion
--region boid

boid={
	p={}, --position
	v={}, --velocity
	a={}, --acceleration
	c=0,  --color
}

function boid:new(b)
	b=b or {}
	b.p=vec:new(
		rnd(pc-pf)+pf,
		rnd(pc-pf)+pf)
	b.v=vec:new(
		rnd(sf)*rnd({-1,1}),
		rnd(sf)*rnd({-1,1}))
	setmetatable(b,boid)
	return b
end

function boid:force(b)
	b.a=vec:new(0,0)
	b.c=14
	--accumulate accel
	boid:turn(b)
	boid:repulse(b)
	boid:align(b)
	boid:attract(b)
end

function boid:update(b)
	b.v+=b.a
 boid:limit(b)
	b.p+=b.v
end

function boid:draw(b)
	circfill(b.p.x,b.p.y,br,b.c)
	if db then
	 circ(b.p.x,b.p.y,rp,2)
	 circ(b.p.x,b.p.y,rv,13)
	end
end

--region rules

function boid:turn(b)
	if(b.p.x<pf) b.a.x+=ft
	if(b.p.x>pc) b.a.x-=ft
	if(b.p.y<pf) b.a.y+=ft
	if(b.p.y>pc) b.a.y-=ft
end

function boid:repulse(b)
	for a in all(bl) do
		local d=b.p-a.p
		if b!=a and vec:mag(d)<rp then
			b.a+=d*fr
			if(db) b.c=8
		end
	end
end

function boid:align(b)
	local v,c=vec:new(0,0),0
	for a in all(bl) do
		local d=b.p-a.p
		if b!=a and vec:mag(d)<rv then
			v+=a.v c+=1
		end
	end
	if(db and c>0 and b.c!=8) b.c=11
	b.a+=(v/c)*fl
end

function boid:attract(b)
	local p,c=vec:new(0,0),0
	for a in all(bl) do
		local d=b.p-a.p
		if b!=a and vec:mag(d)<rv then
			p+=a.p c+=1
		end
	end
	b.a+=(p/c)*fa
end

function boid:limit(b)
 local m=vec:mag(b.v)
	if m>sc then 
		b.v=(b.v/m)*sc
	elseif m<sf then
		b.v=(b.v/m)*sf
	end
end

--endregion
--endregion
--region main

function _init()
	for i=1,bc do
		add(bl,boid:new())
	end
end

function _update()
	for b in all(bl) do
		boid:force(b)
	end
	for b in all(bl) do
		boid:update(b)
	end
end

function _draw()
	cls(1)
	for b in all(bl) do
		boid:draw(b)
	end
end

--endregion
--region vector

vec={}

--get vector
function vec:new(x,y)
	local v
	if type(x)=="table" then
		v={x=x.x,y=x.y}
	else
		v={x=x,y=y}
	end
	setmetatable(v,vec)
	return v
end

--get vector in direction
function vec:dir(t,m)
	local v=vec:new(cos(t),sin(t))
	return vec:nor(v)*m
end

--get normal
function vec:nor(v)
	return v/vec:mag(v)
end

--get magnitude
function vec:mag(v)
	local x,y=v.x,v.y
	return sqrt(x^2+y^2)
end

--region overloads

function vec.__add(a,b)
	return vec:new(a.x+b.x,a.y+b.y)
end

function vec.__sub(a,b)
	return a+(-1*b)
end

function vec.__mul(a,b)
	if type(a)=="number" then
		return vec:new(a*b.x,a*b.y)
	elseif type(b)=="number" then
		return vec:new(a.x*b,a.y*b)
	end
 return a.x*b.x+a.y*b.y
end

function vec.__div(a,b)
	return a*(1/b)
end

--endregion
--endregion
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
