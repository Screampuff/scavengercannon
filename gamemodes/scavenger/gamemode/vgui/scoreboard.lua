surface.CreateFont("sdm_title",{font="Tahoma",size=24,weight=500,additive=true,antialias=true})

local PANEL = {}
	PANEL.PointX = 0
	PANEL.DeathX = 0
	PANEL.PingX = 0
	PANEL.pl = NULL
	PANEL.Plain = true
	
	function PANEL:Init()
		self.Icon = vgui.Create("AvatarImage",self)
		self.NameLabel = vgui.Create("DLabel",self)
			self.NameLabel:SetFont("HUDHintTextLarge")
		self.PointLabel = vgui.Create("DLabel",self)
			self.PointLabel:SetFont("HUDHintTextLarge")
		self.DeathLabel = vgui.Create("DLabel",self)
			self.DeathLabel:SetFont("HUDHintTextLarge")
		self.PingLabel = vgui.Create("DLabel",self)
			self.PingLabel:SetFont("HUDHintTextLarge")
		self.m_bgColor = Color(30,30,30,255)
		self.col = self.m_bgColor
		self.initialized = true
	end

	function PANEL:SetPlayer(pl)
		self.pl = pl
		local col = team.GetColor(pl:Team())
		col.r = col.r*0.7
		col.g = col.g*0.7
		col.b = col.b*0.7
		self.m_bgColor = col
		self.col = self.m_bgColor
		self.Icon:SetPlayer(pl)
		self.NameLabel:SetText(pl:Nick())
		self.NameLabel:SizeToContents()
	end
	
	function PANEL:GetPlayer()
		return self.pl
	end
	
	function PANEL:Think()

		if IsValid(self.pl) then
			if self.pl:Alive() then
				self.m_bgColor = self.col
				--self.m_bgColor.a = 120+math.sin(CurTime())*40
			else
				self.m_bgColor = color_black
			end
			self.PointLabel:SetText(self.pl:Frags())
			self.DeathLabel:SetText(self.pl:Deaths())
			self.PingLabel:SetText(self.pl:Ping())
		end
	end
	
	function PANEL:AutoSetup()
		self.Icon:SetSize(32,32)
		self:SetTall(42)
	end

	--[[
	function PANEL:Paint(pw,ph)
		local skin = self:GetSkin()
		local w,h = self:GetSize()
		skin:DrawGenericBackground(0,0,self.Icon:GetWide()+8,self:GetTall())
		skin:DrawGenericBackground(self.NameLabel.x-4,0,self:GetWide()-(self.NameLabel.x-4),self:GetTall())
	end
	]]

	function PANEL:InvalidateLayout()
		if not self.initialized then
			return false
		end
		self.Icon:SetPos(16,self:GetTall()/2-self.Icon:GetTall()/2)
		self.NameLabel:SetPos(24+self.Icon:GetWide(),self:GetTall()/2-self.NameLabel:GetTall()/2)
		self.PointLabel:SetPos(self.PointX,self.NameLabel.y)
		self.DeathLabel:SetPos(self.DeathX,self.NameLabel.y)
		self.PingLabel:SetPos(self.PingX,self.NameLabel.y)
	end

vgui.Register("sdm_sb_playerpanel",PANEL,"DPanel")





