
local PANEL = {}
	function PANEL:Init()
		self:SetTitle("Round Winner")
		self.NameLabel = vgui.Create("DLabel",self)
			self.NameLabel:SetFont("DermaLarge")
		self.initialized = true
	end
	
	function PANEL:InvalidateLayout()
		if not self.initalized then
			return
		end
	end
	
	function PANEL:SetPlayer(pl)
		if self.Icon then
			self.Icon:Remove()
		end
		self.Icon = vgui.Create("AvatarImage",self)
		self.NameLabel:SetText(pl:Nick())
		self.NameLabel:SizeToContents()
		self.Icon:SetPlayer(pl)
	end
	
	function PANEL:AutoSetup()
		self:SetSize(430,180)
		self.Icon:SetSize(128,128)
		self.Icon:SetPos(16,40)
		self.NameLabel:SetPos(150,32)
	end
	

	vgui.Register("sdm_winnerpanel_pl",PANEL,"DFrame")
	
local PANEL = {}
	function PANEL:Init()
		self:SetTitle("Round Winner")
		self.NameLabel = vgui.Create("DLabel",self)
			self.NameLabel:SetFont("DermaLarge")
		self.Initialized = true
		self.TeamBox = vgui.Create("DPanelList",self)
	end
	
	function PANEL:InvalidateLayout()
		if not self.Initialized then
			return
		end
		self.NameLabel:SizeToContents()
		self.NameLabel:SetPos((self:GetWide()-self.NameLabel:GetWide())/2,32)
		self.TeamBox:SetPos(16,self.NameLabel.y+self.NameLabel:GetTall()+16)
		self.TeamBox:SetSize(self:GetWide()-32,self:GetTall()-self.TeamBox.y-16)
		
	end
	
	function PANEL:SetTeam(teamid)
		self.NameLabel:SetText(team.GetName(teamid).." wins the round!")
		self.NameLabel:SizeToContents()
		self.TeamBox:Clear()
		local w = self:GetWide()
		for _,pl in pairs(team.GetPlayers(teamid)) do
			local panel = vgui.Create("sdm_winnerpanel_team_playerbox",self)
			panel:SetSize(w,42)
			panel:SetPlayer(pl)
			self.TeamBox:AddItem(panel)
		end
		local col = table.Copy(team.GetColor(teamid))
		local mul = GetConVarNumber("scav_col_team_mul")
		col.r = col.r*mul
		col.g = col.g*mul
		col.b = col.b*mul
		self.m_bgColor = col
		self:SetVerticalScrollbarEnabled()
	end
	
	function PANEL:AutoSetup()
		self:SetSize(480,380)
		self:SetPos(ScrW()/2-self:GetWide()/2,ScrH()/2-self:GetTall()/2)
		self:SetSkin("sg_menu")
		self:MakePopup()
	end
	

	vgui.Register("sdm_winnerpanel_team",PANEL,"DFrame")
	
local PANEL = {}

function PANEL:Init()
	self.NameLabel = vgui.Create("DLabel",self)
		self.NameLabel:SetFont("HUDHintTextLarge")
	self.ScoreLabel = vgui.Create("DLabel",self)
		self.ScoreLabel:SetFont("HUDHintTextLarge")
	self.Icon = vgui.Create("AvatarImage",self)
	self.Initialized = true
end

function PANEL:SetPlayer(pl)
	self.Icon:Remove()
	self.Icon = vgui.Create("AvatarImage",self)
	self.Icon:SetPlayer(pl)
	self.Icon:SetSize(32,32)
	self.NameLabel:SetText(pl:Nick())
	self.ScoreLabel:SetText("score: "..pl:Frags())
end

function PANEL:InvalidateLayout()
	if not self.Initialized then
		return
	end
	self.NameLabel:SizeToContents()
	self.NameLabel:SetPos(self.Icon.x+self.Icon:GetWide()+8,(self:GetTall()-self.NameLabel:GetTall())/2)
	self.Icon:SetPos(12,5)
	self.ScoreLabel:SizeToContents()
	self.ScoreLabel:SetPos(self:GetWide()-128,(self:GetTall()-self.ScoreLabel:GetTall())/2)
end

vgui.Register("sdm_winnerpanel_team_playerbox",PANEL,"DPanel")
