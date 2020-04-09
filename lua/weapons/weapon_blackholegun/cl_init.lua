include("shared.lua")
SWEP.Ammo = 0
SWEP.LastDTAmmo = 0
killicon.Add("weapon_blackholegun","hud/weapons/weapon_blackholegun",color_white)
killicon.Add("scav_gravball","hud/weapons/weapon_blackholegun",color_white)

local selecttex = surface.GetTextureID("hud/weapons/weapon_blackholegun")
function SWEP:DrawWeaponSelection(x,y,w,h,a)
	surface.SetTexture(selecttex)
	local size = math.min(w,h)
	surface.SetDrawColor(255,255,255,a)
	surface.DrawTexturedRect(x+(w-size)/2,y+(h-size)/2,size,size)
end

function SWEP:ResetScreen()
	self.DeployedTime = CurTime()
end

local BHG_RTMAT = Material("models/weapons/blackholegun/BHG_RT")
local BHG_RTSCREEN = GetRenderTarget("bhg_screen","256","256")
local col_renderclear = Color(0,0,0,255)

local startuplines = {
"SCAVCO. CF-2200 v4.0",
"Running SkyBIOS rev. 2.033",
"INITIALIZING...",
"] RUNNING SAFETY DIAGNOSTICS...",
"] RECALIBRATING GRAVITY MATRIX ",
"] CHECKING MATTER RESERVOIR",
"] INITIALIZING COOLANT LINES",
"] LOADING WAYPOINT VISUALIZER..",
"] VERIFYING IDENTITY...",
"] VERIFICATION COMPLETE",
"] STATUS: ONLINE",
"] ID PARSED!! WELCOME: THRILLHO"
}

surface.CreateFont("BHG7", {font = "Inconsolata", size = 16, weight = 400, antialiasing = true, additive = false, outlined = false, blur = false})
surface.CreateFont("BHG10", {font = "Inconsolata", size = 20, weight = 400, antialiasing = true, additive = false, outlined = false, blur = false})

function SWEP:DrawScreenBoot(progress)
	progress = math.min(progress,#startuplines)
	local offset = 0
	if progress > 10 then
		offset = progress-10
	end
	local message = startuplines[offset+1]
	for i=offset+1,progress-1 do
		message = message.."\n"..startuplines[i+1]
	end
	draw.DrawText(message,"BHG7",5,5,col_textcol,0)
end

function SWEP:DrawCharging()
	draw.DrawText("SCAVCO. CF-2200 V4.0\nUSER: "..LocalPlayer():Nick().."\n-------------------------------\nAmmunition: "..self:GetAmmo().."/"..self:GetMaxAmmo().."\nCharge Level: "..math.floor(self.Charge).."\nAssigned Waypoints: "..self.dt.WaypointCount.."/"..self.dt.MaxWaypoints,"BHG10",5,5,col_textcol,0)
end

SWEP.DeployedTime = 0
function SWEP:DrawScreen()
	local swide = ScrW()
	local shigh = ScrH()
	local rend = render.GetRenderTarget()
	render.SetRenderTarget(BHG_RTSCREEN)
	render.ClearRenderTarget(BHG_RTSCREEN,col_renderclear)
	render.SetViewPort(0,0,256,256)
	cam.Start2D()
	local bootprogress = math.floor((CurTime()-self.DeployedTime)*2)
	if (bootprogress > 14) || (self.ChargeTime != 0) then
		self:DrawCharging()
	else
		self:DrawScreenBoot(bootprogress)
	end
	local charge = self:GetCharge()
	cam.End2D()
	render.SetRenderTarget(rend)
	render.SetViewPort(0,0,swide,shigh)
	BHG_RTMAT:SetTexture("$basetexture",BHG_RTSCREEN)
end


local chairtex = surface.GetTextureID("hud/bhg_crosshair_corner")
local chairalpha = 0
SWEP.waypointtime = 0

function SWEP:OnWaypointUpdate()
	self.waypointtime = CurTime()
end

function SWEP:DrawHUD()
	local xmid = ScrW()/2
	local ymid = ScrH()/2
	surface.SetTexture(chairtex)
	if (self:GetCharge() > 0) && (self.ChargeTime != 0) then
		chairalpha = math.Clamp(chairalpha+FrameTime()*2000,0,255)
	else
		chairalpha = math.Clamp(chairalpha-FrameTime()*1000,0,255)
	end
	
	local dist
	if CurTime()-self.waypointtime > 0.5 then
		self.waypointtime = 0
	end
	local whitescale = 1
	local distmin = 16
	if self.waypointtime != 0 then
		whitescale = (CurTime()-self.waypointtime)*2
		dist = whitescale/255*8+16
	else
		dist = chairalpha/255*8+16
	end
	//Fuck you, it's efficient. I think.
	if self.dt.WaypointCount > 0 then
		surface.SetDrawColor(255,0,0,chairalpha)
		surface.DrawTexturedRectRotated(xmid-distmin,ymid-distmin,32,32,0)
		if self.dt.WaypointCount > 1 then
			surface.DrawTexturedRectRotated(xmid+distmin,ymid-distmin,32,32,270)
			if self.dt.WaypointCount > 2 then
				surface.DrawTexturedRectRotated(xmid+distmin,ymid+distmin,32,32,180)
				if self.dt.WaypointCount > 3 then
					surface.DrawTexturedRectRotated(xmid-distmin,ymid+distmin,32,32,90)
				else
					surface.SetDrawColor(255,255*whitescale,255*whitescale,chairalpha)
					surface.DrawTexturedRectRotated(xmid-dist,ymid+dist,32,32,90)
				end
			else
				surface.SetDrawColor(255,255*whitescale,255*whitescale,chairalpha)
				surface.DrawTexturedRectRotated(xmid+dist,ymid+dist,32,32,180)
				surface.DrawTexturedRectRotated(xmid-dist,ymid+dist,32,32,90)
			end
		else
			surface.SetDrawColor(255,255*whitescale,255*whitescale,chairalpha)
			surface.DrawTexturedRectRotated(xmid+dist,ymid-dist,32,32,270)
			surface.DrawTexturedRectRotated(xmid+dist,ymid+dist,32,32,180)
			surface.DrawTexturedRectRotated(xmid-dist,ymid+dist,32,32,90)
		end
	else
		surface.SetDrawColor(255,255*whitescale,255*whitescale,chairalpha)
		surface.DrawTexturedRectRotated(xmid-dist,ymid-dist,32,32,0)
		surface.DrawTexturedRectRotated(xmid+dist,ymid-dist,32,32,270)
		surface.DrawTexturedRectRotated(xmid+dist,ymid+dist,32,32,180)
		surface.DrawTexturedRectRotated(xmid-dist,ymid+dist,32,32,90)
	end
	
	self:DrawScreen()
end