AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:SetMass(10000)
			phys:SetMaterial("slipperyslime")
		end
		
		self.Created = CurTime()
	end
	
	function ENT:Think()
	
		if self.Explode and not self.Exploded then
		
			self.Exploded = true
			
			local ef = EffectData()
			ef:SetOrigin(self:GetPos())
			util.Effect("ef_scav_exp3",ef,nil,true)
			
			util.ScreenShake(self:GetPos(),500,10,4,4000)
			util.BlastDamage(self,self.Owner,self:GetPos(),512,250)
			sound.Play("ambient/explosions/explode_3.wav",self:GetPos(),100,100)
			self:Remove()
			
		end
	
	
		if self.Created + 15 < CurTime() then
			self.Explode = true
		end
		
	end
	
	hook.Add("EntityTakeDamage","scav_cannonball",function(ent,dmginfo)
		local inflictor = dmginfo:GetInflictor()
		local attacker = dmginfo:GetAttacker()
		local amount = dmginfo:GetDamage()
		if dmginfo:GetDamageType() == DMG_CRUSH and IsValid(inflictor) and inflictor:GetClass() == "scav_projectile_cannonball" then
			dmginfo:SetAttacker(inflictor.Owner)
			if (amount < ent:Health()) then
				inflictor.Explode = true
			end
		end
	end)
	
else

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end
	
end