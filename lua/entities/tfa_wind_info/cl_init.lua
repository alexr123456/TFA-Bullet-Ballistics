include('shared.lua')

function ENT:Initialize()
      ParticleEffectAttach( "dax_bullettrail3_red", PATTACH_ABSORIGIN_FOLLOW, self, 1)
      self.Initialized = true
end

function ENT:OnRemove()
      if self.Initialized then
            self:StopParticles()
      end
end

function ENT:Draw()

      self:DrawModel()

      render.DrawLine( self:GetPos(), self:GetPos() + ( self:GetForward() * TFA_BALLISTICS.WindSpeed ), Color(255, 0, 0), false)

end