local PANEL = {}

	PANEL.team = 0
	local dkgray = Color(100,100,100,255)
	
	function PANEL:Init()
		self.List = vgui.Create("DPanelList",self)
		self.TeamLabelBox = vgui.Create("sdm_labelbox",self)
			self.TeamLabelBox:SetText("")
			self.TeamLabelBox:SetFont("HUDHintTextLarge")
		--self.ScoreLabel = vgui.Create("DLabel",self)
			--self.ScoreLabel:SetText("Score: 0")
			--self.ScoreLabel:SetFont("HUDHintTextLarge")
			--self.ScoreLabel:SizeToContents()
		self.PointLabel = vgui.Create("DLabel",self)
			self.PointLabel:SetText("Points")
			self.PointLabel:SetFont("DebugFixed")
			self.PointLabel:SizeToContents()
		self.DeathLabel = vgui.Create("DLabel",self)
			self.DeathLabel:SetText("Deaths")
			self.DeathLabel:SetFont("DebugFixed")
			self.DeathLabel:SizeToContents()
		self.PingLabel = vgui.Create("DLabel",self)
			self.PingLabel:SetText("Ping")
			self.PingLabel:SetFont("DebugFixed")
			self.PingLabel:SizeToContents()
		--self.List = vgui.Create("DForm",self)
		self.List:EnableVerticalScrollbar(true)
		self.initialized = true
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		local w,h = self:GetSize()
		self.TeamLabelBox:SetPos(4,4)
		self.TeamLabelBox:SetSize(w-8,32)
		self.TeamLabelBox:InvalidateLayout()
		--self.PointLabel:SetSize(48,16)
		--self.ScoreLabel:SetPos(32,self.TeamLabelBox.y+self.TeamLabelBox:GetTall()+4)
		local ypos = self.TeamLabelBox.y+self.TeamLabelBox:GetTall()+4
		self.PointLabel:SetPos(self:GetWide()-166,ypos)
		self.DeathLabel:SetPos(self:GetWide()-112,ypos)
		self.PingLabel:SetPos(self:GetWide()-64,ypos)
		self.List:SetPos(16,self.PointLabel.y+self.PointLabel:GetTall()+2)
		self.List:SetSize(w-32,h-self.List.y-8)
		self:UpdatePanelPositions()
	end
	
	function PANEL:UpdatePanelPositions()
		for k,v in ipairs(self.List.Items) do
			v.PointX = self.PointLabel.x-v.x
			v.DeathX = self.DeathLabel.x-v.x
			v.PingX = self.PingLabel.x-v.x
			v:InvalidateLayout()
		end
	end
	
	local plpanelsort = function(a,b)
		return SortPlayersByScore(a:GetPlayer(),b:GetPlayer())
	end
	
	function PANEL:SortPlayers()
		table.sort(self.List.Items,plpanelsort)
		self.List:Rebuild()
	end
	
	function PANEL:SetTeam(teamid)
		--self.List:SetTitle(team.GetName(teamid))
		--self.m_bgColor = team.GetColor(teamid)
		--self.m_bgColor.a = 200
		local col = team.GetColor(teamid)
		col.r = col.r*0.7
		col.g = col.g*0.7
		col.b = col.b*0.7
		col.a = 255
		self.TeamLabelBox.m_bgColor = col
		--if teamid == TEAM_UNASSIGNED then
		--	self.ScoreLabel:SetVisible(false)
		--else
		--	self.ScoreLabel:SetVisible(true)
		--	self.ScoreLabel:SetText(team.GetScore(teamid))
		--end
		self.TeamLabelBox:SetText(team.GetName(teamid))
		--[[
		if teamid == TEAM_UNASSIGNED then
			self.TeamLabelBox:SetText(team.GetName(teamid))
		else
			local wins = team.GetWins(teamid)
			if wins == 1 then
				self.TeamLabelBox:SetText(team.GetName(teamid).." - 1 Win")
			else
				self.TeamLabelBox:SetText(team.GetName(teamid).." - ".." Wins")
			end
		end
		]]
		self.TeamLabelBox:InvalidateLayout()
		self.team = teamid
		self:Rebuild()		
	end
	
	function PANEL:GetTeam()
		return self.team
	end
	
	function PANEL:RemovePlayer(pl)
		for k,v in ipairs(self.List.Items) do
			if v:GetPlayer() == pl then
				self.List:RemoveItem(v)
				break
			end
		end
		if #self.List.Items == 0 then
			local sb = self.scoreboard
			sb:SetupTeams()
		end
	end
	
	function PANEL:ValidatePlayers()
		for k,v in ipairs(self.List.Items) do
			if not v:GetPlayer():IsValid() or (v:GetPlayer():Team() ~= self.team) then
				self.List:RemoveItem(v)
			end
		end
		if team.NumPlayers(self.team) ~= #self.List.Items then --Uh Oh, someone is missing!
			self:Rebuild()
		end
	end
	
	function PANEL:AddPlayer(pl)
		for k,v in ipairs(self.List.Items) do
			if v == pl then
				return
			end
		end
		local plpanel = vgui.Create("sdm_sb_playerpanel",self.List)
		plpanel.scoreboard = self
		plpanel:SetPlayer(pl)
		plpanel:AutoSetup()
		self.List:AddItem(plpanel)
		self:SortPlayers()
	end
	
	function PANEL:Rebuild()
		self.List:Clear()
		self:AddAllPlayers()
		self:InvalidateLayout()
	end
	
	function PANEL:Think()
		--self.ScoreLabel:SetText("Score: "..team.GetScore(self.team))
		--self.ScoreLabel:SizeToContents()
		if self.team == TEAM_UNASSIGNED then
			self.TeamLabelBox:SetText("Players")
		else
			self.TeamLabelBox:SetText(team.GetName(self.team).." - "..team.GetScore(self.team).." Points")
		end
		--self.m_bgColor = dkgray
	end
	
	function PANEL:AddAllPlayers()
		for k,v in ipairs(team.GetPlayers(self.team)) do
			local plpanel = vgui.Create("sdm_sb_playerpanel",self.List)
			plpanel.scoreboard = self
			plpanel:SetPlayer(v)
			plpanel:AutoSetup()
			self.List:AddItem(plpanel)
		end
	end
	
	vgui.Register("sdm_sb_teamboard",PANEL,"DPanel")
	
	

