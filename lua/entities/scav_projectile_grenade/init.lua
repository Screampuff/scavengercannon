AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.drag = 1
ENT.NextSound = 0

function ENT:CreateDangerSound()
	local DangerSound = ents.Create("ai_sound")
	DangerSound:SetParent(self)
	DangerSound:SetLocalPos(vector_origin)
	DangerSound:SetKeyValue("soundtype", bit.bor(8,33554432) ) //danger, explosion
	DangerSound:SetKeyValue("duration",0.5)
	DangerSound:SetKeyValue("volume",130)
	return DangerSound
end

function ENT:Think()
	if self.NextSound < CurTime() then --staggering the sound emission to give the appearance of reaction times in the NPCs
		self.DangerPoint:Fire("EmitAISound",nil,0)
		self.NextSound = CurTime()+0.5
		//debugoverlay.Sphere(self.DangerSound:GetPos(),100,0.5,color_red,false)
	end
	if (self.dettime < CurTime()) || self.shouldexplode then
		if !self.expl then
			self.expl = true
			local edata = EffectData()
			edata:SetOrigin(self:GetPos())
			edata:SetNormal(vector_up)
			util.Effect("ef_scav_exp",edata)
			util.ScreenShake(self:GetPos(),100,1,1,800)
			util.BlastDamage(self,self.Owner,self:GetPos(),200,80)
			self:Remove()
		end	
	end
	if !self.bounce then
		self:NextThink(CurTime()+0.05)
		return true
	end
	
end

function ENT:PhysicsCollide(data,physobj)
	self.drag = self.drag+1
	self:GetPhysicsObject():SetDragCoefficient(self.drag)
	if !self.bounce && data.HitEntity && data.HitEntity:IsValid() && (data.HitEntity:IsPlayer() || data.HitEntity:IsNPC()) then
		self:SetMoveType(MOVETYPE_NONE)
		self.shouldexplode = data.HitEntity
	end
	if data.Speed > 50 then
		self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(1,3)..".wav")
	end
	if data.HitEntity:IsWorld() then
		self.bounce = true
	end
end 

function ENT:Touch(hitent)
end