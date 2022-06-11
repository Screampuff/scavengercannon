ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"

PrecacheParticleSystem("scav_smoketrail_2")

if SERVER then
	CreateConVar("scav_maxshurikens",70,FCVAR_ARCHIVE)
end
local shurikens = {}

local function cleanshurikentable()
	local totalshurikens = #shurikens
	for i=0,totalshurikens-1 do
		if !IsValid(shurikens[totalshurikens-i]) then
			table.remove(shurikens,totalshurikens-i)
		end
	end
end

function ENT:Initialize()
    //self:SetModel("models/scav/shuriken.mdl")
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		cleanshurikentable()
		local shurikenstoclean = #shurikens-GetConVar("scav_maxshurikens"):GetInt()+1
		if shurikenstoclean > 0 then
			for i=1,shurikenstoclean do
				for k,v in pairs(shurikens) do
					if IsValid(v) && v.Stuck then
						v:Remove()
						break
					end
				end
			end
		end
		table.insert(shurikens,self)
    else
		//self.Points = {{self:GetPos(),self:GetPos()}}
	end
	self.Created = CurTime()
	
end

function ENT:SetupDataTables()
    self:DTVar("Entity",0,"StickEntity")
    self:DTVar("Int",0,"StickBone")
    self:DTVar("Vector",0,"StickPos")
    self:DTVar("Angle",0,"StickAngle")
    self.dt.StickEntity = NULL
end

function ENT:Think()
    local ent = self.dt.StickEntity
    if SERVER && self.Welded && !IsValid(self.Weld) then
        self.Welded = false
        self:Fire("Kill",nil,5)
        return
    end
    if (ent != nil) && (ent != NULL) then
        if self.dt.StickEntity:IsWorld() then
            self:SetPos(self.dt.StickPos)
            self:SetAngles(self.dt.StickAngle)
            return
        end
        if SERVER then
            self.laststuckentity = self.dt.StickEntity
            if (ent:IsNPC() && (ent:Health() <= 0)) || (ent:IsPlayer() && !ent:Alive()) then
                self:SetParent()
                self.dt.StickEntity = NULL
                self:SetMoveType(MOVETYPE_VPHYSICS)
                self:SetSolid(SOLID_VPHYSICS)
                self:GetPhysicsObject():SetVelocity(ent:GetVelocity())
                self:Fire("Kill",nil,30)
                return
            end
            if ent != self:GetParent() then
                self:SetParent(ent)
            end
        end
    elseif (self:GetMoveType() == MOVETYPE_NONE) && SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:GetPhysicsObject():EnableGravity(true)
        self:GetPhysicsObject():Wake()
    end
end