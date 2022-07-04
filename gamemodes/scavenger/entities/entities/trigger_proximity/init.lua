ENT.Type = "point"
ENT.Base = "base_point"
ENT.Disabled = false
--default values
ENT.Radius = 100

function ENT:Initialize()
	self.TouchingEnts = {}
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	if key == "radius" then
		self.Radius = tonumber(value)
	elseif key == "startdisabled" then
		self:SetEnabled(not tobool(value))
	end
end

function ENT:SetEnabled(state)
	if state then
		self.Disabled = false
	else
		self.Disabled = true
		self.TouchingEnts = {}
	end
end

function ENT:EntPassesFilter(ent)
	return ent:IsValid() and (ent:GetSolid() ~= 0) and (not ent:IsPlayer() or ent:Alive()) and not IsValid(ent:GetParent())
end

function ENT:Think()
	if self.Disabled then
		return
	end
	local sphereents = ents.FindInSphere(self:GetPos(),self.Radius)
	for k,v in pairs(sphereents) do
		if not table.HasValue(self.TouchingEnts,v) and self:EntPassesFilter(v) then
			self:FireEntOutput("OnStartTouch",v,self)
			table.insert(self.TouchingEnts,v)
		end
	end
	for k,v in pairs(self.TouchingEnts) do
		if IsValid(v) then
			if not table.HasValue(sphereents,v) then
				self:FireEntOutput("OnEndTouch",v,self)
			elseif v:IsPlayer() and not v:Alive() then
				self:FireEntOutput("OnToucherKilled",v,self)
			end
		end
	end
	local numtouch = #self.TouchingEnts
	if numtouch == 0 then
		return
	end
	for i=0,numtouch-1,1 do
		if not IsValid(self.TouchingEnts[numtouch-i]) then
			self:FireEntOutput("OnToucherKilled",self,self)
			table.remove(self.TouchingEnts,numtouch-i)
		elseif not table.HasValue(sphereents,self.TouchingEnts[numtouch-i]) then
			self:FireEntOutput("OnEndTouch",self.TouchingEnts[numtouch-i],self)
			table.remove(self.TouchingEnts,numtouch-i)
		end
	end
	--for k,v in pairs(sphereents) do
	--	self:FireEntOutput("OnTouching",v,self)
	--end
end

function ENT:Input(name,value,activator)
	name = string.lower(name)
	if name == "enable" then
		self:SetEnabled(true)
	elseif name == "disable" then
		self:SetEnabled(false)
	elseif name == "toggle" then
		self:SetEnabled(self.Disabled)
	end
end
