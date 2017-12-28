if SERVER then
      util.AddNetworkString( "TFA_BALLISTICS_DoImpact" )
      util.AddNetworkString( "TFA_BALLISTICS_AddBullet" )
      util.AddNetworkString( "TFA_BALLISTICS_StopParticles" )
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

TFA_BALLISTICS.Wind = Angle( 0, 0, 0 )

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

hook.Add( "Tick", "TFA_BALLISTICS_Tick", function()

      for key, bullet in pairs( TFA_BALLISTICS.Bullets ) do
            TFA_BALLISTICS.Simulate( bullet )
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

      local bulletpos = bullet["pos"] + ( finalvelocity ) * FrameTime()

      bullet["pos"] = bulletpos

      bullet["ent"]:SetPos( bullet["pos"] )

end
