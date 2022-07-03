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
		if not IsValid(shurikens[totalshurikens-i]) then
			table.remove(shurikens,totalshurikens-i)
		end
	end
end

function ENT:Initialize()
    --self:SetModel("models/scav/shuriken.mdl")
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
					if IsValid(v) and v.Stuck then
						v:Remove()
						break
					end
				end
			end
		end
		table.insert(shurikens,self)
    else
		--self.Points = {{self:GetPos(),self:GetPos()}}
	end
	self.Created = CurTime()
	
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity",0,"StickEntity")
    self:NetworkVar("Int",0,"StickBone")
    self:NetworkVar("Vector",0,"StickPos")
    self:NetworkVar("Angle",0,"StickAngle")
    self:SetStickEntity(NULL)
end

function ENT:Think()
    local ent = self:GetStickEntity()
    if SERVER and self.Welded and not IsValid(self.Weld) then
        self.Welded = false
        self:Fire("Kill",nil,5)
        return
    end
    if (ent ~= nil) and (ent ~= NULL) then
        if self:GetStickEntity():IsWorld() then
            self:SetPos(self:GetStickPos())
            self:SetAngles(self:GetStickAngle())
            return
        end
        if SERVER then
            self.laststuckentity = self:GetStickEntity()
            if ((ent:IsNPC() or (_ZetasInstalled and ent:GetClass() == "npc_zetaplayer")) and (ent:Health() <= 0)) or (ent:IsPlayer() and not ent:Alive()) then
                self:SetParent()
                self:SetStickEntity(NULL)
                self:SetMoveType(MOVETYPE_VPHYSICS)
                self:SetSolid(SOLID_VPHYSICS)
                self:GetPhysicsObject():SetVelocity(ent:GetVelocity())
                self:Fire("Kill",nil,30)
                return
            end
            if ent ~= self:GetParent() then
                self:SetParent(ent)
            end
        end
    elseif (self:GetMoveType() == MOVETYPE_NONE) and SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:GetPhysicsObject():EnableGravity(true)
        self:GetPhysicsObject():Wake()
    end
end
