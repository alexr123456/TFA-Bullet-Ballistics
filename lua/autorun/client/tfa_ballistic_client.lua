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
