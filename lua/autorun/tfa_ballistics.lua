if SERVER then
      util.AddNetworkString( "TFA_BALLISTICS_DoImpact" )
      util.AddNetworkString( "TFA_BALLISTICS_AddBullet" )
      util.AddNetworkString( "TFA_BALLISTICS_SendWindSpeed" )
end

game.AddParticles( "particles/tfa_ballistics/dax_bullettrails.pcf" )

PrecacheParticleSystem( "dax_bullettrail2" )
PrecacheParticleSystem( "dax_bullettrail2_red" )
PrecacheParticleSystem( "dax_bullettrail2_green" )
PrecacheParticleSystem( "dax_bullettrail3" )
PrecacheParticleSystem( "dax_bullettrail3_red" )
PrecacheParticleSystem( "dax_bullettrail3_green" )

TFA_BALLISTICS = {}

TFA_BALLISTICS.Bullets = {}

if SERVER then
      TFA_BALLISTICS.Wind = {}

      TFA_BALLISTICS.Wind.P = math.Rand( 0, 360 )
      TFA_BALLISTICS.Wind.Y = math.Rand( 0, 360 )
      TFA_BALLISTICS.Wind.R = math.Rand( 0, 360 )

      TFA_BALLISTICS.Wind = Angle( TFA_BALLISTICS.Wind.P, TFA_BALLISTICS.Wind.Y, TFA_BALLISTICS.Wind.R )
      TFA_BALLISTICS.WindApproach = Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ))
      TFA_BALLISTICS.WindDir = Vector(0, 0, 0)

      TFA_BALLISTICS.WindSpeed = math.Rand( 0, 8 )
      TFA_BALLISTICS.WindSpeedApproach = math.Rand( 0, 8 )

      function AngleToVector( self ) // Credit to TehBigA

      	local x = math.cos( math.rad(self.y) )
      	local y = math.sin( math.rad(self.y) )
      	local z = -math.sin( math.rad(self.p) )
      	return Vector( x, y, z )

      end

      TFA_BALLISTICS.WindSimulate = function()

            if math.random( 1, 4000 ) == 250 then
                  TFA_BALLISTICS.WindApproach = Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) )
                  print( "Wind Angle Changed" )
            end
            if math.random( 1, 500 ) == 195 then
                  TFA_BALLISTICS.WindSpeedApproach = math.Rand( 0, 8 )
                  print("Wind Speed Changed")
            end

            TFA_BALLISTICS.WindSpeed = math.Approach( TFA_BALLISTICS.WindSpeed, TFA_BALLISTICS.WindSpeedApproach, 0.1 )

            TFA_BALLISTICS.Wind.p = math.ApproachAngle( TFA_BALLISTICS.Wind.p, TFA_BALLISTICS.WindApproach.p, 0.1)
            TFA_BALLISTICS.Wind.y = math.ApproachAngle( TFA_BALLISTICS.Wind.y, TFA_BALLISTICS.WindApproach.y, 0.1)
            TFA_BALLISTICS.Wind.r = math.ApproachAngle( TFA_BALLISTICS.Wind.r, TFA_BALLISTICS.WindApproach.r, 0.1)
            TFA_BALLISTICS.WindDir = AngleToVector( TFA_BALLISTICS.Wind )

            net.Start( "TFA_BALLISTICS_SendWindSpeed", false)
            net.WriteInt( TFA_BALLISTICS.WindSpeed, 32)
            net.Broadcast()

      end

end

TFA_BALLISTICS.AddBullet = function(damage, velocity, aimcone, num_bullets, pos, dir, owner, ang, weapon)

      if SERVER then
            local bulletent = ents.Create("tfa_ballistic_bullet")
            bulletent:SetPos( pos )
            bulletent:SetAngles( ang )
            bulletent:Spawn()

            local bulletdata = {
                  ["damage"] = damage,
                  ["velocity"] = velocity,
                  ["aimcone"] = aimcone,
                  ["num_bullets"] = num_bullets,
                  ["pos"] = pos,
                  ["dir"] = dir,
                  ["owner"] = owner,
                  ["ang"] = ang,
                  ["weapon"] = weapon,
                  ["dropamount"] = 0,
                  ["ent"] = bulletent,
                  ["lifetime"] = 0
            }

            table.insert( TFA_BALLISTICS.Bullets, bulletdata )
      end

