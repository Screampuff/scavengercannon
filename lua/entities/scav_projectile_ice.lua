AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "rocket"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Speed = 1500
ENT.PhysInstantaneous = true

PrecacheParticleSystem("scav_ice_1")
PrecacheParticleSystem("scav_exp_ice")

function ENT:OnInit()
	if SERVER then
		self.lastupdate = CurTime()
	else
		ParticleEffectAttach("scav_ice_1",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

if CLIENT then
	local rendercol = Color(255,255,255,255)
	local mat = Material("effects/scav_shine5")

	function ENT:Draw()
		render.SetMaterial(mat)
		--render.DrawSprite(self:GetPos()-(self:GetLocalAngles():Forward()*16),64,64,Color(255,200,95,255))
		--render.DrawSprite(self:GetPos(),64,64,rendercol)
	end

	function ENT:OnRemove()
	end
end

if SERVER then

	ENT.SpeedScale = 1
	ENT.PhysType = 1
	ENT.RemoveDelay = 0.2

	function ENT:OnPhys(data,physobj)
	end

	function ENT:OnTouch(hitent)
	end

	function ENT:OnImpact(hitent)
		if IsValid(hitent) and hitent:GetClass() == "phys_bone_follower" then
			hitent = hitent:GetOwner()
		end
		local dmg = DamageInfo()
		local pos = self:GetPos()
		dmg:SetDamagePosition(self:GetPos())
		dmg:SetDamageForce(vector_origin)
		dmg:SetDamageType(DMG_ENERGYBEAM)
		if not hitent.Status_frozen then
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

end
