AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "rocket"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.PhysInstantaneous = true
ENT.RemoveDelay = 0.2
ENT.NoDrawOnDeath = true

PrecacheParticleSystem("scav_smoketrail_1")
PrecacheParticleSystem("scav_jet_1")

function ENT:OnInit()
	if SERVER then
		self.lastupdate = CurTime()
		self.loop = CreateSound(self,"weapons/rpg/rocket1.wav")
		self.loop:Play()
	else
		ParticleEffectAttach("scav_jet_1",PATTACH_POINT_FOLLOW,self,1)
	end
end

if CLIENT then
	local rendercol = Color(150,150,255,255)
	local mat = Material("effects/scav_shine5")

	function ENT:Draw()
		render.SetMaterial(mat)
		--render.DrawSprite(self:GetPos()-(self:GetLocalAngles():Forward()*16),64,64,Color(255,200,95,255))
		render.DrawSprite(self:GetPos()-(self:GetLocalAngles():Forward()*16),64,64,rendercol)
		self:DrawModel()
	end
end

if SERVER then

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
		if dmginfo:IsExplosionDamage() and IsValid(inflictor) and ((inflictor:GetClass() == "scav_projectile_rocket") or (inflictor:GetClass() == "scav_projectile_grenade")) then
			dmginfo:SetDamageForce(dmginfo:GetDamageForce()*20)
		end
	end)

	function ENT:OnRemove()
		if self.loop then
			self.loop:Stop()
		end
	end

end
