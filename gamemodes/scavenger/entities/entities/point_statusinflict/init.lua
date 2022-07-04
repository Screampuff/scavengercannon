ENT.Type = "point"
ENT.Base = "base_point"

--default values
ENT.StatusType = "Burning"
ENT.StatusDuration = 10
ENT.StatusIntensity = 1

function ENT:Initialize()
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	if key == "statustype" then
		self.StatusType = tostring(value)
	elseif key == "statusduration" then
		self.StatusDuration = tonumber(value)
	elseif key == "statusintensity" then
		self.StatusIntensity = tonumber(value)
	end
end

function ENT:Input(name,value,activator)
	name = string.lower(name)
	if name == "setstatustype" then
		self.StatusType = tostring(value)
	elseif name == "setstatusduration" then
		self.StatusDuration = tonumber(value)
	elseif name == "setstatusintensity" then
		self.StatusIntensity = tonumber(value)
	elseif name == "inflictstatus" then
		value:InflictStatusEffect(self.StatusType,self.StatusDuration,self.StatusIntensity,game.GetWorld())
	end
end
