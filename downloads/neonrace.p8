pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--game maker
--[[
mx=0  my=0//map x/y
mx8=0 my8=0
mw=16 mh=16
//mw8=0 mh8=0
//mwc=0 mhc=0
]]--
//xof=0 yof=0//24
cam_x=0  cam_y=0

ic=0 sw=3

ww=128//flr(128/mw)*mw
wh=64//flr(64/mh)*mh
ww8=1024//ww*8
wh8=512//wh*8

fwait=0

dxs={-1,1,0,0}
dys={0,0,-1,1} 

scene="menu"
song=nil

function gotoscene(s)
 scene=s
 //_init()
 inits[scenes[scene]]()

 //18 - space
 //30 -
 //48 - 
 play(scene=="play" and 18 or 48)  
end

function play(m)
 if(m==song)return
 song=m
 music(m)
end

function _init() 
 
 scenes={
  menu=1,
  play=2,
  news=3,
  char=4,
  scor=5,
  podi=6,
  prac=7
 }

 inits={
  ini_menu,
  ini_play,
  ini_news,
  ini_char,
  ini_scor,
  ini_podi,
  ini_prac
 }

 updates={
  upd_menu,
  upd_play,
  upd_news,
  upd_char,
  upd_scor,
  upd_podi,
  upd_prac,
 } 

 draws={
  drw_menu,
  drw_play,
  drw_news,
  drw_char,
  drw_scor,
  drw_podi,
  drw_prac
 }

 draw_ends={
  drwend_menu,
  nil,
  nil,
  drwend_char,
 }
 
 gotoscene(scene)
 //inits[scenes[scene]]()
end

--[[
function upsc()
 //mx8=mx*8
 //my8=my*8
 //mw8=mw*8
 //mh8=mh*8
 //mwc=mw+mx-1
 //mhc=mh+my-1
end]]--

function upd_cam()
 camera(cam_x,cam_y)
end

function cit(sv,f)
 return (sv or sw)/2
 -cos(time()*(f or 0.72))*(sv or sw)/2
end


function _update()
 ci=cit()
 
 while fwait>0 do
  fwait-=1
  flip()
 end
 
 upd_cam()
 //upsc()
 
 updates[scenes[scene]]()
 allsteps()
end

function _draw()
 cls()
 pal()

 draws[scenes[scene]]()
 alldraws()
 local de=draw_ends[scenes[scene]]
 if(de)de()
 //debug
 print(str,cam_x,cam_y+8,7) 
end


str=""
function prnt(s)
 if(s==nil)return
 str= s .."\n" .. str
end

-----
-----
objs={}
function b2n(value)
 return value==true and 1 or 0
end

function objdist(u,v)
 return pdist(u.x,u.y,v.x,v.y)
end

function objdir(u,v)
 return pdir(u.x,u.y,v.x,v.y)
end

function pdist(x1,y1,x2,y2)
 local xx=x2-x1
 local yy=y2-y1
 return sqrt(xx*xx+yy*yy)
end

function pdir(x1,y1,x2,y2)
 return atan2(x2-x1,y2-y1)*360 
end

function mot_add(obj,d,spd)
 obj.hs+=cos(d/360)*spd
 obj.vs+=sin(d/360)*spd
end

function mot_set(obj,d,spd)
 obj.hs=cos(d/360)*spd
 obj.vs=sin(d/360)*spd
end

function rndf(i)
 return rnd(i)-i/2
end

function boxd(u,v,d)
 return abs(u.x-v.x)<d 
     and abs(u.y-v.y)<d
end

function destroy(obj)
 if(obj==nil)return
 obj.step=nil
 obj.draw=nil
 del(objs,obj)
end

function allsteps()
 zorder()
 
 foreach(objs, function(u)
  step(u)
  if(u.step)u.step(u)
 end)
 
end

function alldraws()
 
 foreach(objs,function(u)
  if u.draw then
   u.draw(u)
  elseif not u.vis==false 
  and incam(u)
  then
   draw(u)
  end 
 end)
 
end

function step(obj)
 if(obj==nil)return

 obj.px,obj.py,obj.pz=obj.x,obj.y,obj.z
 
 obj.spd=sqrt(obj.hs*obj.hs
              +obj.vs*obj.vs)
//             +obj.zs*obj.zs)
             
 obj.x+=obj.hs 
 obj.y+=obj.vs
// obj.z+=obj.zs
 obj.ci+=obj.as
 
 if obj.ang then
  while obj.ang>360 do
   obj.ang-=360
  end
 
  while obj.ang<0 do
   obj.ang+=360
  end
 end

 while obj.ci<0 or obj.ci>=obj.ic do
  if(obj.animend)obj.animend(obj)
  
  if obj.re then
   obj.as*=-1
   obj.ci= obj.ci<0 and 0 or obj.ic-0.001
   return
  end
  
  obj.ci=obj.ci+obj.ic*(obj.ci<0 and 1 or -1)
 end
 
end

function draw(obj,x,y)
 if(not obj or not obj.sp) return
 
 obj.esp=flr(obj.sp+obj.ci)
  
--[[ local col=nil
 if obj.outline then 
  col = obj.ocolor
 end]]--
 
 local tx=obj.x+(x or 0)//+xof+mx8
 local ty=obj.y+(y or 0)//-(obj.z or 0)//+yof+my8
 
 //prnt(obj.sp.."-"..obj.ci)
  
 if obj.ang then
  spr_r(obj.esp,tx,ty,obj.ang,1,1)
 else
  spr(obj.esp,tx,ty)
 end
 --[[
 outline_sprite(obj.esp,
 obj.outline and obj.ocolor or nil,
 tx, ty,
 1,1,//abs(obj.xs), abs(obj.ys),
 (obj.xs or 0)<0,(obj.ys or 0)<0)  
 ]]--
end

function nobj(sp,ix,iy,pf)
 local ao={
  sx=ix,sy=iy,
  x=ix, y=iy, 
  px=ix, py=iy,
  xs=1, ys=1,
  hs=0, vs=0,
  z=0,  //zs=0,//zscale=1
  sp=sp, esp=sp,
  as=1, ic=1, ci=0,
  re=false,
  sw=8, sh=8,
  vis=true
 }
 
 if pf then return ao end
 add(objs,ao) 
 return ao
end


function create(obj)
 add(objs,obj)
 return obj
end


function addtotbl(tbld,tbls)
 for i, v in pairs(tbls) do  
  tbld[i]=v
 end
end


function zorder()
 local a=objs
 
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1].z > a[j].z do
   a[j],a[j-1] = a[j-1],a[j]
   j-=1
  end
 end
end

function outline_sprite(nn,col_outline,x,y,w,h,flip_x,flip_y)
  
  local n=nn or 0

  -- draw outline
  if col_outline then
   flx=flip_x
   fly=flip_y
   
   shadow(n,12,2,x,y+1,w,h)//,w,h,flip_x,flip_y)
   shadow(n,7,2,x,y,w,h)//,w,h,flip_x,flip_y)
   shadow(n,col_outline,1,x,y,w,h)//,w,h,flip_x,flip_y)
  end

  -- reset palette
  pal()
  
  -- draw final sprite  
  spr(n,x,y,w,h,flip_x,flip_y)
  
end

function shadow(n,c,d,x,y,w,h,flip_x,flip_y)
 colorize(c)
 
 for xx=-d,d do
  for yy=-d,d do
   if abs(xx)+abs(yy)==d then
    spr(n,x+xx,y+yy,w,h,flx,fly)
   end
  end
 end
end

function colorize(c)
 for col=1,15 do pal(col,c) end 
end

function outline_text(str,x,y,col,ocol)
 for i=-1,1 do
  for j=-1,1 do
   print(str,x+i,y+j,ocol)
  end
 end
 print(str,x,y,col)
end

function incam(u)
 return u.x==mid(cam_x-8,u.x,cam_x+127)
 and u.y==mid(cam_y-8,u.y,cam_y+127)
end

function setoutline(u,col)
 u.outline=true//col and true or false
 u.ocolor=col or 0
end

function grid(maxi,maxj,func)
 for i=1,maxi do
  for j=1,maxj do
   local b=func(i,j)
   if(b==false)return false
  end
 end
 return true
end

function clamp(cv,tv,th)
 return abs(cv-tv)<th and tv or cv
end

