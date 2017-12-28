include('shared.lua')

function ENT:Initialize()
    ParticleEffectAttach( "dax_bullettrail3_green", PATTACH_ABSORIGIN_FOLLOW, self, 1)
    self.Initialized = true
end

function ENT:OnRemove()
      if self.Initialized then
            self:StopParticles()
      end
end

function ENT:Draw()

end
