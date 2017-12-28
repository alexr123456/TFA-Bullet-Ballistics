if SERVER then
      util.AddNetworkString( "TFA_BALLISTICS_DoImpact" )
      util.AddNetworkString( "TFA_BALLISTICS_AddBullet" )
end

game.AddParticles( "particles/tfa_ballistics/dax_tracers.pcf" )

PrecacheParticleSystem( "dax_bulettrail" )
PrecacheParticleSystem( "dax_bullettrail2" )

TFA_BALLISTICS = {}

TFA_BALLISTICS.Bullets = {}

TFA_BALLISTICS.Wind = Angle( 0, 0, 0 )

TFA_BALLISTICS.AddBullet = function(damage, velocity, aimcone, num_bullets, pos, dir, owner, ang, weapon)

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
            ["ent"] = bulletent
      }

      table.insert( TFA_BALLISTICS.Bullets, bulletdata )

      local final_bullet = TFA_BALLISTICS.Bullets[ #TFA_BALLISTICS.Bullets ]

      net.Start( "TFA_BALLISTICS_AddBullet")
            net.WriteTable( TFA_BALLISTICS.Bullets )
            net.WriteTable( bulletdata )
      net.Broadcast()

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

      bullet["dropamount"] = bullet["dropamount"] or 0

      local bullet_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( bullet["dir"] * bullet["velocity"] ) + Vector(0, 0, bullet["dropamount"] )}
      )
      local water_trace = util.TraceLine( {
      	start = bullet["pos"],
            endpos = bullet["pos"] + ( bullet["dir"] * bullet["velocity"] ) + Vector(0, 0, bullet["dropamount"] ),
            mask = MASK_WATER }
      )

      bullet["dropamount"] = bullet["dropamount"] - ( FrameTime() )

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
            SafeRemoveEntity( bullet["ent"] )
            table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )

      end

      bullet["pos"] = ( bullet["pos"] + ( bullet["dir"] * ( bullet["velocity"] / 6.5 ) ) ) + Vector(0, 0, bullet["dropamount"] )

      bullet["ent"]:SetPos( ( bullet["pos"] + ( bullet["dir"] * ( bullet["velocity"] / 6.5 ) ) ) + Vector(0, 0, bullet["dropamount"] ) )

end
