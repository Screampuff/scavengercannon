HUD = {}
HUD.Elements = {}


--[[PanelInfo structure:
Type: The type of VGUI control
Name: Unique identifier
HideOnSpectate: bool
HideOnPlaying: bool
HideOnDead: bool
HideOnAlive: bool

OnInit: Function to call when the panel is created.
OnRemove: Function to call when the panel is removed.
]]

function HUD.AddElement(refinfo)
	local info = table.Copy(refinfo)
	HUD.BuildFromInfo(info)
	HUD.Elements[info.Name] = info
	HUD.PerformLayout()
end

local lastteam = TEAM_CONNECTING
local wasalive = true
local alive = false
local playing = false

local function ElementIsVisible(info)
	return ((alive and not info.HideOnAlive) or (not alive and (not info.HideOnDead or not playing))) and ((playing and not info.HideOnPlaying) or (not playing and not info.HideOnSpec))
end

function HUD.BuildFromInfo(info)
	local name = info.Name
	if HUD.Elements[name] and IsValid(HUD.Elements[name].Panel) then
		HUD.Elements[name].Panel:Remove()
	end
	local panel = vgui.Create(info.Type)
	panel.info = info
	if info.OnInit then
		info.OnInit(panel,info)
	end
	if info.Skin then
		panel:SetSkin(info.Skin)
	end
	panel.x = info.x or 0
	panel.y = info.y or 0
	panel:SetSize(info.wide or panel:GetWide(),info.tall or panel:GetTall())
	info.Panel = panel
	if info.OnHUDUpdate then
		info.LastHUDUpdate = 0
		info.HUDUpdateInterval = info.HUDUpdateInterval or 1
	end
	panel:SetVisible(ElementIsVisible(info))
	return panel
end

function HUD.Clear()
	for name,info in pairs(HUD.Elements) do
		if IsValid(info.Panel) then
			info.Panel:Remove()
		end
		HUD.Elements[name] = nil
	end
end

function HUD.Rebuild()
	for name,info in pairs(HUD.Elements) do
		HUD.BuildFromInfo(info)
	end
	HUD.PerformLayout()
end

local anchors = {"top","none","bottomleft"}

local function SortTop(elements)
	if not elements then
		return
	end
	local totalx = 0
	local totaly = 0
	local hw = ScrW()/2
	for k,v in pairs(elements) do
		totalx = totalx+v.Panel:GetWide()
	end
	offsetx = 0
	for k,v in pairs(elements) do
		v.Panel.x = offsetx+hw-totalx/2
		offsetx = offsetx+v.Panel:GetWide()+4
	end
end

local function SetupBottomLeft(elements)
	local h = ScrH()
	local totalx = 0
	for k,v in pairs(elements) do
		v.Panel:SetPos(v.x+totalx,h-v.Panel:GetTall()+v.y)
		totalx = totalx+v.Panel:GetWide()+6
	end
end

local function sortascend(a,b)
	return a > b
end

function HUD.PerformLayout()
	local elementsbyanchor = {}
	for index,anchor in pairs(anchors) do
		elementsbyanchor[anchor] = {}
		for k,v in pairs(HUD.Elements) do
			if v.Panel:IsVisible() and (v.anchor == anchor) then
				table.insert(elementsbyanchor[anchor],v)
			end
		end
		table.SortByMember(elementsbyanchor[anchor],"sortpriority",sortascend)
	end
	SortTop(elementsbyanchor["top"])
	SetupBottomLeft(elementsbyanchor["bottomleft"])
end

hook.Add("Think","HUDThink",function()
	local pl = LocalPlayer()
	if not IsValid(pl) then
		return
	end
	local startedspec = false
	local startedplaying = false
	local spawned = false
	local died = false
	alive = pl:Alive()
	playing = (pl:Team() ~= TEAM_SPECTATOR)
	if (not playing) and (lastteam ~= TEAM_SPECTATOR) then
		startedspec = true
		lastteam = pl:Team()
	elseif (playing) and (lastteam == TEAM_SPECTATOR) then
		startedplaying = true
		lastteam = pl:Team()
	end
	if alive and not wasalive then
		spawned = true
		wasalive = alive
	elseif not alive and wasalive then
		died = true
		wasalive = alive
	end
	local alive = LocalPlayer():Alive()
	local ctime = CurTime()
	if (spawned or died or startedspec or startedplaying) then
		for k,v in pairs(HUD.Elements) do
			if (spawned and v.HideOnAlive) or (died and playing and v.HideOnDead) or (startedspec and v.HideOnSpectate) or (startedplaying and v.HideOnPlaying) then
				v.Panel:SetVisible(false)
			else
				v.Panel:SetVisible(ElementIsVisible(v))
			end
		end
		HUD.PerformLayout()
	end
	for k,v in pairs(HUD.Elements) do
		if v.OnHUDUpdate and v.Panel:IsVisible() and (ctime-v.LastHUDUpdate > v.HUDUpdateInterval) then
			v.OnHUDUpdate(v.Panel,v)
			v.LastHUDUpdate = ctime
		end
	end
end)

