local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0

local models = {
	[SCAV_BUZZSAW_TF2] = "models/props_forest/sawblade_moving.mdl"
}
models = setmetatable(models, {__index = function() return "models/props_junk/sawblade001a.mdl" end})

local modelscaleinit = {
	[SCAV_BUZZSAW_TF2] = 0.01
}
modelscaleinit = setmetatable(modelscaleinit, {__index = function() return 0.1 end})

local sounds = {
	[SCAV_BUZZSAW_TF2] = "ambient/sawblade.wav",
	[SCAV_BUZZSAW_L4D] = "weapons/chainsaw/chainsaw_idle_lp_01.wav",
	[SCAV_BUZZSAW_ASW] = "weapons/2d/chainsaw/attackonloop.wav",
}
sounds = setmetatable(sounds, {__index = function() return "ambient/machines/spin_loop.wav" end})

local soundsend = {
	[SCAV_BUZZSAW_TF2] = "ambient/_period.wav",
	[SCAV_BUZZSAW_L4D] = "weapons/chainsaw/chainsaw_die_01.wav",
	[SCAV_BUZZSAW_ASW] = "weapons/2d/chainsaw/fullstop.wav",
}
soundsend = setmetatable(soundsend, {__index = function() return "ambient/machines/spindown.wav" end})

function ENT:OnInit()
	local identify = self:GetIdentify()
	self:SetModel(models[identify])
	if identify == SCAV_BUZZSAW_TF2 then
		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:ResetSequenceInfo()
			self:SetSequence("idle")
			self:SetPlaybackRate(2.1)
		end)
	end
	if CLIENT then
		self:SetModelScale(modelscaleinit[identify], 0)
	else
		self.sound = CreateSound(self,sounds[identify])
		self.sound:Play()
	end
	if self.Player.ScavBuzzStop then
		self.Player.ScavBuzzStop:Stop()
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
		self.Player.ScavBuzzStop = CreateSound(self.Player, soundsend[self:GetIdentify()])
		self.Player.ScavBuzzStop:Play()
	end
end

function ENT:OnThink()
	if CLIENT then
		local identify = self:GetIdentify()
		local angpos = self:GetMuzzlePosAng()
		if angpos.Pos then
			self:SetPos(angpos.Pos + self.Player:GetAimVector() * 18)
			local ang = self.Player:GetAimVector():Angle()
			if identify == SCAV_BUZZSAW_TF2 then
				ang.p = ang.p - 100
				ang.r = 180
			else
				ang.p = ang.p + CurTime() * 720 * 4
				ang.r = 90
			end
			self:SetAngles(ang)
		end
		if identify == SCAV_BUZZSAW_TF2 then
			self:FrameAdvance()
		end
	end
end

if CLIENT then

	local modelscalemax = {
		[SCAV_BUZZSAW_TF2] = 0.125
	}
	modelscalemax = setmetatable(modelscalemax, {__index = function() return 1 end})

	local modelscalespeed = {
		[SCAV_BUZZSAW_TF2] = 10
	}
	modelscalespeed = setmetatable(modelscalespeed, {__index = function() return 0.01 end})

	local drawbeam = {
		[SCAV_BUZZSAW_TF2] = false
	}
	drawbeam = setmetatable(drawbeam, {__index = function() return true end})

	local beammat = Material("sprites/physbeama")
	local glowmat = Material("sprites/blueglow2")
	local scalevar = 1.3
	
	function ENT:Draw()
		self:DrawModel()
		local identify = self:GetIdentify()
		self:SetModelScale(Lerp(math.Clamp((CurTime() - self.Created) * modelscalespeed[identify], 0, 1) + math.Clamp(self:GetModelScale() * scalevar, 0, 0.6), 0, modelscalemax[identify]), 0)

		if drawbeam[identify] then
			render.SetMaterial(beammat)
			render.DrawBeam(self:GetMuzzlePosAng().Pos, self:GetPos(), math.Rand(6, 10), CurTime() * 2, CurTime() * 2 + 1, color_white)
			render.SetMaterial(glowmat)
			local di = math.Rand(6, 10)
			render.DrawSprite(self:GetPos(), di, di, color_white)
		end
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_saw", true)