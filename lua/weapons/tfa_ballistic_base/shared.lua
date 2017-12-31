SWEP.Base = "tfa_gun_base"

DEFINE_BASECLASS(SWEP.Base)

SWEP.Primary.Velocity = 500
SWEP.EnableTracer = true
SWEP.TracerColor = Color( 255, 152, 43 )

local TracerName
local cv_forcemult = GetConVar("sv_tfa_force_multiplier")

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() and not CLIENT then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0


	if self.Owner:GetShootPos():Distance( self.Owner:GetEyeTrace().HitPos ) >= 1000 then
		for i = 1, num_bullets do
			local velocity = self:GetStat("Primary.Velocity")

			local angles = self.Owner:EyeAngles()

			angles:RotateAroundAxis( angles:Right(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)
			angles:RotateAroundAxis( angles:Up(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)

			TFA_BALLISTICS.AddBullet( damage, velocity, self.Owner:GetShootPos(), angles:Forward(), self.Owner, self.Owner:GetAngles(), self, self.EnableTracer, self.TracerColor )
		end
	else
		if self.Tracer == 1 then
			TracerName = "Ar2Tracer"
		elseif self.Tracer == 2 then
			TracerName = "AirboatGunHeavyTracer"
		else
			TracerName = "Tracer"
		end

		self.MainBullet.PCFTracer = nil

		if self.TracerName and self.TracerName ~= "" then
			if self.TracerPCF then
				TracerName = nil
				self.MainBullet.PCFTracer = self.TracerName
				self.MainBullet.Tracer = 0
			else
				TracerName = self.TracerName
			end
		end

		self.MainBullet.Attacker = self:GetOwner()
		self.MainBullet.Inflictor = self
		self.MainBullet.Num = num_bullets
		self.MainBullet.Src = self:GetOwner():GetShootPos()
		self.MainBullet.Dir = self:GetOwner():GetAimVector()
		self.MainBullet.HullSize = self:GetStat("Primary.HullSize") or 0
		self.MainBullet.Spread.x = aimcone
		self.MainBullet.Spread.y = aimcone
		if self.TracerPCF then
			self.MainBullet.Tracer = 0
		else
			self.MainBullet.Tracer = self.TracerCount and self.TracerCount or 3
		end
		self.MainBullet.TracerName = TracerName
		self.MainBullet.PenetrationCount = 0
		self.MainBullet.AmmoType = self:GetPrimaryAmmoType()
		self.MainBullet.Force = damage / 6 * math.sqrt(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown") + self:GetStat("Primary.KickHorizontal")) * cv_forcemult:GetFloat() * self:GetAmmoForceMultiplier()
		self.MainBullet.Damage = damage
		self.MainBullet.HasAppliedRange = false

		if self.CustomBulletCallback then
			self.MainBullet.Callback2 = self.CustomBulletCallback
		end

		self.MainBullet.Callback = function(a, b, c)
			if IsValid(self) then
				c:SetInflictor(self)
				if self.MainBullet.Callback2 then
					self.MainBullet.Callback2(a, b, c)
				end

				self.MainBullet:Penetrate(a, b, c, self)

				self:PCFTracer( self.MainBullet, b.HitPos or vector_origin )
			end
		end

		self:GetOwner():FireBullets(self.MainBullet)
	end
end

function SWEP:ImpactEffectFunc(pos, normal, mattype)
	local enabled = true

	if enabled then
		local fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetNormal(normal)

		if self:CanDustEffect(mattype) then
			util.Effect("tfa_dust_impact", fx)
		end

		if self:CanSparkEffect(mattype) then
			util.Effect("tfa_metal_impact", fx)
		end

		local scal = math.sqrt(self:GetStat("Primary.Damage") / 30)
		if mattype == MAT_FLESH then
			scal = scal * 0.25
		end
		fx:SetEntity(self:GetOwner())
		fx:SetMagnitude(mattype or 0)
		fx:SetScale( scal )
		util.Effect("tfa_bullet_impact", fx)

		if self.ImpactEffect then
			util.Effect(self.ImpactEffect, fx)
		end
	end
end

function SWEP:Initialize()
	self.Primary.Velocity = 500
	self.TracerEffect = "dax_bullettrail3_green"
	BaseClass.Initialize( self )
end

function SWEP:DoImpactEffect()
end

if CLIENT then
	local cos, sin, abs, max, rad1, log, pow = math.cos, math.sin, math.abs, math.max, math.rad, math.log, math.pow
      local surface = surface
      function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
      	surface.SetDrawColor(color)
      	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
      end

      function surface.DrawArc(arc)
      	for k,v in ipairs(arc) do
      		surface.DrawPoly(v)
      	end
      end

      function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
      	local quadarc = {}
      	local startang,endang = startang or 0, endang or 0
      	local diff = abs(startang-endang)
      	local smoothness = log(diff,2)/2
      	local step = diff / (pow(2,smoothness))
      	if startang > endang then
      		step = abs(step) * -1
      	end
      	local inner = {}
      	local outer = {}
      	local ct = 1
      	local r = radius - thickness
      	for deg=startang, endang, step do
      		local rad = rad1(deg)
      		local cosrad, sinrad = cos(rad), sin(rad)
      		local ox, oy = cx+(cosrad*r), cy+(-sinrad*r)
      		inner[ct] = {
      			x=ox,
      			y=oy,
      			u=(ox-cx)/radius + .5,
      			v=(oy-cy)/radius + .5,
      		}
      		local ox2, oy2 = cx+(cosrad*radius), cy+(-sinrad*radius)
      		outer[ct] = {
      			x=ox2,
      			y=oy2,
      			u=(ox2-cx)/radius + .5,
      			v=(oy2-cy)/radius + .5,
      		}
      		ct = ct + 1
      	end
      	for tri=1,ct do
      		local p1,p2,p3,p4
      		local t = tri+1
      		p1=outer[tri]
      		p2=outer[t]
      		p3=inner[t]
      		p4=inner[tri]
      		quadarc[tri] = {p1,p2,p3,p4}
      	end
      	return quadarc

      end

      function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
      	for i = 0, seg do
      		local a = math.rad( ( i / seg ) * -360 )
      		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
      	end

      	local a = math.rad( 0 )
      	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

      	surface.DrawPoly( cir )
      end

end

function SWEP:DrawHUD()
	BaseClass.DrawHUD( self )

	surface.SetDrawColor( 26, 26, 26, 150 )
	draw.Circle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.02, 30 )

	surface.SetDrawColor( 26, 26, 26, 200 )
	draw.Circle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.016, 30 )

	startAng = ( StormFox.GetNetworkData( "WindAngle" ) + ( LocalPlayer():GetAngles().y * -1 ) ) - ( StormFox.GetNetworkData( "Wind" ) )
	endAng = ( StormFox.GetNetworkData( "WindAngle" ) + ( LocalPlayer():GetAngles().y * -1 ) ) + ( StormFox.GetNetworkData( "Wind" ) )

	surface.DrawCircle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ) , ScrW() * 0.0196, 26, 26, 26, 200)

	draw.Arc( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.02, ScrW() * 0.004, startAng, endAng, 1, Color(225, 225, 225) )

	surface.SetFont( "TFA_BALLISTICS_Font" )
	surface.SetTextColor( 225, 225, 225 )
	local width, height = surface.GetTextSize( math.Round( StormFox.GetNetworkData( "Wind" ) ) )
	surface.SetTextPos( ( ScrW() / 2 ) - ( width / 2 ), ( ScrH() - ( ScrW() * 0.02 ) ) - ( height / 2 ) )
	surface.DrawText( math.Round( StormFox.GetNetworkData( "Wind" ) ) )
end
