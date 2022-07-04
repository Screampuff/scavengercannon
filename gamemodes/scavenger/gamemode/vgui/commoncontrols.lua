local PANEL = {}
	PANEL.WMargin = 8
	PANEL.HMargin = 4
	PANEL.ASV = false
	PANEL.Wrap = true
	PANEL.Plain = true
	PANEL.Align = TEXT_ALIGN_LEFT

	function PANEL:Init()
		self.Label = vgui.Create("DLabel",self)
		self.Font = "HUDHintTextLarge"
		self.Label:SetFont(self.Font)
		self.Label:SetAutoStretchVertical(self.ASV)
		self.Label:SetWrap(self.Wrap)
		self.initialized = true
	end
	
	function PANEL:InvalidateLayout()
		if not self.initialized then
			return
		end
		--self.Label:SizeToContents()
		--self.Label:SetPos(8,self:GetTall()/2-self.Label:GetTall()/2)
		--self.Label:SetWide(self:GetWide()-16)
		if self.Align == TEXT_ALIGN_LEFT then
			self.Label:SetSize(self:GetWide()-self.WMargin*2,self:GetTall()-self.HMargin*2)
			self.Label:SetPos(self.WMargin,self.HMargin)
		else
			self:UpdateAlign()
		end
		--
		--
	end
	
	function PANEL:SizeToContents()
		self.Label:SizeToContents()
		self.Label:InvalidateLayout()
		self:SetSize(self.Label:GetWide()+self.WMargin*2,self.Label:GetTall()+self.HMargin*2)
		self:InvalidateLayout()
	end
	
	function PANEL:UpdateAlign()
		self.Label:SizeToContents()
		self.Label:InvalidateLayout()
		local wm = self.WMargin
		local hm = self.HMargin
		local w = self:GetWide()-wm*2
		local h = self:GetTall()-hm*2
		local x
		local y
		local lw = self.Label:GetWide()
		local lh = self.Label:GetTall()
		local align = self.Align
		if align == TEXT_ALIGN_LEFT then
			x = 0
			y = (h-lh)/2
		elseif align == TEXT_ALIGN_CENTER then
			x = (w-lw)/2
			y = (h-lh)/2
		elseif align == TEXT_ALIGN_RIGHT then
			x = w-lw
			y = (h-lh)/2
		elseif align == TEXT_ALIGN_TOP then
			x = (w-lw)/2
			y = 0
		elseif align == TEXT_ALIGN_BOTTOM then
			x = (w-lw)/2
			y = h-lh
		end
		x = x+wm
		y = y+hm
		self.Label:SetPos(x,y)
	end
	
	function PANEL:SetWMargin(value)
		self.WMargin = value
		self:InvalidateLayout()
	end
	
	function PANEL:SetHMargin(value)
		self.HMargin = value
		self:InvalidateLayout()
	end
	
	function PANEL:SetMargins(w,h)
		self.WMargin = w
		self.HMargin = h
		self:InvalidateLayout()
	end
	
	function PANEL:SetFont(font)
		self.Font = font
		self.Label:SetFont(font)
		self:InvalidateLayout()
	end

	function PANEL:SetText(text)
		self.Text = text
		self.Label:SetText(text)
		self:InvalidateLayout()
	end
	
	function PANEL:SetAutoStretchVertical(value)
		self.Label:SetAutoStretchVertical(value)
		self.ASV = value
		self:InvalidateLayout()
	end

	function PANEL:SetWrap(value)
		self.Wrap = value
		self.Label:SetWrap(value)
	end	
	
	function PANEL:GetWMargin()
		return self.WMargin
	end
	
	function PANEL:GetHMargin()
		return self.HMargin
	end
	
	function PANEL:GetMargins()
		return self.WMargin,self.HMargin
	end
	
	function PANEL:GetFont()
		return self.Font
	end
	
	function PANEL.GetText()
		return self.Text
	end
	
	function PANEL:GetAutoStretchVertical()
		return self.ASV
	end
	
	function PANEL:GetWrap()
		return self.Wrap
	end
	
	function PANEL:SetAlignment(alignment)
		self.Align = alignment
		if alignment ~= TEXT_ALIGN_LEFT then
			self:SetWrap(false)
		end
		self:UpdateAlign()
	end
	
	vgui.Register("sdm_labelbox",PANEL,"DPanel")
	
	
