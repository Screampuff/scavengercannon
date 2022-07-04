-----------------------------------------------------------------------------------------
---------------------------------------Client Code---------------------------------------
-----------------------------------------------------------------------------------------

if CLIENT then

	CreateClientConVar("cl_scav_iconalpha","200",true,false)
	CreateClientConVar("cl_scav_autoswitchdelay",".375",true,true,"Delay firing by this many seconds when automatically switching to another firemode.",0,1)

	CL_SCAVGUN = NULL

	SWEP.nextfire 				= 0
	SWEP.receivednextfire 		= 0
	SWEP.nextfireearly 			= 0

	SWEP.predicteditem 			= 1
	SWEP.rem_waiting 			= false
	SWEP.zoomed 				= false

	SWEP.vm_angles 				= Angle(0,0,0)

	SWEP.ViewLerpTime			= 0
	SWEP.ViewLerpDuration 		= 0
	SWEP.ViewLerpAngles 		= Angle(0,0,0)

	SWEP.FOVLerpTime 			= 0
	SWEP.FOVLerpDuration 		= 0
	SWEP.FOVLerpValue 			= 0

	SWEP.BarrelRotation 		= 0

	SWEP.LastAnim 				= ACT_VM_IDLE

	local color_red = Color(255,0,0,255)
	local color_red_colorblind = Color(190,76,0,255)
	local color_green = Color(0,255,0,255)
	local color_green_colorblind = Color(124,218,255,255)

	function SWEP:Precache()
		util.PrecacheSound("buttons/lever7.wav")
	end

	net.Receive("ent_emitsound",function()

		local ent = net.ReadEntity()
		local sound = net.ReadString()
		local vol = net.ReadFloat()
		local pitch = net.ReadFloat()
		
		if vol == 0 then
			vol = nil
		end
		
		if pitch == 0 then
			pitch = nil
		end
		ent:EmitSound(sound, vol, pitch)
		
	end)

	function SWEP:RemoveItem(pos) --Doesn't seem to ever get called?
		print("I am here!")
		if self.inv and self.inv.items[pos] then
		
			self.inv.items[pos].icon:Remove()
			
			local postremoved = nil
			
			if self:GetCurrentItem() and ScavData.models[self:GetCurrentItem().ammo] then
				postremoved = ScavData.models[self:GetCurrentItem().ammo].PostRemove
			end
			
			local item = table.remove(self.inv,pos)

			if postremoved then
				postremoved(self,item)
			end
			
			local itemnew = self:GetCurrentItem()
			
			if pos == 1 and itemnew and ScavData.models[itemnew.ammo] and ScavData.models[itemnew.ammo].OnArmed then
				ScavData.models[itemnew.ammo].OnArmed(self,itemnew,item.ammo)
			end
			
			self.menu.icondisplay:Refresh()
			self.predicteditem = 1
			self.rem_waiting = false
			
		end
		
	end

	function SWEP:OnItemRemoved(item)

		if self.inv and item then
		
			local postremoved = nil
			
			if item and item:GetFiremodeTable() then
				postremoved = item:GetFiremodeTable().PostRemove
			end
			
			if postremoved then
				postremoved(self,item)
			end
			
			local itemnew = self:GetCurrentItem()
			
			if item.pos == 1 and itemnew and itemnew:GetFiremodeTable() and itemnew:GetFiremodeTable().OnArmed then
				itemnew:GetFiremodeTable().OnArmed(self,itemnew,item.ammo)
			end
			
		end
		
		self.predicteditem = 1
		self.rem_waiting = false
		
		if self:IsMenuOpen() then
			self.Menu:RemoveIconByID(item.ID)
		end
		
	end

	function SWEP:OnItemReady(item)
		if self:IsMenuOpen() then
			self.Menu:AddIcon(item,item.ID,item.pos)
		end
	end

	function SWEP:OnInvShift(inv)
		if self:IsMenuOpen() then
			self.Menu:UpdateDesiredAngles()
		end
	end

	net.Receive("scv_s_time", function()

		local ent = net.ReadEntity()
		local stime = net.ReadInt(32) + net.ReadFloat()
		
		if not IsValid(ent) then return end
		
		ent:SetNextPrimaryFire(stime)
		ent.nextfire = stime
		ent.receivednextfire = UnPredictedCurTime()
		
	end)

	function SWEP:OnRemove()
		if IsValid(self.Owner) and self.Owner == LocalPlayer() and self:IsMenuOpen() then
			if IsValid(self.Menu) then
				self.Menu:Remove()
			end
		end
		self:DestroyWModel()
	end	

	function SWEP:TranslateFOV(current_fov)

		if GetViewEntity() ~= self.Owner then
			return current_fov
		end
		
		if not self:GetCurrentItem() or not ScavData.models[self:GetCurrentItem().ammo] or not ScavData.models[self:GetCurrentItem().ammo].fov or not self:GetZoomed() then
			self:SetZoomed(false)
		elseif self:GetZoomed() then
			current_fov = ScavData.models[self:GetCurrentItem().ammo].fov
		end
		
		local dfov = GetConVar("fov_desired"):GetFloat()
		local realvmfov = current_fov + 62 - dfov
		
		if realvmfov < 0 then
			self.ViewModelFOV = 64 - realvmfov
		else
			self.ViewModelFOV = 62
		end
		
		return current_fov
		
	end

	function SWEP:AdjustMouseSensitivity()
		if self:GetZoomed() and self:GetCurrentItem() and ScavData.models[self:GetCurrentItem().ammo].fov then
			return ScavData.models[self:GetCurrentItem().ammo].fov / GetConVar("fov_desired"):GetFloat()
		else
			return
		end
	end

	function SWEP:Think()

		local delta = CurTime() - self.LastThink
		
		self.BarrelRotation = (self.BarrelRotation + self:GetBarrelSpinSpeed() * delta) % 360
		
		if not self.Owner:KeyDown(IN_ATTACK) then
			self.Inaccuracy = math.Max(1, self.Inaccuracy - 10 * FrameTime())
		end
		
		if not self:IsLocked() and self.ChargeAttack and self.nextfire < CurTime() then
		
			local shoottime = CurTime()
			local item = self.chargeitem or self.inv.items[self.predicteditem]
			local cooldown = self:ChargeAttack(item) * self:GetCooldownScale()
			self.nextfire = CurTime() + cooldown
			self.receivednextfire = UnPredictedCurTime()
			
			if ScavData.models[item.ammo].chargeanim then
				self:SetSeqEndTime(shoottime + cooldown)
				self:SendWeaponAnim(ScavData.models[item.ammo].chargeanim)
			end
			
		end
		
		if LocalPlayer():KeyDown(IN_RELOAD) then
			self:OpenMenu()
		end
		
		if self.seqendtime ~= 0 and self.seqendtime < CurTime() then
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:SetSeqEndTime(0)
		end
		
		self.HUD:SetVisible(true)
		
		if CL_SCAVGUN == self and CL_SCAVGUNTAB ~= self:GetTable() then --this should hopefully fix the problem that comes up when the client loses connection to the server for a little more than a second
			self:SetTable(CL_SCAVGUNTAB)
		elseif CL_SCAVGUN ~= self then
			CL_SCAVGUNTAB = self:GetTable()
			CL_SCAVGUN = self
		end
		
		self.LastThink = CurTime()
		return true	
		
	end

	function SWEP:Holster()
		self:DestroyWModel()
		return false
	end

	function SWEP:PrimaryAttack()

		if self:IsLocked() or self.ChargeAttack then
			return
		end
		
		local shoottime = CurTime()
		
		local item = self:GetCurrentItem() --the item we're going to use to fire
		
		if item and ScavData.models[item.ammo] and ScavData.models[item.ammo].Level > self:GetNWLevel() then
			self:SendWeaponAnim(ACT_VM_FIDGET)
			self:SetNextPrimaryFire(shoottime + 2)
			self:SetSeqEndTime(shoottime + 1)
			return
		end
		
		if (self.inv:GetItemCount() ~= 0) and self.nextfire < CurTime() or (self.nextfireearly ~= 0 and self.nextfireearly < CurTime()) then
			if self.Owner:KeyPressed(IN_ATTACK) then
				self.mousepressed = false
			else
				if not self.mousepressed then
					self.mousepressed = CurTime()
				end
			end
		end
		
		if self.inv:GetItemCount() ~= 0 and self.nextfire < CurTime() or (self.nextfireearly ~= 0 and self.nextfireearly < CurTime() and not self.mousepressed) then
		
			self.nextfireearly = 0
			
			if not self:HasItemTypeSameAsLast() then
				self.mousepressed = false
			end
			
			if self:GetCurrentItem() then
				self.currentmodel = self:GetCurrentItem().ammo
			else
				self.currentmodel = nil
			end
			
			if item and ScavData.models[item.ammo] then
				ScavData.ProcessLocalPlayerItemKnowledge(item.ammo)
			end
			
			if item and ScavData.models[item.ammo] and ScavData.models[item.ammo].FireFunc then --check to make sure that this item is valid and has a firemode
			
				local cooldown = ScavData.models[self.currentmodel].Cooldown * self:GetCooldownScale()
				
				ScavData.models[item.ammo].FireFunc(self,item)
				
				if ScavData.models[self.currentmodel].anim then
				
					self:SendWeaponAnim(ScavData.models[self.currentmodel].anim)
					self.LastAnim = ScavData.models[self.currentmodel].anim
					
					if not self.ChargeAttack then
						self:SetSeqEndTime(shoottime + math.min(self.Owner:GetViewModel():SequenceDuration(), cooldown))
					end
					
				end
				
				local nextfire = shoottime + cooldown
				self.nextfire = nextfire
				self.receivednextfire = UnPredictedCurTime()
				
			elseif item and ScavData.models[item.ammo] and ScavData.models[item.ammo].anim then --just play an animation if there is an empty firemode
				self:SendWeaponAnim(ScavData.models[self:GetCurrentItem().ammo].anim)
				self.LastAnim = ScavData.models[self:GetCurrentItem().ammo].anim
				self.nextfire = shoottime + ScavData.models[self:GetCurrentItem().ammo].Cooldown * self:GetCooldownScale()
				self.receivednextfire = UnPredictedCurTime()
				self:SetSeqEndTime(self.nextfire)
			elseif item then --just play a generic animation if we have no idea what this item is
				local mass = item:GetMass()
				self.nextfire = shoottime + (math.sqrt(mass) * 0.05) * self:GetCooldownScale()
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				self.LastAnim = ACT_VM_SECONDARYATTACK
				self.receivednextfire = UnPredictedCurTime()
				self:SetSeqEndTime(self.nextfire - 0.1)
			end
			
			if not self.mousepressed then
				self.mousepressed = CurTime()
			end
			
		end
		
	end

	function SWEP:OnRestore()
		self.nextfire = 0
		self.nextfireearly = 0
	end

	function SWEP:GetCurrentItem()
		return self.inv.items[self.predicteditem]
	end

	function SWEP:SecondaryAttack()
	end

