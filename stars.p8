pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--stars by zapp

sl={} --stars
rl={} --regions
cl={} --constellations

function _init()
 makestars(sl)
 makeregions(rl)
 pickstars(sl,rl,cl)
end

function _update()
end

function _draw()
 cls()
 drawstars(sl)
 drawregions(rl)
 connectstars(cl)
end

-->8
--helpers

function rndr(l,u)
 return l+rnd(u-l)
end

function rndd(t,d)
 return t+rnd(d)-d/2
end

function aabb(a,b)
 return not (
  a.x>b.x+b.w or
  a.x+a.w<b.x or
  a.y>b.y+b.h or
  a.y+a.h<b.y
 )
end

function abb(a,b)
 return not (
  a.x>b.x+b.w or
  a.x<b.x or
  a.y>b.y+b.h or
  a.y<b.y
 )
end
-->8
--gameplay

function makestars(sl)
 for i=1,rndd(48,16) do
  local s={}
  s.x=rnd(128)
  s.y=rnd(128)
  s.c=7
  add(sl,s)
 end
end

function makeregions(rl)
 for i=1,rndr(1,4) do
  local r={}
  r.w=rndr(32,64)
  r.h=rndr(32,64)
  r.x=rnd(128-r.w)
  r.y=rnd(128-r.h)
  add(rl,r)
  --cull by overlap?
  -- for c2 in all(cl) do
  --  if(aabb(c,c2)) del(cl,c)
  -- end
 end
end

function pickstars(sl,rl,cl)
 for r in all(rl) do
  local lsl={}
  for s in all(sl) do
   if abb(s,r) then
    add(lsl,s) s.c=2
   end
  end
  if(#lsl==0) break
  local csl={}
  for i=4,8 do
   local s=lsl[flr(rnd(#lsl)+1)]
   add(csl,s) s.c=3
  end
  --cull by angle/dist?
  add(cl,csl)
 end
end

function drawstars(sl)
 for s in all(sl) do
  pset(s.x,s.y,7)
  -- pset(s.x-1,s.y,1)
  -- pset(s.x+1,s.y,1)
  -- pset(s.x,s.y-1,1)
  -- pset(s.x,s.y+1,1)
 end
end

function drawregions(rl)
 for r in all(rl) do
	 local x1=r.x+r.w
	 local y1=r.y+r.h
	 rect(r.x,r.y,x1,y1,2)
 end
end

function connectstars(cl)
 for c in all(cl) do
  for i=1,#c-1 do
   local s1=c[i]
   local s2=c[i+1]
   line(s1.x,s1.y,s2.x,s2.y,7)
  end
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
