local func_empty = function()
end

GM.menu = NULL
GM.MenuOpen = false

local function getbottomofpanel(panel)
	return panel.y+panel:GetTall()
end
local function getrightofpanel(panel)
	return panel.x+panel:GetWide()
end

local MENU = {}

function MENU:Init()
	self.menus = {}
	self.sheet = vgui.Create("DPropertySheet",self)
		self.sheet.Paint = func_empty

	self.menulabel = vgui.Create("DLabel",self)
		self.menulabel:SetText("MAIN MENU")
		self.menulabel:SetFont("HUDHintTextLarge")

	self:AddSubMenu("sdm_submenu_main","Main","gui/silkicons/star")
	self:AddSubMenu("sdm_submenu_equipment","Equipment","gui/silkicons/bomb")
	self:AddSubMenu("sdm_submenu_playermodel","Player Model","gui/silkicons/group")
	self:AddSubMenu("sdm_submenu_options","Options","gui/silkicons/key")
	self.initialized = true
end

function MENU:Think()
	--[[
	if not input.IsKeyDown(KEY_Q) and self:IsValid() and self.QOpened then
		--self:Remove()
		self:SetVisible(false)
		self.MenuOpen = false
		gui.EnableScreenClicker(false)
	end
	]]
end

function MENU:AddSubMenu(classname,name,icon)
	panel = vgui.Create(classname,self.sheet)
	self.menus[name] = panel
	panel.Menu = self
	self.sheet:AddSheet(name,panel,icon,true,true)
	return self.menus[name]
end

function MENU:AutoSetup()
	self:SetPos(ScrW()*0.1,ScrH()*0.1)
	self:SetSize(ScrW()*0.8,ScrH()*0.8-64)
	self.menulabel:SetPos(12,10)
	self.menulabel:SizeToContents()
	self.sheet:SetSkin(self:GetSkin())
	for k,v in pairs(self.menus) do
		v:SetSkin(self:GetSkin())
	end
end

function MENU:SetMode(mode)
	self.menus["Main"].ModeLabel:SetText(mode)
	self.menus["Main"].DescLabel:SetText(GAMEMODE.Description)
end

function MENU:Close()
	self:SetVisible(false)
	gui.EnableScreenClicker(false)
	GAMEMODE.MenuOpen = false
end

function MENU:InvalidateLayout()
	if not self.initialized then
		return
	end
	
	--sheet
	self.sheet:SetPos(8,32)
	self.sheet:SetSize(self:GetWide()-16,self:GetTall()-self.sheet.y)
	for k,v in pairs(self.menus) do
		v:SetPos(0,46)
		v:SetSize(self.sheet:GetWide(),self.sheet:GetTall()-v.y)
	end
end

vgui.Register("sdm_mainmenu",MENU,"DPanel")

function GM:OnSpawnMenuOpen()
	self:OpenMenu()
end

function GM:OnSpawnMenuClose()
	if self.menu:IsValid() then
		self.menu:Close()
	end
end



