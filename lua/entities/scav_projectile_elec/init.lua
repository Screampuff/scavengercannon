AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.lifetime = 4
ENT.RemoveOnImpact = true

function ENT:OnImpact(hitent)
	local pos = self:GetPos()
	if hitent:IsWorld() then
		return true
	end
	ParticleEffectAttach("scav_electrocute",PATTACH_ABSORIGIN_FOLLOW,hitent,0)
	table.insert(self.filter,hitent)
	local dir = self:GetVelocity():GetNormalized()
	local ent = ents.FindInSphere(pos,300)
	local nextent
	local dist
	for k,v in ipairs(ent) do
		if ((v:IsPlayer() && v:Alive()) || v:IsNPC()) && (v != self.Owner) && (v != hitent) && (!nextent || (dist > v:GetPos():Distance(pos))) && !table.HasValue(self.filter,v) then
			nextent = v
			dist = v:GetPos():Distance(self:GetPos())
		end
	end
	if nextent && (nextent:IsNPC() || nextent:IsPlayer()) then
		local entpos = nextent:GetPos()+nextent:OBBCenter()
		self:GetPhysicsObject():SetVelocity((entpos-pos):GetNormalized()*1500)
	end
	local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageForce(vector_origin)
	dmg:SetDamage(40)
	dmg:SetDamageType(DMG_SHOCK)
	dmg:SetDamagePosition(pos)
	if hitent:IsPlayer() then
		hitent:InflictStatus("Shock",20,20)
	end
	hitent:TakeDamageInfo(dmg)
	//self:SetNetworkedVector("vel",self.vel)
	return true
end

function ENT:OnPhys(data,physobj)
	sound.Play("ambient/energy/zap"..math.random(1,3)..".wav",self:GetPos())
	ParticleEffect("scav_exp_elec",data.HitPos-data.HitNormal,Angle(0,0,0),game.GetWorld())
end

function ENT:OnTouch(ent)
	sound.Play("ambient/energy/zap"..math.random(1,3)..".wav",self:GetPos())
	ParticleEffect("scav_exp_elec",self:GetPos(),Angle(0,0,0),game.GetWorld())
end