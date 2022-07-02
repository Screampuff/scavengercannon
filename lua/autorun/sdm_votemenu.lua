AddCSLuaFile()

if not CLIENT then return end

local PANEL = {}
	PANEL.LastRefreshTime = 0
	function PANEL:Init()
		self:SetTitle("Map Vote")
		self:MakePopup()
		self.VotedSettingsLabel = vgui.Create("DLabel",self)
			self.VotedSettingsLabel:SetFont("Scav_MenuLarge")
			self.VotedSettingsLabel:SetText("Settings with votes:")
			self.VotedSettingsLabel:SizeToContents()
		self.FilesLabel = vgui.Create("DLabel",self)
			self.FilesLabel:SetFont("Scav_MenuLarge")
			self.FilesLabel:SetText("All available settings files:")
			self.FilesLabel:SizeToContents()
		self:Refresh()
	end
	
	local function votedrowselect(self,line)
		self:GetParent().MapInfo:SetMap(self:GetLine(line):GetValue(1),self:GetLine(line):GetValue(2))
		self:GetParent().MapInfo:SetVisible(true)
		local filename = self:GetLine(line):GetValue(1).."/"..self:GetLine(line):GetValue(2)
		if not ScavData.AllSettingsFiles[filename] then
			RunConsoleCommand("sdm_vote_requestmap",filename)
		end
		surface.PlaySound("buttons/button9.wav")
	end
	
	
	local function RebuildVotedSettings(panel)
		panel.settings = panel.settings or {}
		local settingswithvotes = {}
		local players = player.GetHumans()
		for _,pl in ipairs(players) do
			local filename = pl:GetNWString("sdm_vote")
			if filename ~= "" then
				settingswithvotes[pl:GetNWString("sdm_vote")] = true
			end
		end
		for k,v in pairs(panel.settings) do
			if v:IsValid() then
				if not settingswithvotes[k] then
					panel:RemoveLine(v:GetID())
					panel.settings[k] = nil
				else
					v:SetValue(3,0)
				end
			end
		end
		for _,pl in ipairs(players) do
			local filename = pl:GetNWString("sdm_vote")
			if filename ~= "" then
				if not panel.settings[filename] or not panel.settings[filename]:IsValid() then
					local mapandsetting = string.Explode("/",filename)
					local map = mapandsetting[1]
					local setting = mapandsetting[2]
					panel.settings[filename] = panel:AddLine(map,setting,1)
				else
					panel.settings[filename]:SetValue(3,panel.settings[filename]:GetValue(3)+1)
				end
			end
		end
	end
	
	net.Receive("UpdateSDMVotes", function() if SDM_VOTEMENU:IsValid() then SDM_VOTEMENU.VotedSettings:Rebuild() end end)
	
	function PANEL:Refresh()
		if self.MapInfo and self.MapInfo:IsValid() then
			self.MapInfo:Remove()
		end
		if self.VotedSettings and self.VotedSettings:IsValid() then
			self.VotedSettings:Remove()
		end
		if self.Files and self.Files:IsValid() then
			self.Files:Remove()
		end
		self.MapInfo = vgui.Create("SDM_VoteMenuSettingInfo",self)
			self.MapInfo:SetVisible(false)
		self.VotedSettings = vgui.Create("DListView",self)
			self.VotedSettings.OnRowSelected = votedrowselect
			self.VotedSettings:AddColumn("Map")
			self.VotedSettings:AddColumn("Setting Name")
			self.VotedSettings:AddColumn("Votes")
			self.VotedSettings.Rebuild = RebuildVotedSettings
			self.VotedSettings:Rebuild()
		self.Files = vgui.Create("SDM_VoteMenuMapContainer",self)
		self:InvalidateLayout()
	end

	function PANEL:InvalidateLayout()
		self.VotedSettingsLabel:SetPos(32,48)
		self.VotedSettings:SetPos(48,64)
		self.VotedSettings:SetSize(self:GetWide()/3-64,self:GetTall()/2-64)
		self.FilesLabel:SetPos(32,self:GetTall()/2+16)
		self.Files:SetPos(48,self:GetTall()/2+32)
		self.Files:SetSize(self:GetWide()/3-64,self:GetTall()-32-self.Files.y)
		self.MapInfo:SetSize(self:GetWide()-64-(self.Files.x+self.Files:GetWide()),self:GetTall()-64-32)
		self.MapInfo:SetPos((self.Files.x+self.Files:GetWide())+32,64)
	end
	
	function PANEL:AutoSetup()
		self:SetSize(ScrW()-64,ScrH()-64)
		self:SetPos(32,32)
		self:InvalidateLayout()
	end
	
	function PANEL:Think()
		if self.LastRefreshTime+2 < CurTime() then
			self.VotedSettings:Rebuild()
			self.LastRefreshTime = CurTime()
		end
		if GetGlobalFloat("sdm_votedeadline") ~= 0 then
			self:SetTitle("Map Vote - "..tostring(math.max(math.floor(CurTime()-GetGlobalFloat("sdm_votedeadline")),0)).." seconds remaining to vote for the next map!")
		end
	end

	vgui.Register("SDM_VoteMenu",PANEL,"DFrame")