---------------------------------------



	
	
	
-------------------------------------
local PANEL = {}

	local specbuttonpress = function(button)
		RunConsoleCommand("changeteam",TEAM_SPECTATOR)
		button.Menu:Close()
	end
	
	local joinbuttonpress = function(button)
		if team.Joinable(TEAM_UNASSIGNED) then
			RunConsoleCommand("changeteam",TEAM_UNASSIGNED)
		else
			local menu = vgui.Create("sdm_teamjoinmenu")
			menu:SetSkin("sg_menu")
			menu:MakePopup()
			menu:AutoSetup()
		end
		--GAMEMODE:SetPanelAsMenu(menu)
	end
	
	function PANEL:Init()
		self.SpecButton = vgui.Create("DButton",self)
			self.SpecButton:SetText("Spectate")		
		self.JoinButton = vgui.Create("DButton",self)
			self.JoinButton:SetText("Join Game")
		self.ModeLabel = vgui.Create("sdm_labelbox",self)
			self.ModeLabel:SetText(GAMEMODE:GetModeName())
		self.DescLabel = vgui.Create("sdm_labelbox",self)
			self.DescLabel:SetWrap(true)
			self.DescLabel:SetAutoStretchVertical(true)
			self.DescLabel:SetMargins(16,8)
		self.Logo = vgui.Create("DImage",self)
			self.Logo:SetImage("vgui/scavlogo1")
		self.initialized = true
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		self.SpecButton.Menu = self.Menu
		self.SpecButton.DoClick = specbuttonpress
		self.JoinButton.Menu = self.Menu
		self.JoinButton.DoClick = joinbuttonpress
		self.Logo:SetPos(16,16)
		local wh = math.min(self:GetWide()/2-32,self:GetTall()-32)
		self.Logo:SetSize(wh,wh)
		self.Logo:SetPos(16,16)
		
		--WATself.ModeLabel:SetText(GAMEMODE.NiceName)
		self.ModeLabel:SetSize(self:GetWide()-32-self.Logo:GetWide()-self.Logo.x,32)
		self.ModeLabel:SetPos(self.Logo.x+self.Logo:GetWide()+16,16)
		
		self.JoinButton:SetSize(self.ModeLabel:GetWide()/2-16,64)
		self.SpecButton:SetSize(self.ModeLabel:GetWide()/2-16,64)
		self.SpecButton:SetPos(self.ModeLabel.x+8,self:GetTall()-self.SpecButton:GetTall()-16)
		self.JoinButton:SetPos(self.SpecButton.x+self.SpecButton:GetWide()+16,self:GetTall()-self.JoinButton:GetTall()-16)
		
		
		--WATself.DescLabel:SetText(GAMEMODE.Description)
		self.DescLabel:SetSize(self.ModeLabel:GetWide(),self.JoinButton.y-self.ModeLabel.y-self.ModeLabel:GetTall()-32)
		self.DescLabel:SetPos(self.Logo.x+self.Logo:GetWide()+16,self.ModeLabel.y+self.ModeLabel:GetTall()+16)
	end

	vgui.Register("sdm_submenu_main",PANEL,"DPanel")

local function nametomodelname(modelname)
	return list.GetForEdit("PlayerOptionsModel")[modelname] or player_manager.TranslatePlayerModel(GetConVarString("cl_playermodel"))
end
	
