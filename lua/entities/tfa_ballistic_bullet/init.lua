AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Locked = false

function ENT:Initialize()

	self:SetModel( "models/bullets/w_pbullet1.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )


	self.Locked = false

end

function ENT:Think()
	if self.InitialPos:Distance( self:GetPos() ) > 1000 and not self.Locked then
		util.SpriteTrail( self, 1, Color(255, 152, 43), false, 2, 1, 0.005, 1, "trails/smoke.vmt")
		self.Locked = true
	end
end