local PANEL = {}

	function PANEL:Init()
		self:AddColumn("Map")
		self:AddColumn("Setting Name")
		local maps = ScavData.GetValidMaps()
		for k,v in pairs(maps) do
			for i,j in pairs(file.Find("scavdata/maps/"..v.."/*","DATA")) do
				self:AddLine(v,j)
			end
		end
	end

	function PANEL:OnRowSelected(line)
		self:GetParent().MapInfo:SetMap(self:GetLine(line):GetValue(1),self:GetLine(line):GetValue(2))
		self:GetParent().MapInfo:SetVisible(true)
		local filename = self:GetLine(line):GetValue(1).."/"..self:GetLine(line):GetValue(2)
		if not ScavData.AllSettingsFiles[filename] then
			RunConsoleCommand("sdm_vote_requestmap",filename)
		end
		surface.PlaySound("buttons/button9.wav")
	end
	
	function PANEL:AutoSize()
		self:SetSize(128,200)
	end
	
	vgui.Register("SDM_VoteMenuMapContainer",PANEL,"DListView")

local PANEL = {}
	
	function PANEL:SetDesc(text)
		self.text = text
		self:SetText(text)
	end
	
	function PANEL:GetDesc()
		return self.text or ""
	end
	
	vgui.Register("SDM_VoteMenuDescLabel",PANEL,"DLabel")
	