end

hook.Add( "InitPostEntity", "TFA_BALLISTICS_SpawnWindIndicator", function()
      if SERVER then
            local winddirent = ents.Create( "tfa_wind_info" )
            winddirent:SetPos( Vector( 0, 0, 0 ) )
            winddirent:SetAngles( TFA_BALLISTICS.Wind )
            winddirent:Spawn()
      end
      hook.Remove( "InitPostEntity", "TFA_BALLISTICS_SpawnWindIndicator" )
end )

hook.Add( "Tick", "TFA_BALLISTICS_Tick", function()

      for key, bullet in pairs( TFA_BALLISTICS.Bullets ) do
            TFA_BALLISTICS.Simulate( bullet )
      end

      if SERVER then
            TFA_BALLISTICS.WindSimulate()
      end

end)

TFA_BALLISTICS.Simulate = function( bullet )

      if not IsFirstTimePredicted() then return end

      if not IsValid( bullet["weapon"] ) then
            table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
            return false
      end

      bullet["lifetime"] = bullet["lifetime"] + ( 0.1 * game.GetTimeScale() )

      local sourcevelocity = ( bullet["velocity"] * 3.28084 * 12 / 0.75 )
      local grav_vec = Vector( 0, 0,GetConVarNumber("sv_gravity") )
      local velocity = bullet["dir"] * sourcevelocity
      local finalvelocity = velocity - ( (grav_vec * 3.28084 * 12) * bullet["lifetime"] ) * FrameTime() / 2

      local bullet_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( finalvelocity ) * FrameTime() }
      )
      local water_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( finalvelocity ) * FrameTime(),
            mask = MASK_WATER }
      )

      if water_trace.Hit then
            bullet["weapon"].MainBullet.Attacker = bullet["owner"]
		bullet["weapon"].MainBullet.Inflictor = bullet["weapon"]
		bullet["weapon"].MainBullet.Num = 1
		bullet["weapon"].MainBullet.Src = water_trace.HitPos
		bullet["weapon"].MainBullet.Dir = bullet["ang"]:Forward()
		bullet["weapon"].MainBullet.HullSize = 1
		bullet["weapon"].MainBullet.Spread.x = 0
		bullet["weapon"].MainBullet.Spread.y = 0
		bullet["weapon"].MainBullet.PenetrationCount = 0
		bullet["weapon"].MainBullet.AmmoType = bullet["weapon"]:GetPrimaryAmmoType()
		bullet["weapon"].MainBullet.Force = bullet["weapon"]:GetStat("Primary.Damage") / 6 * math.sqrt( bullet["weapon"]:GetStat("Primary.KickUp") + bullet["weapon"]:GetStat("Primary.KickDown") + bullet["weapon"]:GetStat("Primary.KickHorizontal")) * 1 * bullet["weapon"]:GetAmmoForceMultiplier()
		bullet["weapon"].MainBullet.Damage = bullet["damage"]
		bullet["weapon"].MainBullet.HasAppliedRange = false
		bullet["weapon"].MainBullet.TracerName = ""

		if bullet["weapon"].CustomBulletCallback then
			bullet["weapon"].MainBullet.Callback2 = bullet["weapon"].CustomBulletCallback
		end

		bullet["weapon"].MainBullet.Callback = function(a, b, c)
			if IsValid( bullet["weapon"] ) then
				c:SetInflictor(bullet["weapon"])
				if bullet["weapon"].MainBullet.Callback2 then
					bullet["weapon"].MainBullet.Callback2(a, b, c)
				end

				bullet["weapon"].MainBullet:Penetrate(a, b, c, bullet["weapon"])
			end
		end

		bullet["weapon"]:GetOwner():FireBullets( bullet["weapon"].MainBullet)

            util.Decal("ExplosiveGunshot", water_trace.HitPos + water_trace.HitNormal, water_trace.HitPos - water_trace.HitNormal)

            net.Start( "TFA_BALLISTICS_DoImpact" )
                  net.WriteEntity( bullet["weapon"] )
                  net.WriteVector( water_trace.HitPos )
                  net.WriteVector( water_trace.HitNormal )
                  net.WriteInt( water_trace.MatType, 32 )
            net.Broadcast()

            bullet["ent"]:StopParticles()
            SafeRemoveEntity( bullet["ent"] )
            table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )

      end

      if bullet_trace.Hit and bullet_trace.Entity != bullet["owner"] then

		bullet["weapon"].MainBullet.Attacker = bullet["owner"]
		bullet["weapon"].MainBullet.Inflictor = bullet["weapon"]
		bullet["weapon"].MainBullet.Num = 1
		bullet["weapon"].MainBullet.Src = bullet_trace.HitPos
		bullet["weapon"].MainBullet.Dir = bullet["ang"]:Forward()
		bullet["weapon"].MainBullet.HullSize = 1
		bullet["weapon"].MainBullet.Spread.x = 0
		bullet["weapon"].MainBullet.Spread.y = 0
		bullet["weapon"].MainBullet.PenetrationCount = 0
		bullet["weapon"].MainBullet.AmmoType = bullet["weapon"]:GetPrimaryAmmoType()
		bullet["weapon"].MainBullet.Force = bullet["weapon"]:GetStat("Primary.Damage") / 6 * math.sqrt( bullet["weapon"]:GetStat("Primary.KickUp") + bullet["weapon"]:GetStat("Primary.KickDown") + bullet["weapon"]:GetStat("Primary.KickHorizontal")) * 1 * bullet["weapon"]:GetAmmoForceMultiplier()
		bullet["weapon"].MainBullet.Damage = bullet["damage"]
		bullet["weapon"].MainBullet.HasAppliedRange = false
		bullet["weapon"].MainBullet.TracerName = ""

		if bullet["weapon"].CustomBulletCallback then
			bullet["weapon"].MainBullet.Callback2 = bullet["weapon"].CustomBulletCallback
		end

		bullet["weapon"].MainBullet.Callback = function(a, b, c)
			if IsValid( bullet["weapon"] ) then
				c:SetInflictor(bullet["weapon"])
				if bullet["weapon"].MainBullet.Callback2 then
					bullet["weapon"].MainBullet.Callback2(a, b, c)
				end

				bullet["weapon"].MainBullet:Penetrate(a, b, c, bullet["weapon"])
			end
		end

		bullet["weapon"]:GetOwner():FireBullets( bullet["weapon"].MainBullet)

            util.Decal( "ExplosiveGunshot", bullet_trace.HitPos + bullet_trace.HitNormal, bullet_trace.HitPos - bullet_trace.HitNormal)

            net.Start( "TFA_BALLISTICS_DoImpact" )
                  net.WriteEntity( bullet["weapon"] )
                  net.WriteVector( bullet_trace.HitPos )
                  net.WriteVector( bullet_trace.HitNormal )
                  net.WriteInt( bullet_trace.MatType, 32 )
            net.Broadcast()

            bullet["ent"]:StopParticles()
            timer.Simple( 0, function()
                  SafeRemoveEntity( bullet["ent"] )
                  table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
            end )

      end

      local windspeed = ( ( TFA_BALLISTICS.WindSpeed * 3.28084 * 12 / 0.75 ) * bullet["lifetime"] )

      local bulletpos = bullet["pos"] + ( finalvelocity + ( TFA_BALLISTICS.WindDir * windspeed ) ) * FrameTime()

      bullet["pos"] = bulletpos

      bullet["ent"]:SetPos( bullet["pos"] )

end
