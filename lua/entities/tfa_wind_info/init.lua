AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/maxofs2d/cube_tool.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetBodyGroups( "010" )

end

function ENT:Think()
	self:SetAngles( TFA_BALLISTICS.Wind )
end
