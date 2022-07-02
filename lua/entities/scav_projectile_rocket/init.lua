AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.SpeedScale = 1
ENT.PhysType = 1

function ENT:OnPhys(data,physobj)
	ScavData.BlastDecals("Scorch",data.HitPos,32)
end 

function ENT:OnTouch(hitent)
	ScavData.BlastDecals("Scorch",self:GetPos(),32)
end

function ENT:OnImpact(hitent)
	if not IsValid(self.Owner) then
		self.Owner = self
	end
	self.expl = true
	self.damagemul = 2
	self.blastmul = 1
	local didhit = false
	local knockback = {}
	knockback = ents.FindInSphere(self:GetPos(),100)
	if table.getn(knockback) ~= 0 then
		local num = table.getn(knockback)
		for i=1,num,1 do
				if knockback[i].Entity and not knockback[i].Entity:IsWorld() and knockback[i]:GetCollisionGroup() ~=0 then
						local tracek = {}
						tracek.start = self:GetPos()+Vector(0,0,5)
						tracek.endpos = knockback[i].Entity:GetPos()
						tracek.mask = MASK_NONE
						tracek.filter = self.Entity
						local trace = util.TraceLine(tracek)

						if knockback[i]:GetPhysicsObject():IsValid() then
							knockback[i]:GetPhysicsObject():Wake()
							knockback[i].Entity:SetGroundEntity(nil)
							knockback[i].Entity:SetVelocity(knockback[i].Entity:GetVelocity()*0.1+Vector(0,0,100)+(tracek.endpos+Vector(0,0,20)-tracek.start):GetNormalized()*500*self.blastmul)
							didhit = true
						end
				end
		end
	end
	util.ScreenShake(self:GetPos(),100,1,1,800)
	util.BlastDamage(self,self.Owner,self:GetPos(),128,60)
	local edata = EffectData()
	edata:SetOrigin(self:GetPos())
	edata:SetNormal(vector_up)
	util.Effect("ef_scav_exp",edata)
	if self.loop then
		self.loop:Stop()
	end
	return true
end

hook.Add("EntityTakeDamage","scav_blastmultiplier",function(ent,dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	if dmginfo:IsExplosionDamage() and ((inflictor:GetClass() == "scav_projectile_rocket") or (inflictor:GetClass() == "scav_projectile_grenade")) then
		dmginfo:SetDamageForce(dmginfo:GetDamageForce()*20)
	end
end)

function ENT:OnRemove()
	if self.loop then
		self.loop:Stop()
	end
end
