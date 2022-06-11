local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0

function ENT:OnInit()	
	self:SetModel("models/props_italian/ava_stained_glass.mdl") --TODO: Make its own model like this (probably slightly more translucent)
	if CLIENT then
		self:SetModelScale(0.1,0)
	else
		self.sound = CreateSound(self,"ambient/machines/wall_loop1.wav")
		self.sound:Play()
		self:PrecacheGibs()
		self:PhysicsInit(6)
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		if angpos.Pos then
			self:SetPos(angpos.Pos+self.Player:GetAimVector()*18)
			local ang = self.Player:GetAimVector():Angle()
			--ang.p = ang.p
			ang.r = ang.r +CurTime()*45
			self:SetAngles(ang)
		end
end

if CLIENT then

	local beammat = Material("sprites/physbeama")
	local glowmat = Material("sprites/blueglow2")
	local scalevar = 1.3
	
	function ENT:Draw()
		self:DrawModel()
		self:SetModelScale(Lerp(math.Clamp((CurTime()-self.Created)*0.1,0,1)+math.Clamp(self:GetModelScale()*scalevar,0,0.6),0,1),0)
		render.SetMaterial(beammat)
		render.DrawBeam(self:GetMuzzlePosAng().Pos,self:GetPos(),math.Rand(6,10),CurTime()*2,CurTime()*2+1,color_white)
		render.SetMaterial(glowmat)
		local di = math.Rand(6,10)
		render.DrawSprite(self:GetPos(),di,di,color_white)
		
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_shield",true)