AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.LifeTime = 6
ENT.NoScav = true
ENT.StatusImmunities = {["Frozen"] = true, ["Slow"] = true}
ENT.Model = Model("models/scav/iceplatform.mdl")

function ENT:Initialize()
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	if SERVER then
		self:NextThink(CurTime() + self.LifeTime)
		self:SetModel(self.Model)
		self:SetMaterial("models/shiny")
		self:SetColor(Color(175,227,255,200))
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():SetMaterial("gmod_ice")
		end
		self:SetAngles(Angle(0,math.random(0,360),0))
	end
end

if SERVER then
	function ENT:Think()
		if IsValid(self) then
			self:EmitSound("physics/glass/glass_sheet_break1.wav")
			local data = EffectData()
			local pos = self:GetPos()+self:OBBCenter()
			for i=1,4 do
				data:SetOrigin(pos)
				local dvec = VectorRand() * 100
				data:SetStart(dvec)
				data:SetNormal(dvec)
				util.Effect("ef_frozen_chunk",data)
			end
			self:Remove()
		end
	end
end