function avg(a,b)
 return (a+b)/2
end

function ppos(u)
 u.x=u.px or u.x
 u.y=u.py or u.y
end

function spos(u)
 u.x=u.sx
 u.y=u.sy
end

function flpc()
 return rnd(2)>1
end

function fspd(u,f)
 u.hs*=f
 u.vs*=f
end

--[[function toclp(v,seg)
 return flr(v/seg)*seg
end]]--

//rotate
function spr_r(s,x,y,a,w,h)
 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s%16)*8
 sy=flr(s/16)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=-sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    local sv=sget(sx+xx,sy+yy)
    if sv!=0 
    and sx+xx>=sx 
    and sx+xx<sx+8
    and sy+yy>=sy
    and sy+yy<sy+8
    then
     pset(x+ix,y+iy,sget(sx+xx,sy+yy))
    end
   end
  end
 end
end

function shuffle(t)
 for n=1,#t*2 do -- #t*2 times seems enough
  local a,b=flr(1+rnd(#t)),flr(1+rnd(#t))
  t[a],t[b]=t[b],t[a]
 end
 return t
end

function reverse(t)
 for i=1,#t/2 do
  local oob=t[i]
  local ti=#t-i+1
  t[i]=t[ti]
  t[ti]=oob
 end
end
-->8
--main menu
bindex=2
pbindex=nil
game_mode="cup"

xof=0


function ini_menu()
 reload()
 pbindex=nil
 //music(30)
 
 menuitem(1)
end

function upd_menu()
 
 //play stuff
 if(hitinv>0)hitinv-=1
 
 
 if pbindex!=bindex then
  destroycars()
  carc=1
  
  if bindex==1 then
   //nothing here news
  elseif bindex==2 then
   for i=1,3 do
    ncar(i,25+i*10,60)   
   end  
  elseif bindex==3 then
   for i=1,3 do
    local nc=ncar(i,25+i*10,60) 
    if(i==1)bombc=nc
   end
   
   dmtype=2
  elseif bindex==4 then
   ncar(1,25+1*10,60)   
  end
  
  crsx={42,68,42}
  crsy={50,50,50}
  dmwait=0
  pbindex=bindex 
 end
 //carcolcheck()

 
 xof=clamp(xof*0.68,0,1)
 
 if(btnp(0))bindex-=1 xof=8 sfx(62)
 if(btnp(1))bindex+=1 xof=-8 sfx(62)
 bindex=mid(2,bindex,4)
 
 if btnp(4) then
  sfx(61)
  //todo set values
  if bindex==1 then
   gotoscene("news")
  elseif bindex==2 then
   destroycars()
   tlaps=10
   tcars=8
   
   milaps={
   flr(1),//rnd(2)+0),
   flr(rnd(2)+2),
   flr(rnd(2)+4),
   flr(rnd(2)+6)}//{1,2,3,4,5,6,7}
   
   game_mode="cup"
   gotoscene("char")
  elseif bindex==3 then
   destroycars()
   tlaps=0
   tcars=8
   milaps={1}
   game_mode="grounds"
   gotoscene("char")
  elseif bindex==4 then
   destroycars()
   gotoscene("prac")
  end
  
 end
end

x=-50
function drw_menu()
 //rect(0,0,127,127,1)
 
 //oval(40,54,88,74)
 
 tic()

 local cols={
  {15,14,14},//news
  {15,6,9},//cup
  {6,12,13},//grounds
  {6,7,7},//prac
 }//white

 pal(13,cols[bindex][3])
 map(3,3,xof+24,24,10,7)
 pal()
end

function drwend_menu()

 local mtexts={
  "news",
  "grand prix",
  "battle royale",
  "practice",
  "credits",
 }
 
 
--logo

 local lx=63-5*8/2
 local ly=2//2+cit(6,0.53)*0.75
 shadow(139,1,1,
 lx,ly+1,5,4)
 shadow(139,2,1,
 lx,ly,5,4)
 pal()
 spr(139,lx,ly,5,4)
 
 //rectfill(0,1,7,6,0)
 //spr(144+flr(time()*4)%4,0)
 
--game mode title 
 local ccs={2,2,1,5,5}
 local at=mtexts[bindex]
 outline_text(
 at,
 64-#at*2+xof/2,82,10,ccs[bindex])
 
--arrow buttons  
 if bindex>2 then
  spr(182,16+cit()/2,52,1,1)
 end
 
 if bindex<#mtexts-1 then
  spr(183,106-cit()/2,52)
 end
 
--play
 outline_textb("play 🅾️",
 50,94+cit()/2,ccs[bindex])

--by calixjumio
 //outline_textb(
 print(
   "\66\89",2,121,5,1) 
 outline_text("@\67\65\76\73\88\74\85\77\73\79",
   13,121,9,1)
 //outline_textb(
 print(
 "\77\85\83\73\67 \66\89",
 68,121,5,1)
 outline_text(
 "gruber",103,121,14,1)   
end

function outline_textb(astr,x,y,c,c2)
 outline_text(astr,x+cam_x,y+1+cam_y,1,1)
 outline_text(astr,x+cam_x,y+cam_y  ,c or 0,c2 or 7)
end


t=0
function tic()

local pcol={1,0}

 local cols={
  {15,14},//news
  {15,6},//cup
  {12,6},//grounds
  {7,6},//prac
 }//white

 local inplay=scene=="play"
           or scene=="scor"
 local bc=inplay
       and pcol
       or  cols[bindex]
 
 local tt=inplay and 0.03 or time()/16 
 tx=sin(tt)*32+0.5//t%(8*#bc)
 ty=cos(tt)*32+0.5//t%(8*#bc)
 for i=-4,20 do
  for j=-4,20 do
   //local sp=184+(i+j)%2
   local c=1+(i+j)%#bc
   local xp=i*8-tx
   local yp=j*8-ty
   local acol=
   rectfill(xp,yp,xp+7,yp+7,bc[c])
  end
 end
 
 //rectfill(0,32,127,127-56,bgs[bindex])
 //t=t+bindex/2-1
end
-->8
--play

crsx={}
crsy={}
cars={}
gmode=1

milaps={1}//{1,2,3,4,5,6,7}
mindex=1
maplv=1

dmwait=1
racen=1
tlaps=1//10
mlaps=0
rwait=0
lwait=0
placc={}
hitinv=0

function ini_play()
 maplv=milaps[mindex]
 mlaps=0
 palt()
 placc={}
 rwait=30*3.5
 
 local mtxt="end race"
 menuitem(1,mtxt, function()
  gotoscene("menu")
 end) 
 
 reload()
 destroycars()
 
 rerace()
end

function destroycars()
 if cars then
  foreach(cars, function(acar)
   destroy(acar)  
   del(cars,acar)
  end)
 end
end

function rerace()
 
 //1. snipe
 //2. bomb
 dmtype=1
 dmtime=30*15
 dmwait=30*15
 bombc=nil
 hitinv=0
 cars={}
 crsx={}
 crsy={}
 
 //move all to 0,0
 for i=0,15 do
  for j=0,15 do
   mset(i,j,
   mget(maplv*16+i,j))
  end
 end
 
 for s=112,127 do
  for i=0,0+15 do
   for j=0,15 do
    if mget(i,j)==s then
     add(crsx,i*8)
     add(crsy,j*8)
     mset(i,j,80)
    
    elseif mget(i,j)==110then 
     
     if #cars<tcars then
      local id=c_cars[#cars+1].id
     
      local acar=ncar(id,
      i*8,j*8)  
         
      for cci=1,#ctrls do
       if ctrls[cci]==acar.id then
        acar.ctrlid=cci-1
        acar.ctrl=true  
        
        acar.draw=function(u)
         cardraw(u)
         if flr(time()*8)%2==0 
         and rwait>0 then
          outline_text(
          (acar.ctrlid+1).."p",
          u.x+1,u.y-8,0,7)
         end
        end    
       end
      end
      
      
     end  
     mset(i,j,80)
     
    end
    
   end
  end
 end
 
 add(crsx,crsx[1])
 add(crsy,crsy[1])
 
end

function ncar(id,x,y)
 local sp=1+(id-1)*8
 local car=nobj(sp,x,y)
 add(cars,car)
 car.id=id-1
 car.ang=0
 car.place=0
 car.as=0.25
 car.ic=4
 car.ts=0
 car.turn=0
 car.run=0
 car.curt=1
 car.col=7
 car.laps=0
 car.xs=-1
 car.draw=cardraw
  
 car.step=function(u)
  
  if(rwait>0)return
  
  if game_mode=="cup" then
   if u.laps>=tlaps then
    u.ctrl=false
   end
  end
     
  u.z=u.y
  
  local pd=pdir(u.x,u.y,
            crsx[u.curt],
            crsy[u.curt])
  local pdst=pdist(u.x,u.y,
            crsx[u.curt],
            crsy[u.curt])
  local da=u.ang-pd+rndf(100)
   
   
  if u.ctrl then
   //user input
   if(btn(0,u.ctrlid))u.turn=1
   if(btn(1,u.ctrlid))u.turn=-1
   if(btn(2,u.ctrlid))u.run=1
   if(btn(3,u.ctrlid))u.run=-1
   
  else
   
   
   if abs(da)<60 or abs(da)>300 then
    u.run=1
   end
   
   if (da<-10 and da>-170)
   then
    u.turn=1 
   elseif (da>10 and da<170)
   then
    u.turn=-1
   elseif da>0
   then
    u.turn=1 
   else
    u.turn=-1
   end
   
   //if close enough, +1 curt
   
  end 
  
  if pdst<24 then    
    u.curt+=1
    if(u.curt>#crsx-1)u.curt=1 
  end
  
  u.ts+=u.turn
  u.ang+=u.ts
  u.ts*=0.75
  u.turn*=0.75
  u.run*=0.75
  
  local tx=u.x/8+0.5
  local ty=u.y/8+0.5
  
  local fl=mget(tx,ty)
  
  if u.curt>=#crsx-1 and fl==111 then
   u.curt=1
   u.laps+=1
   if u.laps>mlaps then
    mlaps=u.laps
    lwait=60
   end
   
   if u.laps==tlaps then
    add(placc,u.id+1)
    u.fplace=#placc
   end
   
   snd(0)
   //addvfx(140,u.x,u.y-4)
  end
  
  if dmwait<=0 then
   
   if dmtype==1
   and u.place==#cars then
    u.run*=1.1
   end
   
   if dmtype==2
   and bombc==u then
    u.run*=1.25
   end
   
   if dmtype==3 
   and u.place==1 then
    fspd(u,0.92)
    u.turn+=rndf(1)
   end
   
  end
  
  if fget(fl,5) then
  //slippery
   mot_add(u,u.ang,u.run/20)
   u.ic=2
  elseif not fget(fl,0) then
  //bumpy
   mot_add(u,u.ang,u.run/5)
   fspd(u,0.9)
   u.ic=2
  else
  //normal
   mot_add(u,u.ang,u.run/5) 
   fspd(u,0.9)
   u.ic=4
  end 
  
  if u.run>0 
  and scene=="play" then
   sfx(59,2,u.spd*10,u.spd*10+1)
  end 
  
  local f0=fget(fl,1)
  local f1=fget(fl,2)
  local f2=fget(fl,3)
  local f3=fget(fl,4)
  
  local iscor= (f0 and f2)
  or (f0 and f3)
  or (f1 and f2)
  or (f1 and f3) 
  local sf= iscor and 0.025 or 0.1
  
  if f0 or f1 or f2 or f3 then
   snd(2)
  end
  
  if(iscor)fspd(u,0.9)
  
  if f0 and f1 and f2 and f3 then
   
   local dist=pdist(u.x,u.y,flr(tx)*8,flr(ty)*8)-1
   local adir=pdir(u.x,u.y,flr(tx)*8,flr(ty)*8)
   mot_add(u,adir,-dist*dist*0.05)
  else
   if f0 then
   
    local xdist=tx*8-u.x-1
    u.hs-=xdist*xdist*sf
   end
  
   if f1 then
    local xdist=tx*8-u.x-1
    u.hs+=xdist*xdist*sf
   end
  
   if f2 then
    local ydist=ty*8-u.y-1
    u.vs-=ydist*ydist*sf
   end
  
   if f3 then
    local ydist=ty*8-u.y-1
    u.vs+=ydist*ydist*sf
   end
  end  
 end
 
 return car
end

function cardraw(u)
 for i=0,2 do
  spr_r(u.sp+2-i,u.x,u.y-i+1,u.ang,1,1)   
 end
    
 if(u.hs>0.1)u.xs=-1
 if(u.hs<-0.1)u.xs=1
 
 spr(u.sp+u.ci+3,u.px+1,
 u.py-4,1,1,u.xs==1)  
 
 //place
 if u.fplace then
  outline_textb(u.fplace,
  u.x+3,u.y-8)
 end
 
 if dmwait>0 then return end
 
 if dmtype==1
 and u.place==#cars then
  spr(128+(time()*10)%4,
  u.px*4-u.x*3,u.py*2-u.y-8)
  return
 end
 
 //draw bomb
 if dmtype==2
 and u==bombc then
  spr(132+(time()*10)%4,
  u.px*4-u.x*3-2,u.py*2-u.y-8)
  return
 end
 
 //draw crown
 if dmtype==3
 and u.place==1 then
  spr(144+(time()*10)%4,
  u.px*4-u.x*3,u.py*2-u.y-8)
  return
 end
end
 
function upd_play()
 if rwait>0 then
  rwait-=1
  return
 end
 
 if lwait>0 then
  lwait-=1
 end
 
 if dmwait>0 then
  if(game_mode=="grounds")dmwait-=1
  if dmwait==0 then
   if dmtype==2 then
    bombc=cars[#cars]
   end 
  end 
 else
  dmtime-=1
 end
 
 //if everyone finished lines
 //destroy all and goto
 if #placc==#c_cars then
  if next_scene==nil then
   if game_mode=="grounds" then
    //reverse array
    reverse(placc)
   end
  

   next_scene=#milaps>1 and "scor" or "podi"
    
   nswait=60
  else
   nswait-=1
   if nswait<=0 then
    destroycars()
    if(#milaps<=1)scorensort()
    //prnt(#milaps)
    gotoscene(next_scene)
    next_scene=nil
   end
  end
 end
 
 if(hitinv>0)hitinv-=1
 
 if(#crsx>2)carorder()
 
 for i=1,#cars do
  cars[i].place=i
 end
 
 if dmtime<=0 then
  
  
  if dmtype==1 then
   local u=cars[#cars]
   
   add(placc,u.id+1)
    u.fplace=#cars

   del(cars,u)
   destroy(u)
  elseif dmtype==2 then
   local u=bombc
   add(placc,u.id+1)
    u.fplace=#cars
   
   del(cars,u)
   destroy(u)
   
   bombc=nil
  elseif dmtype==3 then
   
  end
  
  
  dmwait=30*#cars*2
  dmtime=30*#cars*2
  dmtype=dmtype%3+1
  
  if #cars==1 then
   dmtype=-1
   
   local u=cars[1]
   add(placc,u.id+1)
   u.fplace=1
   
   
  end
   
  
 end

 
 carcolcheck()
end


function carcolcheck()
//check collisions
 for i=1,#cars do
 
  local u=cars[i]
  for j=1,#cars do
  
   local co=cars[j]
   if not(co==u) then
   
    if boxd(u,co,8)then
     local ds=objdist(u,co)
     if ds<8 then
    
      local pd=objdir(u,co)
      mot_add(u,pd,-0.8)
      mot_add(co,pd,0.8)
      
      //if bumpy cars
--[[
      u.turn+=rndf(2)
      co.turn+=rndf(2)
      u.ang+=rndf(2)
      co.ang+=rndf(2)
      ]]--
      fspd(u,0.98)
      fspd(co,0.98)
      
      if(u.place<co.place)then
       snd(1)
      end
     
      if u==bombc  
      and hitinv<=0 then
      
       bombc=co
       hitinv=4
            
      end
      fspd(u,0.5)
     end//end if collides
    end//end if box collide
   end//end if not same obj
   
  end//end for i
 end//end for j
end


function drw_play()
 tic()
 map(3,3,xof+24,24,10,7)
 
 map(0,0,0,0,16,16)
 
 
 if game_mode=="grounds"
 and rwait<=0 then
  
  if dmwait>0 then
   local secs=tostr(flr(dmwait/30)).."\83"
  
  	outline_textb("standby",50,56)
  	outline_textb(secs,64-#secs*2,64)
  else
   local secs=tostr(flr(dmtime/30)).."\83"

   if dmtype<3 then
  	 outline_textb("\69\76\73\77\73\78\65\84\73\78\71",64-22,50)  
   end
   
   if dmtype>=0 then
    local txts={
     "last place!",
     "hot potato!",
     "huge crown!"
    }
    txts[0]="oops"
  	 outline_textb(txts[dmtype],64-#txts[dmtype]*2,56)
  	 outline_textb(secs,64-#secs*2,64)
   end
  end
 end
 
 
 local ssx=64-12
 local ssy=64-4
 if rwait>0 then
  spr(176,ssx,ssy,3,1)
  spr(179,ssx,ssy,3-flr(rwait/30),1)
  
  local tlx=tlaps.." laps"
  if game_mode=="grounds" then
   tlx="survive"
  elseif game_mode=="cup" then
   
   if rwait>60 then
    tlx="race "..mindex.."/"..#milaps   
    if mindex==#milaps then
     tlx="last race"
    end
   end  
  end
  
  
  if(rwait==1)lwait=60
  outline_textb(tlx,64-#tlx*2,64-12,0,7)
 end
 
 
 if game_mode=="cup"
 and lwait>0 
 and mlaps<tlaps then
  local tlx="lap "..(mlaps+1).." / "..tlaps
  if(mlaps+1==tlaps)tlx="final lap"
  outline_textb(tlx,64-#tlx*2,64-12,0,7)
 end
 
 if dmtype==-1 then
  return
 end
 
 local lcar=cars[#cars]
 if(bombc)lcar=bombc
 if(dmtype==3)lcar=cars[1]
 
end

function carcompare(acar,lcar)
 
 if acar.laps<lcar.laps then
  //if less laps: do
  return false
 elseif acar.laps==lcar.laps 
 and acar.curt<lcar.curt then
  //if = laps less curt: do
  return false
 elseif acar.laps==lcar.laps 
 and acar.curt==lcar.curt then
  //same laps and curt
  local dl0=pdist(lcar.x,lcar.y,crsx[lcar.curt],crsy[lcar.curt])
  local dl1=pdist(lcar.x,lcar.y,crsx[lcar.curt+1],crsy[lcar.curt+1])
  local da0=pdist(acar.x,acar.y,crsx[acar.curt],crsy[acar.curt])
  local da1=pdist(acar.x,acar.y,crsx[acar.curt+1],crsy[acar.curt+1])
 
  if acar.laps==lcar.laps
  and acar.curt==acar.curt 
  and da0+da1>dl0+dl1
  then
   return false
  end
 end//end if
 
 return true
end

function carorder()
 if #cars<2 then return end
 
 local a=cars

 for i=1,#a do
  local j = i
  
  while j > 1 
  and not carcompare(a[j-1],a[j]) do
   a[j],a[j-1] = a[j-1],a[j]
   j-=1
  end
 end
end



function addvfx(sp,x,y)
//   addvfx(140,u.x,u.y-4)
 local n=nobj(sp,x,y)
 n.as=0.1
 n.z=100
 n.animend=destroy
 n.step=function(u)
  u.vs+=0.25
  mot_add(u,rnd(360),0.1)
  fspd(u,0.96)
 end
 mot_add(n,90,2)
end

function snd(i)
 if(scene!="play")return
 if not sc then
  sc={}
  for i=0,4 do
   sc[i]=0
  end
  
 end

 local sci=sc[i] 
 sfx(i*4+sci)
 sci+=1
 if(sci>=4)sci=0
 sc[i]=sci
end
-->8
--news

function ini_news()
 
end

function upd_news()
 if btnp(5) then
  gotoscene("menu")
 end
end

function drw_news()
 tic()
 
 map(3,3,xof+24,24,10,7)

end
-->8
--char

chindex=1
ctrls={}//each ctrl linked to
        //id of car 
isrdy=false
tcars=8
c_cars={}
r_cars={}

p_chars={
 {1,"peng", 1, 
 "i'll win this time, "..
 "for sure!",
 "that was close!     "..
 "                    ",
 "i did it! hi mom!   "..
 "hi sis, i'm on tv!  "},
 
 {2,"fozz", 2, 
 "i'm the numero uno, "..
 "that's what i say",
 "heh, the first spot "..
 "is mine",
 "ha ha ha, drinks are"..
 "on me!!!"},
 
 {3,"cham", 5, 
 "aaaaaaaaaaaaaaaaaaa "..
 "aaa",
 " aaaaaaaaaaaaaaaaaaa"..
 "aaa",
 "aaaaaaaaaaaaaaaaaaaa"..
 "aaa"},
 
 {4,"peck", 8, 
 "you won't outwit me "..
 "chump",
 "it was a great race "..
 "and a better outcome",
 "i'm happy with this "..
 "results"},
 
 {5,"samy",12, 
 "is all about speed, "..
 "the road, and you",
 "the race isn't over "..
 "until i'm dead",
 "yeah!!, woo hoo!!   "..
 ""},
 
 {6,"pegy",14, 
 "no car has a chance "..
 "against this baby",
 "bwahaha!! what did i"..
 "tell you",
 "visit our website we"..
 "repair and build m.."},
 {7,"snek", 3,
 "you all gonna eat my"..
 "dust ★★★", 
 "aaand the victory 's"..
 "4 meeee >:3",
 "wha did i tell you? "..
 "hell yeahhh boyzz!! "},
 
 {8,"mick",13, 
 "well, i will prove  "..
 "all them wrong!",
 "a close competition,"..
 "all us did owr best",
 "and thanks to my mom"..
 "and family who su..."},
 
}

function ini_char()
 cars={}
 mindex=1
 iswait=false
 
 for i=1,8 do
  local acar=ncar(i,((i-1)%4)*16+36,48+flr((i-1)/4)*24-12)  
  
  acar.id=#cars
  acar.step=function(u)
   u.ang-=2.5
   u.xs=(u.ang>90 and u.ang<270) and 1 or -1
  end
  acar.draw=function(u)
   cardraw(u)
   if chindex==u.id then
    local pch=p_chars[u.id]
    chardialog(u.id,pch[4])
    
   end
  end
  
  c_cars[i]={
   id=i,
   score=0
  }
  
 end
end

function upd_char()
 local pc=#ctrls
 
 if iswait then
  for i=0,5 do
   if btnp(i,pc) 
   and #ctrls<tcars then
    iswait=false
    //chindex+=1
   end
  end
 end
 
 
  if btnp(4,pc) 
  and #ctrls<tcars then
   sfx(61)
   for i=1,#ctrls do
    if ctrls[i]==chindex then
     return
    end
   end
   add(ctrls,chindex-1)
   iswait=true
   return
  elseif btnp(4) then
   sfx(61)
   if isrdy then
    
    while #c_cars>tcars do
     local r=flr(rnd(#c_cars))+1
     local cc=c_cars[r]
     
     local isc=false
     for i=1,#ctrls do
      if ctrls[i]==cc.id-1 then
       isc=true
       break
      end
     end
     
     if not isc then
      del(c_cars,cc)
     end
    end
    
    shuffle(c_cars)
    foreach(cars, destroy)
    gotoscene("play")
   else
    isrdy=true
   end
   return
  end
 
  
 if(chindex>#cars)chindex-=#cars
 if(chindex<0)chindex+=#cars
 
 if btnp(5) then
  sfx(60)
  if isrdy then
   isrdy=false
   return
  else
   iswait=false 
  end

  if #ctrls>0 then
   chindex=ctrls[#ctrls]+1
   ctrls[#ctrls]=nil  
   return
  end
  
  gotoscene("menu")
  foreach(cars, destroy)
  return
 end
 
 if btnp(0,pc) then
  chindex-=1 sfx(62)
 elseif btnp(1,pc) then
  chindex+=1 sfx(62)
 elseif btnp(2,pc) then
  chindex-=4 sfx(62)
 elseif btnp(3,pc) then
  chindex+=4 sfx(62)
 end
 
 chindex=mid(1,chindex,#cars)
 
end

function drw_char()
 tic()
 
 map(3,3,xof+24,24,10,7)
end

function drwend_char()

 
 outline_textb(
 "character selection",26,16)
 
 local ach=cars[chindex]
 if ach and not iswait then
  outline_textb((#ctrls+1).."p",
  ach.x+1,
  ach.y-10+cit()*0.2)
 end
 
 for i=1,#ctrls do
  local ach=cars[ctrls[i]+1]
  outline_textb(i.."p",ach.x+1,ach.y+9)
 end
 
 if(#ctrls>0)then
  local astr= isrdy
   and "go! 🅾️"
   or  "ready? 🅾️"
   
  outline_textb(astr,
  120-#astr*4,118, 
  isrdy and 10 or 2,
  isrdy and 0 or 9)
  //isrdy and 10 or 4,
  //isrdy and  4 or 0)
 end
 
end

function chardraw(uid,txp,typ)
 //frame

 pal(13,4)
 pal(5,0)
 map(0, 0,txp+1,typ-4,3,3)
 pal()
 //thumbnail
 outline_sprite(190+uid*2,1,
 txp+5,typ-2,2,2)
end

function chardialog(uid,text)
 local txp=8
 local typ=86
 
 pal(13,9)
 map(0,10,txp,typ-2,14,4)

 chardraw(uid,txp,typ)
    
 //name and desc
 local pch=p_chars[uid]

 local ll=20
 local pch4=text or "--"
 local cou=flr(#pch4/ll)
 for i=0,cou do
  local astr=sub(
  pch4,i*ll+1,
  min(#pch4,(i+1)*ll))
     
  //outline_textb(
  print(
  astr,
  txp+25,typ+8+8*i,7)
 end

 outline_textb(
 pch[2],
 txp+25,typ-1,pch[3],7)

end
-->8
--scor

function ini_scor()
 reload()
 scorensort()
 
 
 for i=1,8 do
  local ccar=c_cars[i]
  local acar=ncar(ccar.id,16,2+i*9)  
  acar.id=ccar.id
  acar.p=i
  acar.step=nil
  acar.draw=function(u)
  
   local dcar=c_cars[u.p]
   local pch=p_chars[u.id]
  
   //map(3,0,u.x-3,u.y-16,5,3)
   
   local ptx=u.p.."."..pch[2]
   print(ptx,
   28,
   u.y,7)
  
   local stx=dcar.score..
   "(+"..(dcar.lscore)..")"
   print(stx,
   116-#stx*4,
   u.y,
   7)
  
   cardraw(u)
  end
 end
end

function scorensort()

//add scores
 for i=1,#placc do
  local ccar=nil
  for j=1,#c_cars do
   if placc[i]==c_cars[j].id then
    ccar=c_cars[j]
    break
   end
  end
  
  local nsc=#placc-i
  ccar.score+=nsc
  ccar.lscore=nsc
 end
 
 //order c_chars
 local a=c_cars
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1].score < a[j].score do
   a[j],a[j-1] = a[j-1],a[j]
   j-=1
  end
 end
end

function upd_scor()
 //on going out, destroy cars
 //again
 if btnp(4) then
  if game_mode=="cup" then
   if mindex<#milaps then
    mindex+=1  
    gotoscene("play")
   else
    //goto podium
    gotoscene("podi")
   end
  end
  
  return
 end
end

function drw_scor()
 tic()
 
 local cc=c_cars[1]
 local ccid=cc.id
 local tex=p_chars[ccid][5]
 chardialog(ccid,
 tex)
 
 local astr="next 🅾️"
 outline_textb(
 astr,120-#astr*4,118,10,0)
end
-->8
--podi
function ini_podi()
 reload()
 destroycars()
 
 //add cars on podium
 local pxs={64,40,88}
 local pys={40,48,52}
 
 
 for i=1,min(#placc,3) do
  local ccar=c_cars[i]
  local acar=ncar(placc[i],
  pxs[i]-4,
  pys[i]-4)
  acar.step=function(u)
   u.ang-=2.5
  end
  acar.draw=function(u)
   cardraw(u)
   local pvs={"1\83\84",
              "2\78\68",
              "3\82\68"}
   outline_textb(pvs[i],           
   u.x-1,u.y+10)
  end
  
 end
end

function upd_podi()
 if btnp(4) then
  destroycars()
  gotoscene("menu")
 end
end

function drw_podi()
 tic(true)
 
 local astr="quit 🅾️"
 outline_textb(
 astr,64-#astr*2,112,7,0)
 
 local ct="congratulations!"
 for i=1,#ct do
  local tc=sub(ct,i,i)
  outline_textb(tc,
  64-#ct*3-4+i*6,
  12+flr(sin(time()+i/12)+0.5),
  7,2)
 end
 
 local pxs={64,40,88}
 local pys={40,48,52}
 local cfl={10,4,13}
 local cbg={9,2,1}
 
 for iv=1,3 do
  local i=4-iv
  rectfill(pxs[i]-12,pys[i],
           pxs[i]+12,128,
           cbg[i])
  rectfill(pxs[i]-12,pys[i]-2,
           pxs[i]+12,pys[i]+6,
           cfl[i])
 end
 
 local chid=placc[1]
 if chid then
  local pch=p_chars[chid]
  chardialog(chid,pch[6])
 end    
end

-->8
--prac
pindex=1


function ini_prac()
 pindex=1
 
 maplv=1
 tlaps=10
 tcars=8
end


function upd_prac()
 if(btnp(2))pindex-=1 sfx(62)
 if(btnp(3))pindex+=1 sfx(62)
 
 if btnp(0) then
   sfx(62)
  if pindex==1 then
   maplv-=1
  elseif pindex==2 then
   tlaps-=1
  elseif pindex==3 then
   tcars-=1
  end
  
 elseif btnp(1) then
   sfx(62)
  if pindex==1 then
   maplv+=1
  elseif pindex==2 then
   tlaps+=1
  elseif pindex==3 then
   tcars+=1
  end
 end
 
 maplv=mid(1,maplv,7)
 tlaps=mid(1,tlaps,20)
 tcars=mid(1,tcars,8)
 pindex=mid(1,pindex,3)
 
 if btnp(4) then
  sfx(61)
  milaps={maplv}
  game_mode="cup"
  gotoscene("char")
 end
 
 if btnp(5) then
  sfx(60)
  gotoscene("menu")
 end
end

function drw_prac()
 tic(true)
 
 local strs={
  "map       "..maplv,
  "laps     "..(tlaps<10 and " " or "")..tlaps,
  "cars      "..tcars
 }
 
 for i=0,15 do
  for j=0,15 do
   local s=mget(i+maplv*16,j)
   local ss=4
   local ox=32
   local oy=48
   if(s>=112 and s<=127)s=80
   if s!=0 then
    sspr((s%16)*8,8*flr(s/16),
         8,8,
         i*ss+ox,j*ss+oy,ss,ss)
   end
  end
 end
 
 for i=1,3 do
  local tt=strs[i]
  outline_textb(tt,64-#tt*2,8+i*8)
  if i==pindex then
   spr(182,8*8.5+cit()/2-2,8+i*8-1)
   spr(183,8*11-cit()/2+2,8+i*8-1)
  end
 end
 
 
 
end


__gfx__
00000000000000000000000000000000077110000000000000000000000000000000000000000000000000000000000090004000000000000000000090004000
000000009999800002888222011001107557114907711000077110000111100000000000eeeee0000e2222260110011049999400900040004999994049999900
00700700a21122a00288822201100110755719907557114975571100751111000000000074884e700e2222260110011092299900499994007229990072274400
00077000a11112809288888200000000177114107557199075571999115714000000000078888ee00e2222260000000072274400922999009227440092294400
00077000a11112809288888200000000111111991771141017711444111119990000000078888ee00e2222260000000092299990722744009999922099999220
00700700a21122a00288822201100110011110001111119911111199111114990000000074884e700e2222260110011099999220922999909999999099999990
000000009999800002888222011001100000000001111000011110000111100000000000eeeee0000e2222260110011009999900999992200999990009999900
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999000000000000000000
00000000000000000000000000000000ddddd0000000000000000000ddddd0000000000000000000000000001110011100008888000000000000000000088880
00000000bbbbb00033ccccc301100110d11ddd00ddddd000ddddd000d11ddd00000000000faaaa00049999401110011100888888000088880088888800888888
00000000c1113b7033ccccc3011001101111ddd0d11ddd00d11ddd001d11dd0000000000f422477002fff99211100111008888800088888808888888077c8888
00000000c1111bb033ccccc3000000001d11dd101111ddd011d1dd001111ddd0000000009222277002fff99200000000077c11000088888008888880077c1100
00000000c1111bb033ccccc3000000005115511011d1dd101111ddd051155d50000000009222277002fff99200000000077c2990077c1100077c110000222990
00000000c1113b7033ccccc301100110055555005115511051155d500555550000000000f422477002fff9921110011100222940077c29900022299000222940
00000000bbbbb00033ccccc30110011000550000055555000555550000550000000000000faaaa00049999401110011100222200002229400022294000222200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110011100000000002222000000000000000000
000000000000000000000000111001110770dd00000000000000000000770dd0000000000000eee0000000000000000000000000000000000000000000000000
00000000ccddc000ddccccc111100111077777d00770dd0000770dd0077777d0000000000001eeee00000000000000000eeeeee00000000000000000222eee22
00000000cd11dc70ddddddc11110011101117710077777d0077777d0011177100000000000dd11ee0222280000000000222eee220eeeeee000000000222eee22
00000000c1111dc0ddddddc100000000711177100111771007777770711177100000000088ddd1981122281111000011222eee22222eee220eeeeee0e1ee8880
00000000c1111dc0ddddddc100000000777c7ddd7111771071117710777c7ddd0000000088ddd1881122281111000011eeee888e222eee22222e8882eee82828
00000000cd11dc70ddddddc11110011177777777777c7ddd71117ddd777777770000000000dd11ee0222280000000000eee82828eeee888e22282828eee88888
00000000ccddc000ddccccc11110011107777770777777777777777707777770000000000001eeee00000000000000000ee88888eee82828eee888880eeeeee0
0000000000000000000000001110011100000000077777700777777000000000000000000000eee00000000000000000000000000ee888880eeeeee000000000
0000000000000000000000000000000011000000000000000000000011000000000000000000000000000000000000000000dd00000000000000000000000000
000000000001110000000000000000001113bbb011000000110000001131bbb000000000000000000000000000000000ddd7770e0000dd000000000000000000
0000000001111cd001111c70000000001111bbbb1113bbb01133bbb0111a3bbb00000000000288200000000000000000dd111770ddd7770e0007770000077700
0000000001551cccc1111cc111000011111a1bbb1111bbbb1113bbbb111a1bbb000000000911188208118822110000110d611770dd1117700d11177e0d77777e
0000000001551cccc1111cc111000011011a13bb111a1bbb11113bbb011a13bb00000000091118820811882211000011007777000d611770dd611770dd111770
0000000001111cd001111c700000000003111133011a13bb011a13bb03111133000000000002882000000000000000000017710000777700dd777700dd677700
00000000000111000000000000000000003333300311113303111133003333300000000000000000000000000000000000011000001771000017710000177100
00000000000000000000000000000000000300000033333000333330000300000000000000000000000000000000000000000000000110000001100000011000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555000000000000000000000000000000000000000055555555555555555555555555555555555555555555555500000000000000000001dd5555dd1000
55555555000000000000000000000000000000000000000055555555555dd5555555555555555dd55dd5555550055555000000000000000000011dd55dd11000
55555555000000000000000000000000000000000000000055555555555dd555555555555555ddd55ddd5555555555550000000000000000000011dddd110000
55555555000000000000000000000000000000000000000055555555555dd5555dddddd5555ddd5555ddd5555555500500000000000000000000011dd1100000
55555555000000000000000000000000000000000000000055555555555dd5555dddddd555ddd555555ddd55555555550000000dd00000000000001111000000
55555555000000000000000000000000000000000000000055555555555dd555555555555ddd55555555ddd550055555000000dddd0000000000000110000000
55555555000000000000000000000000000000000000000055555555555dd555555555555dd5555555555dd55555555500000dd11dd000000000000000000000
5555555500000000000000000000000000000000000000005555555555555555555555555555555555555555555550050000dd1551dd00000000000000000000
00000000555555555555555555555555551dd000000dd1550000000000000000000dd555555dd000000dd555555dd00055555555000000005555555555555555
000000005551155555555555555555555551dd0000dd15550000000000000000000dd555555dd000000dd555555dd00055555555000000005557775551117775
0000000055111155555555555555555555551dd00dd155550000000000000000000dd555555dd000000dd555555dd00055555555000000005555575551117775
00000000511111155555555dd5555555555551dddd1555550000dddddddd0000000dddddddddd000000dd555555dd000dddddddddddddddd5555575551117775
0000000051111115555555dddd5555555555551dd1555555000dddddddddd0000001dddddddd1000000dd555555dd000dddddddddddddddd5555575557771115
000000005511115555555dd11dd555555555555115555555000dd111111dd0000001111111111000000dd555555dd00011111111111111115555575557771115
00000000555115555555dd1111dd55555555555555555555000dd555555dd0000000111111110000000dd555555dd00011111111555555555557775557771115
0000000055555555555dd110011dd5555555555555555555000dd555555dd0000000000000000000000dd555555dd00000000000555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55550555555000555550005555505055555000555550555555500055555000555550005550550005505550555055000550550005505505055055000550550005
55500555555550555555505555505055555055555550555555555055555050555550505500550505005500550055550500555505005505050055055500550555
55550555555000555555005555500055555000555550005555555055555000555550005550550505505550555055000550555005505500055055000550550005
55550555555055555555505555555055555550555550505555555055555050555555505550550505505550555055055550555505505555055055550550550505
55500055555000555550005555555055555000555550005555555055555000555555505500050005000500050005000500050005000555050005000500050005
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000880000000000000000000000ee0000000000008888aa00011a000000000000000000000000000000000000000000000000000000000000000000000000000
000880000000000000000000000ee000002200008888880001111000001100000000000000000000000000000000000000000000000000000000000000000000
000880000008800000000000000ee000022220008888880001111000011110000000000000000000000000000000000000000000000000000000000000000000
000880000008800000222200000ee000022220008888880000110000011110000000000000000000000000000000000000000000000000000000000000000000
0000000000000000002222000000000000220000888888000000000000110000000000000000000000000000079077aa000007aaa900007aaaa00079077aa000
00008800000088000002222000000000000000000888800000000000000000000000000000000000000000000aa7aaaaa0007aaaaa9007aaaaaa00aa7aaaaa00
0000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000aaaaaaaaa0aaa00aaa0aaaee9aaa0aaaaaaaaa0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaae0aaaa0aa7aaaae0aaee099aa0aaae0aaaa0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa000aaa0aaaaaae00aa90009aa0aaa000aaa0
0a0aa0e0090a90e00909e0e0090790e0000000000000000000000000000000000000000000000000000000000aaa000aaa0aa9000000aa99099aa0aaa000aaa0
0aa999900aa999900999999007aa9990000000000000000000000000000000000000000000000000000000000aaa000aaa0aaa900aa0aaa9997ae0aaa000aaa0
0a9999900aa999900a9999900aaa9990000000000000000000000000000000000000000000000000000000000aaa000aae00aaaaaae00aaaaaaa00aaa000aae0
0aa999e00aaa99e00aaa99e009aaa9e00000000000000000000000000000000000000000000000000000000000ae000ae0000aaaae0000aaaae0000ae000ae00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000079077a00007aa90aa0007aaaa00007aaa90000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaa007aaaa9aa007aaa7aa007aaaaa9000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaae0aaae9aaaa0aaae9aae0aaa00aaa000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa9ae00aae00aaaa0aae00aa90aa7aaaae000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa00000aa900aaaa0aa9000000aaaaaae0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa00000aaa00aaaa0aa9000000aa900000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa00000aaaaa7aaa0aaa997aa0aaa900aa000
000000000000000000000000000000000000000000000000000900000000900001010101000000000000000000aaa000000aaaaa9aa00aaaaaae00aaaaaae000
001111000011110000111100008888000099990000bbbb000099000000009900101010100000000000000000000ae0000000aaae0ae000aaaae0000aaaae0000
01111110011111100111111008a8888009a999900babbbb009990000000099900101010109999990000000000000000000000000000000000000000000000000
01111110011111100111111008888880099999900bbbbbb0999900000000999910101010098888e0000000000000000000000000000000000000000000000000
01111110011111100111111008888880099999900bbbbbb019990000000099910101010101888e10000000000000000000000000000000000000000000000000
01111110011111100111111008888880099999900bbbbbb00199000000009910101010100018e100000000000000000000000000000000000000000000000000
001111000011110000111100008888000099990000bbbb0000190000000091000101010100011000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000010000000010001010101000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000999000004440000000000000000000000000088888880000777770006666600000000000000000011003bbbbbb00000000000000000000
0000000000000000009999999999400000ddddddd0000000000008888888888007777770066666600000ee0000ee0000011133bbbbbbb0000000000000000000
0007777111000000009999999999900000ddddddddd0000000088888888888800677776777d66600000eeeeeeeee00000111133bbbbbbb00000000000dd00000
0071117711100990009999999999900000ddddddddddd00000888888888888800d611177777d10000222222eeee2222001111113bbbbbbb000ddd000dddd0ee0
07111117711199900097222999999000001111dddddddd00002888888888888000111117777111000222222eeee22220011119a13bbbbbb00ddddd6777777ee0
071111177119aaa000772222444440000111111dddddddd000777c288888888000111007777001000222221eeee1222001119a7a1bbbbbb00dddd11117777700
07111117719aaa0000ff22224999400001111111ddddddd0077777c12888880000677cc7777cc000001111e88888211001119aaa13bbbbb00ddd57c111777700
0771117779aaa00000fff22f9992222001171111ddddddd0077777c111100000077777777dddddd000eeee888888880003119aaa13bbbb3000dd771151777700
01777777119aa000009ffff99999229001111111ddddddd0077777c229999000077777777dddddd00eeee8888181888003311991113bb3100000776116777600
011777711119aa00009999999999999001111115ddd5dd5000777c22299490000777777777dddd700eeee88812812880033bb111111bb1100000777777776000
011111111111990000999999999944900011115dddddddd0000222222499000007777777777777700eeee888228228800333bbbbbbbbbbb00000777777760000
001111111110000000099999999444000055555555555000000222222220000000777777776666000eeee28888888800033333bbbbbbbb000000077777600000
0001111111000000000009999444400000055555555000000002222222200000000077776666600000ee22211111110000333333000000000000077770000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd888888dddddddddddddddddddddddddddddddd11111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd8888888ddddddddddddddddddddddddddddddddd1111
111dddddddddddddddddddddddddddddddd7711ddddddddddddddddddddddddddddddddddddddddddddd888888ddddddddddddddddddddddddddddddddddd111
111dddd555555555555555555555555555755711555555555555555555555555555555555555555555552771995555555555555555555555555555555dddd111
111ddd55555555555555555555555555557557199955555555555555555555555555555555555555555522229455555555555555555555555555555555ddd111
111ddd55555555555555555555555555551771144455555555555555555555555555555555555555555592222455555555555555555555555555555555ddd111
111ddd55555555555555555555555555551111119955555550007775555555555555555555555555555592224945555555555555555555555555555555ddd111
111ddd5555555555555555555555555555a111198255555550007775555555555555555555555555555942222995555555555555555555555555555555ddd111
111ddd5555555555555555555555555555a111198255555550007775555555555555555555555555555492229995555555555555555555555555555555ddd111
111ddd5555555555555555555555555555a21129a2555555577700055555555555555555555555555555299499f5555555555555555555555555555555ddd111
111ddd555555555555555555555555555599998882555555577700055555555555555555555555555555124449f5555555555555555555555555555555ddd111
111ddd55555555555555555555555555555288888255555557770005555555555555555555555555555551549ff5555555555555555555555555555555ddd111
111ddd55555555555555555555555555555115511555555555555555555555555555555555555ddddd5555511555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555d11ddd555555555555555555533535555555555555555ddd111
111ddd5555555555555555555555555555555555555555555000777555555555555555555555511d1dd5555555555555555553bbbb3555555555555555ddd111
111ddd555555555555555555555555555555555555555555500077755555555555555555499999411ddd55555555555555555b13bbb355555555555555ddd111
111ddd5555555555555555555555555555555555555555555000777555555555555555557229991155d575555555555555555b193bbb55555555555555ddd111
111ddd55555555555555555555555555555555555555555557770005555555555555555592274455555b35555555555555552b3993bb55555555555555ddd111
111ddd5555555555555555555555555555555555555555555777000555555555555555559999922111b3355555555555555513b311bb55555555555555ddd111
111ddd5555555555555555555555555555555555555555555777000555555555555555559999999bbb373555555555555555513bbbb355555555555555ddd111
111ddd555555555555555555555555555555555555555555555555555555555555555555599999f7133335555555555eeeeee5b7777555555555555555ddd111
111ddd555555555555555555555555555555555555555555555555555555555555555555788888ef5377b665555555222e888271177155555555555555ddd111
111ddd55555555555555555555555555555555555555555550007775555555555555555574888ef2577777655555552228282771177155555555555555ddd111
111ddd555555555555555555555555555555555555555555500077755555555555555555eeee4f7e57dd77d5555555eee8887777772755555555555555ddd111
111ddd5555555555555555555555555555555555555555555000777555555555555555555e22ff2e77dd76665555555eeeee7771111155555555555555ddd111
111ddd555555555555555555555555555555555555555555577700055555555555555555511522ee777d76665555554777667711111155555555555555ddd111
111ddd555555555555555555555555555555555555555555577700055555555555555555555551157777776755555556e662411111cc55555555555555ddd111
111ddd555555555555555555555555555555555555555555577700055555555555555555555555555677777c55555555eee455171ccc55555555555555ddd111
111ddd555555555555555555555555555555555555555555555555555555555555555555555555555c666661c5555555eee4555c1ccc55555555555555ddd111
111ddd5555555555555555555555555555555555555555555555555555555555555555555555555551c6661cc5555555555155555dcd55555555555555ddd111
111ddd5555555555555555555555555555555555555555555555555555555555555555555555555555cc66cc155555555555555555d555555555555555ddd111
111ddd555555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddd1111111ddd555555555555555555555555555555ddd111
111ddd55555555555555555555555555555ddddddddddddddddddddddddddddddddddddddddddddddd1111d11dddd55555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddddddddddddddddddddddddddddddddddddddddddddddddd11ddddddddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555dddd1111111111111111111111111111111111111111111111111111dddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111111111111111111111111111111111111111111111111111111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111111111111111111111111111111111111111111111111111111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111555555555555555555555555555555555555555555555555111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111111111111111111111111111111111111111111111111111111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555ddd111111111111111111111111111111111111111111111111111111ddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555dddd1111111111111111111111111111111111111111111111111111dddd5555555555555555555555555555ddd111
111ddd5555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5555555555555555555555555555ddd111
111ddd55555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555555555555555555555555555ddd111
111ddd555555555555555555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddd555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111ddd55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd111
111dddd555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddd111
111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
11111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010014120c0a00010101010014120c0a001e0a0c121414120c0a04020810010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
666d67666d6d6d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6a506b6a5050506b0000000000000000000000000000000000000000000000005c6d6d6d6d6d6d6d6d6d6d6d6d6d6d5d666d6d6d6d6d6d6d6d6d6d5d000000005c6d6d6d6d6d6d6d6d6d6d6d6d6d6d5d5c6d6d6d6d6d6d6d6d5d0000000000005c6d6d6d6d6d6d6d6d6d6d6d6d6d5d005c6d6d6d6d6d6d6d6d6d6d6d6d6d5d00
686c69686c6c6c6900000000000000005c6d6d6d6d6d6d6d6d6d6d6d6d6d6d5d6a6e7b6e7c6e6f50505050507d50506b6a6e506e506e6f505050506b000000006a6e506e506e6f50505050505050506b6a6e506e506e6f5050645d00000000006a6e506e506e6f50505050505050645d6a6e506e506e6f50505050505050645d
000000000000000000000000000000006a6e506e506e6f50505050505050506b6a506e506e506f70505050505050506b6a506e7e6e506f50507f506b000000006a506e506e7c6f50707d50715050506b6a506e7b6e7c6f50707d6b00000000006a506e7d6e7e6f50707f50715050506b6a506e7b6e7c6f5070505071507d506b
000000666d6d6d6d6d6d6d6d670000006a506e506e7a6f50707b50505050506b6a6e506e506e6f50505050715050506b6a6e7d6e506e6f507050506b000000006a6e506e506e6f50505050505050506b6a6e506e506e6f5050506b00000000006a6e506e506e6f50505050505050506b6a6e506e506e6f50505050505050506b
0000006a56565656565656566b0000006a6e506e506e6f50505050507150506b6a507a50626c6c6c6c6c6c635050506b6a507c50626c6c635071506b000000006a50507b626c6c6c6c6c6c635072506b6a5050505062635071506b00000000006a505050626c6c6c6c6c6c635072506b6a507a50626c6c6c6c6c6c635072506b
0000006a56565656565656566b0000006a505079626c6c6c6c6c6c635072506b6a505050645d00000000006a5072506b6a507b50646d6d65505050646d6d6d5d6a5050506b0000000000006a5050506b6a50507a506465505050646d6d5d00006a5050506b0000000000006a5050506b6a507950645d000000005c655050506b
0000006a56565656565656566b0000006a5050506b0000000000006a5050506b6a50507950645d000000006a5050506b6a50507a50505057505050575050506b6a5050506b0000000000006a5050506b6a505050505750725050575050645d006a507c50646d6d6d6d6d6d655050506b6a50507850645d00005c65507350506b
0000006a56565656565656566b0000006a5050506b0000000000006a5050506b5e6350505050645d0000006a5073506b6a50505050507957507850577750506b6a507a506b0000000000006a5073506b5e63505079575050785057775050645d6a505050595050505050505a5050506b5e6350507750645d5c6550505050625f
000000686c6c6c6c6c6c6c6c690000006a505078646d6d6d6d6d6d655073506b005e6350785050645d00006a5050506b6a50505050505057507250575050506b6a5050506b0000000000006a5050506b005e635050575050505057505050506b5e635059507b50747a7350505a50625f005e6350505050616150745050625f00
0000666d6d6d6d6d6d6d6d6d6d6700006a50505050505050505050505050506b00005e6350507750645d006a5074506b5e6c6c6c6c6c6c63505050615076506b6a5050506b0000000000006a5050506b00005e6c6c635073506263505050506b005e6c635050505050505050626c5f0000005e635076506161505050625f0000
00006a505050505050505050506b00006a50505077505076505075745050506b0000005e6350505050646d655050506b000000000000006a505050615050506b6a507950646d6d6d6d6d6d655074506b00000000006a5050506465507650506b0000006a50755061615079506b0000000000006a50505050507550506b000000
00006a505050505050505050506b00006a50505050505050505050505050506b000000005e635050507650505050506b000000000000006a507350505075506b6a50505050505050505050505050506b00000000006a5050745050505050506b0000006a50505050505050786b0000000000006a50505050505050506b000000
0000686c6c6c6c6c6c6c6c6c6c6900005e6c6c6c6c6c6c6c6c6c6c6c6c6c6c5f00000000005e6350505050755050506b000000000000006a505050745050506b6a50505078505077505076755050506b00000000005e6350505075505050625f0000006a50505050505050506b0000000000005e63505050505050625f000000
00000000000000000000000000000000000000000000000000000000000000000000000000005e63505050505050506b000000000000006a505050505050506b6a50505050505050505050505050506b0000000000005e635050505050625f000000005e63765050775050625f000000000000005e6c6c6c6c6c6c5f00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000005e6c6c6c6c6c6c6c5f000000000000005e6c6c6c6c6c6c6c5f5e6c6c6c6c6c6c6c6c6c6c6c6c6c6c5f000000000000005e6c6c6c6c6c5f0000000000005e6c6c6c6c6c6c5f0000000000000000000000000000000000000000
__sfx__
000100001b0101b0101b0101b0101b0101b0101b0101b0101b0101b0101b0101b0101b0101b0101b010210002100021000257002700027000270001e0101a0101a0101e0101e0101e0101e0101e0101e0101e010
000100001c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c010210002100021000257002700027000270001e0101e0101e0101e0101e0101e0101e0101e0101e0101e010
000100001e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101e0101d4001e4001e400200002100020000200002000020000200002001020010200102001020010200102001020010200102001020010
000100002002020020200202002020020200202002020020200202002020020200202002020020200201c0201c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c0101c01000000
000200001601016010160101601016010160100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001701017010170101701017010170100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001901019010190101901019010190100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c0101c0101c0101c0101c0101c0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001211012110121101211012110121101211012110121101211012110131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001411014110141101411014110141101411014110141101411014110131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001611016110161101611016110161101611016110161101611016110171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e1101e1101e1101e1101e1101e1101e1101e1101e1101e1101e110131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000b5500b5500b5500b5500000000000000000000000000000000000000000000000000000000000000b5500b5500b5500b550000000000000000000000000000000000000000000000000000000000000
000400000c5500c5500c5500c5500000000000000000000000000000000000000000000000000000000000000b5500b5500b5500b550000000000000000000000000000000000000000000000000000000000000
00040000095500955009550095500000000000000000000000000000000000000000000000000000000000000b5500b5500b5500b550000000000000000000000000000000000000000000000000000000000000
000400000e5500e5500e5500e55000000000000000000000000000000000000000000000000000000000000010550105501055010550000000000000000000000000000000000000000000000000000000000000
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
011a00000173401025117341102512734120250873408025127341202501734010251173411025087340802505734050250d7340d025147341402506734060250873408025127341202511734110250d7340d025
010d00200c0331b51119515195152071220712145151451518615317151d5151d515125050c03314515145150c0330150519515195150d517205161451514515186153171520515205150d5110c033145150c033
011a00000a7340a02511734110250d7340d02505734050250673406025147341402511734110250d7340d0250a7340a02511734110250d7340d02508734080250373403025127341202511734110250d7340d025
010d00200c0331b511295122951220712207122c5102c51018615315143151531514295150c03329515295150c0330150525515255150d517205162051520515186153171520515205150d5110c033145150c033
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5001e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50030011
0114001800140005351c7341c725247342472505140055352173421725287342872504140045351f7341f725247342472502140025351d7341d72524734247250000000000000000000000000000000000000000
011400180c043287252b0152f72534015377253061528725290152d72530015377250c0432f7253001534725370153c725306152b7252d01532725370153b7250000000000000000000000000000000000000000
0114001809140095351f7341f7252473424725091400953518734187251f7341f72505140055351f7341f7252473424725051400553518734187251f7341f7250000000000000000000000000000000000000000
0114001802140025351f7341f725247342472504140045351f7341f725247342472505140055352b7242b715307243071507140075352b7242b71534724347150000000000000000000000000000000000000000
01040000000150001502015030150401505015060150701508015090150a0150b0150d0150e0150f0151101517005000050000500005000050000500005000050000500005000050000500005000050000500005
0001000034013307252b01526725210151c725000052e7252c0152972526015257250c003287052900530705370053c70530605287052900530705370053c7050000000000000000000000000000000000000000
0001000021013287252b0152f725340153772500005287252901530725370153c7250c003287052900530705370053c70530605287052900530705370053c7050000000000000000000000000000000000000000
0001000026013260152601526015260153101531015310153101531015370053c7050c0032f7053000534705370053c705306052b7052d00532705370053b7050000000000000000000000000000000000000000
000200000713008130081300913009130131301413013130141301d5001d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00014344
00 00014344
01 00014344
00 00014344
00 02034344
02 02034344
00 04424344
00 04424344
00 04054344
00 04054344
01 04054344
00 04054344
00 06074344
02 08094344
01 0a0b4344
00 0c0d4344
00 0a0e4344
02 0c0e4344
00 10424344
01 104f4344
00 104f4344
00 10114344
00 12114344
02 12134344
01 14154344
00 14154344
00 16154344
00 16154344
00 18174344
02 16174344
00 19424344
01 191a4344
00 191a4344
00 1b1a4344
00 191c4344
02 1b1c4344
01 1d1e4344
00 1d1f4344
00 1d1e4344
00 1d1f4344
00 21204344
02 1d224344
00 27424344
01 24234344
00 24234344
02 26254344
01 28294344
03 2a2b4344
01 2d304344
00 2e304344
00 2d304344
00 2e304344
00 2d2c4344
00 2d2c4344
02 2e2f4344
01 31324344
00 31324344
00 33344344
02 35364344
01 3738433f
00 3738433f
00 393b433f
00 393c433f
02 3a3d433f

