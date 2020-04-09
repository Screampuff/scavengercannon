ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "rocket"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Speed = 1500
ENT.PhysInstantaneous = true

PrecacheParticleSystem("scav_ice_1")
PrecacheParticleSystem("scav_exp_ice")

function ENT:OnInit()
	if SERVER then
		self.lastupdate = CurTime()
	else
		ParticleEffectAttach("scav_ice_1",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end
