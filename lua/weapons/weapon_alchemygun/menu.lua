AddCSLuaFile()

local SWEP = SWEP or weapons.GetStored("weapon_alchemygun")
local color_red = Color(255,0,0,255)
local color_red_colorblind = Color(190,76,0,255)
local color_green = Color(0,255,0,255)
local color_green_colorblind = Color(124,218,255,255)

local function PlayerColor(self)
	local bgcol = Vector(0,0,0)
	if IsValid(LocalPlayer()) then
		if LocalPlayer():Team() == 1001 then --unassigned
			bgcol = LocalPlayer():GetPlayerColor()
			self.BGColor = Color(bgcol.r * 255, bgcol.g * 255, bgcol.b * 255, 255)
		else
			self.BGColor = team.GetColor(LocalPlayer():Team())
		end
		if (self.BGColor.r + self.BGColor.g + self.BGColor.b) / 3 < 150 then
			self.TextColor = Color(255,255,255,255)
		else
			self.TextColor = Color(0,0,0,255)
		end
	end
	for i=1,4 do
		if self.items then
			self.items[i].Type:SetTextColor(self.TextColor)
			self.items[i].Cost:SetTextColor(self.TextColor)
		end
	end
	if self.HaveLabel then
		self.HaveLabel:SetTextColor(self.TextColor)
	end
	if self.CostLabel then
		self.CostLabel:SetTextColor(self.TextColor)
	end

	self:SetBackgroundColor(self.BGColor)
end

--Preview panel border

local PANEL = {}

PANEL.BGColor 	= Color(255,255,255,255)

function PANEL:Paint()
	SKIN:PaintPreview(self,self:GetWide(),self:GetTall())
end

vgui.Register( "DPanelPreview", PANEL, "DPanel" )

-------------------------------------------------------------------------------
--								MENU
-------------------------------------------------------------------------------

local PANEL = {}

PANEL.BGColor 	= Color(50,50,50,255)
PANEL.TextColor = Color(255,255,255,255)

function PANEL:Paint()
	SKIN:PaintFrame(self,self:GetWide(),self:GetTall())
end

function PANEL:SetWeapon(wep)
	if self.wep ~= wep then
		self.wep = wep
		self.CostFrame:SetWeapon(wep)
	end
end

function PANEL:AutoSetup()
	self:SetSize(500,400)
	self:SetPos(ScrW()/2-self:GetWide()/2,ScrH()/2-self:GetTall()/2)
end

function PANEL:PopulateWithStock()
	if self.stockpopulated then
		return
	end
	for k,v in pairs(SWEP.StockProps) do
		self:AddModel(v.model,v.skin,true)
	end
	self.stockpopulated = true
end

function PANEL:OpenMenu()
	if self.DoAutoSetup then
		self.DoAutoSetup = false
		self:AutoSetup()
	end
	PlayerColor(self)
	self:SetVisible(true)
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	self.CostFrame:Update()
end

function PANEL:CloseMenu()
	self:SetVisible(false)
end

function PANEL:Init()
	include("autorun/scavgun_skins.lua")
	self:SetSkin("sg_menu")
	PlayerColor(self)
	self.PreviewFrame = vgui.Create("DPanelPreview",self)
	self.PreviewBox = vgui.Create("DModelPanel",self.PreviewFrame)
	self.PreviewBox:SetModel("models/Items/car_battery01.mdl")
	self.PreviewBox:SetFOV(90)
	self.PreviewBox:SetLookAt(Vector(0,0,0))
	self.CostFrame = vgui.Create("alchmenu_costboard",self)
	self.CostFrame.Menu = self
	self.IconSheet = vgui.Create("DPropertySheet",self)
	self.StockBox = vgui.Create("DPanelList")
	self.StockBox:EnableHorizontal(true)
	self.StockBox:EnableVerticalScrollbar(true)
	self.LearnedBox = vgui.Create("DPanelList")
	self.LearnedBox:EnableHorizontal(true)
	self.LearnedBox:EnableVerticalScrollbar(true)
	self.IconSheet:AddSheet("#scav.alchemy.stockitems",self.StockBox,"icon16/wrench.png",false,false)
	self.IconSheet:AddSheet("#scav.alchemy.learneditems",self.LearnedBox,"icon16/brick_add.png",false,false)
	self.Initialized = true
