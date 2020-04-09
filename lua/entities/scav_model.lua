AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then

	function ENT:Initialize()
		self.Created = CurTime()
		self:SetNoDraw(true)
	end
	
	function ENT:Think()
		if self.Created + 0.1 < CurTime() then
			self:Remove()
		end
	end
	
else

	function ENT:Initialize()
		self.Created = CurTime()
		self:SetNoDraw(true)
	end
	
end