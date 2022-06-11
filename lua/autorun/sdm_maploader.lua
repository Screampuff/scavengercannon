AddCSLuaFile()

/*=======================================================================*/
--		Map Loader
/*=======================================================================*/
	
if SERVER then
	CreateConVar("sdm_settingsfile", "default.txt", FCVAR_ARCHIVE)
	CreateConVar("sdm_allowvote", 0, FCVAR_ARCHIVE)
end
	
function ScavData.StartScavDM(map,settingsfile)
	RunConsoleCommand("sdm_settingsfile", settingsfile)
	RunConsoleCommand("changegamemode", map, "scavenger_deathmatch")
end
	
function ScavData.GetValidMaps()

	if SERVER then
	
		local potentialmaps = file.Find("scavdata/maps/*","DATA")
		local maps = {}
		
		for _,v in pairs(potentialmaps) do
			if file.Find("scavdata/maps/"..v.."*.txt","DATA") then
				table.insert(maps,v)
			end
		end
		
		return maps
		
	else
		return ScavData.SettingsFilePaths
	end
	
end

local loader = {}
ScavData.AllSettingsFiles = {}

function loader.New()
	local newloader = {}
	table.Inherit(newloader,loader)
	return newloader
end

function loader.Get(filename)
	if ScavData.AllSettingsFiles[filename] then
		return ScavData.AllSettingsFiles[filename]
	else
		local newloader = loader.New()
		newloader:Read(filename)
		ScavData.AllSettingsFiles[filename] = newloader
		return newloader
	end
end
		
ScavData.GetSettingsIO = loader.Get --the filename argument is optional, it will automatically load the given file if supplied

