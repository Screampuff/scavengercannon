

function TEAM_SetColor(numTeam, tblColor) team.SetUp(numTeam,team.GetName(numTeam),tblColor) end
function TEAM_SetName(numTeam, strName) team.SetUp(numTeam,strName,team.GetColor(numTeam)) end
TEAM_SetColor(TEAM_CONNECTING,color_white)
TEAM_SetColor(TEAM_UNASSIGNED,Color(100,100,100,255))
TEAM_SetColor(TEAM_SPECTATOR,Color(150,150,150,100))

TEAM_SetColor(TEAM_RED,Color(155,40,40,255))
TEAM_SetColor(TEAM_BLUE,Color(26,115,187,255))
TEAM_SetColor(TEAM_GREEN,Color(181,230,29,255))
TEAM_SetColor(TEAM_YELLOW,Color(255,255,0,255))
TEAM_SetColor(TEAM_ORANGE,Color(255,128,16,255))
TEAM_SetColor(TEAM_PURPLE,Color(146,26,255,255))
TEAM_SetColor(TEAM_BROWN,Color(128,64,0,255))
TEAM_SetColor(TEAM_TEAL,Color(0,255,172,255))

TEAM_SetName(TEAM_SPECTATOR,"Spectators")
TEAM_SetName(TEAM_RED,"Red Team")
TEAM_SetName(TEAM_BLUE,"Blue Team")
TEAM_SetName(TEAM_GREEN,"Green Team")
TEAM_SetName(TEAM_YELLOW,"Yellow Team")
TEAM_SetName(TEAM_ORANGE,"Orange Team")
TEAM_SetName(TEAM_PURPLE,"Purple Team")
TEAM_SetName(TEAM_BROWN,"Brown Team")
TEAM_SetName(TEAM_TEAL,"Teal Team")

GM.Teams = {}
	GM.Teams[TEAM_UNASSIGNED] = false
	GM.Teams[TEAM_RED] = false
	GM.Teams[TEAM_BLUE] = false
	GM.Teams[TEAM_GREEN] = false
	GM.Teams[TEAM_YELLOW] = false
	GM.Teams[TEAM_ORANGE] = false
	GM.Teams[TEAM_PURPLE] = false
	GM.Teams[TEAM_BROWN] = false
	GM.Teams[TEAM_TEAL] = false

function team.Joinable(teamid)
	--[[
	local ent = team.GetInfoEnt(teamid)
	if not IsValid(ent) or not ent.Joinable then
		return false
	else
		return true
	end
	]]
	return GAMEMODE:GetGNWBool("TeamJoinable"..teamid)
end


local teamnametoindex = {}
	teamnametoindex["unassigned"] = TEAM_UNASSIGNED
	teamnametoindex["spectators"] = TEAM_SPECTATOR
	teamnametoindex["red"] = TEAM_RED
	teamnametoindex["blue"] = TEAM_BLUE
	teamnametoindex["green"] = TEAM_GREEN
	teamnametoindex["yellow"] = TEAM_YELLOW
	teamnametoindex["orange"] = TEAM_ORANGE
	teamnametoindex["purple"] = TEAM_PURPLE
	teamnametoindex["brown"] = TEAM_BROWN
	teamnametoindex["teal"] = TEAM_TEAL

function team.ToTeamID(name)
	if type(name) == "number" then
		return name
	end
	return teamnametoindex[string.lower(name)] or MsgAll("ERROR! Unknown team: "..tostring(name))
end
	
if CLIENT then
	local function ReceiveTeams(um) --receives the playable teams from the server
		GAMEMODE.Teams[TEAM_UNASSIGNED] = um:ReadBool()
		GAMEMODE.Teams[TEAM_RED] = um:ReadBool()
		GAMEMODE.Teams[TEAM_BLUE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_GREEN] = um:ReadBool()
		GAMEMODE.Teams[TEAM_YELLOW] = um:ReadBool()
		GAMEMODE.Teams[TEAM_ORANGE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_PURPLE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_BROWN] = um:ReadBool()
		GAMEMODE.Teams[TEAM_TEAL] = um:ReadBool()
	end
	usermessage.Hook("sdm_teams",ReceiveTeams)
end

