local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:SetTeam(teamid)
		self.team = teamid
	end

	local teamstostrings = {}
		teamstostrings[TEAM_UNASSIGNED] = "unassigned"
		teamstostrings[TEAM_SPECTATOR] = "spectators"
		teamstostrings[TEAM_RED] = "red"
		teamstostrings[TEAM_BLUE] = "blue"
		teamstostrings[TEAM_GREEN] = "green"
		teamstostrings[TEAM_YELLOW] = "yellow"
		teamstostrings[TEAM_ORANGE] = "orange"
		teamstostrings[TEAM_PURPLE] = "purple"
		teamstostrings[TEAM_BROWN] = "brown"
		teamstostrings[TEAM_TEAL] = "teal"	
		
	function PANEL:DoClick()
		RunConsoleCommand("changeteam",self.team)
		self.Menu:Remove()
		gui.EnableScreenClicker(false)
	end

	vgui.Register("sdm_teamjoinbutton",PANEL,"DButton")

local PANEL = {}
	
	function PANEL:Init()
		self.teams = {}
		self.Form = vgui.Create("DForm",self)
		self:SetTitle("Select Team")
		self.Form:SetName("")
		self.initialized = true
		for k,v in pairs(GAMEMODE.Teams) do
			if v then
				self:AddTeam(k)
			end
		end
	end
	
	function PANEL:AutoSetup()
		self:SetSize(300,260)
		self:SetPos(ScrW()/2-self:GetWide()/2,ScrH()/2-self:GetTall()/2)
	end

	function PANEL:AddTeam(teamid)
		if not self.teams[teamid] then
			local button = vgui.Create("sdm_teamjoinbutton",self.Form)
			self.Form:AddItem(button)
			self.teams[teamid] = button
			button.ColorSquare = vgui.Create("DImage",button)
			button.ColorSquare:SetImage("vgui/sgskin/c_holo")
				button.ColorSquare:SetSize(12,12)
				button.ColorSquare:SetPos(4,button:GetTall()/2-button.ColorSquare:GetTall()/2)
				button.ColorSquare:SetImageColor(team.GetColor(teamid))
				button.ColorSquare:SetVisible(true)
			button.Menu = self
			button:SetTeam(teamid)
			button:SetText(team.GetName(teamid))
		end
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		self.Form:SetPos(4,21)
		self.Form:SetSize(self:GetWide()-8,self:GetTall()-21)
	end
	
	vgui.Register("sdm_teamjoinmenu",PANEL,"DFrame")