if SERVER then
		
	util.AddNetworkString("scv_loader")
	
	function loader:SendToClient(pl)
		net.Start("scv_loader")
			net.WriteString(self:GetFileName())
			net.WriteString(self:GetName())
			net.WriteString(self:GetAuthor())
			net.WriteString(self:GetMode())
			net.WriteInt(self:GetPointLimit(),32)
			net.WriteFloat(self:GetTimeLimit())
			net.WriteFloat(self:GetMaxTeams())
			net.WriteBool(self:GetFriendlyFire())
			net.WriteFloat(self:GetDamageScale())
			net.WriteString(self:GetModString())
		net.Send(pl)
	end

	util.AddNetworkString("scv_settingsfiles")
	
	function ScavData.SendAllSettingsToClient(pl)
		local maps = ScavData.GetValidMaps()
		net.Start("scv_settingsfiles")
			local filter = RecipientFilter()
			filter:AddPlayer(pl)
			net.WriteTable(maps)
		net.Send(filter)
	end
	
	function ScavData.CloseClientVoteMenus()
		for _,v in ipairs(player.GetHumans()) do
			v:ConCommand("sdm_vote_close")
		end
	end
	
	concommand.Add("sdm_vote_requestfiles",function(pl,cmd,args)
		if not pl.WasSentSDMSettingsList then --doing this so some wise guy can't force the server to constantly stream to him. This concommand can be overwritten if for some reason you're adding new settings files to the server in the middle of a game
			ScavData.SendAllSettingsToClient(pl)
			pl.WasSentSDMSettingsList = true
		end
	end)			

	concommand.Add("sdm_vote_requestmap",function(pl,cmd,args)
		local filename = args[1]
		if string.find(filename,"..",nil,true) or not string.find(filename,"/") then
			return false
		end
		if file.Exists("scavdata/maps/"..tostring(filename)) then
			local loader = ScavData.GetSettingsIO(filename)
			loader:SendToClient(pl)
		end
	end)
	
	local mapchangestarted = false
	
	function ScavData.SetVotingDeadline(time)
		if mapchangestarted then return end
		SetGlobalFloat("sdm_votedeadline",CurTime() + time)
		PrintMessage(HUD_PRINTTALK,"SDM Map voting will end in "..tostring(time).." seconds!")
	end
			
	local function beginmapchange()
	
		if mapchangestarted then return end
		mapchangestarted = true
		
		local vote = ScavData.GetWinningMapVote()
		local mapandsetting = string.Explode("/",vote)
		local map = mapandsetting[1]
		local setting = mapandsetting[2]
		
		ScavData.CloseClientVoteMenus()
		
		timer.Simple(0.1, function() PrintMessage(HUD_PRINTTALK,"Voting has ended. \""..setting.."\" on "..map.." has won the map vote. Changing maps in 5..") end)
		timer.Simple(5.1, function() ScavData.StartScavDM(map,setting) end)
		timer.Simple(1.1, function() PrintMessage(HUD_PRINTTALK,"4..") end)
		timer.Simple(2.1, function() PrintMessage(HUD_PRINTTALK,"3..") end)
		timer.Simple(3.1, function() PrintMessage(HUD_PRINTTALK,"2..") end)
		timer.Simple(4, function() PrintMessage(HUD_PRINTTALK,"1..") end)
		
	end			
			
	hook.Add("Think","sdm_votetimer",function()
		local deadline = GetGlobalFloat("sdm_votedeadline")
		if deadline ~= 0 and deadline <= CurTime() then
			beginmapchange()
		end
	end)
	
	util.AddNetworkString("UpdateSDMVotes")
	util.AddNetworkString("sdm_dispvote")
	
	concommand.Add("sdm_vote_submit",function(pl,cmd,args)
	
		if not GetConVar("sdm_allowvote"):GetBool() and GAMEMODE.Name ~= "Scavenger Deathmatch" then
			pl:PrintMessage(HUD_PRINTTALK,"Cannot vote on this server. sdm_allowvote must be set to 1")
			pl:ConCommand("sdm_vote_close")
			return
		end
		
		local filename = args[1]
		
		if string.find(filename,"..",nil,true) or not string.find(filename,"/") then
			return false
		end

		if file.Exists("scavdata/maps/"..tostring(filename)) then
		
			net.Start("UpdateSDMVotes")
				local rf = RecipientFilter()
				rf:AddAllPlayers()
			net.Send(rf)
			
			if pl.SDMMapVote ~= filename then
			
				pl.SDMMapVote = filename
				pl:SetNWString("sdm_vote",filename)
				
				local mapandsetting = string.Explode("/",filename)
				local map = mapandsetting[1]
				local setting = mapandsetting[2]
				
				net.Start("sdm_dispvote")
					local rf = RecipientFilter()
					rf:AddAllPlayers()
					net.WriteEntity(pl)
					net.WriteString(map)
					net.WriteString(setting)
				net.Send(rf)
				
			end
			
			local uncastvotecount = 0
			local players = player.GetHumans()
			
			for _,v in pairs(players) do
				local vote = ScavData.GetPlayerMapVote(v)
				if vote == "none" then
					uncastvotecount = uncastvotecount + 1
				end
			end
			
			if uncastvotecount == 0 then
				beginmapchange()
			elseif uncastvotecount < math.floor(#players * 0.25) and GetGlobalFloat("sdm_votedeadline") == 0 then
				PrintMessage(HUD_PRINTTALK,"A majority vote of at least 75% wishes to change the map at this time.")
				for _,v in pairs(players) do
					v:ConCommand("sdm_vote")
				end
				ScavData.SetVotingDeadline(30)
			end
			
		else
			MsgAll("Error! Could not load mapsettings file S \"scavdata/maps/"..filename.."\"")
		end
	end)
	
	hook.Add("PlayerDisconnect","updatesdmvotes",function()
		net.Start("UpdateSDMVotes")
			local rf = RecipientFilter()
			rf:AddAllPlayers()
		net.Send(rf)
	end)

else

	ScavData.SettingsFilePaths = {}
	
	net.Receive("scv_settingsfiles",function()
	
		local tbl = net.ReadTable()
		
		if tbl then
			ScavData.SettingsFilePaths = tbl
		end
		
		if SDM_VOTEMENU and SDM_VOTEMENU:IsValid() then
			SDM_VOTEMENU:Refresh()
		end
		
	end)
	
	color_green = Color(0,255,0,255)
	color_blue = Color(0,0,255,255)
	
	net.Receive("sdm_dispvote",function()
		local pl = net.ReadEntity()
		local col = pl:GetPlayerColor() or pl:GetWeaponColor() or Color(255,255,255,255)
		local map = net.ReadString()
		local setting = net.ReadString()
		chat.AddText(col,pl:Nick(),color_white," has voted for the map ",color_green,map,color_white," with settings file ",color_green,setting,color_white,".")
	end)
	
	net.Receive("scv_loader",function()
	
		local filename = net.ReadString()
		local obj = loader.New()
		
		if not obj.data then
			obj.data = {}
			obj.data.gamevars = {}
			obj.data.entities = {}
		end
		
		obj:SetFileName(filename)
		obj:SetName(net.ReadString())
		
		local author = net.ReadString()
		
		obj:SetAuthor(author)
		obj:SetMode(net.ReadString())
		obj:SetPointLimit(net.ReadInt(32))
		obj:SetTimeLimit(net.ReadFloat())
		obj:SetMaxTeams(net.ReadFloat())
		obj:SetFriendlyFire(net.ReadBool())
		obj:SetDamageScale(net.ReadFloat())
		obj.modstring = net.ReadString()
		
		ScavData.AllSettingsFiles[filename] = obj
		
	end)
	
end

--READ
		
function loader:Read(filename)
	self.filename = filename
	local filecontents = file.Read("scavdata/maps/"..tostring(filename),"DATA")
	self.data = util.JSONToTable(filecontents)
end

function loader:GetFileName()
	return self.filename
end

function loader:GetName()
	return self.data.gamevars.name
end

function loader:GetAuthor()
	return self.data.gamevars.author
end

function loader:GetMode()
	return self.data.gamevars.mode
end

function loader:GetPointLimit()
	return self.data.gamevars.maxpoints
end

function loader:GetTimeLimit()
	return self.data.gamevars.timelimit
end

function loader:GetTeamPlay()
	return self:GetMaxTeams() > 1
end

function loader:GetMaxTeams()
	if SERVER then
	
		local teams = 0
		local teamplay = false
		local foundteams = {}
		
		for _,v in ipairs(self.data.entities) do
		
			if (v.classname == "info_sdm_spawn") then
			
				local teamid = ScavData.ColorNameToTeam(v.KeyValues.team)
				
				if teamid ~= TEAM_UNASSIGNED and teamid ~= TEAM_SPECTATOR and not foundteams[teamid] then
					if not teamplay then
						teams = 0
						teamplay = true
					end
					foundteams[teamid] = true
					teams = teams + 1
				end
				
				if (teamid == TEAM_UNASSIGNED) and not teamplay then
					teams = 0
				end
				
			end
			
		end
		
		self.data.gamevars.maxteams = teams
		
	end
	
	return self.data.gamevars.maxteams
	
end

function loader:GetFriendlyFire()
	return self.data.gamevars.friendlyfire
end

function loader:GetDamageScale()
	return self.data.gamevars.damagescale or 1
end

function loader:GetGravity()
	return self.data.gamevars.gravity or 600
end

function loader:GetPlSpeed()
	return self.data.gamevars.plspeed or 1
end

function loader:GetMod(name)
	return self.data.gamevars["mod_"..name]
end

function loader:GetModString()

	if SERVER and not self.modstring then
	
		local mods = {}
		
		for k,v in pairs(self.data.gamevars) do
			if v && (string.Left(k,4) == "mod_") then
				table.insert(mods,string.Right(k,#k-4))
			end
		end
		
		self.modstring = string.Implode(", ",mods)
		
	end
	
	return self.modstring or ""
	
end
		
--WRITE

function loader:SetFileName(filename) --just to clarify, this should be in the format of "mapnamehere/settingsnamehere"
	self.filename = filename
end

function loader:Write(filename)
	file.Write("scavdata/maps/"..filename,util.TableToJSON(self.data))
end

function loader:SetName(name)
	self.data.gamevars.name = name
end

function loader:SetAuthor(author)
	self.data.gamevars.author = author
end

function loader:SetMode(mode)
	self.data.gamevars.mode = mode
end

function loader:SetPointLimit(limit)
	self.data.gamevars.maxpoints = limit
end

function loader:SetTimeLimit(limit)
	self.data.gamevars.timelimit = limit
end

function loader:SetMaxTeams(maxteams)
	self.data.gamevars.maxteams = maxteams
end

function loader:SetFriendlyFire(ffon)
	self.data.gamevars.friendlyfire = ffon
end

function loader:SetDamageScale(scale)
	self.data.gamevars.damagescale = scale
end

function loader:SetGravity(grav)
	self.data.gamevars.gravity = grav
end

function loader:SetPlSpeed(speed)
	self.data.gamevars.plspeed = speed
end

function loader:SetMod(name,on) --"mods" are boolean-only simple modifiers for the gamemode.
	self.data.gamevars["mod_"..name] = on
end

if SERVER then
	util.AddNetworkString("sdm_voteset")
end

function ScavData.SetPlayerMapVote(pl,mapsetting,transmitto)
	 pl.SDMMapVote = mapsetting
	 if SERVER then
		util.AddNetworkString("scv_voteset")
		 net.Start("sdm_voteset")
			net.WriteEntity(pl)
			net.WriteString(mapsetting)
		 net.Send(transmitto)
	end
end	

function ScavData.GetPlayerMapVote(pl)
	return pl.SDMMapVote or "none"
end
		
function ScavData.GetWinningMapVote()

	local votes = {}
	
	for _,v in pairs(player.GetHumans()) do
		local name = ScavData.GetPlayerMapVote(v)
		if name ~= "none" then
			votes[name] = (votes[name] or 0) + 1
		end
	end
	
	local highvotename
	local highvotecount = 0
	
	for votename,votecount in pairs(votes) do
	
		if not highvotename then
			highvotename = votename
		end
		
		if votecount > highvotecount then
			highvotename = votename
			highvotecount = votecount
		end
		
	end
	
	if highvotecount == 0 then
		return "none"
	else
		return highvotename
	end
	
end

hook.Add("PlayerInitialSpawn","NetworkSDMMapVotes",function(pl)
	for _,v in pairs(player.GetHumans()) do
		ScavData.SetPlayerMapVote(pl,ScavData.GetPlayerMapVote(v),pl)
	end
end)

if CLIENT then
	net.Receive("sdm_voteset",function()
		local pl = net.ReadEntity()
		if IsValid(pl) then
			ScavData.SetPlayerMapVote(pl,net.ReadString())
		end
	end)
end