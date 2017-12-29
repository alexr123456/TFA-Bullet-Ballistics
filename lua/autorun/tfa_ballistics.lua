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

      TFA_BALLISTICS.Wind.P = 0
      TFA_BALLISTICS.Wind.Y = math.Rand( 0, 360 )
      TFA_BALLISTICS.Wind.R = math.Rand( 0, 360 )

      TFA_BALLISTICS.Wind = Angle( 0, TFA_BALLISTICS.Wind.Y, TFA_BALLISTICS.Wind.R )
      TFA_BALLISTICS.WindApproach = Angle( 0, math.Rand( 0, 360 ), math.Rand( 0, 360 ))

      TFA_BALLISTICS.WindSpeed = math.Rand( 0, 4 )
      TFA_BALLISTICS.WindSpeedApproach = math.Rand( 0, 4 )

      local function AngleToVector( self ) // Credit to TehBigA

      	local x = math.cos( math.rad(self.y) )
      	local y = math.sin( math.rad(self.y) )
      	local z = -math.sin( math.rad(self.p) )
      	return Vector( x, y, z )

      end

      TFA_BALLISTICS.WindSimulate = function()

            if math.random( 1, 10000 ) == 250 then
                  TFA_BALLISTICS.WindApproach = Angle( 0, math.Rand( 0, 360 ), math.Rand( 0, 360 ) )
                  print("Major wind direction shift")
            else
                  if math.random(1, 750) == 50 then
                        TFA_BALLISTICS.WindApproach = Angle( 0, math.Rand( TFA_BALLISTICS.WindApproach.y - 5, TFA_BALLISTICS.WindApproach.y + 5), math.Rand( TFA_BALLISTICS.WindApproach.r - 5, TFA_BALLISTICS.WindApproach.r + 5) )
                        print("Slight wind direction shift")
                  end
            end
            if math.random( 1, 1500 ) == 195 then
                  TFA_BALLISTICS.WindSpeedApproach = math.Rand( 0, 4 )
                  print("Wind speed change")
            end

            TFA_BALLISTICS.WindSpeed = math.Approach( TFA_BALLISTICS.WindSpeed, TFA_BALLISTICS.WindSpeedApproach, FrameTime() )

            TFA_BALLISTICS.Wind.p = math.ApproachAngle( TFA_BALLISTICS.Wind.p, TFA_BALLISTICS.WindApproach.p, FrameTime())
            TFA_BALLISTICS.Wind.y = math.ApproachAngle( TFA_BALLISTICS.Wind.y, TFA_BALLISTICS.WindApproach.y, FrameTime())
            TFA_BALLISTICS.Wind.r = math.ApproachAngle( TFA_BALLISTICS.Wind.r, TFA_BALLISTICS.WindApproach.r, FrameTime())
            TFA_BALLISTICS.WindDir = AngleToVector( TFA_BALLISTICS.Wind )

            net.Start( "TFA_BALLISTICS_SendWindSpeed", false)
            net.WriteInt( TFA_BALLISTICS.WindSpeed, 32)
            net.Broadcast()

      end

end

TFA_BALLISTICS.AddBullet = function(damage, velocity, num_bullets, pos, dir, owner, ang, weapon, tracereffect)

      if SERVER then
            local bulletent

            if tracereffect then
                  bulletent = ents.Create("info_particle_system")
                  bulletent:SetPos( pos )
                  bulletent:SetKeyValue( "effect_name", tracereffect )
                  bulletent:SetKeyValue( "start_active", "1")
                  bulletent:Spawn()
                  bulletent:Activate()
            end

            local bulletdata = {
                  ["damage"] = damage,
                  ["velocity"] = velocity,
                  ["num_bullets"] = num_bullets,
                  ["pos"] = pos,
                  ["dir"] = dir,
                  ["owner"] = owner,
                  ["ang"] = ang,
                  ["weapon"] = weapon,
                  ["dropamount"] = 0,
                  ["ent"] = bulletent,
                  ["lifetime"] = 0,
                  ["tracer"] = tracereffect
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
      local windspeed = ( ( TFA_BALLISTICS.WindSpeed * 3.28084 * 12 / 0.75 ) * bullet["lifetime"] )

      if IsValid( bullet["ent"] ) then
            bullet["ent"]:SetAngles( finalvelocity:Angle() )
      end

      local bullet_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( finalvelocity + ( TFA_BALLISTICS.WindDir * windspeed ) ) * FrameTime() }
      )
      local water_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( finalvelocity + ( TFA_BALLISTICS.WindDir * windspeed ) ) * FrameTime(),
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

            if IsValid( bullet["ent"] ) then
                  bullet["ent"]:StopParticles()
                  SafeRemoveEntity( bullet["ent"] )
            end
            timer.Simple( 0, function()
                  table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
            end )

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

            if IsValid( bullet["ent"] ) then
                  bullet["ent"]:StopParticles()
                  SafeRemoveEntity( bullet["ent"] )
            end
            timer.Simple( 0, function()
                  table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
            end )

      end

      local bulletpos = bullet["pos"] + ( finalvelocity + ( TFA_BALLISTICS.WindDir * windspeed ) ) * FrameTime()

      bullet["pos"] = bulletpos

      if IsValid( bullet["ent"] ) then
            bullet["ent"]:SetPos( bullet["pos"] )
      end

end