--------------------------------------------------------------------------------
	--HUD Ammo Display 
--------------------------------------------------------------------------------

	local PANEL 	= {}
	PANEL.BGColor 	= Color(255,255,255,255)
	PANEL.wep 		= NULL

	function PANEL:Init()
		self.Preview = vgui.Create("SpawnIcon",self)
		self.Preview:SetSize(64,64)
		self.Preview.parent = self
		self:AutoSetPos()
	end

	function PANEL:AutoSetPos()
		self:SetSize(268,96)
		self:SetPos(ScrW() - self:GetWide() - 32, ScrH() - self:GetTall() - 16)
	end

	function PANEL:PerformLayout()
		self.Preview:SetPos(16, self:GetTall() / 2 - self.Preview:GetTall() / 2)
	end

	function PANEL:Think()
		if LocalPlayer().GetActiveWeapon then

			self.wep = LocalPlayer():GetActiveWeapon()
			local isscav = IsValid(self.wep) and self.wep:GetClass() == "scav_gun"
			
			self:SetVisible(isscav)
			
			if not IsValid(self.wep) then
				return
			end
			
			if isscav then
				if self.wep.ChargeAttack then
					self.item = self.wep.chargeitem
				elseif IsValid(self.wep) and self.wep.GetCurrentItem and self.wep:GetCurrentItem() then
					self.item = self.wep:GetCurrentItem()
				end
			end
			
			if isscav and self.item and (self.wep.ChargeAttack or self.wep.inv:GetItemCount() > 0)  then
				self.Preview:SetVisible(true)
				self.Preview:SetModel(self.item.ammo,self.item.data)
			else
				self.Preview:SetVisible(false)
				self.item = nil
			end
			
		end
	end

	function PANEL:PaintOver()

		if LocalPlayer():GetActiveWeapon():GetClass() ~= "scav_gun" then
			self:SetVisible(false)
			return
		end
		
		local wep = self.wep
		local item = wep:GetCurrentItem()
		
		if IsValid(wep) and wep:GetClass() == "scav_gun" then
		
			surface.SetTextColor(255,255,255,255)
			surface.SetFont("Scav_MenuLarge")
			surface.SetTextPos(96,48)
			
			local firemodename = "#scav.scavcan.unknown"
			
			if item then
				local itemtab = ScavData.models[item.ammo]
				if ScavData.LocalPlayerKnowsItem(item.ammo) and itemtab then
					if itemtab.Name then
						firemodename = itemtab.Name
					elseif itemtab.GetName then
						firemodename = itemtab.GetName(wep,item)
					end
				end
			end
			
			surface.DrawText(firemodename)
			surface.SetTextPos(96,16)	

			surface.DrawText(ScavLocalize("scav.scavcan.ammo",wep.inv:GetItemCount(),wep:GetCapacity()))
			surface.SetTextPos(104,64)
			surface.SetDrawColor(255, 255, 255, 200)
			surface.DrawRect(16, 80, (wep.nextfire-UnPredictedCurTime()) * 256 / (wep.nextfire - wep.receivednextfire) - 32, 8)
			
			if item then 
				if self.item.subammo == SCAV_SHORT_MAX then
					surface.DrawText(ScavLocalize("scav.scavcan.subammo","scav.scavcan.inf"))
				else
					surface.DrawText(ScavLocalize("scav.scavcan.subammo",self.item.subammo))
				end
			else
				surface.DrawText(ScavLocalize("scav.scavcan.subammo","0"))
			end
		end
	end

	vgui.Register("scav_hud",PANEL,"DPanel")

	SWEP.HUD = vgui.Create("scav_hud")

	local HUD = SWEP.HUD
	HUD:SetVisible(false)
	HUD:SetSkin("sg_menu")

	function SWEP:HasItemTypeSameAsLast()
		if not self:GetCurrentItem() then
			return false
		else
			return (ScavData.models[self.currentmodel] == ScavData.models[self:GetCurrentItem().ammo])
		end
	end

	function SWEP:Deploy()
		self:SetHoldType(self.HoldType)
		self.seqendtime = 0
		self.BarrelRotation = 0
	end

	net.Receive("scv_asgn", function()
		local self = net.ReadEntity()
		local id = net.ReadInt(16)
		local inv = GetScavInventoryByID(id)
		self.inv = inv
	end)

	net.Receive("scv_ht",function()
		local self = net.ReadEntity()
		local htype = net.ReadString()
		if IsValid(self) and IsValid(self.Owner) and self.Owner ~= LocalPlayer() and self.SetHoldType then
			self:SetHoldType(htype)
		end
	end)
	
	net.Receive("scv_lock", function()
		local self = net.ReadEntity()
		local start = net.ReadFloat()
		local endtime = net.ReadFloat()
		self:Lock(start,endtime)
	end)
	
	if game.SinglePlayer() then
		net.Receive("scv_setsubammo", function() 
			local self = net.ReadEntity()
			local int = net.ReadInt(16)
			if IsValid(self) and int and self.inv.items[1] then 
				self.inv.items[1].subammo = int
			end 
		end)
	else
		net.Receive("scv_setsubammo", function() 
			local self = net.ReadEntity()
			local int = net.ReadInt(16)
			local pos = net.ReadInt(8)
			if IsValid(self) and int and self.inv.items[pos] then 
				self.inv.items[pos].subammo = int
			end 
		end)
	end
	
	local function applyeffect(ent)
		if IsValid(ent) then
			ent:SetModelScale(0,0.1)
			local edata = EffectData()
			edata:SetOrigin(ent:GetPos())
			edata:SetEntity(ent)
			util.Effect("ef_scav_launch",edata,true,true)
			return true
		end
		return false
	end
	
	hook.Add("OnEntityCreated","scv_leffect",function(ent)
		if IsValid(ent) and ent:GetMaterial() == "scv_leffect" then
			ent:SetMaterial()
			applyeffect(ent)
		end
	end)
	
	-------------------------------------
	------------/Drawing-----------------
	-------------------------------------

	local vec_white 		= Vector(1,1,1)

	local selecttex 		= surface.GetTextureID("hud/weapons/scav_gun")
	local screencolvec 		= Vector(1,1,1)

	SWEP.CrosshairFraction 	= 0
	local c_hairtex 		= surface.GetTextureID("hud/scav_crosshair_corner")
	local c_hairrotation 	= 0

	function SWEP:DrawWeaponSelection(x,y,w,h,a)
		local size = math.min(w,h)
		surface.SetTexture(selecttex)
		surface.SetDrawColor(255,255,255,a)
		surface.DrawTexturedRect(x + (w - size) / 2, y + (h - size) / 2, size, size)
	end

