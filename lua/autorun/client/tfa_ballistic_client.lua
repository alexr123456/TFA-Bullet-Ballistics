local function genOrderedTbl(str, min, max)
	if not min then min = 1 end
	if not max then
		max = min
		min = 1
	end
	local tbl = {}
	for i=min, max do
		table.insert(tbl, str:format(i))
	end
	return tbl
end

local subsonicsounds = genOrderedTbl("ballistics/subsonic/%i.wav", 27)
local supersonicsounds = genOrderedTbl("ballistics/supersonic/%i.wav", 12)

sound.Add( {
	name = "TFA_BALLISTICS.Subsonic",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 100,
	pitch = { 95, 110 },
	sound = subsonicsounds
} )

sound.Add( {
	name = "TFA_BALLISTICS.Supersonic",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 100,
	pitch = { 95, 110 },
	sound = supersonicsounds
} )

net.Receive( "TFA_BALLISTICS_DoImpact", function ()
      local weapon = net.ReadEntity()
      local hitpos = net.ReadVector()
      local hitnormal = net.ReadVector()
      local mattype = net.ReadInt( 32 )
      if weapon.ImpactEffectFunc then
            weapon:ImpactEffectFunc( hitpos, hitnormal, mattype )
      end
end)

net.Receive( "TFA_BALLISTICS_StopParticles", function ()
      local ent = net.ReadEntity()
      ent:StopParticles()
end)

net.Receive( "TFA_BALLISTICS_SendWindSpeed", function ()
      local windspeed = net.ReadInt( 32 )
      TFA_BALLISTICS.WindSpeed = windspeed
end)
