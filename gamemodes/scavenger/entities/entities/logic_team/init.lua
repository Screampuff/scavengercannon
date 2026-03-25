ENT.Type = "point"
ENT.Base = "base_point"

ENT.Team = TEAM_UNASSIGNED

function ENT:Initialize()
end

function ENT:KeyValue(key, value)
	
end

function ENT:Input(name, value, activator)
	name = string.lower(name)
	if name == "dooutput" then
		for _, pl in pairs(team.GetPlayers(self.Team)) do
			self:FireEntOutput("OutputPlayer", pl)
		end
	end
end