local PANEL = {}
	function PANEL:Init()
	
		self.PreviewLabel = vgui.Create("sdm_labelbox",self)
		self.PreviewLabel:SetText(GetConVarString("cl_playermodel"))
		self.PreviewLabel:SetMargins(0,0)
		self.PreviewLabel:SetAlignment(TEXT_ALIGN_CENTER)
		self.PreviewBox = vgui.Create("DPanel",self)
		self.Preview = vgui.Create("DModelPanel",self.PreviewBox)
		self.Preview:SetModel(nametomodelname(GetConVarString("cl_playermodel")))
		self.Models = vgui.Create("DPanelList",self)
		self.Models:EnableHorizontal(true)
		self.Models:EnableVerticalScrollbar(true)

		self:SetupPlayerModels()

		self.initialized = true
	end
	
	local function pmodelbuttonpressed(button)
		RunConsoleCommand("cl_playermodel",button.nicename)
		LocalPlayer():EmitSound("buttons/button14.wav")
		button.Preview:SetModel(button.modelname)
		button.PreviewLabel:SetText(button.nicename)
	end
	
	function PANEL:SetupPlayerModels()
		self.Models:Clear()
		--for k,v in pairs(list.GetForEdit("PlayerOptionsModel")) do
		local playermodels = table.Merge(player_manager.AllValidModels(),list.GetForEdit("PlayerOptionsModel"))
		--table.SortByKey(playermodels)
		local alphabetizedkeys = {}
		for k,v in pairs(playermodels) do
			table.insert(alphabetizedkeys,k)
		end
		table.sort(alphabetizedkeys)
		
		--local i=0
		for k,name in pairs(alphabetizedkeys) do
			local model = playermodels[name]
			--i=i+1
			local icon = vgui.Create("SpawnIcon")
			icon:SetModel(model)
			icon:SetVisible(true)
			icon.modelname = model
			icon.nicename = name
			icon:SetMouseInputEnabled(true)
			icon.OnMousePressed = pmodelbuttonpressed --self.menu.wepclick1
			icon:SetEnabled(true)
			icon.Preview = self.Preview
			icon.PreviewLabel = self.PreviewLabel
			icon:SetToolTip(name)
			self.Models:AddItem(icon)
			--print(k)
		end
		--print(i)
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		

		
		self.Models:SetPos(self:GetWide()/3+64,32)
		self.Models:SetWide(self:GetWide()/3*2-96)
		self.Models:SetTall(self:GetTall()-64)
		self.Models:SetSkin(self:GetSkin())
		
		self.PreviewLabel:SetSkin(self:GetSkin())
		self.PreviewLabel:SetPos(32,32)
		self.PreviewLabel:SetSize(self:GetWide()/3-32,32)		
		
		self.PreviewBox:SetPos(32,72)
		self.PreviewBox:SetWide(self:GetWide()/3-32)
		self.PreviewBox:SetTall(self:GetTall()-104)
		self.PreviewBox:SetSkin(self:GetSkin())
		local dimensions = math.min(self.PreviewBox:GetTall()-32,self.PreviewBox:GetWide()-32)
		self.Preview:SetSize(dimensions,dimensions)
		--self.Preview:SetTall(self.Preview:GetWide())
		self.Preview:SetPos(self.PreviewBox:GetWide()/2-self.Preview:GetWide()/2,self.PreviewBox:GetTall()/2-self.Preview:GetTall()/2+8)
		self.Preview:RunAnimation(ACT_WALK)
		self.Preview:SetAnimated(true)
		self.Preview:SetAnimSpeed(1)
		self.Preview:SetFOV(85)
	end

	vgui.Register("sdm_submenu_playermodel",PANEL,"DPanel")
	
	
	
	
	CreateClientConVar("sdm_w2","weapon_backuppistol",true,true)
	
	local PANEL = {}
	local modelradius = {}
	
	local function LockedPosition(self)
		local ent = self:GetEntity()
		local angpos = ent:GetAttachment(ent:LookupAttachment("muzzle"))
		local bpos,bang = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
		local lookat = (angpos.Pos+bpos)/2
		self:SetLookAt(lookat)
		camvec = lookat*1
		camvec.x = lookat.x+math.cos(CurTime())*30
		camvec.y = lookat.y-math.sin(CurTime())*30
		camvec.z = 1
		self:SetCamPos(camvec)
	end
	
	function PANEL:Init()
		--weapon
			self.WepLabel = vgui.Create("sdm_labelbox",self)
				self.WepLabel:SetText("Secondary Weapon")
			self.WepDescLabel = vgui.Create("sdm_labelbox",self)
				self.WepDescLabel:SetText("This is a gun")
				self.WepDescLabel:SetWrap(true)
			self.WepPreviewLabel = vgui.Create("sdm_labelbox",self)
			self.WepSelectBox = vgui.Create("DPanelList",self)
				self:SetupWeaponSelection()
				self.WepSelectBox:EnableVerticalScrollbar(true)
			self.WepPreviewBox = vgui.Create("DPanel",self)
			self.WepPreview = vgui.Create("DModelPanel",self.WepPreviewBox)
			self.WepPreview.LayoutEntity = LockedPosition
			self:SetWeapon(GetConVarString("sdm_w2"))
		--extra
			self.ExtraLabel = vgui.Create("sdm_labelbox",self)
			self.ExtraLabel:SetText("Gadget - Not yet available.")
		self.initialized = true
	end
	
	local function weaponbuttonpressed(button)
		RunConsoleCommand("sdm_w2",button.weaponclassname)
		LocalPlayer():EmitSound("buttons/button14.wav")
		button.submenu:SetWeapon(button.weaponclassname)
	end

	local flavortexts = {
						["weapon_blackholegun"] = ('An awe and terror inspiring machine of war, the CF-2200 "Black Hole Gun" is one of the most dreaded weapons to see on the other side of the battlefield. It is capable of using any nearby matter to fuel its internal gravity manipulator. The weapon uses this manipulator to turn loose junk into a storm of deadly projectiles that fly toward the point of impact. Many users have reported a strange slowing of time during an active "black hole". \n \n This weapon is reccomended for advanced combatants.'),
						["weapon_alchemygun"] =   ('Originally designed as a tool to end world hunger, the technology behind the Alchemy Gun had so much potential in military applications that the original project was scrapped entirely and the team behind it found a new job in making it into a tool of war. This device will disassociate the elements of any object and store them for later use. A variety of useful items can be made using these gathered resources, such as health kits, ammunition, and powerful weapons. \n \n Reccomended for expert combatants.'),
						--["capture_device"] = ('    Much like its deadlier cousin, the SC-08 "Scavenger Cannon", the Capture Device is capable of picking up and storing various objects. Unlike the Scavenger Cannon, it has a capacity of one object and will not modify the original object in any way. The convenience of this is that while objects become irrecoverable or unstable once they enter the Scavenger Cannon, anything trapped in the Capture Device can be released at any time or injected into the Scavenger Cannon. \n \n Reccomended for experienced combatants.'),
						["weapon_backuppistol"] =  ("A standard pistol. While it may lack the immediate appeal of some of the other weapons available on the battlefield, its versatility makes it a life saver. This weapon feeds on your battle suit's energy reserves, which means that with proper use, you will never run out of ammo. The weapon can also be primed to fire up to ten beams at once with its secondary fire. Additional damage is inflicted upon enemy combatants that are already injured. \n \n Reccomended for newer combatants.")
					 }
	
	
	function PANEL:SetupWeaponSelection()
		self.WepSelectBox:Clear()
		local size = self.WepSelectBox:GetWide()
		for k,v in pairs(GAMEMODE:GetValidWeapons()) do
			local icon = vgui.Create("DImageButton",self.WepSelectBox)
			local weptab = weapons.Get(v)
			icon:SetImage("HUD/weapons/"..weptab.ClassName)
			icon:SetKeepAspect(true)
			icon:SetDrawBorder(true)
			icon:SetSize(size,size)
			--icon:SetModel(weptab.WorldModel)
			icon.submenu = self
			icon.weaponclassname = v
			icon.DoClick = weaponbuttonpressed
			icon:SetMouseInputEnabled(true)
			icon:SetToolTip(false)
			self.WepSelectBox:AddItem(icon)
		end
	end

	function PANEL:SetWeapon(classname)
		local wep = weapons.Get(classname)
		if not wep then
			return
		end
		self.WepPreview:SetModel(wep.WorldModel)
		self.WepPreview:LayoutEntity()
		self.WepPreviewLabel:SetText(wep.PrintName)
		self.WepDescLabel:SetText(flavortexts[classname])
		self.WepDescLabel:InvalidateLayout()
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end


		self.WepLabel:SetPos(16,16)
		self.WepLabel:SetSize(self:GetWide()-64,32)
		
		self.ExtraLabel:SetPos(16,self:GetTall()/2)
		self.ExtraLabel:SetSize(self:GetWide()-64,32)
		
		self.WepSelectBox:SetPos(32,getbottomofpanel(self.WepLabel)+8)
		self.WepSelectBox:SetSize(80,self:GetTall()/2-16-self.WepSelectBox.y)
		
		self.WepPreviewBox:SetPos(getrightofpanel(self.WepSelectBox)+8,getbottomofpanel(self.WepLabel)+8)
		self.WepPreviewBox:SetWide(self:GetWide()/3-32-48)
		self.WepPreviewBox:SetTall(self:GetTall()/2-16-self.WepPreviewBox.y)
		
		self.WepPreviewLabel:SetPos(getrightofpanel(self.WepPreviewBox)+8,getbottomofpanel(self.WepLabel)+8)
		self.WepPreviewLabel:SetSize(self:GetWide()-64-self.WepPreviewLabel.x,32)	
		
		self.WepDescLabel:SetPos(getrightofpanel(self.WepPreviewBox)+8,getbottomofpanel(self.WepPreviewLabel)+8)
		self.WepDescLabel:SetSize(self:GetWide()-64-self.WepDescLabel.x,self:GetTall()/2-16-self.WepDescLabel.y)
		
		local previewsize = math.min(self.WepPreviewBox:GetTall()-32,self.WepPreviewBox:GetWide()-32)
		self.WepPreview:SetSize(previewsize,previewsize)
		--self.Preview:SetTall(self.Preview:GetWide())
		self.WepPreview:SetPos(self.WepPreviewBox:GetWide()/2-self.WepPreview:GetWide()/2,self.WepPreviewBox:GetTall()/2-self.WepPreview:GetTall()/2+8)
		self.WepPreview:SetAnimated(true)
		self.WepPreview:SetAnimSpeed(1)
		self.WepPreview:SetCamPos(Vector(40,0,10))
		self.WepPreview:SetFOV(50)
		self.WepPreview:SetLookAt(vector_origin)
	end

	vgui.Register("sdm_submenu_equipment",PANEL,"DPanel")

	local PANEL = {}
	local oncolorpress = function()
		RunConsoleCommand("scav_opencolor")
	end
	--concommand: scav_opencolor
	--convar: cl_scav_high
	--convar: cl_scav_iconalpha
	--convar: scav_hands
	
	
	function PANEL:Init()
		self.ColorMenuButton = vgui.Create("DButton",self)
		self.ColorMenuButton:SetText("Select Color")
		self.ColorMenuButton.DoClick = oncolorpress
		self.initialized = true
	end

	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		self.ColorMenuButton:SetPos(32,32)
		self.ColorMenuButton:SetSize(96,32)
	end

	vgui.Register("sdm_submenu_options",PANEL,"DPanel")
