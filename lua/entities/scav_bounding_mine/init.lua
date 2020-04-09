AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.constraint = NULL
ENT.wasconstrained = false

function ENT:Arm()
	self:SetPoseParameter("blendstates",0)
	self:EmitSound("npc/roller/blade_cut.wav")
	self:EmitSound("npc/roller/mine/combine_mine_deploy1.wav")
	self.constrained = true
	self.dt.state = 0
end

function ENT:Disarm()
	if self.constraint:IsValid() then
		self.constraint:Remove()
	end
	self:SetPoseParameter("blendstates",65)
	self:EmitSound("npc/roller/blade_in.wav")
	self.constrained = false
	self.dt.state = 3
end

function ENT:OnGravGunPickup(pl)
	self.Owner = pl
	self.nothink = false
	self:GetPhysicsObject():ClearGameFlag(FVPHYSICS_WAS_THROWN)
	self.held = true
	if self.constraint:IsValid() then
		self.constraint:Remove()
	end
end

function ENT:IsHeld()
	return self.held
end

function ENT:OnGravGunDropped(pl)
	if pl:KeyDown(IN_ATTACK) then
		self:GetPhysicsObject():SetDragCoefficient(-2500)
		self:GetPhysicsObject():AddGameFlag(FVPHYSICS_WAS_THROWN)
	end
	self:SetPoseParameter("blendstates",65)
	self.held = false
end


function ENT:PhysicsCollide(data,physobj)
	if physobj:HasGameFlag(FVPHYSICS_WAS_THROWN) && !self.exploded then
		timer.Simple(0, function() self:NextThink(CurTime()) self.Explode = true end)
	end
	self.hascollided = true
end

function ENT:Constrain(hitent)
	self.constraint = constraint.Weld(self,hitent,0,0,7000,false)
end

function ENT:PhysicsUpdate()
end



function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch()

end

function ENT:OnRemove()
	self.sound1:Stop()
end

function ENT:OnTakeDamage()
end