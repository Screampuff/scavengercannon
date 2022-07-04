ENT.Type = "point"
ENT.Base = "base_entity"
ENT.spawnclass = "prop_physics"
ENT.modelname = "models/Combine_Helicopter/helicopter_bomb01.mdl"
ENT.delay = 90
ENT.value = 30
ENT.lifetime = 0
ENT.noscav = 0
ENT.frozen = 0
ENT.resettime = 0
ENT.sent = NULL
ENT.timeofdeath = 0

function ENT:Initialize()
	--self:SpawnEntity()
	self.timeofdeath = 1
end

function ENT:AcceptInput(name,activator,caller)
	if name == "spawn" then
		self:RemoveEntity()
		self:SpawnEntity()
	elseif name == "remove" then
		self:RemoveEntity()
	end
end

function ENT:KeyValue(key,value)
	if string.lower(key) == "spawnclass" then
		self.spawnclass = value
		if string.find(self.spawnclass,"prop_physics") and util.IsValidRagdoll(self.modelname) then
			self.spawnclass = "prop_ragdoll"
		end
	elseif string.lower(key) == "modelname" then
		self.modelname = value
		if string.find(self.spawnclass,"prop_physics") and util.IsValidRagdoll(self.modelname) then
			self.spawnclass = "prop_ragdoll"
		end
	elseif string.lower(key) == "skin" then
		self.skin = value
	elseif string.lower(key) == "delay" then
		self.delay = tonumber(value)
	elseif string.lower(key) == "lifetime" then
		self.lifetime = tonumber(value)
	elseif string.lower(key) == "frozen" then
		self.frozen = tobool(value)
	elseif string.lower(key) == "noscav" then
		self.noscav = tobool(value)
	end
end

function ENT:Think()
	if not IsValid(self.sent) and self.timeofdeath == 0 then
		self.timeofdeath = CurTime()
	end
	if (self.timeofdeath ~= 0) and (CurTime() > self.timeofdeath+self.delay) then
		self:SpawnEntity()
		self.timeofdeath = 0
	end
	if (self.lifetime ~= 0) and (self.resettime < CurTime()) then
		--print("LifeTime: "..self.lifetime..", Overdue by "..(CurTime()-self.resettime))
		if self.sent:IsValid() then
			if (self.sent:GetPos() == self:GetPos()) then
				self.resettime = CurTime()+self.lifetime
			else
				self.sent:Remove()
				self:SpawnEntity()
				self.resettime = CurTime()+self.lifetime
			end
		end
	end
end

function ENT:SpawnEntity()
	if not self.spawnclass then
		return
	end
	if self.sent and self.sent:IsValid() then
		self.sent:Remove()
	end
	self.sent = ents.Create(self.spawnclass)
	self.sent:SetModel(self.modelname)
	self.sent:SetSkin(self.skin)
	self.sent:SetPos(self:GetPos())
	self.sent:SetAngles(self:GetAngles())
	self.sent:Spawn()
	self.sent.value = self.value
	--if self.lifetime ~= 0 then
	--	EntReaper.AddDyingEnt(self.sent,self.lifetime)
	--end
	self.resettime = CurTime()+self.lifetime
	if (self.noscav == 1) then
		self.sent.NoScav = true
	else
		--ParticleEffectAttach("scav_propspawn",PATTACH_ABSORIGIN_FOLLOW,self.sent,0)
		local edata = EffectData()
		edata:SetOrigin(self.sent:GetPos())
		edata:SetEntity(self.sent)
		util.Effect("PropSpawn",edata)
	end
	if (self.frozen == 1) and self.sent:GetPhysicsObject():IsValid() then
		self.sent:GetPhysicsObject():EnableMotion(false)
	end
end

function ENT:RemoveEntity()
	if self.sent and self.sent:IsValid() then
		self.sent:Remove()
	end
end
