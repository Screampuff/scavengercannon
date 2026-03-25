local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"

PrecacheParticleSystem("scav_radio")
PrecacheParticleSystem("scav_radio_vm")



function ENT:ScavStreamKeyboardSound(delay)
	if CLIENT then return end
	local snd = math.random(#self.sound)
	if self.sound[snd] then
		self.sound[snd]:Stop()
		self.sound[snd]:Play()
	end
	timer.Create(tostring(self) .. "ScavStreamKeyboardSound", delay, 1, function()
		if not IsValid(self) then return end
		self:ScavStreamKeyboardSound(delay)
	end)
end


function ENT:OnInit()
	local identify = self:GetIdentify()
	local sounds = {
		[SCAV_HACK_KB] =  {
			CreateSound(self, "ambient/machines/keyboard1_clicks.wav"),
			CreateSound(self, "ambient/machines/keyboard2_clicks.wav"),
			CreateSound(self, "ambient/machines/keyboard3_clicks.wav"),
			CreateSound(self, "ambient/machines/keyboard4_clicks.wav"),
			CreateSound(self, "ambient/machines/keyboard5_clicks.wav"),
			CreateSound(self, "ambient/machines/keyboard6_clicks.wav"),
			--A chance to pause
			false,
			false
		},
		[SCAV_HACK_WHEATLEY] = {}
	}
	sounds = setmetatable(sounds, {__index = function() return CreateSound(self, "ambient/levels/labs/equipment_beep_loop1.wav") end})
	--don't bother if we aren't using it
	if identify == SCAV_HACK_WHEATLEY then
		if TF2 then
			for i = 2, 37 do
				table.insert(sounds[SCAV_HACK_WHEATLEY], CreateSound(self, "vo/items/wheatley_sapper/wheatley_sapper_hacking" .. (i < 10 and "0" or "") .. tostring(i) ..".mp3"))
			end
		elseif PORTAL2 then
			sounds[SCAV_HACK_WHEATLEY] = {
				CreateSound(self, "vo/wheatley/bw_a4_death_trap_escape10.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_death_trap_escape10.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_death_trap_nags04.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale02_beamtrap_inbeama01.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale02_mashplate_intro01.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale02_pipe_collapse01.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale02_pipe_collapse04.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale02_trapintro01.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_finale_one01.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_first_test_solve_nags02.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_first_test_solve_nags03.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_misc_solve_nags02.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_misc_solve_nags03.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_misc_solve_nags04.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_paradox04.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_paradox06.wav"),
				CreateSound(self, "vo/wheatley/bw_a4_paradox08.wav"),
				CreateSound(self, "vo/wheatley/bw_finale04_stalemate_intro01.wav"),
				CreateSound(self, "vo/wheatley/bw_finale04_stalemate_intro06.wav"),
				CreateSound(self, "vo/wheatley/bw_finale4_hackworked03.wav"),
				CreateSound(self, "vo/wheatley/bw_sp_a4_stop_the_box_solve04.wav"),
				CreateSound(self, "vo/wheatley/bw_sp_a4_tb_wall_button_solve02.wav"),
				CreateSound(self, "vo/wheatley/bw_sp_a4_tb_trust_drop_impatient01.wav"),
				CreateSound(self, "vo/wheatley/demospherefirstdoorwaysequence02.wav"),
				CreateSound(self, "vo/wheatley/demospherefirstdoorwaysequence09.wav"),
				CreateSound(self, "vo/wheatley/demospherefirstdoorwaysequence10.wav"),
				CreateSound(self, "vo/wheatley/demospherefirstdoorwaysequence13.wav"),
				CreateSound(self, "vo/wheatley/demospherepowerup01.wav"),
			}
		end
	end
	self.sound = sounds[identify]
	if identify == SCAV_HACK_KB or identify == SCAV_HACK_WHEATLEY then
		local delay = self:GetIdentify() == SCAV_HACK_KB and 0.375 or 5
		self:ScavStreamKeyboardSound(delay)
		if identify == SCAV_HACK_WHEATLEY and not TF2 and SERVER then
			self.sound2 = sounds[SCAV_HACK_DEFAULT]
			self.sound2:Play()
		end
	elseif SERVER then
		self.sound:Play()
	end
	--if CLIENT then
		--self:CreateParticleEffect("scav_radio", self:GetOwner():LookupAttachment("muzzle"))
	--end
end

function ENT:OnKill()

	if type(self.sound) == "table" then
		for _, v in ipairs(self.sound) do
			if v then
				v:Stop()
			end
		end
	elseif self.sound then
		self.sound:Stop()
	end
	if self.sound2 then
		self.sound2:Stop()
	end

	if CLIENT then
		local vm = self:GetViewModel()
		local wep = self.Weapon
		if IsValid(vm) then
			vm:StopParticleEmission()
		end
		if IsValid(wep) then
			wep:StopParticleEmission()
		end
	end
end

function ENT:OnThink()
	if CLIENT then
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
	end
end

function ENT:OnViewMode()
	local vm = self:GetViewModel()
	local wep = self.Weapon
	if IsValid(wep) then
		wep:StopParticleEmission()
	end
	if IsValid(vm) then
		ParticleEffectAttach("scav_radio_vm", PATTACH_POINT_FOLLOW, vm, vm:LookupAttachment("muzzle"))
	end
end

function ENT:OnWorldMode()
	local wep = self.Weapon
	local vm = self:GetViewModel()
	if IsValid(vm) then
		vm:StopParticleEmission()
	end
	if IsValid(wep) then
		ParticleEffectAttach("scav_radio", PATTACH_POINT_FOLLOW, wep, wep:LookupAttachment("muzzle"))
	end
end

scripted_ents.Register(ENT, "scav_stream_radio")
