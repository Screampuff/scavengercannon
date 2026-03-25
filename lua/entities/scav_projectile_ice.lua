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
		self.Submerged = self:WaterLevel() > 2
	else
		ParticleEffectAttach("scav_ice_1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end
end

if CLIENT then
	--local mat = Material("effects/scav_shine5")

	function ENT:Draw()
		--render.SetMaterial(mat)
		--render.DrawSprite(self:GetPos() - (self:GetLocalAngles():Forward() * 16), 64, 64, Color(255, 200, 95, 255))
		--render.DrawSprite(self:GetPos(), 64, 64, color_white)
	end

	function ENT:OnRemove()
	end
end

if SERVER then

	ENT.SpeedScale = 1
	ENT.PhysType = 1
	ENT.RemoveDelay = 0.2

	function ENT:OnPhys(data, physobj)
	end

	function ENT:OnTouch(hitent)
	end

	function ENT:OnImpact(hitent)
		ParticleEffect("scav_exp_ice", self:GetPos(), angle_zero, game.GetWorld())
		if not IsValid(hitent) then return true end

		if hitent:GetClass() == "phys_bone_follower" then
			hitent = hitent:GetOwner()
		end
		if hitent:GetClass() == "scav_iceplatform" then
			hitent:NextThink(CurTime() + hitent.LifeTime) 
			return true
		end
		local dmg = DamageInfo()
		dmg:SetDamagePosition(self:GetPos())
		dmg:SetDamageForce(vector_origin)
		dmg:SetDamageType(DMG_FREEZE)
		if not hitent.Status_frozen then
			dmg:SetDamage(math.min(hitent:Health() - 1, 35))
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
			statusduration = math.min(10 - (hitent.Status_frozen.EndTime - CurTime()), 10)
		end
		hitent:InflictStatusEffect("Frozen", statusduration, 0, self:GetOwner())
		return true
	end

	local blue = Color(0, 0, 255)
	--Create a platform on the surface
	--TODO: this is bad and there has to be a better way to do it, but I can't find it and have already spent hours on this
	function ENT:Think()
		if not self.Submerged and self:WaterLevel() > 1 and self.prevpos then
			local findsurface = {}
				findsurface.start = self.prevpos
				findsurface.endpos = self:GetPos()
				findsurface.filter = {self, self.Owner}
				findsurface.mask = CONTENTS_WATER

			local tr = util.TraceLine(findsurface)
			--print(tr.HitTexture)
			debugoverlay.Line(tr.StartPos, findsurface.endpos, 2, blue, true)
			debugoverlay.Cross(tr.HitPos, 16, 2, blue, true)
			if tr.FractionLeftSolid < 1 then
				local ice = ents.Create("scav_iceplatform")
				if IsValid(ice) then
					ice:SetPos(tr.HitPos)
					ice:Spawn()
					self:Remove()
				end
			end
		end
		self.prevpos = self:GetPos()
	end
end
