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
		
		self.SoundLoop = CreateSound(self,"weapons/flaregun/burn.wav")
		self.SoundLoop:PlayEx(20,20)
		
		local flareeffect = ents.Create("env_flare")
		flareeffect:SetPos(self:GetPos())
		flareeffect:SetParent(self)
		flareeffect:SetKeyValue("duration",60)
		flareeffect:Spawn()
		flareeffect:Activate()
		flareeffect:Fire("SetParentAttachment","fuse",0)
		flareeffect:SetColor(Color(0,0,0,0))
		flareeffect:SetRenderMode(RENDERMODE_TRANSALPHA)
		
		self:Fire("Kill",nil,70)
		
	end
	
	function ENT:Think()
		if self.Created + 60 < CurTime() then
			self.SoundLoop:Stop()
		elseif self.Created + 50 < CurTime() then
			self.SoundLoop:PlayEx(100-(CurTime() - self.Created - 50) * 8 + 20,50 - (CurTime() - self.Created - 50) * 5 + 50)
		elseif self.Created + 5 > CurTime() then
			self.SoundLoop:PlayEx((CurTime()-self.Created) * 20 + 20,(CurTime() - self.Created) * 10 + 60)
		end


	end
	
	function ENT:PhysicsCollide(data,physobj)
		if data.OurOldVelocity:Length() > 100 and self.Created + 30 > CurTime() then
			data.HitEntity:Ignite(10)
			data.HitEntity.ignitedby = self.Owner
		end
	end
	
else

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end
	
end