function GM:SendPlayerTeams(pl)
	umsg.Start("sdm_teams",pl)
		umsg.Bool(team.Joinable(TEAM_UNASSIGNED))
		umsg.Bool(team.Joinable(TEAM_RED))
		umsg.Bool(team.Joinable(TEAM_BLUE))
		umsg.Bool(team.Joinable(TEAM_GREEN))
		umsg.Bool(team.Joinable(TEAM_YELLOW))
		umsg.Bool(team.Joinable(TEAM_ORANGE))
		umsg.Bool(team.Joinable(TEAM_PURPLE))
		umsg.Bool(team.Joinable(TEAM_BROWN))
		umsg.Bool(team.Joinable(TEAM_TEAL))
	umsg.End()
end

if CLIENT then
	GM.Teams = {}
		GM.Teams[TEAM_UNASSIGNED] = false
		GM.Teams[TEAM_RED] = false
		GM.Teams[TEAM_BLUE] = false
		GM.Teams[TEAM_GREEN] = false
		GM.Teams[TEAM_YELLOW] = false
		GM.Teams[TEAM_ORANGE] = false
		GM.Teams[TEAM_PURPLE] = false
		GM.Teams[TEAM_BROWN] = false
		GM.Teams[TEAM_TEAL] = false
	local function ReceiveTeams(um) --receives the playable teams from the server
		GAMEMODE.Teams[TEAM_UNASSIGNED] = um:ReadBool()
		GAMEMODE.Teams[TEAM_RED] = um:ReadBool()
		GAMEMODE.Teams[TEAM_BLUE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_GREEN] = um:ReadBool()
		GAMEMODE.Teams[TEAM_YELLOW] = um:ReadBool()
		GAMEMODE.Teams[TEAM_ORANGE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_PURPLE] = um:ReadBool()
		GAMEMODE.Teams[TEAM_BROWN] = um:ReadBool()
		GAMEMODE.Teams[TEAM_TEAL] = um:ReadBool()
	end
	usermessage.Hook("sdm_teams",ReceiveTeams)
end

function team.GetSpawnTime(teamid)
	return 10
end

function GM:UpdateTeams()
	for k,v in pairs(player.GetAll()) do
		self:SendPlayerTeams(v)
	end
end

function GM:SendPlayerInfo(pl)
	--[[
	for k,v in pairs(InitCVars) do
		umsg.Start("sdm_cvar",pl)
			umsg.String(k)
			umsg.String(v)
		umsg.End()
	end
	umsg.Start("sdm_subgm",pl)
		umsg.String(s_file.gamevars.mode)
	umsg.End()
	]]
	GM:SendPlayerTeams(pl)
	--[[
	umsg.Start("sync_roundstart",pl)
		umsg.Long(game_roundendtime)
	umsg.End()]]
end
	
TeamScores = {}

function team.SetScore(teamid,score) --I overwrote this, I don't remember why other than the original version not working
	GAMEMODE:SetGNWVar("TeamScore"..teamid,score)
	TeamScores[teamid] = score
end

function team.AddScore(teamid,score)
	team.SetScore(teamid,team.GetScore(teamid)+score)
end

function team.GetScore(teamid)
	if not teamid then
		return
	end
	if not TeamScores[teamid] then
		TeamScores[teamid] = 0
	end
	if SERVER then
		return TeamScores[teamid]
	end
	if CLIENT then
		return GAMEMODE:GetGNWVar("TeamScore"..teamid)
	end
end

function team.GetScoreLimit(teamid)
	if SERVER then
		local infoent = team.GetInfoEnt(teamid)
		if IsValid(infoent) and infoent:GetScoreLimit() then
			return infoent:GetScoreLimit()
		else
			--return GAMEMODE:GetInfoEnt():GetScoreLimit()
			return GAMEMODE:GetGameVar("PointLimit")
		end
	else
		return GAMEMODE:GetGNWShort("TeamPointLimit"..teamid)
	end
end

function team.GetWins(teamid)
	return GAMEMODE:GetGNWShort("TeamWins"..teamid)
end

function team.AddWin(teamid)
	GAMEMODE:SetGNWShort("TeamWins"..teamid,team.GetWins(teamid)+1)