end

function PANEL:PerformLayout()
	if not self.Initialized then
		return
	end
	self:SetSkin("sg_menu")
	PlayerColor(self)
	local pbsize = self:GetWide()/2-16
	self.PreviewFrame:SetPos(16,24)
	self.PreviewFrame:SetSize(pbsize,pbsize)
	self.PreviewBox:SetPos(8,8)
	self.PreviewBox:SetSize(self.PreviewFrame:GetWide()-16,self.PreviewFrame:GetTall()-16)
	self.CostFrame:SetSize(self.PreviewFrame:GetWide(),self:GetTall()-self.PreviewFrame.y-self.PreviewFrame:GetTall()-32)
	self.CostFrame:SetPos(self.PreviewFrame.x,self.PreviewFrame.y+self.PreviewFrame:GetTall()+8)
	self.IconSheet:SetPos(self:GetWide()/2+8,24)
	self.IconSheet:SetWide(self:GetWide()-self.IconSheet.x-24)
	self.IconSheet:SetTall(self:GetTall()-48)
	self.StockBox:SetSize(self.IconSheet:GetWide(),self.IconSheet:GetTall())
end



local function modelselect(panel)
	surface.PlaySound("npc/scanner/scanner_nearmiss1.wav")
	panel.Menu:SelectIcon(panel)
end

local siconglow = surface.GetTextureID("vgui/spawnmenu/hover")
local siconglowmat = Material("vgui/spawnmenu/hover")
local glowcolvec = Vector(1,1,1)

--paint selection border
local function siconpaintover(panel)
	if panel.Menu.selectedicon == panel then
		local playercolor = LocalPlayer():GetPlayerColor()
		local brightest = 0
		if playercolor.x > brightest then
			brightest = playercolor.x
		end
		if playercolor.y > brightest then
			brightest = playercolor.y
		end
		if playercolor.z > brightest then
			brightest = playercolor.z
		end
		if brightest == 0 then
			glowcolvec.x = 1
			glowcolvec.y = 1
			glowcolvec.z = 1
		else
			glowcolvec.x = playercolor.r / brightest
			glowcolvec.y = playercolor.g / brightest
			glowcolvec.z = playercolor.b / brightest
		end
		siconglowmat:SetVector("$color",glowcolvec)
		surface.SetTexture(siconglow)
		surface.DrawTexturedRect(0,0,panel:GetWide(),panel:GetTall())
		glowcolvec.x = 1
		glowcolvec.y = 1
		glowcolvec.z = 1
		siconglowmat:SetVector("$color",glowcolvec)
	end
end

--insufficient ammo, paint icon red
local function siconpaintoverred(panel)
	siconpaintover(panel)
	surface.SetDrawColor(255,0,0,100)
	surface.DrawRect(0,0,panel:GetWide(),panel:GetTall())
end

function PANEL:AddModel(model,skin,stock)
	local panel = vgui.Create("SpawnIcon")
	panel.Menu = self
	panel:SetModel(model,skin)
	panel:SetSize(64,64)
--	panel:SetIconSize(64)
	panel:InvalidateLayout()
	panel.model = model
	panel.skin = skin
	panel:SetMouseInputEnabled(true)
	panel:SetEnabled(true)
	panel:SetToolTip(false)
	--panel.OnMousePressed = modelselect
	panel.DoClick = modelselect
	panel.PaintOver = siconpaintover
	local surf = SWEP:GetAlchemyInfo(model)
	local surftab = SWEP:GetSurfaceInfo(surf.material)
	panel.Costs = {}
	panel.Costs[1] = surftab.metal*surf.mass
	panel.Costs[2] = surftab.chem*surf.mass
	panel.Costs[3] = surftab.org*surf.mass
	panel.Costs[4] = surftab.earth*surf.mass
	if stock then
		self.StockBox:AddItem(panel)
	else
		self.LearnedBox:AddItem(panel)
	end
