AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "scav vphysics-projectile base"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"

ENT.BBMins = Vector(-5,-5,-5)
ENT.BBMaxs = Vector(5,5,5)
ENT.target = NULL
ENT.hashit = false
ENT.Speed = 2000

function ENT:PhysicsUpdate()
	if self.dead or CLIENT then return end
	
	local delta = CurTime() - self.lastupdate
	self.lastupdate = CurTime()
	local phys = self:GetPhysicsObject()
	
	if IsValid(self.target) and (not self.target:IsPlayer() or self.target:Alive()) then
		if not IsValid(phys) then return end
		local vel = self:GetVelocity():Angle()
		local vec1 = (self.target:GetPos() + self.target:OBBCenter() - self:GetPos()):Angle()
		local amt = 45 * (CurTime() - self.Created) * delta
		vel.p = math.ApproachAngle(vel.p,vec1.p,amt)
		vel.y = math.ApproachAngle(vel.y,vec1.y,amt)
		vel.r = math.ApproachAngle(vel.r,vec1.r,amt)
		phys:SetVelocity(vel:Forward() * self.Speed * self.SpeedScale)
	else
		self.target = NULL
		if not IsValid(phys) then return end
		if self.PhysInstantaneous then
			phys:SetVelocityInstantaneous(phys:GetVelocity():GetNormalized() * self.Speed * self.SpeedScale)
		else
			phys:SetVelocity(phys:GetVelocity():GetNormalized() * self.Speed * self.SpeedScale)
		end
	end
	
	if self.Gravity then
		phys:AddVelocity(self.Gravity * delta)
	end
	
	if self:GetVelocity():Length() ~= 0 then
		self:SetLocalAngles(phys:GetVelocity():GetNormalized():Angle())
	end
end

function ENT:Initialize()
	if self.Model then self:SetModel(self.Model) end
	
	self.Created = CurTime()
	self:DrawShadow(false)
	
	if SERVER then
		self:PhysicsInitBox(self.BBMins, self.BBMaxs)
		self:SetCollisionBounds(self.BBMins, self.BBMaxs)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self.lastupdate = CurTime()
		self:SetTrigger(true)
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
		
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		
			if self.PhysType == 1 then
				phys:SetBuoyancyRatio(0)
				phys:EnableDrag(false)
				phys:EnableGravity(false)
			end
			
			if self.vel then
				phys:SetVelocity(self.vel)
			end
		
		end
	else
		self:SetMoveType(MOVETYPE_NONE)
	end
	
	self:OnInit()
end

function ENT:OnInit()
end

function ENT:Use()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	return
end

--[[---------------------------------------------------------------------------
		SERVER
---------------------------------------------------------------------------]]--

ENT.target = NULL
ENT.SpeedScale = 1
ENT.PhysTrigger = true
ENT.TouchTrigger = false
ENT.RemoveOnImpact = true
ENT.StopOnPhys = true
ENT.NoDrawOnDeath = false
--ENT.RemoveDelay = 1 --this is a value that you can specify in your projectile to delay its removal (useful if it's got an OB Particle effect attached)

function ENT:OnTakeDamage()
end

function ENT:PhysicsCollide(data,physobj)
	if not self.PhysTrigger or self.hashit or data.HitEntity == self:GetOwner() then return end
	self:OnPhys(data,physobj)
	if self.StopOnPhys then
		physobj:SetVelocity(vector_origin)
		physobj:EnableMotion(false)
		self.CollisionPos = self:GetPos()
	end
	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:ProcessImpact(data.HitEntity)
	end)
end

function ENT:OnPhys(data,physobj)
end

function ENT:ProcessImpact(hitent)

	if self.dead then return end

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
			self:DelayedDeath(self.RemoveDelay, self.NoDrawOnDeath)
		end
	end

	self:SetMoveType(MOVETYPE_NONE)

end

function ENT:DelayedDeath(amt, nodraw)
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
	timer.Simple(amt, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
	if not IsValid(hitent) or hitent == self.Owner then return end
	if self.hashit then return end
	if hitent:GetSolid() == SOLID_NONE or (hitent:GetSolid() == SOLID_BSP and not self.TouchTrigger) then return end
	
	if string.find(hitent:GetClass(), "func_") then return end
	self:OnTouch(hitent)
	self.CollisionPos = self:GetPos()
	self:ProcessImpact(hitent)
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
