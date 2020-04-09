TOOL.Category				= "Construction"
TOOL.Name					= "#Scav Turret"
TOOL.ConfigName				= ""
TOOL.ClientConVar["type"] 	= "Rocket"

cleanup.Register("turrets")

Sound("ambient.electrical_zap_3")
Sound("NPC_FloorTurret.Shoot")

if CLIENT then
	language.Add("Tool.scavturret.name", 	"Scav Turret")
	language.Add("Tool.scavturret.desc", 	"Fire!")
	language.Add("Tool.scavturret.0", 		"Click somewhere to spawn an turret.")
	language.Add("Tool.scavturret.type", 	"Turret Type")
	language.Add("Undone.scavturret", 		"Undone Scav Turret")
	language.Add("Cleanup.scavturrets", 	"Scav Turret")
	language.Add("Cleaned.scavturrets", 	"Cleaned up all Scav Turrets")
	language.Add("SBoxLimit_scavturrets", 	"You've reached the Scav Turret limit!")
end

function TOOL:LeftClick(trace, worldweld)

	worldweld = worldweld or false

	if trace.Entity and trace.Entity:IsPlayer() then return false end

	if SERVER and not util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return false end
	
	if CLIENT then return true end
	
	local ply = self:GetOwner()

	if not self:GetSWEP():CheckLimit("scav_turrets") then return false end

	if trace.Entity ~= NULL and (not trace.Entity:IsWorld() or worldweld) then
		trace.HitPos = trace.HitPos + trace.HitNormal * 2
	else
		trace.HitPos = trace.HitPos + trace.HitNormal * 2
	end

	local turret = MakeScavTurret(ply, trace.HitPos)
	turret:SetAngles((trace.HitNormal*(-1)):Angle()
	)
	local weld

	if trace.Entity ~= NULL and (not trace.Entity:IsWorld() or worldweld) then
		weld = constraint.Weld(turret, trace.Entity, 0, trace.PhysicsBone, 0, 0, true)
		turret:GetPhysicsObject():EnableCollisions(false)
		turret:GetTable().nocollide = true
	end
	
	undo.Create("Scav Turret")
		undo.AddEntity(turret)
		undo.AddEntity(weld)
		undo.SetPlayer(ply)
	undo.Finish()
	
	return true

end

function TOOL:RightClick(trace)
	return self:LeftClick(trace, true)
end

function TOOL.BuildCPanel(CPanel)

	CPanel:AddControl("Header", {Text = "#Tool.scavturret.name", Description = "#Tool.scavturret.desc"})

	local weaponType = {Label = "#Tool.scavturret.type", MenuButton = 0, Options={}, CVars = {}}
	
	weaponType["Options"]["Rocket"]							= {scavturret_type = "rocket"}
	weaponType["Options"]["Grenade"] 						= {scavturret_type = "grenade"}
	weaponType["Options"]["Plasma"]							= {scavturret_type = "plasma"}
	weaponType["Options"]["Laser"] 							= {scavturret_type = "laser"}
	weaponType["Options"]["Seeking Rocket"]					= {scavturret_type = "seekrocket"}
	weaponType["Options"]["Flamethrower"] 					= {scavturret_type = "flamethrower"}
	weaponType["Options"]["Tank Shell"]						= {scavturret_type = "tankshell"}
	weaponType["Options"]["Frag 12 High Explosive Shell"] 	= {scavturret_type = "frag12"}
	weaponType["Options"]["Freezing Gas"] 					= {scavturret_type = "freeze"}
	
	CPanel:AddControl("ComboBox", weaponType)

end