end

function PANEL:ForgetModels()
	self.LearnedBox:Clear()
end

function PANEL:SelectIcon(icon)
	self.selectedicon = icon
	self:SelectModel(icon.model,icon.skin)
end

function PANEL:SelectModel(model,skin)
	self.PreviewBox:SetModel(model,skin)
	local properties = SWEP:GetAlchemyInfo(model)
	local surfacetable = SWEP:GetSurfaceInfo(properties.material)
	self.PreviewBox:SetCamPos(Vector(7,0,6)*math.sqrt(properties.mass+2))
	local m = (surfacetable.metal*properties.mass)
	local c = (surfacetable.chem*properties.mass)
	local o = (surfacetable.org*properties.mass)
	local e = (surfacetable.earth*properties.mass)
	self.CostFrame:SetCosts(m,c,o,e)
	RunConsoleCommand("scav_ag_model",model)
	RunConsoleCommand("scav_ag_skin",skin)
end

vgui.Register("alchmenu",PANEL,"DPanel")

-------------------------------------------------------------------------------
--								COST BOARD
-------------------------------------------------------------------------------

local PANEL = {}

PANEL.BGColor 	= Color(50,50,50,255)
PANEL.TextColor = Color(255,255,255,255)

function PANEL:Paint()
	SKIN:PaintFrame(self,self:GetWide(),self:GetTall())
end

function PANEL:Init()
	include("autorun/scavgun_skins.lua")
	self:SetSkin("sg_menu")
	PlayerColor(self)
	self.OldAmmo = {}
	self.OldAmmo[1] = 0
	self.OldAmmo[2] = 0
	self.OldAmmo[3] = 0
	self.OldAmmo[4] = 0
	
	self.HaveLabel = vgui.Create("DLabel",self)
		self.HaveLabel:SetFont("Scav_ConsoleText")
		self.HaveLabel:SetText("#scav.alchemy.have")
		self.HaveLabel:SetTextColor(self.TextColor)
		self.HaveLabel:SizeToContents()
	self.CostLabel = vgui.Create("DLabel",self)
		self.CostLabel:SetFont("Scav_ConsoleText")
		self.CostLabel:SetText("#scav.alchemy.cost")
		self.CostLabel:SetTextColor(self.TextColor)
		self.CostLabel:SizeToContents()
	self.items = {}
	for i=1,4 do
		local panel = vgui.Create("DPanel",self)
		panel.Type = vgui.Create("DLabel",panel)
		panel.Type:SetFont("Scav_ConsoleText")
		panel.Type:SetTextColor(self.TextColor)
		panel.Image = vgui.Create("DImage",panel)
		panel.Image:SetSize(16,16)
		panel.Have = vgui.Create("DLabel",panel)
		panel.Have:SetFont("Scav_ConsoleText")
		panel.Have:SetText("0")
		panel.Have:SetTextColor(self.TextColor)
		panel.Cost = vgui.Create("DLabel",panel)
		panel.Cost:SetFont("Scav_ConsoleText")
		panel.Cost:SetText("0")
		panel.Cost:SetTextColor(self.TextColor)
		panel.RealCost = 0
		table.insert(self.items,panel)
	end
	self.items[1].Image:SetImage("hud/alchemy_gun/metal")
	self.items[1].Type:SetText("#scav.alchemy.ammometal")
	self.items[2].Image:SetImage("hud/alchemy_gun/chemicals")
	self.items[2].Type:SetText("#scav.alchemy.ammochems")
	self.items[3].Image:SetImage("hud/alchemy_gun/org")
	self.items[3].Type:SetText("#scav.alchemy.ammoorgan")
	self.items[4].Image:SetImage("hud/alchemy_gun/earth")
	self.items[4].Type:SetText("#scav.alchemy.ammoearth")
	self.Initialized = true
end

