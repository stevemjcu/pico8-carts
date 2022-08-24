-- shooting star
-- by sako and muse_energy

function _init()
 -- replace palette
 pal({129,1,140,13,14,9,10,135,7,7,7,7,7,7,7},1)
   
 star={
  x=85,
  y=75,
  s=32+rnd(16),--size
  a=rnd(1), --angle
 }
   
 trail={}
   
 bgstars={}
 for i=1,128 do
  local s={
   x=rnd(128),
   y=rnd(128),
   xprev=0,
   yprev=0,
   n=1+flr(rnd(9)),
   d=rnd(1)^4 --distance
  }
  add(bgstars,s)
 end
   
 spd=32  --move speed
   
 music(0)
end

function _update()
 star.s=32+rnd(24)
 star.a-=0.0025
   
 -- update trail
 while #trail>64 do
  del(trail,trail[1])
 end
   
 for tp in all(trail) do
  tp.x+=tp.xvel
  tp.y+=tp.yvel
 end
   
 local s=sin(time()*0.6)*0.7
 local w=0.5+sin(time()*6)*0.1
 local r=0.15
 for i=-1,1,2 do
  local tp={}
  tp.x=star.x
  tp.y=star.y
  tp.xvel=-spd*0.1-s/2+i*w-r+rnd(r*2)
  tp.yvel=-spd*0.1*0.5+s-i*w-r+rnd(r*2)
  add(trail,tp)
 end
   
 -- update bg stars
 for s in all(bgstars) do
  if s.x<0 then
   s.x=128+spd*s.d
   s.y=rnd(128)
   s.n=1+flr(rnd(9))
  end
 
  if s.y<0 then
   s.y=128+spd*s.d
   s.x=rnd(128)
  end
   
  s.xprev=s.x
  s.yprev=s.y
  s.x-=spd*s.d
  s.y-=spd*s.d*0.5
 end
end

function _draw()
 cls()
   
 -- draw trail
 local x0=star.x
 local y0=star.y
 local x1=star.x
 local y1=star.y
 local x2=x1
 local y2=y1
 local tb=star.s*0.05
 for i=#trail,1,-1 do
  x0,y0 = trail[i].x,trail[i].y
  local n=ceil(tb+rnd(1))
  if (n>0) p01_triangle_335(x0,y0,x1,y1,x2,y2,n)
  x2,y2 = x1,y1
  x1,y1 = trail[i].x,trail[i].y
  tb=max(0,tb-0.04) 
 end
   
 -- draw star
 for i=0,3 do
  local x2=star.x+cos(star.a+i/4)*star.s
  local y2=star.y+sin(star.a+i/4)*star.s
  line_a_g(star.x,star.y,x2,y2,4)
 end
 circfill_a_g(star.x,star.y,star.s/4,5)
   
 scr_gradient()
   
 -- draw bg stars
 for s in all(bgstars) do
  line_a(s.x,s.y,s.xprev,s.yprev,s.n-s.n*s.d)
 end
end

-->8
-- custom functions
function pset_a(x,y,n)
 if n>0 then
  local c=pget(x,y)
  local c2=min(flr(c+n),9)
  pset(x,y,c2)
 end
end

function line_a(x1,y1,x2,y2,n)
 x1,y1 = flr(x1+0.5),flr(y1+0.5)
 x2,y2 = flr(x2+0.5),flr(y2+0.5)
 local xr=x2-x1
 local yr=y2-y1
   
 if abs(xr)>abs(yr) then
  for x=x1,x2,sgn(xr) do
   local prog=(x-x1)/xr
   local y=flr(y1+yr*prog+0.5)
   pset_a(x,y,n)
  end
 else
  for y=y1,y2,sgn(yr) do
   local prog=(y-y1)/yr
   local x=flr(x1+xr*prog+0.5)
   pset_a(x,y,n)
  end
 end
end

function line_a_g(x1,y1,x2,y2,n)
 x1,y1 = flr(x1+0.5),flr(y1+0.5)
 x2,y2 = flr(x2+0.5),flr(y2+0.5)
 local xr=x2-x1
 local yr=y2-y1
   
 if abs(xr)>abs(yr) then
  for x=x1,x2,sgn(xr) do
   local prog=(x-x1)/xr
   local y=flr(y1+yr*prog+0.5)
   local _n=ceil(n-prog*n)
   pset_a(x,y,_n)
  end
 else
  for y=y1,y2,sgn(yr) do
   local prog=(y-y1)/yr
   local x=flr(x1+xr*prog+0.5)
   local _n=ceil(n-prog*n)
   pset_a(x,y,_n)
  end
 end
end

function rectfill_a(x1,y1,x2,y2,n)
 x1,y1 = flr(x1+0.5),flr(y1+0.5)
 x2,y2 = flr(x2+0.5),flr(y2+0.5)
 local xr=x2-x1
 local yr=y2-y1
   
 for y=y1,y2,sgn(yr) do
  for x=x1,x2,sgn(xr) do
   pset_a(x,y,n)
  end
 end
end

function circfill_a(x,y,r,n)
 -- copied from https://gamedev.stackexchange.com/questions/176036/how-to-draw-a-smoother-solid-fill-circle
 local d=r*2
 for _y=0,d do
  for _x=0,d do
   if ((_x-r)^2+(_y-r)^2)<=r^2 then
 pset_a(x+_x-r,y+_y-r,n)
   end
  end
 end
end

function circfill_a_g(x,y,r,n)
 -- copied from https://gamedev.stackexchange.com/questions/176036/how-to-draw-a-smoother-solid-fill-circle
 local d=r*2
 for _y=0,d do
  for _x=0,d do
   local _n=n-((_x-r)^2+(_y-r)^2)/r^2*9
   pset_a(x+_x-r,y+_y-r,_n)
  end
 end
end

function scr_gradient()
 for y=0,127 do
  for i=0,15 do
   local amt=flr(y/26+rnd(1))
   local a=0x6000+y*64+i*4
   local b=$a
   local n=0x1111.1111*amt
   poke4(a,b+n)
  end
 end
end

-- @po1
-- copied from lexaloffle.com/bbs/?tid=31478
function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
function p01_trapeze_w(t,b,tt,bt,x0,x1)
 tt,bt=(tt-t)/(x1-x0),(bt-b)/(x1-x0)
 if(x0<0)t,b,x0=t-x0*tt,b-x0*bt,0
 x1=min(x1,128)
 for x0=x0,x1 do
  rectfill(x0,t,x0,b)
  t+=tt
  b+=bt
 end
end
function p01_triangle_335(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 if max(x2,max(x1,x0))-min(x2,min(x1,x0)) > y2-y0 then
  col=x0+(x2-x0)/(y2-y0)*(y1-y0)
  p01_trapeze_h(x0,x0,x1,col,y0,y1)
  p01_trapeze_h(x1,col,x2,x2,y1,y2)
 else
  if(x1<x0)x0,x1,y0,y1=x1,x0,y1,y0
  if(x2<x0)x0,x2,y0,y2=x2,x0,y2,y0
  if(x2<x1)x1,x2,y1,y2=x2,x1,y2,y1
  col=y0+(y2-y0)/(x2-x0)*(x1-x0)
  p01_trapeze_w(y0,y0,y1,col,x0,x1)
  p01_trapeze_w(y1,col,y2,y2,x1,x2)
 end
end