local PANEL = {}
	PANEL.Ent = NULL
	local flagtex = surface.GetTextureID("HUD/sdm/dot")
	local flagtex2 = surface.GetTextureID("HUD/sdm/dot2")
	local flagtex3 = surface.GetTextureID("HUD/sdm/dot3")
	
	function PANEL:Init()
		--self.Color = Color(255,255,255,255)
	end
	
	function PANEL:SetEntity(ent)
		self.Ent = ent
	end
	
	function PANEL:GetEntity()
		return self.Ent
	end
	
	function PANEL:SetColor(col)
		if type(col) == "nil" then
			self.Color = nil
		else
			self.Color = table.Copy(col)
		end
	end

	function PANEL:GetColor()
		return table.Copy(self.Color)
	end
	
	function PANEL:Paint(pw,ph)
		local yaw = EyeAngles().y
		local pos1 = EyePos()
		if IsValid(self.Ent) then
			local r,g,b,a = 255,255,255,255
			if self.Color then
				r,g,b,a = self.Color.r,self.Color.g,self.Color.b,self.Color.a
			elseif self.Ent.dt and self.Ent.dt.Team then
				local col = team.GetColor(self.Ent.dt.Team)
				r,g,b,a = col.r,col.g,col.b,col.a	
			end
			local w,h = self:GetSize()
			local dia = math.min(w,h)
			if self.Ent:GetOwner() == GetViewEntity() then
				surface.SetTexture(flagtex2)
			else
				surface.SetTexture(flagtex)
			end
			local pos2 = self.Ent:GetPos()
			surface.SetDrawColor(r,g,b,a)
			local dist = pos2:Distance(pos1)
			surface.DrawTexturedRectRotated(w/2,h/2,dia,dia,math.Rad2Deg(math.atan2((pos2.y-pos1.y),(pos2.x-pos1.x)))-yaw)
			if self.Ent:GetOwner():IsPlayer() then
				surface.SetTexture(flagtex3)
				local col = team.GetColor(self.Ent:GetOwner():Team())
				surface.SetDrawColor(col.r,col.g,col.b,col.a)
				surface.DrawTexturedRect(w/2-dia/2,h/2-dia/2,dia,dia)
			end
			surface.SetDrawColor(255,255,255,255)
		end
	end
		
	vgui.Register("sdm_entpointer",PANEL)

	local PANEL = {}
		PANEL.DoAutoPos = true
		PANEL.PointerHorizontalSpacing = 32
		PANEL.PointerVerticalSpacing = 16
		PANEL.PointerDiameter = 32
		
		function PANEL:Init()
			self.initialized = true
			self.Items = {}
		end
		
		function PANEL:SetPointerDiameter(amt)
			self.PointerDiameter = amt
			self:AutoSize()
		end
		
		function PANEL:SetPointerHorizontalSpacing(amt)
			self.PointerHorizontalSpacing = amt
			self:AutoSize()
		end
		
		function PANEL:SetPointerVerticalSpacing(amt)
			self.PointerVerticalSpacing = amt
			self:AutoSize()
		end
		
		function PANEL:AutoSize()
			local mul = self.PointerHorizontalSpacing+self.PointerDiameter
			for k,v in ipairs(self.Items) do
				v:SetPos(self.PointerHorizontalSpacing+(k-1)*mul,self.PointerVerticalSpacing)
				v:SetSize(self.PointerDiameter,self.PointerDiameter)
			end
			self:SetSize(self.PointerHorizontalSpacing+#self.Items*mul,self.PointerVerticalSpacing*2+self.PointerDiameter)
		end
		
		function PANEL:AutoPos()
			self:SetPos(ScrW()/2-self:GetWide()/2,0)
		end
		
		function PANEL:InvalidateLayout()
			if not self.initialized then
				return
			end

		end
		
		function PANEL:Clear()
			for k,v in ipairs(self.Items) do
				self.Items[k] = nil
				v:Remove()
			end
		end
		

		
		function PANEL:AddFlag(ent)
			if not ent.dt then
				return
			end
			local panel = vgui.Create("sdm_entpointer",self)
			panel:SetSize(self.PointerDiameter,self.PointerDiameter)
			panel:SetEntity(ent)
			panel:SetColor(team.GetColor(ent.dt.Team))
			table.insert(self.Items,panel)
			self:AutoSize()
		end
		
		function PANEL:SetupFlags()
			self:Clear()
			for k,v in ipairs(ents.FindByClass("sdm_flag")) do
				self:AddFlag(v)
			end
			if self.DoAutoPos then	
				self:AutoPos()
			end
		end
		
		vgui.Register("sdm_flagtracker",PANEL,"DPanel")
		
	local PANEL = {}
		
		function PANEL:Init()
		end
		
		function PANEL:AutoPos()
			self:SetPos(ScrW()/2-self:GetWide()/2,64)
		end
		
		vgui.Register("sdm_objective",PANEL,"sdm_labelbox")
		
	local PANEL = {}
		PANEL.Title = "Title"
		PANEL.Text = "Text"
		function PANEL:Init()
			self.initialized = true
			self:SetSize(112,56)
			self.TitleLabel = vgui.Create("DLabel",self)
				self.TitleLabel:SetText(self.Title)
				self.TitleLabel:SetFont("HUDHintTextLarge")
				self.TitleLabel:SetPos(4,4)
				self.TitleLabel:SizeToContents()
			self.TextLabel = vgui.Create("DLabel",self)
				self.TextLabel:SetFont("DermaLarge")
				self.TextLabel:SetPos(24,14)
				self.TextLabel:SetText(self.Text)
		end


		function PANEL:InvalidateLayout()
			if not self.initialized then
				return
			end
		end
		
		function PANEL:SetText(text)
			self.TextLabel:SetText(text)
			self.TextLabel:SizeToContents()
			self.TextLabel:SetPos((self:GetWide()-self.TextLabel:GetWide())/2,12+(self:GetTall()-12-self.TextLabel:GetTall())/2)
		end
		
		function PANEL:SetTitle(title)
			self.TitleLabel:SetText(title)
			self.TitleLabel:SizeToContents()
		end
		
		vgui.Register("sdm_generichudbox",PANEL,"DPanel")

	local PANEL = {}
		PANEL.EndTime = 0
		PANEL.Title = "Time:"
		PANEL.Wide = 112
		PANEL.Tall = 48
		
		function PANEL:Init()
			self.initialized = true
			self:SetSize(self.Wide,self.Tall)
			self.TitleLabel = vgui.Create("DLabel",self)
				self.TitleLabel:SetText("Time: ")
				self.TitleLabel:SetFont("DebugFixed")
				self.TitleLabel:SetPos(4,4)
				self.TitleLabel:SizeToContents()
			self.TextLabel = vgui.Create("DLabel",self)
				self.TextLabel:SetFont("Trebuchet24")
				self.TextLabel:SetPos(24,14)
				self.TextLabel:SetText("00:00")
		end
		
		function PANEL:Think()
			local timeleft = self.EndTime-CurTime()
			if timeleft > 0 then
				self.TextLabel:SetText(string.FormattedTime(timeleft,"%02i:%02i"))
			else
				self.TextLabel:SetText("00:00")
			end
		end
		
		function PANEL:SetEndTime(when)
			self.EndTime = when
		end
		
		function PANEL:GetEndTime()
			return self.EndTime
		end
		
		vgui.Register("sdm_timer",PANEL,"DPanel")
		
	local PANEL = {}
		PANEL.Player = NULL
		PANEL.Title = "Health"
		PANEL.Wide = 112
		PANEL.Tall = 48
		
		function PANEL:Init()
			self:SetSize(self.Wide,self.Tall)
			self:SetTitle("Health")
		end
		
		function PANEL:Think()
			if IsValid(self.Player) then
				self:SetText(self.Player:Health())
			else
				self:SetText("0")
			end
		end
		
		function PANEL:SetPlayer(pl)
			self.Player = pl
		end
		
		function PANEL:GetPlayer()
			return self.Player
		end
		
		vgui.Register("sdm_healthpanel",PANEL,"sdm_generichudbox")

	local PANEL = {}
		PANEL.Title = "Armor"
		PANEL.Wide = 96
		PANEL.Tall = 48

		function PANEL:Init()
			self:SetSize(self.Wide,self.Tall)
			self:SetTitle("Armor")
		end
		
		function PANEL:Think()
			if IsValid(self.Player) then
				self:SetText(math.floor(self.Player:Armor()))
			else
				self:SetText("0")
			end
		end
		
		vgui.Register("sdm_armorpanel",PANEL,"sdm_healthpanel")

	local PANEL = {}
		PANEL.Title = "Energy"
		PANEL.Wide = 72
		PANEL.Tall = 48

		function PANEL:Init()
			self:SetSize(self.Wide,self.Tall)
			self:SetTitle("Energy")
		end
		
		function PANEL:Think()
			if IsValid(self.Player) then
				self:SetText(math.floor(self.Player:GetEnergy()))
			else
				self:SetText("0")
			end
		end
		
		vgui.Register("sdm_energypanel",PANEL,"sdm_healthpanel")
		
	local PANEL = {}
		PANEL.Title = "Score"
		PANEL.Wide = 112
		PANEL.Tall = 48

		function PANEL:Init()
			self:SetTitle("Score: ")
		end
	
		function PANEL:Think()
			if IsValid(self.Player) then
				self:SetText(math.floor(self.Player:Frags()).."/"..GAMEMODE:GetGNWShort("PointLimit"))
			else
				self:SetText("0/"..GAMEMODE:GetGNWShort("PointLimit"))
			end
		end
		
		vgui.Register("sdm_fragpanel",PANEL,"sdm_healthpanel")
		
	local PANEL = {}
		PANEL.Title = "Next"
		PANEL.Wide = 128
		PANEL.Tall = 48

		function PANEL:Init()
			self:SetTitle("Points to next:")
		end
	
		function PANEL:Think()
			
			if IsValid(self.Player) and (self.Player:Team() ~= TEAM_SPECTATOR) then
				local sortedplayers = team.GetSortedPlayers(self.Player:Team())
				local place = 1
				for k,v in pairs(sortedplayers) do
					if v == self.Player then
						place = k
						break
					end
				end
				if place == 1 then
					--self:SetText(math.floor(team.GetScoreLimit(self.Player:Team())-self.Player:Frags()))
					self:SetText("LEAD")
				else
					local nextpl = sortedplayers[place-1]
					local text = math.floor(nextpl:Frags()-self.Player:Frags())
					if text == 0 then
						text = "TIED"
					end
					self:SetText(text)
				end
			else
				self:SetText("0")
			end
		end
		
		vgui.Register("sdm_dm_fragsbehind",PANEL,"sdm_healthpanel")
		
		team.GetSortedPlayers(teamnum)
		
	local PANEL = {}
		PANEL.TitleString = "Title"
		PANEL.TextString = "Text"
		function PANEL:Init()
			self.Title = vgui.Create("DLabel",self)
				self.Title:SetFont("DebugFixed")
			self.Text = vgui.Create("DLabel",self)
				self.Text:SetFont("DermaLarge")
			self.initialized = true
		end
		
		function PANEL:SetTitle(text)
			self.TitleString = text
			self.Title:SetText(text)
			self.Title:SizeToContents()
			self:InvalidateLayout()
		end

		function PANEL:SetText(text)
			self.TextString = text
			self.Text:SetText(text)
			self.Text:SizeToContents()
			self:InvalidateLayout()
		end
		
		function PANEL:InvalidateLayout()
			if not self.initialized then
				return false
			end
			self.Title:SetPos(self:GetWide()/2-self.Title:GetWide()/2,8)
			self.Text:SetPos(self:GetWide()/2-self.Text:GetWide()/2,16)
		end
	
		function PANEL:AutoPos()
			self:SetPos(ScrW()/2-self:GetWide()/2,0)
		end
		
	vgui.Register("sdm_hudpanel2",PANEL,"DPanel")
