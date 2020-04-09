AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.target = NULL
ENT.SpeedScale = 1
ENT.PhysTrigger = true
ENT.TouchTrigger = true
ENT.RemoveOnImpact = true
ENT.StopOnPhys = true
ENT.NoDrawOnDeath = false
--ENT.RemoveDelay = 1 --this is a value that you can specify in your projectile to delay its removal (useful if it's got an OB Particle effect attached)

function ENT:OnTakeDamage()
end

function ENT:PhysicsCollide(data,physobj)
	if self.PhysTrigger and not self.hashit and data.HitEntity ~= self:GetOwner() then
		self:OnPhys(data,physobj)
		if self.StopOnPhys then
			physobj:SetVelocity(vector_origin)
			physobj:EnableMotion(false)
			self.CollisionPos = self:GetPos()
		end
		if not self.hashit then
			timer.Simple(0, function() self:ProcessImpact(data.HitEntity) end)
		end
	end
end

function ENT:OnPhys(data,physobj)
end

function ENT:ProcessImpact(hitent)

	if self.dead or hitent == NULL then
		return
	end
	
	if not IsValid(self.Owner) then
		self.Owner = self
		self:SetOwner(self)
	end
	
	if not self.hashit then
		self.hashit = self:OnImpact(hitent)
	end
	
	if self.hashit and self.RemoveOnImpact then
		if not self.RemoveDelay then
			self:Remove()
		else
			self:DelayedDeath(self.RemoveDelay,self.NoDrawOnDeath)
		end
	end
	
	self:SetMoveType(MOVETYPE_NONE)
	
end

function ENT:DelayedDeath(amt,nodraw)
	self.dead = true
	self:SetNoDraw(nodraw)
	self:DrawShadow(false)
	self:GetPhysicsObject():SetVelocity(vector_origin)
	self:SetMoveType(MOVETYPE_NONE)
	if self.CollisionPos then
		self:SetPos(self.CollisionPos)
	end
	self:SetSolid(SOLID_NONE)
	self:NextThink(amt + 1) --stop thinking
	self:Fire("Kill",nil,amt)
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
	if not self.hashit and self.TouchTrigger and hitent:GetSolid() ~= SOLID_NONE and hitent:GetSolid() ~= SOLID_VPHYSICS and hitent ~= self.Owner then
		self:OnTouch(hitent)
		self.CollisionPos = self:GetPos()
		self:ProcessImpact(hitent)
	end
end

function ENT:OnTouch(hitent)
end

function ENT:Think()
end

function ENT:OnImpact(hitent)
	return true
end

function ENT:OnRemove()
end