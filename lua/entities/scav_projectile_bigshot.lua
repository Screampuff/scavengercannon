AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "plasma charge"
ENT.Author = "Ghor"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"

ENT.Charge = 1
ENT.PhysType = 1
ENT.BBMins = Vector(-12,-12,-12)
ENT.BBMaxs = Vector(12,12,12)
ENT.Speed = 500
ENT.lasttrace = 0
ENT.Model = "models/Effects/combineball.mdl"

PrecacheParticleSystem("scav_bigshot")
PrecacheParticleSystem("scav_bigshot_charge")
PrecacheParticleSystem("scav_exp_bigshot")
PrecacheParticleSystem("scav_exp_bigshot_a")
PrecacheParticleSystem("scav_exp_bigshot_b")
PrecacheParticleSystem("scav_exp_bigshot_c")
PrecacheParticleSystem("scav_bigshot_beam")

function ENT:OnInit()

	if SERVER then

		if not self.filter then
			self.filter = {self.Owner}
		end
		
		self.enemies = {}
		self.beams = {}
		self.Speed = self.Speed * (1 + (self.Charge - 1) / 2)
		
	else
	
		self.soundloop = CreateSound(self,"ambient/machines/electric_machine.wav")
		self.soundloop:PlayEx(100,255)
		
		ParticleEffectAttach("scav_bigshot",PATTACH_ABSORIGIN_FOLLOW,self,0)
		
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
		
		self.Created = CurTime()
		
		self.dlight = DynamicLight(0)
		self.dlight.Pos = self:GetPos()
		self.dlight.r = 100
		self.dlight.g = 200
		self.dlight.b = 100
		self.dlight.Brightness = 3
		self.dlight.Size = 500
		self.dlight.Decay = 500
		self.dlight.DieTime = CurTime() + 1
		
	end
	
	self:DrawShadow(false)
	
end


function ENT:Think()

	if CLIENT then
	
		if self.dlight then
			self.dlight.Pos = self:GetPos()
			self.dlight.Size = 500
			self.dlight.DieTime = CurTime() + 1
		end
		
		
	else
	
		if not self.Hit then
		
			self:NextThink(CurTime() + 0.05)
		
			local dmg = DamageInfo()
			dmg:SetDamage(self.Charge)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(vector_origin)
			dmg:SetDamageType(DMG_ENERGYBEAM)
			
			for _,v in ipairs(ents.FindInSphere(self:GetPos(),512)) do -- check all enemies within range, add them to the enemies table if they aren't there already
			
				if IsValid(v) and (v:IsNPC() or (v:IsPlayer() and v:Alive()) or v:IsNextBot()) and not v:IsFriendlyToPlayer(self.Owner) and v ~= self.Owner and not table.HasValue(self.enemies,v) then
				
					table.insert(self.enemies,v)
					
					local beam = ents.Create("info_particle_system")
					beam:SetPos(self:GetPos())
					beam:SetParent(self)
					beam:SetKeyValue("effect_name","scav_bigshot_beam")
					beam:SetKeyValue("start_active","true")
					
					if v:GetName() == "" then
						v:SetName(v:EntIndex())
					end
					
					v:SetName(v:GetName()) --apparently player:GetName() is different than entity:GetName() , and returns the player's nick
					
					beam:SetKeyValue("cpoint1",v:GetName())
					beam:Spawn()
					beam:Activate()
					beam:Fire("Start",nil,0)
					
					table.insert(self.beams,beam)
					
				end
				
			end
			
			local removes = {} --create the table for entities that are no longer in range
			
			for k,v in ipairs(self.enemies) do
				if not IsValid(v) or v:GetPos():Distance(self:GetPos()) > 512 then
					table.insert(removes,k)
				else --do damage to entities in the enemies table that are still in range
					dmg:SetDamagePosition(v:GetPos()+v:OBBCenter())
					v:TakeDamageInfo(dmg)
				end
			end
			
			local removeamt = #removes
			
			if removeamt > 0 then
			
				for i=0,removeamt - 1 do --remove all entities from the enemies table that were no longer in range
				
					local slot = removes[removeamt - i]
					
					table.remove(self.enemies,slot)
					if IsValid(self.beams[slot]) then
						self.beams[slot]:Remove()
					end
					
					table.remove(self.beams,removes[slot])
					
				end
				
			end
			
		end

	end
	
	self.lasttrace = CurTime()
	
end

function ENT:OnImpact(hitent)

	if not self.Hit then
	
		self.Hit = true

		local pos = self:GetPos()
	
		if IsValid(self.HitEnt) then
			local dmg = DamageInfo()
			dmg:SetDamage(200 * self.Charge)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(vector_origin)
			dmg:SetDamageType(DMG_ENERGYBEAM)
			dmg:SetDamagePosition(pos)
			self.HitEnt:TakeDamageInfo(dmg)
		end

		util.ScreenShake(pos, 500, 10, 4, 4000)
		util.BlastDamage(self, self.Owner, pos,260 + 50 * self.Charge, 100 * self.Charge)
		
		if self.Charge == 4 then
			ParticleEffect("scav_exp_bigshot",pos,Angle(0,0,0),Entity(0))
		else
			if self.Charge > 2 then
				ParticleEffect("scav_exp_bigshot_c",pos,Angle(0,0,0),Entity(0))
			end
			if self.Charge > 1 then
				ParticleEffect("scav_exp_bigshot_b",pos,Angle(0,0,0),Entity(0))
			end
			ParticleEffect("scav_exp_bigshot_a",pos,Angle(0,0,0),Entity(0))
		end
		
	end
	
	if self.soundloop then
		self.soundloop:Stop()
	end
	
	self:EmitSound("ambient/explosions/explode_3.wav")
	return true
	
end

function ENT:OnRemove()
	if self.soundloop then
		self.soundloop:Stop()
	end
end
