pico-8 cartridge // http://www.pico-8.com
version 35
__lua__

-- oop
-- flicker
-- inertia
-- blending

pal(1, 1 + 128, 1)
poke(24365, 1)

function circfillp(x, y, w, c, p)
	fillp(p)
	circfill(x, y, w, c)
end

function mag(x, y)
	return sqrt(x*x + y*y)
end

function _init()
 lights = {}
	add(lights, {x = 48, y = 48, w = 16})
	add(lights, {x = 80, y = 80, w = 24})
	cursor = {}
	cursor.x = 0
	cursor.y = 0
	cursor.pressed = 0
	cursor.light = nil
	flicker = {0.9, 0.95, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.05, 1.1}
end

function _update()
	cursor.x = stat(32)
	cursor.y = stat(33)
	cursor.pressed = stat(34)
	for light in all(lights) do
		if cursor.light == nil and cursor.pressed == 1 then
		 local a = mag(cursor.x, cursor.y)
			local b = mag(light.x, light.y)
			if abs(a - b) < 3 then
			 cursor.light = light
				cursor.x = light.x
				cursor.y = light.y
			end
		elseif cursor.pressed == 0 then
			cursor.light = nil
		end
		if cursor.light != nil then
			cursor.light.x = cursor.x
			cursor.light.y = cursor.y
		end
	end
end

function _draw()
	cls()
	for light in all(lights) do
		light.f = light.w * rnd(flicker)
	end
	for light in all(lights) do
		circfillp(light.x, light.y, light.f, 1, ▥)
	end
	for light in all(lights) do
		circfillp(light.x, light.y, 8, 0)
	end
	for light in all(lights) do
		circfillp(light.x, light.y, 8, 5, ▥)
	end
	for light in all(lights) do
		circfillp(light.x, light.y, 2, 7)
	end
	pset(cursor.x, cursor.y, 7)
	debug()
end

function debug()
	color(11)
	print("m.x:"..cursor.x)
	print("m.y:"..cursor.y)
	print("m.p:"..tonum(cursor.pressed))
	print("fps:"..stat(7))
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
