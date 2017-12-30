include('shared.lua')

ENT.CanEmitSound = true

function ENT:Initialize()
      ParticleEffectAttach( "dax_bullettrail3_red", PATTACH_ABSORIGIN_FOLLOW, self, 1)
      self.Initialized = true
      self.CanEmitSound = true
      self:SetBodyGroups( "010" )
end

function ENT:OnRemove()
      if self.Initialized then
            self:StopParticles()
      end
end

function ENT:Draw()

end

function ENT:Think()

      if self:GetPos():Distance( LocalPlayer():GetPos() ) < 500 and self.CanEmitSound and self:GetOwner() != LocalPlayer() then
            LocalPlayer():EmitSound("TFA_BALLISTICS.Supersonic", 25, 100, 1, CHAN_AUTO)
            timer.Simple( 0, function()
                  self.CanEmitSound = false
            end )
      end
      
end
