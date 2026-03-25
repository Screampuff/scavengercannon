AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "electricity beam"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Model = "models/effects/combineball.mdl"
ENT.BBMins = Vector(-8, -8, -8)
ENT.BBMaxs = Vector(8, 8, 8)
ENT.PhysType = 1
ENT.Speed = 1500
ENT.RemoveDelay = 0.2
ENT.PhysInstantaneous = true
--ENT.TouchTrigger = false

PrecacheParticleSystem("scav_electrocute")
PrecacheParticleSystem("scav_exp_elec")

function ENT:OnInit()
	self:DrawShadow(false)
	self.lasttrace = CurTime()

	if SERVER then
		self.filter = {self, self.Owner}
		return
	end
	self.Owner = self:GetOwner()
	self.points = {self:GetPos()}
	
	local wep = self:GetOwner():GetActiveWeapon()
	if not IsValid(wep) then return end

	self.points = {ScavData.GetTracerShootPos(self:GetOwner(), self:GetPos())}
end

local tracep = {}
		tracep.mask = bit.bor(MASK_SHOT, CONTENTS_WATER)
		tracep.mins = ENT.BBMins
		tracep.maxs = ENT.BBMaxs
		
function ENT:Think()
	if CLIENT then
		if not self.points then self.points = {self:GetPos()} end
		if CurTime() - self.Created > 0.1 then
			table.insert(self.points, 1, self:GetPos() + VectorRand() * 8)
			if self.points[10] then
				table.remove(self.points, 10)
			end
		end
	else
		if self:WaterLevel() > 0 then
			ScavData.Electrocute(self, self.Owner, self:GetPos(), 500, 500, true)
			ParticleEffect("scav_exp_elec", self:GetPos(), angle_zero, game.GetWorld())
			self.electrocuted = true
			self:DelayedDeath(0.2)
		end
		local vel = self:GetVelocity() * (CurTime() - self.lasttrace)
		tracep.start = self:GetPos()
		tracep.filter = self.filter
		tracep.endpos = self:GetPos() + vel
		local tr = util.TraceHull(tracep)
		if tr.HitWorld then
			if (tr.MatType == MAT_SLOSH) and not self.electrocuted then
				ScavData.Electrocute(self, self.Owner, tr.HitPos, 500, 500, true)
				ParticleEffect("scav_exp_elec", tr.HitPos, angle_zero, game.GetWorld())
				self.electrocuted = true
				self:DelayedDeath(0.2)
			end	
		end
	end
	self.lasttrace = CurTime()
end

if CLIENT then

	local mat = Material("trails/electric")
	local mat2 = Material("effects/scav_elec1")


	function ENT:Draw()
		if not self.points then return end

		render.SetMaterial(mat)
		render.StartBeam(#self.points)
		for i = 1, #self.points do
			render.AddBeam(self.points[i], 10 - i, ((i - 1) / 10), color_white)
		end
		render.EndBeam()
		render.SetMaterial(mat2)

		--if #self.points == 0 then return end

		render.DrawSprite(self.points[1], 32, 32, color_white)
	end

	return
end

--[[---------------------------------------------------------------------------
		SERVER
---------------------------------------------------------------------------]]--

ENT.lifetime = 4
ENT.RemoveOnImpact = true

function ENT:OnImpact(hitent)
	if not IsValid(hitent) then return true end

	local pos = self:GetPos()
	if hitent:IsWorld() then
		return true
	end
	ParticleEffectAttach("scav_electrocute", PATTACH_ABSORIGIN_FOLLOW, hitent, 0)
	table.insert(self.filter, hitent)
	local dir = self:GetVelocity():GetNormalized()
	local ent = ents.FindInSphere(pos, 300)
	local nextent
	local dist
	for _, v in ipairs(ent) do
		if not IsValid(v) then continue end 
		if not ((v:IsPlayer() and v:Alive()) or v:IsNPC() or v:IsNextBot()) then continue end
		if v == self.Owner or v == hitent or table.HasValue(self.filter, v) then continue end
		if nextent and dist <= v:GetPos():Distance(pos) then continue end

		nextent = v
		dist = v:GetPos():Distance(self:GetPos())
	end
	if nextent then
		local entpos = nextent:GetPos() + nextent:OBBCenter()
		self:GetPhysicsObject():SetVelocity((entpos-pos):GetNormalized() * 1500)
	end
	local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageForce(vector_origin)
	dmg:SetDamage(40)
	dmg:SetDamageType(DMG_SHOCK)
	dmg:SetDamagePosition(pos)
	if hitent:IsPlayer() then
		hitent:InflictStatusEffect("Shock", 20, 20)
	end
	hitent:TakeDamageInfo(dmg)
	--self:SetNetworkedVector("vel", self.vel)
	hitent:Fire("StartRagdollBoogie", 2, 0)
	return true
end

function ENT:OnPhys(data, physobj)
	sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", self:GetPos())
	ParticleEffect("scav_exp_elec", data.HitPos - data.HitNormal, angle_zero, game.GetWorld())
end

function ENT:OnTouch(ent)
	sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", self:GetPos())
	ParticleEffect("scav_exp_elec", self:GetPos(), angle_zero, game.GetWorld())
end
