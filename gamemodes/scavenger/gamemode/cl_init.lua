include("shared.lua")


local function hideinstructions()
	gamemode.Call("RemoveMenuInstructions")
end

function GM:ShowMenuInstructions()
	local panel = vgui.Create("sdm_labelbox")
	if panel then
		panel:SetSkin("sg_menu")
		panel:SetFont("DebugFixed")
		panel:SetAlignment(TEXT_ALIGN_CENTER)
		panel:SetAutoStretchVertical(false)
		panel:SetText("Hold down the Spawn Menu key (default 'Q') to open the menu and join the game.")
		--panel:SizeToContents()
		panel:InvalidateLayout()
		panel:SizeToContents()
		panel:SetPos(ScrW()-panel:GetWide()-32,ScrH()-panel:GetTall()-32)
		self:RemoveMenuInstructions()
		self.MenuInstructionsPanel = panel
	end
	hook.Add("OnSpawnMenuOpen","HideMenuInstructions",hideinstructions)
end

function GM:RemoveMenuInstructions()
	if IsValid(self.MenuInstructionsPanel) then
		self.MenuInstructionsPanel:Remove()
	end
	--hook.Remove("OnSpawnMenuOpen","HideMenuInstructions")
end

hook.Add("InitPostEntity","SetupScoreboard",function()

	GAMEMODE.ScoreBoard = vgui.Create("sdm_sb_scoreboard")

	if IsValid(GAMEMODE.ScoreBoard) then
		GAMEMODE.ScoreBoard:AutoSetup()
		GAMEMODE.ScoreBoard:SetSkin("sg_menu")
		GAMEMODE.ScoreBoard:SetVisible(false)
	end

	GAMEMODE.Menu = vgui.Create("sdm_mainmenu")

	if IsValid(GAMEMODE.Menu) then
		GAMEMODE.Menu:AutoSetup()
		GAMEMODE.Menu:SetSkin("sg_menu")
		GAMEMODE.Menu:SetVisible(false)
		GAMEMODE:ShowMenuInstructions()
	end

end)

function GM:ScoreboardShow()
	if IsValid(self.ScoreBoard) then
		self.ScoreBoard:SetVisible(true)
		self.ScoreBoard:MakePopup()
		self.ScoreBoard:SetKeyboardInputEnabled(false)
	end
end

function GM:ScoreboardHide()
	if IsValid(self.Scoreboard) then
		self.ScoreBoard:SetVisible(false)
	end
end

function GM:SpawnMenuEnabled()
	return false
end

function GM:OnSpawnMenuOpen()
	if IsValid(self.Menu) then
		self.Menu:SetVisible(true)
		self.Menu:MakePopup()
		self.Menu:SetKeyboardInputEnabled(false)
	end
end

function GM:OnSpawnMenuClose()
	if IsValid(self.Menu) then
		self.Menu:SetVisible(false)
	end
end

local last_movez = 0
local last_landz = 0
local sprint_ang = 0

function GM:CalcView(pl,pos,angles,fov)
	local tab = self.BaseClass:CalcView(pl,pos,angles,fov)
	if pl.landingtime and CurTime()-pl.landingtime < math.Min(math.sqrt(pl.landingspeed)/35,1) then
		local progress = math.sqrt(math.Clamp((CurTime()-pl.landingtime)/math.Min(math.sqrt(pl.landingspeed)/35,1),0,1))
		last_landz = math.sin(progress*math.pi)*math.sqrt(pl.landingspeed)/13
		tab.origin.z = tab.origin.z-last_landz*0.7
	else
		last_landz = 0
	end
	local pl_z = pl:GetVelocity().z
	local sign = 1
	if pl_z < 0 then
		sign = -1
	end
	last_movez=math.Approach(last_movez,math.sqrt(math.abs(pl_z))/34*sign,10*FrameTime())
	if tab.vm_origin then
		tab.vm_origin.z = tab.vm_origin.z-math.Clamp(last_landz+last_movez,-3,3)
	end
	if pl.sprinting then
		if IsValid(pl:GetActiveWeapon()) then
			pl:GetActiveWeapon().BobScale = 4
		end
		sprint_ang = math.Approach(sprint_ang,-13,80*FrameTime())
	else
		if IsValid(pl:GetActiveWeapon()) then
			pl:GetActiveWeapon().BobScale = 1
		end
		sprint_ang = math.Approach(sprint_ang,0,80*FrameTime())
	end
	if tab.vm_angles then
		tab.vm_angles:RotateAroundAxis(tab.vm_angles:Right(),sprint_ang)
	end
	return tab
end

usermessage.Hook("sdm_pldmged",function(um)
	--um:ReadEntity():EmitSound("physics/plastic/plastic_box_impact_bullet5.wav")
	surface.PlaySound("physics/plastic/plastic_box_impact_bullet5.wav")
	surface.PlaySound("physics/plastic/plastic_box_impact_bullet5.wav")
end)


local function getweapontoswitchto(pl,slot)
	local tab = {}
	for k,v in pairs(pl:GetWeapons()) do
		if v.Slot == slot then
			table.insert(tab,v)
		end
	end
	local wep = pl:GetActiveWeapon()
	table.SortByMember(tab,"SlotPos")
	for k,v in pairs(tab) do
		if nextiswep then
			wep = v
			break
		end
		if v == wep then
			nextiswep = true
		end
	end
	return wep
end

local slottranslate = {}
	slottranslate["slot1"] = 0
	slottranslate["slot2"] = 1
	slottranslate["slot3"] = 2
	slottranslate["slot4"] = 3
	slottranslate["slot5"] = 4
	slottranslate["slot6"] = 5
	slottranslate["slot7"] = 6
	slottranslate["slot8"] = 7
	slottranslate["slot9"] = 8

function GM:PlayerBindPress(pl,bind,pressed)
	if slottranslate[bind] then
		local wep = getweapontoswitchto(pl,slottranslate[bind])
		if IsValid(wep) then
			RunConsoleCommand("use",wep:GetClass())
		end
		return true
	end
	return false
end