local PANEL = {}

	--INFO
		--MaxPlayers (char)
		--Mode (string)
			--Point Limit (long)
			--Time Limit (float)
		--TeamPlay (bool)
			--Max Teams (char)
			--Friendly Fire (bool)
		--Damage Scale (float)
		--Rounds before vote(char)
		--Author Summary (string)
		--think about adding support for rotations

	PANEL.infovalid = true
	
	local function votebuttonpress(panel)
		surface.PlaySound("buttons/button4.wav")
		RunConsoleCommand("sdm_vote_submit",panel:GetParent().FileName or "..")
		--print(panel:GetParent().FileName)
	end
	
	function PANEL:Init() --before I'M visible there should be some sort of label instructing the player to select a map
		self.MapBG = vgui.Create("DImage",self)
			self.MapBG:SetImageColor(Color(255,255,255,128))
		self.DescriptionLabels = {}
		self.MapLabel = vgui.Create("DLabel",self)
			self.MapLabel:SetFont("Scav_HUDNumber3")
			self.MapLabel:SetPos(32,16)
			self.MapLabel:SizeToContents()
		self.MapIcon = vgui.Create("DImage",self)
			self.MapIcon:SetSize(256,192)
			self.MapIcon:SetPos(32,64)
		self.SettingNameLabel = self:AddDescriptionLabel()
		self.AuthorNameLabel = self:AddDescriptionLabel()
		self.ModeLabel = self:AddDescriptionLabel()
		self.TeamsLabel = self:AddDescriptionLabel()
		self.FriendlyFireLabel = self:AddDescriptionLabel()
		self.PointLimitLabel = self:AddDescriptionLabel()
		self.TimeLimitLabel = self:AddDescriptionLabel()
		self.DamageScaleLabel = self:AddDescriptionLabel()
		self.ModifierLabel = self:AddDescriptionLabel()
			self.ModifierLabel:SetFont("Scav_MenuLarge")
			self.ModifierLabel.ForcedY = 48
			self.ModifierLabel:SetWrap(true)
		--self.MapLabelBar = vgui.Create("DVerticalDivider",self)
		--	self.MapLabelBar:SetPos(0,self.MapLabel.y+self.MapLabel:GetTall())
		self.VoteButton = vgui.Create("DButton",self)
		self.VoteButton:SetFont("Scav_HUDNumber5")
		self.VoteButton:SetText("VOTE!")
		self.VoteButton.DoClick = votebuttonpress
			--buttons/button5.wav
		--self.initialized = true
	end
	
	function PANEL:AddDescriptionLabel()
		local index = table.insert(self.DescriptionLabels,vgui.Create("SDM_VoteMenuDescLabel",self))
			self.DescriptionLabels[index]:SetDesc("")
			self.DescriptionLabels[index]:SetVisible(false)
			self.DescriptionLabels[index]:SetFont("Scav_HUDNumber")
		return self.DescriptionLabels[index]
	end
	
	function PANEL:DescriptionLabelSetText(label,text)
		label.text = text
		label:SetText(text)
	end
	
	function PANEL:DoSetup()
		self.VoteButton:SetPos(32,self:GetTall()-64)
		self.VoteButton:SetSize(self:GetWide()-64,48)
		self.MapBG:SetPos(16,16)
		self.MapBG:SetSize(self:GetWide()-32,self:GetTall()-32)
		local accumulatedy = 0
		for k,v in ipairs(self.DescriptionLabels) do
			if v:GetDesc() ~= "" then
				v:SetPos(self.MapIcon.x,self.MapIcon.y+self.MapIcon:GetTall()+16+accumulatedy)
				if not v.ForcedY then
					v:SizeToContents()
				else
					v:SetSize(self:GetWide()-64,v.ForcedY)
				end
				v:SetVisible(true)
				accumulatedy = accumulatedy+math.Max(24,v:GetTall())
			else
				v:SetVisible(false)
			end
		end

	end
	
	function PANEL:InvalidateLayout()

		--self.MapLabelBar:SetSize(self:GetWide(),4)
	end

	local modetranslate = {
		["deathmatch"]		= "Deathmatch",
		["team_deathmatch"]	= "Team Deathmatch",
		["hoard"] 			= "Hoard",
		["cell_control"] 	= "Cell Control",
		["ctf"] 			= "Capture the Flag",
		["survival"] 		= "Survival"
	}
	
	function PANEL:SetMap(mapname,settingsfile)
	--CHECKTHIS 10/17/2011:
		--if file.Exists("../materials/maps/"..mapname..".vmt") then
		if file.Exists("materials/maps/"..mapname..".vmt", true) then
			self.MapIcon:SetImage("maps/"..mapname)
		else
			self.MapIcon:SetImage("vgui/NoMapIcon")
		end
		self.MapBG:SetImage(self.MapIcon:GetImage())
		self.MapLabel:SetText(mapname..": "..string.gsub(settingsfile,".txt",""))
		self.MapLabel:SizeToContents()
		self.FileName = mapname.."/"..settingsfile
		--print(self.FileName)
		local mapinfo = ScavData.AllSettingsFiles[mapname.."/"..settingsfile]
		if mapinfo then
			self.infovalid = true
			--Setting Name
			if (not mapinfo:GetName() or mapinfo:GetName() == "") then
				self.SettingNameLabel:SetDesc("?")
			else
				self.SettingNameLabel:SetDesc(mapinfo:GetName())
			end
			
			--Author Name
			if (not mapinfo:GetAuthor() or mapinfo:GetAuthor() == "") then
				self.AuthorNameLabel:SetDesc("Author: Anonymous")
			else
				self.AuthorNameLabel:SetDesc("Author: "..mapinfo:GetAuthor())
			end
			
			--mode
			self.ModeLabel:SetDesc("Mode: "..modetranslate[mapinfo:GetMode()])
			
			--teams
			if mapinfo:GetMaxTeams() == 0 then
				self.TeamsLabel:SetDesc("")
				self.FriendlyFireLabel:SetDesc("")
			else
				self.TeamsLabel:SetDesc("Teams: "..tostring(mapinfo:GetMaxTeams()))
				if mapinfo:GetFriendlyFire() then
					self.FriendlyFireLabel:SetDesc("Friendly Fire: Off")
				else
					self.FriendlyFireLabel:SetDesc("Friendly Fire: On")
				end
			end
			
			
			
			--point limit
			if mapinfo:GetPointLimit() == 0 then
				self.PointLimitLabel:SetDesc("Point Limit: None")
			else
				self.PointLimitLabel:SetDesc("Point Limit: "..mapinfo:GetPointLimit())
			end
			
			--time limit
			if mapinfo:GetTimeLimit() == 0 then
				self.TimeLimitLabel:SetDesc("Time Limit: None")
			else
				local fillzero = ""
				if mapinfo:GetTimeLimit()*60-math.floor(mapinfo:GetTimeLimit())*60 < 10 then
					fillzero = "0"
				end
				self.TimeLimitLabel:SetDesc("Time Limit: "..math.floor(mapinfo:GetTimeLimit()/60)..":"..fillzero..math.floor(mapinfo:GetTimeLimit()-math.floor(mapinfo:GetTimeLimit()/60)*60))
			end
			
			--Damage Scale
				if mapinfo:GetDamageScale() == 1 then
					self.DamageScaleLabel:SetDesc("")
				else
					self.DamageScaleLabel:SetDesc("Damage Scale: "..mapinfo:GetDamageScale())
				end
				
			--Mods
				if mapinfo:GetModString() == "" then
					self.ModifierLabel:SetDesc("")
				else
					self.ModifierLabel:SetDesc("Modifiers: "..mapinfo:GetModString())
				end
		else
			self.infovalid = false
			self.waitingmapname = mapname
			self.waitingsettingsname = settingsfile
			for k,v in ipairs(self.DescriptionLabels) do
				v:SetDesc("")
			end
		end
		self:DoSetup()
	end
	
	function PANEL:Think()
		if not self.infovalid then
			self:SetMap(self.waitingmapname,self.waitingsettingsname)
		end
	end
	
	function PANEL:Close()
		self:Remove()
		gui.EnableScreenClicker(false)
	end
	
	vgui.Register("SDM_VoteMenuSettingInfo",PANEL,"DPanel")

SDM_VOTEMENU = NULL

concommand.Add("sdm_vote",function(pl,cmd,args)
	RunConsoleCommand("sdm_vote_requestfiles")
	local votemenu = vgui.Create("SDM_VoteMenu")
	votemenu:SetSkin("sg_menu")
	votemenu:AutoSetup()
	SDM_VOTEMENU = votemenu
end)

concommand.Add("sdm_vote_close",function(pl,cmd,args)
	if SDM_VOTEMENU:IsValid() then
		SDM_VOTEMENU:Close()
	end
end)
