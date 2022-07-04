GM:SetGNWVar("RoundInProgress",false)
GM:SetGNWVar("RoundStartTime",0)
GM:SetGNWVar("RoundEndTime",0)
GM:SetGNWVar("PreRound",false)

local _E = debug.getregistry()

_E.ENDCONDITION_TIME = 0
_E.ENDCONDITION_FRAG = 1
_E.ENDCONDITION_CANCELED = 2
_E.ENDCONDITION_CUSTOM = 3

--SetNextRoundStartTime
--CanStartRound

if SERVER then
	hook.Add("Think","RoundManage",function()
		local self = GAMEMODE
		if not self:GetGNWVar("PreRound") and self:IsRoundInProgress() and (self:GetGNWVar("RoundEndTime") ~= 0) and (CurTime() > self:GetGNWVar("RoundEndTime")) then
			self:EndRound(ENDCONDITION_TIME)
		end
	end)
end

if CLIENT then

	local colmod = {}
	colmod[ "$pp_colour_addr" ]			= 0
	colmod[ "$pp_colour_addg" ]			= 0
	colmod[ "$pp_colour_addb" ]			= 0
	colmod[ "$pp_colour_brightness" ]	= 0
	colmod[ "$pp_colour_contrast" ]		= 1
	colmod[ "$pp_colour_colour" ]		= 1
	colmod[ "$pp_colour_mulr" ]			= 0
	colmod[ "$pp_colour_mulg" ]			= 0
	colmod[ "$pp_colour_mulb" ]			= 0

	local function docolormod()
		if GAMEMODE:IsRoundInProgress() then
			colmod["$pp_colour_addb"] = math.Approach(colmod["$pp_colour_addb"],0,FrameTime()*5)
			--colmod["$pp_colour_brightness"] = math.Approach(colmod["$pp_colour_brightness"],0,FrameTime()/3)
			colmod["$pp_colour_colour"] = math.Approach(colmod["$pp_colour_colour"],1,FrameTime()/3)
			--colmod["$pp_colour_contrast"] = math.Approach(colmod["$pp_colour_contrast"],1,FrameTime()/3)
		else
			colmod["$pp_colour_addb"] = math.Approach(colmod["$pp_colour_addb"],10/100,FrameTime()*5)
			--colmod["$pp_colour_brightness"] = math.Approach(colmod["$pp_colour_brightness"],-0.37,FrameTime()/3)
			colmod["$pp_colour_colour"] = math.Approach(colmod["$pp_colour_colour"],0.2,FrameTime()/3)
			--colmod["$pp_colour_contrast"] = math.Approach(colmod["$pp_colour_contrast"],0.94,FrameTime()/3)
		end
		DrawColorModify(colmod)
	end
	hook.Add("RenderScreenspaceEffects","RoundColor",docolormod)
end

function GM:SetRoundEndTime(time)
	if SERVER then
		self:SetGNWVar("RoundEndTime",time)
	end
end

function GM:AddRoundTime(time)
	self:SetRoundEndTime(self:GetGNWVar("RoundEndTime")+time)
end

function GM:StartRound(timelimit,delay)
	local timelimit = self:GetGNWFloat("TimeLimit")
	local delay = 3
	if not self:IsRoundInProgress() then
		gamemode.Call("OnPreRoundStart",delay)
		game.CleanUpMap()
		gamemode.Call("DoSetup")
		self:SetGNWVar("PreRound",true)
		self:SetGNWVar("RoundInProgress",true)
		self:PreparePlayers()
		for k,v in pairs(self.Teams) do
			team.SetScore(k,0)
		end
		timer.Simple(delay,function() gamemode.Call("OnRoundStart",timelimit) end)
	end
end

--[[
function GM:HasEnoughPlayersForRound()
	
end
]]

function GM:OnPreRoundStart(delay)
end

function GM:EndRound()
	if self:IsRoundInProgress() then
		gamemode.Call("OnRoundEnd",endcondition,enddata)
	end
end

function GM:EndRoundTeam(winningteam,wincondition)
	if self:IsRoundInProgress() then
		gamemode.Call("OnRoundEnd")
	end
end

function GM:EndRoundPlayer(winningplayer,wincondition)
	if self:IsRoundInProgress() then
		gamemode.Call("OnRoundEnd")
	end
end

function GM:IsRoundInProgress()
	return self:GetGNWVar("RoundInProgress")
end

function GM:PreparePlayers()
	for k,v in pairs(player.GetAll()) do	
		v:SetFrags(0)
		v:SetDeaths(0)
		if not v:IsSpectator() then
			v:KillSilent()
			v:Spawn()
		end
	end
end

function GM:OnRoundStart()
	if SERVER then
		local ctime = CurTime()
		self:SetGNWVar("RoundStartTime",ctime)
		local timelimit = self:GetGameVar("timelimit")
		if timelimit == 0 then
			self:SetRoundEndTime(0)
		else
			self:SetRoundEndTime(ctime+timelimit)
		end
		self:SetGNWVar("PreRound",false)
		umsg.Start("sdm_roundstart")
		umsg.End()
		
		for k,v in pairs(player.GetAll()) do
			if not v:IsSpectator() then
				--v:Freeze(false)
			end
		end
	else
		surface.PlaySound("ambient/alarms/warningbell1.wav")
	end
end

function GM:GetInitialTimeLimit()
	return self:GetGNWVar("TimeLimit")
end

function GM:OnRoundEnd()
	if SERVER then
		self:SetGNWVar("RoundInProgress",false)
		umsg.Start("sdm_roundend")
		umsg.End()
		timer.Simple(15, function() self:StartRound() end)
	else
		surface.PlaySound("ambient/explosions/explode_8.wav")
	end
end

if SERVER then
--[[
	hook.Add("PlayerSpawn","PreroundFreeze",function(pl)
		if GAMEMODE:GetGNWVar("PreRound") then
			pl:Freeze(true)
		end
	end)
	]]
	

	
end

	hook.Add("Move","PreroundFreeze",function(pl,movedata)
		if GAMEMODE:GetGNWVar("PreRound") then
			movedata:SetMaxClientSpeed(0)
			movedata:SetMaxSpeed(0)
			movedata:SetForwardSpeed(0)
			movedata:SetSideSpeed(0)
		end
	end)

if CLIENT then
	usermessage.Hook("sdm_roundstart",function(um)
		gamemode.Call("OnRoundStart")
	end)
	usermessage.Hook("sdm_roundend",function(um)
		gamemode.Call("OnRoundEnd")
	end)
end
