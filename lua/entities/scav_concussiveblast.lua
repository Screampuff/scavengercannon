AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then

	local dmginfo = DamageInfo()
	local function concblastcallback(ent,position,radius,attacker,inflictor,fraction)
	
		if IsValid(attacker) then
			dmginfo:SetAttacker(attacker)
		else
			dmginfo:SetAttacker(game.GetWorld())
		end
		
		if IsValid(inflictor) then
			dmginfo:SetInflictor(inflictor)
		else
			dmginfo:SetInflictor(game.GetWorld())
		end
		
		dmginfo:SetDamage(200)
		dmginfo:SetDamagePosition(position)
		dmginfo:SetDamageType(bit.bor(DMG_BLAST,DMG_DISSOLVE))
		ent:TakeDamageInfo(dmginfo)
		
	end
	
	function ENT:Initialize()
		ScavData.DoBlastCalculation(self:GetPos(),256,self:GetOwner(),self,concblastcallback)
		self:SetNoDraw(true)
		self:Remove()
	end
	
else
	
	function ENT:Initialize()
	
		self:SetNoDraw(true)
		
		local pos = self:GetPos()
		self.concem = ParticleEmitter(pos)

		for i=0,16,1 do
		
			local part = self.concem:Add("particle/particle_noisesphere",pos)
			
			if part then
				part:SetLifeTime(0)
				part:SetDieTime(math.Rand(0.2,0.4))
				part:SetStartSize(math.random(4,8))
				part:SetEndSize(math.random(32,64))
				part:SetVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)) * math.Rand(64,128))
				part:SetStartAlpha(math.random(64,128))
				part:SetEndAlpha(0)
				part:SetRoll(math.Rand(180,360))
				part:SetRollDelta(math.Rand(-4,4))
				local col = math.Rand(235,255)
				part:SetColor(col,col,col,255)
			end
			
		end

		for i=0,2,1 do
		
			local part = self.concem:Add("particle/particle_noisesphere",pos)
			
			if part then
				part:SetLifeTime(0)
				part:SetDieTime(math.Rand(1,2))
				part:SetStartSize(math.random(32,64))	
				part:SetEndSize(math.random(100,128))
				part:SetVelocity(Vector(math.Rand(-0.8,0.8),math.Rand(-0.8,0.8),math.Rand(-0.8,0.8)) * math.Rand(16,32))
				part:SetStartAlpha(math.random(32,64))
				part:SetEndAlpha(0)
				part:SetRoll(math.Rand(180,360))
				part:SetRollDelta(math.Rand(-1,1))
				local col = math.Rand(235,255)
				part:SetColor(col,col,col,255)
			end
			
		end

		local part = self.concem:Add("effects/blueflare1",pos)
		
		if part then
			part:SetLifeTime(0)
			part:SetDieTime(0.1)
			part:SetRoll(math.Rand(180,360))
			part:SetRollDelta(math.Rand(-1,1))
			part:SetColor(128,128,128,255)			
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetStartSize(16)
			part:SetEndSize(64)
		end
		
		local part = self.concem:Add("effects/blueflare1",pos)
		
		if part then
			part:SetLifeTime(0)
			part:SetDieTime(0.2)
			part:SetRoll(math.Rand(180,360))
			part:SetRollDelta(math.Rand(-1,1))
			part:SetColor(32,32,32,255)			
			part:SetStartAlpha(64)
			part:SetEndAlpha(0)
			part:SetStartSize(64)
			part:SetEndSize(128)
		end

		local dlight = DynamicLight(0)
		
		if dlight then
			dlight.Pos = pos
			dlight.r = 64
			dlight.g = 64
			dlight.b = 64
			dlight.Size = math.Rand(128,256)
			dlight.DieTime = CurTime() + 0.1
		end

		local numsparks = math.random(16,32)
		
		for i=0,numsparks,1 do
			local part = self.concem:Add("effects/blueflare1",pos)
			if part then
				part:SetLifeTime(0)
				part:SetDieTime(math.Rand(0.1,0.2))
				local width = math.Rand(1,2)
				part:SetStartSize(width)	
				part:SetEndSize(width)
				local length = math.Rand(0.01,0.1)
				part:SetStartLength(length)
				part:SetEndLength(length)
				part:SetVelocity(VectorRand() * math.Rand(800,1000))
				part:SetRoll(math.Rand(180,360))
				part:SetRollDelta(math.Rand(-1,1))
				local col = math.Rand(0.75,1) * 255
				part:SetColor(col,col,col,255)
			end
		end

		local numsparks = math.random(8,16)
		
		for i=0,numsparks,1 do
			local part = self.concem:Add("effects/blueflare1",pos)
			if part then
				part:SetLifeTime(0)
				part:SetDieTime(math.Rand(0.2,1))
				local width = math.Rand(1,2)
				part:SetStartSize(width)	
				part:SetEndSize(width)
				local length = math.Rand(0.01,0.1)
				part:SetStartLength(length)
				part:SetEndLength(length)
				local dir = VectorRand()
				dir.z = math.Rand(0,0.75)
				part:SetVelocity(dir * math.Rand(128,512))
				part:SetRoll(math.Rand(180,360))
				part:SetRollDelta(math.Rand(-1,1))
				local col = math.Rand(0.75,1) * 255
				part:SetColor(col,col,col,255)
			end
		end
			
--		self.concem:Finish()

	end
	
end