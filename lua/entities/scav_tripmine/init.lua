AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:OnTakeDamage()
	if !self.exploded && !self.damaged then
		timer.Simple(0.2, function() self:Explode() end)
		self.damaged = true
	end
end

function ENT:OnBeamCrossedByEnemy(tr)
	if !self.exploded then
		self:Explode()
	end
end

function ENT:Explode()
	if self:IsValid() && !self.exploded then
		self.exploded = true
		local edata = EffectData()
		edata:SetOrigin(self:GetPos())
		edata:SetNormal(vector_up)
		util.Effect("ef_scav_exp",edata)
		util.BlastDamage(self,self.Owner||self,self:GetPos(),200,100)
		self:Remove()
	end
end