local DefaultHUDElements = {
	["CAchievementNotificationPanel"] = true,
	["CHudHealth"] = false,
	["CHudSuitPower"] = false,
	["CHudBattery"] = false,
	["CHudCrosshair"] = true,
	["CHudAmmo"] = false,
	["CHudSecondaryAmmo"] = false,
	["CHudChat"] = true,
	["CHudCloseCaption"] = true,
	["CHudCredits"] = true,
	["CHudDeathNotice"] = true,
	["CHudTrain"] = true,
	["CHudMessage"] = true,
	["CHudMenu"] = true,
	["CHudWeapon"] = true,
	["CHudWeaponSelection"] = true,
	["CHudGMod"] = true,
	["CHudDamageIndicator"] = true,
	["CHudHintDisplay"] = true,
	["CHudVehicle"] = true,
	["CHudVoiceStatus"] = true,
	["CHudVoiceSelfStatus"] = true,
	["CHudSquadStatus"] = false,
	["CHudZoom"] = true,
	["CHudCommentary"] = true,
	["CHudGeiger"] = true,
	["CHudHistoryResource"] = false,
	["CHudAnimationInfo"] = true,
	["CHUDAutoAim"] = true,
	["CHudFilmDemo"] = true,
	["CHudHDRDemo"] = true,
	["CHudPoisonDamageIndicator"] = true,
	["CPDumpPanel"] = true
}

function GM:HUDShouldDraw(name)
	return DefaultHUDElements[name]
end




local timeremaining = {}
timeremaining.Type = "sdm_timer"
timeremaining.Name = "Timer"
timeremaining.x = 0
timeremaining.y = 12
timeremaining.anchor = "top"
timeremaining.centerx = true
timeremaining.centery = false
timeremaining.sortpriority = 0
timeremaining.Skin = "sg_menu"
timeremaining.HideOnSpectate = false
timeremaining.HideOnDead = true
timeremaining.HUDUpdateInterval = 1

function timeremaining.OnHUDUpdate(panel,info)
	panel:SetEndTime(GAMEMODE:GetGNWVar("RoundEndTime"))
end

local fragcounter = {}
fragcounter.Type = "sdm_fragpanel"
fragcounter.Name = "LocalFrags"
fragcounter.x = 0
fragcounter.y = 12
fragcounter.anchor = "top"
fragcounter.centerx = true
fragcounter.centery = false
fragcounter.sortpriority = 1
fragcounter.Skin = "sg_menu"
fragcounter.HideOnSpectate = true
fragcounter.HideOnDead = true

function fragcounter.OnInit(panel,info)
	panel:SetPlayer(LocalPlayer())
end

local fragsbehind = {}
fragsbehind.Type = "sdm_dm_fragsbehind"
fragsbehind.Name = "LocalFragsBehind"
fragsbehind.x = 0
fragsbehind.y = 12
fragsbehind.wide = 128
fragsbehind.anchor = "top"
fragsbehind.centerx = true
fragsbehind.centery = false
fragsbehind.sortpriority = 2
fragsbehind.Skin = "sg_menu"
fragsbehind.HideOnSpectate = true
fragsbehind.HideOnDead = true

fragsbehind.OnInit = fragcounter.OnInit

local health = {}
health.Type = "sdm_healthpanel"
health.Name = "Health"
health.x = 32
health.y = -16
health.wide = 112
health.tall = 72
health.anchor = "bottomleft"
health.centerx = true
health.centery = false
health.sortpriority = 0
health.Skin = "sg_menu"
health.HideOnSpectate = true
health.HideOnDead = true

health.OnInit = fragcounter.OnInit

local armor = {}
armor.Type = "sdm_armorpanel"
armor.Name = "Armor"
armor.x = 32
armor.y = -16
armor.wide = 96
armor.tall = 64
armor.anchor = "bottomleft"
armor.centerx = true
armor.centery = false
armor.sortpriority = 1
armor.Skin = "sg_menu"
armor.HideOnSpectate = true
armor.HideOnDead = true

armor.OnInit = fragcounter.OnInit

local energy = {}
energy.Type = "sdm_energypanel"
energy.Name = "Energy"
energy.x = 32
energy.y = -16
energy.wide = 72
energy.tall = 48
energy.anchor = "bottomleft"
energy.centerx = true
energy.centery = false
energy.sortpriority = 2
energy.Skin = "sg_menu"
energy.HideOnSpectate = true
energy.HideOnDead = true

energy.OnInit = fragcounter.OnInit

local function setupdm()
	HUD.Clear()
	if GAMEMODE:GetGNWFloat("TimeLimit") ~= 0 then
		HUD.AddElement(timeremaining)
	end
	HUD.AddElement(fragcounter)
	HUD.AddElement(fragsbehind)
	HUD.AddElement(health)
	HUD.AddElement(armor)
	HUD.AddElement(energy)
end

hook.Add("OnRoundStart","SetupDMHUD",setupdm)
