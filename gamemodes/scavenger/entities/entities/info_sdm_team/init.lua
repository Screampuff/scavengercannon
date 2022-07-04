ENT.Type = "point"
ENT.Base = "base_point"

--ENT.Team = TEAM_UNASSIGNED
ENT.SpawnDelay = 10
ENT.PointLimit = 0
ENT.DeathTeam = 0
ENT.Joinable = true

local TeamEnts = {}

function team.GetInfoEnt(teamnumber)
	return TeamEnts[teamnumber] or NULL
end

function ENT:Initialize()
	TeamEnts[self.Team] = self
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	if key == "team" then
		value = team.ToTeamID(value)
		self.Team = tonumber(value)
		GAMEMODE:SetGNWBool("TeamJoinable"..self.Team,self.Joinable)
		GAMEMODE:SetGNWShort("TeamPointLimit"..self.Team,self.PointLimit)
	elseif key == "spawndelay" then
		self.SpawnDelay = tonumber(value)
	elseif key == "deathteam" then
		self.DeathTeam = tonumber(value)
	elseif key == "pointlimit" then
		self.PointLimit = tonumber(value)
		GAMEMODE:SetGNWShort("TeamPointLimit"..self.Team,self.PointLimit)
	elseif key == "joinable" then
		self.Joinable = tobool(value)
		if self.Team then
			GAMEMODE:SetGNWBool("TeamJoinable"..self.Team,self.Joinable)
		end
	end
end

function ENT:GetScoreLimit()
	if self.PointLimit ~= 0 then
		return self.PointLimit
	else
		return GAMEMODE:GetInfoEnt():GetScoreLimit()
	end
end

function ENT:Input(name,value,activator)
	name = string.lower(name)
	if name == "addpoints" then
		team.AddPoints(self.Team,tonumber(value))
	elseif name == "setspawndelay" then
		self.SpawnDelay = tonumber(value)
	elseif name == "setdeathteam" then
		self.DeathTeam = tonumber(value)
	elseif name == "setpointlimit" then
		self.PointLimit = tonumber(value)
	end
end

hook.Add("PostPlayerDeath","DoTeamSwitch",function(victim,attacker,inflictor)
	local teament = team.GetInfoEnt(victim:Team())
	if IsValid(teament) then
		if teament.DeathTeam == -1 then
			victim:SetTeam(attacker:Team())
		elseif teament.DeathTeam > 0 then
			victim:SetTeam(teament.DeathTeam)
		end
	end
end)

hook.Add("SetTeamPoints","DoPointCheck",function(team,oldpoints,newpoints)
	local teament = team.GetInfoEnt(team)
	if IsValid(teament) then
		local checkvalue = 0
		local ginfoent = GAMEMODE:GetInfoEnt()
		if (teament.PointLimit == -1) then
			if IsValid(ginfoent) then
				checkvalue = ginfoent.PointLimit
			end
		elseif (teament.PointLimit > 0) then
			checkvalue = teament.PointLimit
		end
		if (checkvalue > 0) and (newpoints > checkvalue) then
			GAMEMODE:RoundEndTeam(team)
		end
	end
end)