--------------------------------------------------------------------------------
--Screen
--------------------------------------------------------------------------------

	local SCAV_RTMAT = Material("models/weapons/scavenger/screen")
	local SCAV_RTSCREEN = GetRenderTarget("scav_screen","256","256")
	local col_renderclear = Color(0,0,0,255)

	surface.CreateFont("ScavScreenFont", {font = "Trebuchet MS", size = 40, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})
	surface.CreateFont("ScavScreenFontSm", {font = "Trebuchet MS", size = 32, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})
	surface.CreateFont("ScavScreenFontSmX", {font = "Trebuchet MS", size = 24, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})

	alpha = 12
	greenscr = Color(108,172,24,alpha)
	greenscr_colorblind = Color(124,218,255,alpha)
	yellowscr = Color(172,172,24,alpha)
	yellowscr_colorblind = Color(172,172,24,alpha)
	redscr = Color(172,24,24,alpha)
	redscr_colorblind = Color(190,76,0,alpha)

	function DrawScreenBKG(col)
		--edge fade
		surface.SetDrawColor(color_black)
		surface.DrawRect(0,0,256,256)
		local i = 8
		local j = 4
		local u = 256-i*2
		local v = 128-j*2
		local a = alpha
		while u > 0 and v > 0 and a < 255 do
			draw.RoundedBox(32,i,j,math.max(1,u),math.max(1,v),col)
			i = i + 1
			j = j + 1
			u = u - 2
			v = v - 2
			a = a + alpha
		end
	end

	hook.Add("ScavScreenDrawOverride","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverrideIdle","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverridePost","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverridePost","RadStatic",function(self)
		radthink = radthink or CurTime()
		geiger = geiger or SCAV_SHORT_MAX
		--GetInternalVariable("m_iGeigerRange")
		if radthink <= CurTime() then
			--geiger decay (effect trails off nicely instead of just abruptly ending)
			if geiger < 800 then
				geiger = geiger + 50
			end
			for _,v in pairs(ents.FindInBox(self.Owner:GetPos()-Vector(800,800,800),self.Owner:GetPos()+Vector(800,800,800))) do
				if v:GetStatusEffect("Radiation") then
					geiger = math.min(geiger,self.Owner:GetPos():Distance(v:GetPos()))
				end
			end
			radthink = CurTime() + 0.25
		end
		if geiger < 800 then
		 	for i=1,(800-geiger) do
				surface.SetDrawColor(255,255,255)
				surface.DrawRect(math.Rand(0,255),math.Rand(0,127),math.Rand(1,math.ceil(i/100)),math.Rand(1,math.ceil(i/100)))
			end
		end
	end)

	function SWEP:DrawIdle()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.ok"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.ok") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.ok"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
	end

	function SWEP:DrawNice()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.nice"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.nice") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.nice"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
	end

	function SWEP:DrawLocked()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(redscr)
		else
			DrawScreenBKG(redscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.locked"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.locked") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		local _, use = math.modf(CurTime())
		if use < .5 then
			draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.locked"),fontsize,128,vpos,color_white,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.locked"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		end
	end

	function SWEP:DrawCooldown()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(yellowscr)
		else
			DrawScreenBKG(yellowscr_colorblind)
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","\0"),"ScavScreenFont",128,12,color_black,TEXT_ALIGN_CENTER)
		local _, use = math.modf(math.abs(CurTime()-self.nextfire))
		if use < .25 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress0"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		elseif use < .5 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress3"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		elseif use < .75 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress2"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress1"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		end
	end

	function SWEP:DrawFiring()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 12
		local fontsize = "ScavScreenFont"
		if #(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress3")) > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","\0"),"ScavScreenFont",128,12,color_black,TEXT_ALIGN_CENTER)
		local _, use = math.modf(CurTime())
		if use < .25 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress0"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		elseif use < .5 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress1"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		elseif use < .75 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress2"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress3"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		end
	end

	 function SWEP:DrawAutoTargetScreen(on)
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			if on then
				DrawScreenBKG(greenscr)
			else
				DrawScreenBKG(redscr)
			end
		else
			if on then
				DrawScreenBKG(greenscr_colorblind)
			else
				DrawScreenBKG(redscr_colorblind)
			end
		end
		local vpos = 12
		local fontsize = "ScavScreenFontSm"
		if #language.GetPhrase("scav.scavcan.autotarget") > 14 then
			fontsize = "ScavScreenFontSmX"
			vpos = vpos + 8
		end
		local _, use = math.modf(CurTime())
		local col = color_black
		if not on and use < .5 then
			col = color_white
		end
		draw.DrawText(language.GetPhrase("scav.scavcan.autotarget"),fontsize,128,vpos,col,TEXT_ALIGN_CENTER)
		if on then
			draw.DrawText(language.GetPhrase("scav.scavcan.on"),"ScavScreenFont",128,20+vpos,col,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.off"),"ScavScreenFont",128,20+vpos,col,TEXT_ALIGN_CENTER)
		end
	end

	local idle = idle or true

	function SWEP:DrawScreen()
		local swide = ScrW()
		local shigh = ScrH()
		local rend = render.GetRenderTarget()
		render.SetRenderTarget(SCAV_RTSCREEN)
		--render.ClearRenderTarget(SCAV_RTSCREEN,col_renderclear)
		render.SetViewPort(0,0,256,256)
		cam.Start2D()
			local item = nil
			if IsValid(self.inv.items[1]) then
				item = ScavData.models[self.inv.items[1].ammo]
			end
			--Locked screen
			if self:IsLocked() then
				self:DrawLocked()
			--Screen Draw Override Hook
			elseif hook.Run("ScavScreenDrawOverride",self,true) then
				hook.Run("ScavScreenDrawOverride",self)
			--Auto-Targeting System screen
			elseif item and item.Name == "#scav.scavcan.computer" then
				self:DrawAutoTargetScreen(item.On)
			--Cooldown screen
			elseif ((self.nextfire - CurTime() > 0.25 and self.nextfireearly == 0) or self.nextfireearly - CurTime() > 0.25) and not self.ChargeAttack then
				self:DrawCooldown()
				idle = false
			--Nice screen
			elseif IsValid(self.inv.items[1]) and self.inv.items[1].subammo == 69 then
				self:DrawNice()
			--Charge Attack Firing screen
			elseif self.ChargeAttack then
				self:DrawFiring()
			--Seeking Rocket Screen
			elseif item and item.Name == "#scav.scavcan.rocket" then
				local seeking = false
				for i,v in pairs(self.inv.items) do
					if ScavData.models[v.ammo] and ScavData.models[v.ammo].Name == "#scav.scavcan.computer" then
						seeking = ScavData.models[v.ammo].On
						break
					end
				end
				if seeking then
					self:DrawAutoTargetScreen(seeking)
				elseif hook.Run("ScavScreenDrawOverrideIdle",true) then
					hook.Run("ScavScreenDrawOverrideIdle")
				else
					self:DrawIdle()
					idle = true
				end
			--Screen Draw Override Idle Hook
			elseif hook.Run("ScavScreenDrawOverrideIdle",self,true) and self.nextfire <= CurTime() then
				hook.Run("ScavScreenDrawOverrideIdle",self)
			--Idle Screen 
			elseif self.nextfire <= CurTime() or idle then
				self:DrawIdle()
				idle = true
			--Cooldown Screen ending catch
			else
				self:DrawCooldown()
			end
			--Screen Post Draw Hook
			if hook.Run("ScavScreenDrawOverridePost",self,true) then
				hook.Run("ScavScreenDrawOverridePost",self)
			end
		cam.End2D()
		render.SetRenderTarget(rend)
		render.SetViewPort(0,0,swide,shigh)
		SCAV_RTMAT:SetTexture("$basetexture",SCAV_RTSCREEN)
	end


	function SWEP:DrawCrosshairs()

		local tr = self.Owner:GetEyeTraceNoCursor()
		local pos = tr.HitPos:ToScreen()
		
		if IsValid(tr.Entity) and tr.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
			self.CrosshairFraction = math.Approach(self.CrosshairFraction, 1, FrameTime() * 10)
		else
			self.CrosshairFraction = math.Approach(self.CrosshairFraction, 0, FrameTime() * 2)
			if self.CrosshairFraction == 0 then
				c_hairrotation = 0
			end
		end
		
		surface.SetTexture(c_hairtex)
		
		
		local frac = self.CrosshairFraction
		local x = pos.x
		local y = pos.y
		local cfrac = math.cos(c_hairrotation * 5) * frac * 16
		local cfrac2 = math.cos(c_hairrotation * 5 + math.pi / 2) * frac * 16
		local sfrac = math.sin(c_hairrotation * 5) * frac * 16
		local sfrac2 = math.sin(c_hairrotation * 5 + math.pi / 2) * frac * 16
		local size = frac * 16
		local angoffset = -1 * math.deg(c_hairrotation * 5)
		
		if self:GetCanScav() and IsValid(tr.Entity) then
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				surface.SetDrawColor(color_green)
			else
				surface.SetDrawColor(color_green_colorblind)
			end
			c_hairrotation = c_hairrotation + FrameTime()
		elseif IsValid(tr.Entity) then
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				surface.SetDrawColor(color_red)
			else
				surface.SetDrawColor(color_red_colorblind)
			end
			-- X on the crosshair if we're trying to suck the unsuckable
			if self.Owner:KeyDown(IN_ATTACK2) then
				surface.DrawLine(x-size/2,y-size/2,x+size/2,y+size/2)
				surface.DrawLine(x-size/2+1,y-size/2,x+size/2+1,y+size/2)
				surface.DrawLine(x-size/2-1,y-size/2,x+size/2-1,y+size/2)
				surface.DrawLine(x-size/2,y+size/2,x+size/2,y-size/2)
				surface.DrawLine(x-size/2+1,y+size/2,x+size/2+1,y-size/2)
				surface.DrawLine(x-size/2-1,y+size/2,x+size/2-1,y-size/2)
			end
		else
			surface.SetDrawColor(150,150,150,150)
		end
		--draw the rotating colored crosshair
		surface.DrawTexturedRectRotated(x + cfrac, y + sfrac, size, size, 225 + angoffset)
		surface.DrawTexturedRectRotated(x + cfrac2, y + sfrac2, size, size, 135 + angoffset)
		surface.DrawTexturedRectRotated(x - cfrac2, y - sfrac2, size, size, 315 + angoffset)
		surface.DrawTexturedRectRotated(x - cfrac, y - sfrac, size, size, 45 + angoffset)
		
		--draw the normal crosshair
		local x = ScrW() / 2
		local y = ScrH() / 2
		local frac = 1 - self.CrosshairFraction
		surface.DrawCircle(x, y, 6 * frac, color_white)
		surface.SetTexture(0)
		surface.DrawTexturedRect(x - 1, y, 3 * frac, 1)
		surface.DrawTexturedRect(x, y - 1, 1, 3 * frac)
		
	end

	function SWEP:PreDrawViewModel(vm,wep,pl)
	end

	function SWEP:PostDrawViewModel(vm,wep,pl)
	end

	function SWEP:DestroyWModel()
		if IsValid(self.wmodel) then
			SafeRemoveEntity(self.wmodel)
		end
	end

	function SWEP:BuildWModel() --using a cmodel since SetPoseParameter only works on the LocalPlayer's weapon normally
		if not IsValid(self) then return end
		self:DestroyWModel()
		self.wmodel = ClientsideModel(self.WorldModel, RENDERGROUP_OPAQUE)
		self.wmodel:SetParent(self:GetOwner()) --just a heads up, if you parent it to the weapon its pose parameters won't work because of bonemerging to existing bones
		local meffects = bit.bor(EF_BONEMERGE,EF_NODRAW,EF_NOSHADOW)
		self.wmodel:AddEffects(meffects)
		self.wmodel:SetSkin(self:GetSkin())
	end

	function SWEP:DrawWorldModel()

		if IsValid(pl) and IsValid(self.wmodel) and IsValid(self.Owner) then
			
			self.wmodel:SetPoseParameter("panel", self:GetPoseParameter("panel"))
			self.wmodel:SetPoseParameter("block", self:GetPoseParameter("block"))
			
			if self.Owner == LocalPlayer() then
				self.wmodel:SetPoseParameter("spin", self.BarrelRotation)
			else
				local param = self:GetPoseParameter("spin")
				self.wmodel:SetPoseParameter("spin", param * 360)
			end
			
			self.wmodel:DrawModel()

		else
			timer.Simple(0, function() if self.BuildWModel then self:BuildWModel(self) end end)
			self:DrawModel()
		end
		
	end

	function SWEP:DrawHUD()
		self:DrawCrosshairs()
		self:DrawScreen()
	end
	
	-------------------------------------
	----------------Menu-----------------
	-------------------------------------
	
	SWEP.Menu = NULL

	function SWEP:IsMenuOpen()
		if IsValid(self.Menu) then
			return true
		end
	end

	SWEP.tips = { --TODO: don't think these are used at all anymore. Make them usable?

		"#scav.scavtips.acid",
		"#scav.scavtips.flamethrower",
		--"Some items allow you to zoom in. Click on the icon in the ACTIVE SLOT to activate zoom mode for that item.", TODO: Get this working again!
		"#scav.scavtips.zoom",
		"#scav.scavtips.scrollbinds",
		"#scav.scavtips.projectilecatch",
		"#scav.scavtips.delete",
		"#scav.scavtips.select",
		"#scav.scavtips.experiment",
		"#scav.scavtips.medkit",
		"#scav.scavtips.inf",
		"#scav.scavtips.passive",
		"#scav.scavtips.acid2",
		"#scav.scavtips.rocketjump",
		"#scav.scavtips.superphysjump",
		"#scav.scavtips.shower",
		"#scav.scavtips.crossfire"
	}

	local sh = ScrH()
	local sw = ScrW()

	local iconradius = 120

	local ITEMICON = {}
	ITEMICON.currentangle = 0
	ITEMICON.desiredangle = 0

	function ITEMICON:Init()
		self:SetAlpha(GetConVar("cl_scav_iconalpha"):GetFloat())
		self.item = nil
	end
			
	function ITEMICON:SetItem(item)
		self:SetModel(item:GetAmmoType(), item:GetData())
		self.item = item
	end
			
	function ITEMICON:GetItem()
		return self.item
	end
			
	function ITEMICON:Think()
		if not IsValid(self:GetParent()) then
			self:Remove()
		end
	end

	function ITEMICON:OnCursorEntered()
		self:SetAlpha(255)
	end

	function ITEMICON:OnCursorExited()
		self:SetAlpha(GetConVar("cl_scav_iconalpha"):GetFloat())
	end
			
	function ITEMICON:OnMousePressed(mc)
		if mc == MOUSE_LEFT then
			local amt = -self.pos
			RunConsoleCommand("scv_itm_shft", amt)
		elseif mc == MOUSE_RIGHT then
			RunConsoleCommand("scv_itm_rem", self.id)
		end
	end

	function ITEMICON:PaintOver()
		if self.item.subammo == SCAV_SHORT_MAX then
			draw.DrawText("#scav.scavcan.inf", "Scav_DefaultSmallDropShadow", 60, 52, color_white, TEXT_ALIGN_RIGHT) --∞
		else
			draw.DrawText(self.item.subammo, "Scav_DefaultSmallDropShadow", 60, 52, color_white, TEXT_ALIGN_RIGHT)
		end
	end
			
	vgui.Register("scavitemicon",ITEMICON,"spawnicon")

	local PANEL = {}
	PANEL.Weapon = NULL
	PANEL.iconradius = iconradius
	PANEL.angupdatesuppress = false

	function PANEL:Init()
		self.icons = {}
		self.iconids = {}
		self.Initialized = true
	end

	--allow mouse scrolling to move inventory while menu is open
	function PANEL:OnMouseWheeled(delta)
		if delta > 0 then
			RunConsoleCommand("scv_itm_shft",1)
			return true
		elseif delta < 0 then
			RunConsoleCommand("scv_itm_shft",-1)
			return true
		end
	end
		
	function PANEL:InvalidateLayout()
		if not self.Initialized then
			return
		end
	end
		
	function PANEL:Think()

		if not LocalPlayer():KeyDown(IN_RELOAD) then
			gui.EnableScreenClicker(false)
			for _,v in ipairs(self.icons) do
				if IsValid(v) then
					v:Remove()
				end
			end
			hook.Remove("HUDPaintBackground","Scav_Menu")
			self:Remove()
		end
		
		local delta = FrameTime()
		local w = self:GetWide()/2
		local h = self:GetTall()/2
		
		for _,icon in pairs(self.icons) do
			if icon.desiredangle then
				icon.currentangle = math.ApproachAngle(icon.currentangle,icon.desiredangle,delta * 720)
				icon:SetPos(w + math.cos(math.rad(icon.currentangle)) * self.iconradius - 32, h - math.sin(math.rad(icon.currentangle)) * self.iconradius - 48)
			end
		end
	end
		
	function PANEL:SetWeapon(wep)
		self.Weapon = wep
	end

	function PANEL:UpdateDesiredAngles()

		if self.angupdatesuppress then
			return
		end
		local itemnum = 0
		
		for _,v in pairs(self.Weapon.inv.items) do
		
			local icon = self.iconids[v.ID]
			
			if icon then
				icon.desiredangle = (itemnum) * 360 / self.Weapon:GetCapacity()
				icon.pos = itemnum
				icon:SetZPos(self.Weapon:GetCapacity() - itemnum)
				itemnum = itemnum + 1
			end
			
		end
		
	end

	function PANEL:RemoveIconByID(itemid)

		local icon = self.iconids[itemid]
		
		for k,v in pairs(self.icons) do
			if icon == v then
				table.remove(self.icons,k)
				break
			end
		end
		
		icon:Remove()
		self.iconids[itemid] = nil
		self:UpdateDesiredAngles()
		
	end

	function PANEL:AddIcon(item,itemid,pos)
		local icon = vgui.Create("scavitemicon", self)
		icon:SetItem(item)
		icon.id = itemid
		self.iconids[itemid] = icon
		table.insert(self.icons,pos or #self.icons + 1, icon)
		self:UpdateDesiredAngles()
		icon.currentangle = icon.desiredangle
		return icon
	end
		
	--local bkgcol = Color(50,50,50)

	function PANEL:Rebuild()

		for k,v in pairs(self.icons) do
			v:Remove()
			self.icons[k] = nil
		end
		
		for k,v in pairs(self.iconids) do
			self.iconids[k] = nil
		end
		
		local itemnum = 0
		self.angupdatesuppress = true
		
		for k,v in pairs(self.Weapon.inv.items) do
			local icon = self:AddIcon(v, v.ID)
			icon:SetZPos(self.Weapon:GetCapacity() - itemnum)
			icon.pos = itemnum
			icon.desiredangle = (itemnum) * 360 / self.Weapon:GetCapacity()
			icon.currentangle = icon.desiredangle
			itemnum = itemnum + 1
		end
		
		self.angupdatesuppress = false
		
	end
		
	function PANEL:AutoSetup()
		self:SetSize(320,350)
		self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetWide() / 2)
	end

	vgui.Register("scav_menu",PANEL,"DPanel")

	-- local triangle = {
	-- 	{ x = sw*.51+(iconradius-32), y = (sh+iconradius/2-32)*.5 },
	-- 	{ x = sw*.4975+(iconradius-32), y = (sh+iconradius/2-32)*.5125 },
	-- 	{ x = sw*.4975+(iconradius-32), y = (sh+iconradius/2-32)*.4875 }
	-- }

	function SWEP:OpenMenu()
		if not IsValid(self.Menu) then
			self.Menu = vgui.Create("scav_menu")
			self.Menu:SetSkin("sg_menu")
			self.Menu:SetWeapon(self)
			self.Menu:AutoSetup()
			self.Menu:Rebuild()
			self.Menu:SetVisible(true)
			self.Menu:MakePopup()
			self.Menu:SetKeyboardInputEnabled(false)
			--hook.Add("HUDPaintBackground","Scav_Menu",function() 
				--better show our active item
				--surface.SetDrawColor( 50,50,50 )
				--draw.NoTexture()
				--draw.RoundedBoxEx(8,sw/2+iconradius-32,sh/2-32,64,64,bkgcol,true,true,true,false)
				--surface.DrawPoly(triangle)
			--end)
		end
	end
	
	-------------------------------------
	-------------View Punch--------------
	-------------------------------------
	
	local PLAYER = FindMetaTable("Player")

	ScavData.ViewPunches = {}

	function SWEP:SetViewLerp(oldangle,duration)
		duration = duration or 1
		self.ViewLerpTime = CurTime()
		self.ViewLerpDuration = duration
		self.ViewLerpAngles = oldangle
	end

	function SWEP:SetFOVLerp(oldfov,duration)
		duration = duration or 1
		self.FOVLerpTime = CurTime()
		self.FOVLerpDuration = duration
		self.FOVLerpValue = oldfov
	end

	net.Receive("scv_svl", function()
		local self = net.ReadEntity()
		if not self then
			return
		end
		self:SetViewLerp(net.ReadAngle(),net.ReadFloat())
	end)

	net.Receive("scv_sfl", function()
		local self = net.ReadEntity()
		if not self then
			return
		end
		self:SetFOVLerp(net.ReadFloat(),net.ReadFloat())
	end)
		
	function SWEP:CalcView(pl,origin,angles,fov)

		local totalviewpunch = nil
		
		if self.ViewLerpDuration ~= 0 then
			local ang = LerpAngle(math.Clamp((CurTime() - self.ViewLerpTime) / self.ViewLerpDuration, 0, 1), self.ViewLerpAngles, angles)
			angles = ang
			self.vm_angles = ang * 1
			if CurTime() - self.ViewLerpTime > self.ViewLerpDuration then
				self.ViewLerpDuration = 0
			end
		end
		
		if self.FOVLerpDuration ~= 0 then
			fov = Lerp(math.Clamp((CurTime() - self.FOVLerpTime) / self.FOVLerpDuration, 0, 1), self.FOVLerpValue, fov)
			if CurTime() - self.FOVLerpTime > self.FOVLerpDuration then
				self.FOVLerpDuration = 0
			end
		end
		
		if totalviewpunch then
			self.vm_angles = self.vm_angles + totalviewpunch
			angles = angles + totalviewpunch
		end
		
		return origin,angles,fov
		
	end
		
	function SWEP:GetViewModelPosition(pos,ang)
		local totalviewpunch = ang
		if self.Owner.viewpunch and (CurTime() - self.Owner.viewpunch.Created) < self.Owner.viewpunch.lifetime then
			local wat = (CurTime() - self.Owner.viewpunch.Created) / self.Owner.viewpunch.lifetime
			totalviewpunch = ang + self.Owner.viewpunch.angle * math.sin(math.sqrt(wat) * math.pi)
		end
		return pos, totalviewpunch
	end

	net.Receive("scv_vwpnch", function() LocalPlayer():ScavViewPunch(net.ReadAngle(), net.ReadFloat()) end)

	local function NewViewPunch(angles,duration)
		local tab = {}
		tab.angle = angles
		tab.lifetime = duration
		tab.Created = UnPredictedCurTime()
		return tab
	end
		
	function PLAYER:ScavViewPunch(angles,duration,freeze)
		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end
		local vp = NewViewPunch(angles,duration)
		table.insert(self.ScavViewPunches,vp)
	end
		
	local totalviewpunch = Angle()
	local expiredVPs = {}

	hook.Add("CalcView","ScavViewPunch",function(pl,origin,angles,fov)
		if not pl.ScavViewPunches or pl ~= GetViewEntity() then return end
		local vpang = pl:GetCurrentScavViewPunch()
		angles.p = angles.p + vpang.p
		angles.y = angles.y + vpang.y
		angles.r = angles.r + vpang.r
	end)
		
	function PLAYER:GetCurrentScavViewPunch(dodebug)

		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end
		
		local angles = Angle(0,0,0)
		
		totalviewpunch.p = 0
		totalviewpunch.y = 0
		totalviewpunch.r = 0
		
		for k,v in pairs(self.ScavViewPunches) do
			local progress = (UnPredictedCurTime() - v.Created) / v.lifetime
			if progress > 1 then
				table.insert(expiredVPs,k)
			else
				local progress = math.Clamp(progress, 0, 1)
				local multiplier = math.sin(math.sqrt(progress) * math.pi)
				totalviewpunch.p = totalviewpunch.p + multiplier * v.angle.p
				totalviewpunch.y = totalviewpunch.y + multiplier * v.angle.y
				totalviewpunch.r = totalviewpunch.r + multiplier * v.angle.r
			end
		end
		
		local numexpVPs = #expiredVPs
		for i=0,numexpVPs - 1 do
			table.remove(self.ScavViewPunches, expiredVPs[numexpVPs - i])
			expiredVPs[numexpVPs - i] = nil
		end	
		
		totalviewpunch.p = math.Max(-90 - angles.p, totalviewpunch.p)
		totalviewpunch.p = math.Min(90 - angles.p, totalviewpunch.p)
		
		angles.p = angles.p + totalviewpunch.p
		angles.y = angles.y + totalviewpunch.y
		angles.r = angles.r + totalviewpunch.r
		
		self.LastScavVPAngle = angles * 1
		self.LastScavViewPunchCalc = CurTime()
		
		return angles
		
	end
	
end
