DeriveGamemode("base")

--GAMEMODE INFO

GM.Name		= "Scavenger Deathmatch"
GM.Author	= "Ghor"

--EXTERNAL FILES

if SERVER then
	include("loader.lua")
end

include("enum.lua")
AddCSLuaFile("enum.lua")

include("GNWVar.lua")
AddCSLuaFile("GNWVar.lua")

function GM:GetMode()
	return self:GetGNWVar("mode") or 0
end

--include("stats.lua")
--AddCSLuaFile("stats.lua")

include("weapons.lua")
AddCSLuaFile("weapons.lua")

include("player.lua")
AddCSLuaFile("player.lua")

include("teams.lua")
AddCSLuaFile("teams.lua")

include("rounds.lua")
AddCSLuaFile("rounds.lua")

include("character.lua")

local modetranslate = {
[SDM_MODE_DM] = "Deathmatch",
[SDM_MODE_DM_TEAM] = "Team Deathmatch",
[SDM_MODE_CTF] = "Capture the Flag",
[SDM_MODE_CELLCONTROL] = "Cell Control",
[SDM_MODE_HOARD] = "Hoard",
[SDM_MODE_SURVIVAL] = "Survival",
[SDM_MODE_CAPTURE] = "Capture",
[SDM_MODE_CUSTOM] = "Mission"
}

function GM:GetModeName()
	local mode = self:GetMode()
	return modetranslate[mode]
end


if SERVER then --include server files, send client files
	AddCSLuaFile("vgui/commoncontrols.lua")
	AddCSLuaFile("vgui/scoreboard.lua")
	AddCSLuaFile("vgui/mainmenu.lua")
	AddCSLuaFile("vgui/teamsmenu.lua")
	AddCSLuaFile("HUD.lua")
end

if CLIENT then --include client files
	include("vgui/commoncontrols.lua")
	include("vgui/scoreboard.lua")
	include("vgui/mainmenu.lua")
	include("vgui/teamsmenu.lua")
	include("HUD.lua")
end

--PLAYERS = {}

function GM:Think()
	--PLAYERS = player.GetAll()
	if SERVER then
		if not self:IsRoundInProgress() and (self:GetGNWFloat("MapEndTime") < CurTime()) and (GetGlobalFloat("sdm_votedeadline") == 0) then
			PrintMessage(HUD_PRINTTALK,"Map time limit reached. Voting for next map has begun.")
			for k,v in pairs(player.GetHumans()) do
				v:ConCommand("sdm_vote")
			end
			ScavData.SetVotingDeadline(30)
		end
	end
end
