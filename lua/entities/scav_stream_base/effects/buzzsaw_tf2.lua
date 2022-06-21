local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0

util.PrecacheModel("models/props_forest/sawblade_moving.mdl")

function ENT:OnInit()	
	self:SetModel("models/props_forest/sawblade_moving.mdl")
	timer.Simple(0,function() if IsValid(self)then self:ResetSequenceInfo()
	self:SetSequence("idle")
	self:SetPlaybackRate(2.1)
	end end)
	if CLIENT then
		self:SetModelScale(0.01,0)
	else
		self.sound = CreateSound(self,"ambient/sawblade.wav")
		self.sound:Play()
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:OnThink()
	if CLIENT then
		local angpos = self:GetMuzzlePosAng()
		if angpos.Pos then
			self:SetPos(angpos.Pos+self.Player:GetAimVector()*18)
			local ang = self.Player:GetAimVector():Angle()
			ang.p = ang.p - 100
			ang.r = 180
			self:SetAngles(ang)
		end
		self:FrameAdvance()
	end
end

if CLIENT then

	local beammat = Material("sprites/physbeama")
	local glowmat = Material("sprites/blueglow2")
	local scalevar = 1.3
	
	function ENT:Draw()
		self:DrawModel()
		self:SetModelScale(Lerp(math.Clamp((CurTime()-self.Created)*10,0,1)+math.Clamp(self:GetModelScale()*scalevar,0,0.6),0,.125),0)
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_saw_tf2",true)