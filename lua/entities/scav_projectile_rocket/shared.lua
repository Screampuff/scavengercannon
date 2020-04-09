ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "rocket"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.PhysInstantaneous = true
ENT.RemoveDelay = 0.2
ENT.NoDrawOnDeath = true

PrecacheParticleSystem("scav_smoketrail_1")
PrecacheParticleSystem("scav_jet_1")

function ENT:OnInit()
	if SERVER then
		self.lastupdate = CurTime()
		self.loop = CreateSound(self,"weapons/rpg/rocket1.wav")
		self.loop:Play()
	else
		ParticleEffectAttach("scav_jet_1",PATTACH_POINT_FOLLOW,self,1)
	end
end
