ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"


	PrecacheParticleSystem( "striderbuster_attach" )
	PrecacheParticleSystem( "striderbuster_attached_pulse" )
	PrecacheParticleSystem( "striderbuster_explode_core" )
	PrecacheParticleSystem( "striderbuster_explode_dummy_core" )
	PrecacheParticleSystem( "striderbuster_break_flechette" )
	PrecacheParticleSystem( "striderbuster_trail" )
	PrecacheParticleSystem( "striderbuster_shotdown_trail" )
	PrecacheParticleSystem( "striderbuster_break" )
	PrecacheParticleSystem( "striderbuster_flechette_attached" )
	PrecacheParticleSystem( "striderbuster_smoke" )
	

	

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.dettime = CurTime()+2
	self.firstbounce = 0
	if SERVER then
		ScavData.GetNewInfoParticleSystem("striderbuster_smoke",self:GetPos(),self)
	else
	
	end
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
end