end



function GM:PlayerRequestTeam(pl,teamid)
	if pl:Team() == teamid then
		return
	end
	if not pl.NextTeamswitch then
		pl.NextTeamswitch = 0
	end
	-- This team isn't joinable
	if (teamid ~= TEAM_SPECTATOR) and (pl.NextTeamswitch > CurTime()) then
		pl:PrintMessage(HUD_PRINTTALK,"You must wait "..math.ceil(pl.NextTeamswitch-CurTime()).." seconds before changing teams.")
		return
	end
	if (not GAMEMODE:PlayerCanJoinTeam( pl, teamid )) then
		 -- Messages here should be outputted by this function
		return
	end
	if pl:Team() ~= TEAM_SPECTATOR then
		pl:Kill()
		pl.NextSpawnTime = CurTime()+team.GetSpawnTime(teamid)
	else
		--pl:Kill()
		pl:KillSilent()
	end
	GAMEMODE:PlayerJoinTeam(pl,teamid)
end

function GM:PlayerJoinTeam(pl,teamid)
	local oldteam = pl:Team()
	pl:SetFrags(0)
	pl:SetDeaths(0)
	if teamid == TEAM_SPECTATOR then
		pl:Spectate(OBS_MODE_ROAMING)
	elseif pl:Team() == TEAM_SPECTATOR then
		--pl:UnSpectate()
	end
	pl:SetTeam(teamid)
	gamemode.Call("OnPlayerChangedTeam",pl,oldteam,teamid)
end

function GM:PlayerCanJoinTeam(pl,teamid)
	if team.Joinable(teamid) or (teamid == TEAM_SPECTATOR) then
		return true
	end
	return false
end

if SERVER then
	function GM:OnPlayerChangedTeam(pl,oldteam,newteam)
		if (oldteam == newteam) then
			return
		end
		local oldteamname = team.GetName(oldteam)
		local newteamname = team.GetName(newteam)
		if newteam == TEAM_SPECTATOR then
			PrintMessage(HUD_PRINTTALK,pl:Name().." is now spectating.")
		elseif oldteam == TEAM_SPECTATOR then
			PrintMessage(HUD_PRINTTALK,pl:Name().." has joined "..newteamname..".")
		else
			PrintMessage(HUD_PRINTTALK,pl:Name().." has left "..oldteamname.." and joined "..newteamname..".")
		end
		if (newteam ~= TEAM_SPECTATOR) then
			pl.NextTeamswitch = CurTime()+10
		end
		umsg.Start("gm_plchangedteam")
			umsg.Entity(pl)
			umsg.Short(oldteam)
			umsg.Short(newteam)
		umsg.End()
	end
end

if CLIENT then
	usermessage.Hook("gm_plchangedteam",function(um)
		local pl = um:ReadEntity()
		local oldteam = um:ReadShort()
		local newteam = um:ReadShort()
		gamemode.Call("OnPlayerChangedTeam",pl,oldteam,newteam)
	end)
end

GM.teamstuff = {}
function GM.teamstuff.sortbyfrags(a,b)
	local frags = (a:Frags() > b:Frags())
	if not frags and (a:Frags() == b:Frags()) then
		local deaths = (a:Deaths() < b:Deaths())
		if not deaths and (a:Deaths() == b:Deaths()) then
			return (a:EntIndex() < b:EntIndex())
		else
			return deaths
		end
	else
		return frags
	end
end

SortPlayersByScore = GM.teamstuff.sortbyfrags

-- return or ((a:Frags() == b:Frags()) and (a:Deaths() > b:Deaths())) or ((a:Deaths() == b:Deaths()) and (a:EntIndex() > b:EntIndex()))

function GM:GetTeamPlayersByPlace(n_team)
	self.teamstuff.scoresort[n_team] = team.GetPlayers(n_team)
	table.sort(self.teamstuff.scoresort[n_team],SortPlayersByScore)
	return self.teamstuff.scoresort[n_team]
end

function team.GetSortedPlayers(teamnum)
	local players = team.GetPlayers(teamnum)
	table.sort(players,SortPlayersByScore)
	return players
end

function team.SetLives(lives) --this function sets how many lives a team's players spawn with
end

