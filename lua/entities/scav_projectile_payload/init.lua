AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.drag = 1

function ENT:Think()

	if self.Explode and not self.expl then
	
		self.expl = true
		
		net.Start("scv_falloffsound")
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			net.WriteVector(self:GetPos())
			net.WriteString("items/cart_explode.wav")
		net.Send(rf)
		
		self:SetPos(self:GetPos() + vector_up * 200)
		self:SetLocalAngles((vector_up * -1):Angle())
		util.ScreenShake(self:GetPos(),16,50,1,5000)
		util.BlastDamage(self,self.Owner,self:GetPos(),1000,500)
		ParticleEffectAttach("cinefx_goldrush",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self:Fire("kill",1,10)
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		
	end	
	
end

function ENT:PhysicsCollide(data,physobj)
	self.Explode = true
end 

function ENT:Touch(hitent)
end