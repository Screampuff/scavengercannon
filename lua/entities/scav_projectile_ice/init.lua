AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.SpeedScale = 1
ENT.PhysType = 1
ENT.RemoveDelay = 0.2

function ENT:OnPhys(data,physobj)
end 

function ENT:OnTouch(hitent)
end

function ENT:OnImpact(hitent)
	if hitent:GetClass() == "phys_bone_follower" then
		hitent = hitent:GetOwner()
	end
	local dmg = DamageInfo()
	local pos = self:GetPos()
	dmg:SetDamagePosition(self:GetPos())
	dmg:SetDamageForce(vector_origin)
	dmg:SetDamageType(DMG_ENERGYBEAM)
	if !hitent.Status_frozen then
		dmg:SetDamage(math.min(hitent:Health()-1,35))
	else
		dmg:SetDamage(35)
	end
	if IsValid(self.Owner) then
		dmg:SetAttacker(self.Owner)
	end
	dmg:SetInflictor(self)
	hitent:TakeDamageInfo(dmg)
	local statusduration = 10
	if hitent.Status_frozen then
		statusduration = math.min(10-(hitent.Status_frozen.EndTime-CurTime()),10)
	end
	hitent:InflictStatusEffect("Frozen",statusduration,0,self:GetOwner())
	ParticleEffect("scav_exp_ice",pos,Angle(0,0,0),game.GetWorld())
	return true
end