function PANEL:PerformLayout()
	if not self.Initialized then
		return
	end
	self:SetSkin("sg_menu")
	PlayerColor(self)
	self.HaveLabel:SizeToContents()
	self.CostLabel:SizeToContents()
	self.CostLabel:SetPos(self:GetWide()-self.CostLabel:GetWide()-32,6)
	self.HaveLabel:SetPos(self.CostLabel.x-self.HaveLabel:GetWide()-24,6)
	local topspace = self.HaveLabel.y+self.HaveLabel:GetTall()+2
	local remainingspace = self:GetTall()-self.HaveLabel.y*2-self.HaveLabel:GetTall()-2
	local spaceper = remainingspace/#self.items
	for k,v in pairs(self.items) do
		v.Image:SetSize(v:GetTall()-8,v:GetTall()-8)
		v.Image:SetPos(8,v:GetTall()/2-v.Image:GetTall()/2)
		v.Type:SizeToContents()
		v.Type:SetPos(v.Image.x+v.Image:GetWide(),v:GetTall()/2-v.Type:GetTall()/2)
		v.Have:SizeToContents()
		v.Have:SetPos(self.HaveLabel.x+self.HaveLabel:GetWide()/2-v.Have:GetWide()/2,v:GetTall()/2-v.Have:GetTall()/2)
		v.Cost:SizeToContents()
		v.Cost:SetPos(self.CostLabel.x+self.CostLabel:GetWide()/2-v.Cost:GetWide()/2,v:GetTall()/2-v.Cost:GetTall()/2)
		v:SetSize(self:GetWide()-8,spaceper)
		v:SetPos(4,(k-1)*spaceper+topspace)
	end
end

function PANEL:SetWeapon(wep)
	if self.wep ~= wep then
		self.wep = wep
		self:Update()
	end
end

function PANEL:Update()
	if not IsValid(self.wep) or not self:IsVisible() then
		return
	end
	for i=1,4 do
		if self.wep.dt["Ammo"..i] < self.items[i].RealCost then
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				self.items[i].Have:SetTextColor(color_red)
			else
				self.items[i].Have:SetTextColor(color_red_colorblind)
			end
		else
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				self.items[i].Have:SetTextColor(color_green)
			else
				self.items[i].Have:SetTextColor(color_green_colorblind)
			end
		end
	end
	if self.Menu then
		for k,v in pairs(self.Menu.StockBox:GetItems()) do
			local affordable = true
			for i=1,4 do
				if self.wep.dt["Ammo"..i] < v.Costs[i] then
					affordable = false
					break
				end
			end
			if not affordable then
				v.PaintOver = siconpaintoverred
			else
				v.PaintOver = siconpaintover
			end
		end
		for k,v in pairs(self.Menu.LearnedBox:GetItems()) do
			local affordable = true
			for i=1,4 do
				if self.wep.dt["Ammo"..i] < v.Costs[i] then
					affordable = false
					break
				end
			end
			if not affordable then
				v.PaintOver = siconpaintoverred
			else
				v.PaintOver = siconpaintover
			end
		end
	end
	self:InvalidateLayout()
end

function PANEL:AutoCosts()
	local model = GetConVar("scav_ag_model"):GetString()
	local modelinfo = SWEP:GetAlchemyInfo(model)
	local surfaceinfo = SWEP:GetSurfaceInfo(modelinfo.material)
	self:SetCosts(surfaceinfo.metal*modelinfo.mass,surfaceinfo.chem*modelinfo.mass,surfaceinfo.org*modelinfo.mass,surfaceinfo.earth*modelinfo.mass)
end

function PANEL:SetCosts(metal,chem,org,earth)
	self.items[1].Cost:SetText(math.ceil(metal))
	self.items[1].RealCost = metal
	self.items[2].Cost:SetText(math.ceil(chem))
	self.items[2].RealCost = chem
	self.items[3].Cost:SetText(math.ceil(org))
	self.items[3].RealCost = org
	self.items[4].Cost:SetText(math.ceil(earth))
	self.items[4].RealCost = earth
	self:Update()
	self:InvalidateLayout()
end

