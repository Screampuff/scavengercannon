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
			phys:AddGameFlag(bit.bor(FVPHYSICS_NO_IMPACT_DMG,FVPHYSICS_NO_NPC_IMPACT_DMG))
		end
		
		self.Created = CurTime()
		self.SoundLoop = CreateSound(self,"ambient/gas/cannister_loop.wav")
		self.SoundLoop:PlayEx(20,20)
		self:Fire("Kill",nil,65)
		
	end
	
	function ENT:Think()
		
		if self.Created + 30 < CurTime() then
			self.SoundLoop:Stop()
		elseif self.Created + 25 < CurTime() then
			self.SoundLoop:PlayEx(100 - (CurTime() - self.Created-50) * 8 + 20,50 - (CurTime() - self.Created - 50) * 5 + 50)
		elseif self.Created + 5 > CurTime() then
			self.SoundLoop:PlayEx((CurTime() - self.Created) * 20 + 20,(CurTime() - self.Created) * 10 + 60)
		end
		
	end
	
else

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.em = ParticleEmitter(self:GetPos())
		self.Created = CurTime()
	end
	
	local airresist = 400
	local maxvel = 90
	
	local function partthink(part)
		local progress = math.Clamp((CurTime() - part.Created) / part.lifetime,0,1)
		local size = math.sqrt(progress) * part.endsize + 2
		part:SetStartSize(size)
		local alpha = (1 - progress ^ 2) * 255
		part:SetStartAlpha(alpha)
		part:SetNextThink(CurTime() + 0.05)
		return true
	end
	
	function ENT:Think()
		if self.Created + 30 > CurTime() then
			local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),self:GetPos())
			if part then
				part:SetVelocity(self:GetAngles():Up() * 60)
				part:SetColor(200,200,200)
				part.lifetime = 17
				part:SetDieTime(part.lifetime)
				part:SetStartSize(2)
				part.endsize = 64 + math.random(0,32)
				part:SetEndSize(part.endsize)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetGravity(VectorRand() * maxvel)
				part:SetRoll(math.Rand(0,6.28))
				part:SetAirResistance(airresist)
				part:SetThinkFunction(partthink)
				part.Created = CurTime()
				part:SetNextThink(CurTime() + 0.05)
			end
		end
	end
	
end