local PANEL = {}

	PANEL.LastRefresh = 0
	
	function PANEL:Init()
		self.ServerInfo = vgui.Create("DForm",self)
			self.ServerInfo.Plain = true
			self.ServerInfo:SetName("")
			self.ServerInfo:SetPadding(2)
			self.ServerInfo:SetSpacing(0)
			self.ServerInfo.ServerName = vgui.Create("sdm_labelbox",self.ServerInfo)
				self.ServerInfo.ServerName:SetFont("sdm_title")
				self.ServerInfo.ServerName:SetText(GAMEMODE:GetGNWVar("ServerName")..": "..#player.GetAll().."/"..game.MaxPlayers())
				self.ServerInfo.ServerName:SetHMargin(0)
				self.ServerInfo:AddItem(self.ServerInfo.ServerName)
			self.ServerInfo.ModeName = vgui.Create("DLabel",self.ServerInfo)
				--self.ServerInfo.ServerName:SetFont("sdm_title")
				self.ServerInfo.ModeName:SetFont("HUDHintTextLarge")
				self.ServerInfo.ModeName:SetText("     MODE: "..GAMEMODE:GetModeName())
				self.ServerInfo:AddItem(self.ServerInfo.ModeName)
		self.TeamSpace = vgui.Create("DPanelList",self)
		self.TeamSpace:EnableHorizontal(true)
		self.SpectatorsBox = vgui.Create("sdm_labelbox",self)
			self.SpectatorsBox:SetWrap(true)
			self.SpectatorsBox:SetAutoStretchVertical(false)
			self.SpectatorsBox:SetText("Spectators: ")
		self.TextTable = {"HOSTNAME",": ","0","/"..game.MaxPlayers().." | Map Time Remaining: ","00:00"}
		self.initialized = true
	end
	
	function PANEL:GetPlayingTeamCount()
		totalteams = 0
		for k,v in pairs(GAMEMODE.Teams) do
			if #team.GetPlayers(k) > 0 then
				totalteams = totalteams+1
			end
		end
		return totalteams
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		self.ServerInfo:SetPos(32,8)
		self.ServerInfo:SetAutoSize(false)
		self.ServerInfo:SetSize(math.max(256,self:GetWide()/2),32)
		self.TeamSpace:SetPos(32,self.ServerInfo:GetTall()+self.ServerInfo.y+48)
		self.TeamSpace:SetSize(self:GetWide()-64,self:GetTall()-self.ServerInfo:GetTall()-self.ServerInfo.y-128)
		self.SpectatorsBox:SetPos(32,self:GetTall()-72)
		self.SpectatorsBox:SetSize(self:GetWide()-64,64)
	end
	
	function PANEL:AutoSetup()
		self:SetSize(ScrW()-128,ScrH()-128-96)
		self:SetPos(64,96)
		self:SetupTeams()
		self:InvalidateLayout()
	end

	
	function PANEL:SetupTeams()
		self.TeamSpace:Clear()
		local teamcount = self:GetPlayingTeamCount()
		local wscale = 1
		local hscale = 1
		if teamcount > 1 then
			wscale = 0.5
		end
		if teamcount > 2 then
			hscale = 0.5
		end
		if teamcount > 4 then
			wscale = 0.25
		end
		local teams = GAMEMODE.Teams
		
		for k,v in pairs(teams) do
			if v and (#team.GetPlayers(k) > 0) then
				local panel = vgui.Create("sdm_sb_teamboard",self.TeamSpace)
				panel:SetBGColor(Color(100,100,100,255))
				--panel:SetPos(16,16)
				panel:SetSize(self.TeamSpace:GetWide()*wscale,self.TeamSpace:GetTall()*hscale)
				panel.scoreboard = self
				self.TeamSpace:AddItem(panel)
				panel:SetTeam(k)
			end
		end
		self:UpdateSpectators()
		if #(self.TeamSpace.Items) == 0 then
			self:ShowNoTeamsPanel()
		end
	end
	
	function PANEL:Think()
		if CurTime()-self.LastRefresh > 0.1 then
			local timeleft = tostring(math.max(math.floor(GAMEMODE:GetGNWFloat("MapEndTime")),0))
			self.TextTable[1] = GAMEMODE:GetGNWVar("ServerName")
			self.TextTable[3] = #player.GetAll()
			self.TextTable[5] = string.FormattedTime(timeleft,"%02i:%02i")
			local text = table.concat(self.TextTable)
			self.ServerInfo.ServerName:SetText(text) --really messy but whatever
			self:Refresh()
			self.LastRefresh = CurTime()
		end
	end
	
	function PANEL:ShowNoTeamsPanel()
		self:InvalidateLayout()
		self.NoTeamsPanel = vgui.Create("sdm_labelbox",self.TeamSpace)
		self.NoTeamsPanel:SetAutoStretchVertical(false)
		self.NoTeamsPanel:SetSize(self.TeamSpace:GetWide(),self.TeamSpace:GetTall())
		self.NoTeamsPanel.Label:SetSize(self.TeamSpace:GetWide(),self.TeamSpace:GetTall())
		self.NoTeamsPanel:SetFont("sdm_title")
		self.NoTeamsPanel:SetText("No players have joined the game!")
		self.NoTeamsPanel:InvalidateLayout()
		self.NoTeamsPanel.NoTeamsPanel = true
		self.TeamSpace:AddItem(self.NoTeamsPanel)
	end
	
	function PANEL:UpdateSpectators()
		local players = team.GetPlayers(TEAM_SPECTATOR)
		for k,v in ipairs(players) do
			players[k] = v:Nick()
		end
		local specs = "Spectators: "..string.Implode(", ",players)
		self.SpectatorsBox:SetText(specs)
	end
	
	function PANEL:AddPlayer(pl)
		--self.ServerInfo.ServerName:SetText(GetGlobalString("ServerName")..": "..#player.GetAll().."/"..game.MaxPlayers())
		if pl:Team() == TEAM_SPECTATOR then
			self:UpdateSpectators()
			return
		end
		local teampanel = not self:GetTeamPanel(pl:Team())
		if not teampanel then
			self:SetupTeams()
		else
			teampanel:AddPlayer(pl)
		end
	end
	
	function PANEL:UpdatePlayerTeam(pl)
		self:UpdateSpectators()
		local foundteam = false
		for _,teampanel in ipairs(self.TeamSpace.Items) do
			if not teampanel.NoTeamsPanel then
				for _,playerpanel in ipairs(teampanel.List.Items) do
					if playerpanel:GetPlayer() == pl then
						teampanel:RemovePlayer(pl)
						self:AddPlayer(pl)
						foundteam = true
					end
				end
			end
		end
		if not foundteam then
			self:SetupTeams()
		end
	end
	
	--hook.Add("OnPlayerChangedTeam","ScoreboardUpdate",function(pl,oldteam,newteam)
	--	timer.Simple(0.1,function() GAMEMODE.ScoreBoard:UpdatePlayerTeam(pl) end)
	--end)
	
	function PANEL:SortPlayerTeam(pl)
		local panel = self:GetTeamPanel(pl:Team())
		if panel then
			panel:SortPlayers()
		else
			self:SetupTeams()
		end
	end
	
	function PANEL:ValidateTeam(teamid)
		local panel = self:GetTeamPanel(teamid)
		if panel then
			panel:ValidatePlayers()
			if #panel.List.Items == 0 then
				self:SetupTeams()
			end
		end
	end
	
	function PANEL:GetTeamPanel(teamid)
		for k,v in ipairs(self.TeamSpace.Items) do
			if not v.NoTeamsPanel then
				if v:GetTeam() == teamid then
					return v
				end
			end
		end
		return false
	end
	
	function PANEL:Refresh()
		for k,v in pairs(self.TeamSpace.Items) do
			if v.SortPlayers then
				v:SortPlayers()
			end
		end
	end
	
	--[[
	1=[1,1]
	2=[2,1]
	3=[2,2]
	4=[2,2]
	5=[3,2]
	6=[3,2]
	7=[4,2]
	8=[4,2]
	]]
	
	vgui.Register("sdm_sb_scoreboard",PANEL,"DPanel")
	
