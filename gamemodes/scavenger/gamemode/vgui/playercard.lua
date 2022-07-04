local PANEL = {}
PANEL.Player = NULL


function PANEL:Init()
	self.Initialized = true
	self.Icon = vgui.Create("DImage",self)
end

function PANEL:InvalidateLayout()
	if not self.Initialzied then
		return
	end
	self.Icon:SetWide(self:GetWide()/2-32)
	self.Icon:SetTall(self.Icon:GetWide())
end

function PANEL:SetPlayer(pl)
	self.Player = pl
	if IsValid(self.Icon) then
		self.Icon:Remove()
	end
	self.Icon = vgui.Create("AvatarImage",self)
	self.Icon:SetPlayer(pl)
	self:InvalidateLayout()
end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:AutoSetup()
	self:SetSize(300,300)
	self:SetPos((ScrW()-self:GetWide())/2,(ScrH()-self:GetTall())/2)
end