function PANEL:Think()
	if IsValid(self.wep) then
		local update = false
		for i=1,4 do
			if self.OldAmmo[i] ~= self.wep.dt["Ammo"..i] then
				update = true
				self.OldAmmo[i] = self.wep.dt["Ammo"..i]
				self.items[i].Have:SetText(math.ceil(self.OldAmmo[i]))
			end
		end
		if update then
			self:Update()
		end
	end
end

vgui.Register("alchmenu_costboard",PANEL,"DPanel")

-------------------------------------------------------------------------------
--								AMMO HUD
-------------------------------------------------------------------------------

local PANEL = {}

PANEL.BGColor 	= Color(50,50,50,255)
PANEL.TextColor = Color(255,255,255,255)

function PANEL:Paint()
	--SKIN:PaintFrame(self,self:GetWide(),self:GetTall())
end

function PANEL:SetWeapon(wep)
	if self.wep ~= wep then
		self.wep = wep
		self.CostBoard:SetWeapon(wep)
		wep:ResetMenu()
	end
end

function PANEL:AutoSetup()
	self:SetSize(296,120)
	self:SetPos(ScrW()-self:GetWide()-32,ScrH()-self:GetTall()-16)
end

function PANEL:Init()
	include("autorun/scavgun_skins.lua")
	self:SetSkin("sg_menu")
	PlayerColor(self)
	self.CostBoard = vgui.Create("alchmenu_costboard",self)
	self.PreviewFrame = vgui.Create("DPanelPreview",self)
	self.PreviewIcon = vgui.Create("SpawnIcon",self.PreviewFrame)
	self.PreviewIcon:SetSize(64,64)
	self.Initialized = true
end

function PANEL:PerformLayout()
	if not self.Initialized then
		return
	end
	self:SetSkin("sg_menu")
	PlayerColor(self)
	self.PreviewFrame:SetSize(96,self:GetTall())
	self.PreviewIcon:SetPos((self.PreviewFrame:GetWide()-self.PreviewIcon:GetWide())/2,(self:GetTall()-self.PreviewIcon:GetTall())/2)
	self.CostBoard:SetPos(self.PreviewFrame:GetWide(),0)
	self.CostBoard:SetSize(self:GetWide()-self.PreviewFrame:GetWide(),self:GetTall())
end

function PANEL:Think()
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) or (wep:GetClass() ~= "weapon_alchemygun") then
		self:SetVisible(false)
	end
end

function PANEL:Update()
	local model = GetConVar("scav_ag_model"):GetString()
	local skin = GetConVar("scav_ag_skin"):GetInt()
	self.PreviewIcon:SetModel(model,skin)
	self.CostBoard:AutoCosts()
end

vgui.Register("alch_HUD",PANEL,"DPanel")

local HUD = vgui.Create("alch_HUD")
	HUD:SetVisible(false)
	HUD:SetSkin("sg_menu")
	HUD:AutoSetup()
	
	local function HUDUpdateCallback(cvar,previousvalue,newvalue)
		HUD:Update()
	end
	
	cvars.AddChangeCallback("scav_ag_model",HUDUpdateCallback)
	cvars.AddChangeCallback("scav_ag_skin",HUDUpdateCallback)

	SWEP.HUD = HUD
	
hook.Add("InitPostEntity","SetupAlchMenu",function()
	SWEP.Menu = vgui.Create("alchmenu")
	SWEP.Menu:SetSkin("sg_menu")
	SWEP.Menu:SetVisible(false)
	SWEP.Menu.DoAutoSetup = true
end)

hook.Add("KeyPress","AlchMenuOpen",function(pl,key)
	local wep = pl:GetActiveWeapon()
	if IsValid(wep) and (wep:GetClass() == "weapon_alchemygun") and (key == IN_RELOAD) then
		wep:OpenMenu()
	end
end)

hook.Add("KeyRelease","AlchMenuOpen",function(pl,key)
	local wep = pl:GetActiveWeapon()
	if IsValid(wep) and (wep:GetClass() == "weapon_alchemygun") and (key == IN_RELOAD) then
		wep:CloseMenu()
	end
end)
