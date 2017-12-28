DEFINE_BASECLASS("tfa_gun_base")

SWEP.Primary.Velocity = 500

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	local velocity = self:GetStat("Primary.Velocity")

	TFA_BALLISTICS.AddBullet( damage, velocity, aimcone, num_bullets, self.Owner:EyePos(), self.Owner:GetAimVector(), self.Owner, self.Owner:GetAngles(), self )
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


function SWEP:DoImpactEffect()
end
