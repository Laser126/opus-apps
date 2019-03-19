local Array   = require('array')
local kinetic = require('neural.kinetic')
local Point   = require('point')

local device = _G.device
local os     = _G.os

local pos = { x = 0, y = 0, z = 0 }
local sensor = device['plethora:sensor'] or error('Missing sensor')
local intro  = device['plethora:introspection'] or error('Missing introspection module')

local ownerId = intro.getMetaOwner().id

local function findTargets()
	local l = Array.filter(sensor.sense(), function(a)
    return math.abs(a.motionY) > 0 and ownerId ~= a.id
  end)
  table.sort(l, function(e1, e2)
		return Point.distance(e1, pos) < Point.distance(e2, pos)
	end)

  return l[1]
end

local last
local count = 0

while true do
  local target = findTargets()
  if target and (not last or Point.distance(last, target) > .2) then
    last = target
    kinetic.lookAt(target)
    count = 0
    os.sleep(0)
  else
    count = count + 1
    if count > 50 or not target then
      kinetic.lookAt({
        x = math.random(-10, 10),
        y = math.random(-10, 10),
        z = math.random(-10, 10)
      })
      os.sleep(3)
    else
      os.sleep(.1)
    end
  end
end