AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

PrecacheParticleSystem("scav_absorb")

function ENT:Initialize()
	if SERVER then
		timer.Simple(0,function() ParticleEffectAttach("scav_absorb",PATTACH_ABSORIGIN_FOLLOW,self,0) end)
		self:Fire("Kill",nil,0.5)
	end
	self.Created = CurTime()
end

if CLIENT then
	local shinymat = Material("models/shiny")
	function ENT:Draw()
		render.MaterialOverride(shinymat)
		render.SetColorModulation(0.8,0.8,1)
		render.SetBlend(1-math.Clamp((CurTime() - self.Created) * 2,0,1))
		render.SuppressEngineLighting(true)
		self:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetBlend(1)
		render.SetColorModulation(1,1,1)
		render.MaterialOverride()
	end
end