AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self.Created = CurTime()
end

if SERVER then
	function ENT:Think()
		if self.Created + 6 < CurTime() then
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