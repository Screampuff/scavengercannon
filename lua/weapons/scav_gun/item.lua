--NOTE: An inventory cannot hold more than 255 items.
local SWEP = SWEP
local ScavData = ScavData

local state
if CLIENT then
	state = "Client - "
else
	state = "Server - "
end

CreateConVar("scav_itemdebug",0,FCVAR_REPLICATED)

local function debugprint(infotype,message)
	if GetConVar("scav_itemdebug"):GetBool() then
		print(state..infotype..": "..message)
	end
end

ScavInventories = {}

local INVENTORY = {}

INVENTORY.numberofitems = 0

function INVENTORY:Initialize(weapon)

	self.items = {}
	self.itemids = {}
	
	if SERVER then
		self.rf = {} --using a table instead of a CRecipientFilter because the values of a CRF can't be retrieved
		
		local id = 1
		
		for i=1,#ScavInventories do
			if not ScavInventories[i] then
				id = i
				break
			end
		end
		
		self.ID = id --the permanent inventory id
		ScavInventories[id] = self
		
	end
	
	self.Owner = weapon
	
end
	
function INVENTORY:GetRecipientFilter()
	if not IsValid(self.Owner) or IsValid(self.Owner) and not IsValid(self.Owner.Owner) then return false end
	local rf = self.Owner.Owner
	return rf
end
	
function GetScavInventoryByID(id)
	return ScavInventories[id]
end

function INVENTORY:AddPlayerToRecipientFilter(pl)
	if not table.HasValue(self.rf,pl) then
		table.insert(self.rf,pl)
	end
end

if SERVER then
	util.AddNetworkString("scv_invadd")
end
	
function INVENTORY:AddOnClient(pl)

	if pl and not pl:IsValid() then
		return
	end
	
	net.Start("scv_invadd")
		net.WriteInt(self.ID,16)
		net.WriteEntity(self.Owner)
	net.Send(pl or self:GetRecipientFilter())
	
	for k,v in ipairs(self.items) do
		v:AddOnClient(pl or self:GetRecipientFilter())
	end

end
	
if CLIENT then
	net.Receive("scv_invadd",function()
	
		local id = net.ReadInt(16)
		local inv = ScavInventories[id]
		local owner = net.ReadEntity()
		
		if inv then
			inv:Remove()
		end
		
		inv = ScavInventory(owner)
		inv.ID = id
		ScavInventories[id] = inv
		owner.inv = inv
		
	end)
end
	
function ScavInventory(weapon)
	local inv = {}
	table.Inherit(inv,INVENTORY)
	inv:Initialize(weapon)
	return inv
end

function ReinitializeScavInventory(inv)
	table.Inherit(inv,INVENTORY)
	for _,v in ipairs(inv.items) do
		v.parent = inv
		ReinitializeScavItem(v)
	end
end

function INVENTORY:FindVacantID()
	for i=1,255 do
		if not self.itemids[i] then
			return i
		end
	end
	return 1
end
	
function INVENTORY:GetItems()
	return self.items
end

function INVENTORY:GetItemIDs()
	return self.itemids
end

function INVENTORY:GetItemCount()
	return self.numberofitems
end

if SERVER then
	util.AddNetworkString("scv_invrem")
end
	
function INVENTORY:Remove() --Calling this on the server will send a net message that calls this same function on the client.

	local rf = self:GetRecipientFilter()
	
	if SERVER and (type(rf) == "Player" or type(rf) == "CRecipientFilter") then
		net.Start("scv_invrem")
			net.WriteInt(self.ID,16)
		net.Send(rf)
	end

	for _,v in pairs(self.itemids) do
		v:Remove(true)
	end
	
	ScavInventories[self.ID] = nil
	
end
	
if CLIENT then
	net.Receive("scv_invrem",function()
		local inv = ScavInventories[net.ReadInt(16)]
		if inv then
			inv:Remove()
		end
	end)
end
	
	
function INVENTORY:UpdateItemPositions()
	for k,v in ipairs(self.items) do
		v.pos = k
	end
end
	
function INVENTORY:CallOnUpdate(func)
	self.OnUpdateFunction = func
end
	
function INVENTORY:Update()
	for k,v in ipairs(self.items) do
		v.pos = k
	end
	if self.OnUpdateFunction then
		self:OnUpdateFunction()
	end
end

if SERVER then
	util.AddNetworkString("scv_invclr")
end

function INVENTORY:ClearOnClient(pl)
	net.Start("scv_invclr")
		net.WriteInt(self.inv:GetID(),16)
	net.Send(pl or self:GetRecipientFilter())
end
	
if CLIENT then
	net.Receive("scv_invclr",function()
		local inv = ScavInventories[net:ReadInt(16)]
		if inv then
			for _,v in ipairs(inv:GetItemIDs()) do
				v:Remove()
			end
		end
	end)
end
		
function INVENTORY:AddAllToClient(pl)
	for _,v in ipairs(self.items) do
		v:AddOnClient(pl)
	end
end

if SERVER then
	util.AddNetworkString("scv_invshft")
end
	
function INVENTORY:ShiftItems(amt,pl)

	if amt < 0 then --shift down
		for i=1,-amt do
			table.insert(self.items,table.remove(self.items,1))
		end
	elseif amt ~= 0 then --shift up
		local tabsize = self:GetItemCount()
		for i=1,amt do
			table.insert(self.items,1,table.remove(self.items,tabsize))
		end
	end
	
	self:Update()
	
	if IsValid(self.Owner) and self.Owner:GetClass() == "scav_gun" then
		self.Owner:SendWeaponAnim(ACT_VM_RELOAD)
		self.Owner:SetSeqEndTime(CurTime() + 1)
	end
	
	if SERVER then
		net.Start("scv_invshft")
			net.WriteInt(self.ID,16)
			net.WriteInt(amt,9)
		net.Send(self:GetRecipientFilter())
	end
	
	if self.Owner.OnInvShift then
		self.Owner:OnInvShift(self)
	end
	
end
	
if CLIENT then
	net.Receive("scv_invshft",function()
		local inv = ScavInventories[net.ReadInt(16)]
		if inv then
			local amt = net.ReadInt(9)
			inv:ShiftItems(amt)
		end
	end)
end
	
if SERVER then

	util.AddNetworkString("scv_snap")

	function INVENTORY:SendSnapshot()
		net.Start("scv_snap")
			net.WriteInt(self.ID,16)
			local amt = #self.items
			net.WriteInt(amt,9)
			for i=1,amt do
				net.WriteInt(self.items[i].ID,9)
			end
		net.Send(self:GetRecipientFilter())
	end
	
else

	net.Receive("scv_snap",function()
		local inv = ScavInventories[net.ReadInt(16)]
		local amt = net.ReadInt(9)
		if inv then
			for k,v in pairs(inv.items) do
				inv.items[k] = nil
			end
			for i=1,amt do
				inv.items[i] = inv.itemids[net.ReadInt(9)]
			end
		end
	end)
	
end

local ITEM = {}
ITEM.ParentTable = nil
ITEM.ammo = ""
ITEM.subammo = 0
ITEM.data = 0
ITEM.mass = 0
ITEM.pos = 0 --position in the inventory

--update the position field of ITEM whenever its position in the inventory changes
function ScavItem(parent,pos,id)
	local item = table.Copy(ITEM)
	item:Initialize(parent,pos,id)
	return item
end
	
--[[---------------------------------------------------------
   Name: ITEM:Initialize( parent )
   Desc: Called when the item is created
---------------------------------------------------------]]--

function ITEM:Initialize(parent,pos,id)

	if id then
		self.ID = id
	end
	
	self.valid = true
	self.parent = parent -- the inventory to which this item belongs
	
	if SERVER then --only the server should set the ID
		self:SetID(self.parent:FindVacantID()) --our permanent ID within this inventory
	end
	
	if pos then
		self.pos = table.insert(self.parent.items,pos,self)
	else
		self.pos = table.insert(self.parent.items,self)
	end
	
	self.parent.numberofitems = self.parent.numberofitems + 1
	
	debugprint("items","inc itemcount to "..self.parent.numberofitems)
	
	if self.parent.Owner.OnItemInitialized then
		self.parent.Owner:OnItemInitialized(self)
	end
	
end

function ITEM:FinishSetup() --this will need to be called after you've finished setting up the item
	if self.parent.Owner.OnItemReady then
		self.parent.Owner:OnItemReady(self)
	end
end

--[[---------------------------------------------------------
   Name: ITEM:AddOnClient( pl )
   Desc: Makes the item known to the client
---------------------------------------------------------]]--

if SERVER then
	util.AddNetworkString("scv_itmadd")
end
	
function ITEM:AddOnClient(pl)

	if not IsValid(pl) then return end

	net.Start("scv_itmadd")
		net.WriteInt(self:GetParentID(),16)
		net.WriteInt(self.ID,9)
		if self.pos ~= 1 then  --instead of sending the absolute position, which could get messy, we'll send the ID of the item we're above, 0 if we're not above anything
			net.WriteInt(self.parent.items[self.pos-1]:GetID(),9)
		else
			net.WriteInt(0,9)
		end
		net.WriteString(self.ammo)
		net.WriteInt(self.subammo,16)
		net.WriteInt(self.data,16)
		net.WriteFloat(self.mass)
	net.Send(pl or self.parent:GetRecipientFilter())
	
end

function ReinitializeScavItem(item)
	table.Inherit(item,ITEM)
end
	
if CLIENT then

	net.Receive("scv_itmadd",function()
	
		local invid = net.ReadInt(16)
		
		local inv = ScavInventories[invid]
		if not inv then
			return
		end
		local id = net.ReadInt(9)
		if inv.itemids[id] then
			inv.itemids[id]:Remove()
		end
		
		local idofprev = net.ReadInt(9)
		local model = net.ReadString()
		local subammo = net.ReadInt(16)
		local data = net.ReadInt(16)
		local mass = net.ReadFloat()
		
		local skin = 0
		
		if data ~= 0 and (not ScavData.models[model] or not ScavData.models[model].noskin) then
			skin = data
		end
		--func_physboxes
		if string.find(model,"*%d",0,false) then
			model = "models/error.mdl"
			--model = "models/hunter/triangles/1x1x2carved.mdl" --TODO: figure out how to get the texture off of the physbox and put it on here. Something along the lines of - GetBrushSurfaces()[1]:GetName() - 
		end
		
		local item = nil
		
		if idofprev == 0 or not inv.itemids[idofprev] then
			item = ScavItem(inv,1,id)
		else
			item = ScavItem(inv,inv.itemids[idofprev].pos + 1,id)
		end
		
		item:SetID(id)
		inv.itemids[id] = item
		item:SetAmmoType(model)
		item:SetSubammo(subammo)
		item:SetData(data)				
		item:SetMass(mass)
		item:FinishSetup()

		local self = inv.Owner
		
		if IsValid(self) then return end
		
		if ScavData.models[item.ammo] and ScavData.models[item.ammo].OnPickup then
			ScavData.models[item.ammo].OnPickup(self,item)
		end
		if inv:GetItemCount() == 1 and ScavData.models[item.ammo] and ScavData.models[item.ammo].OnArmed then
			ScavData.models[item.ammo].OnArmed(self,item,"")
		end
		
	end)
	
end

--[[---------------------------------------------------------
   Name: ITEM:Remove( )
   Desc: Remove this item
---------------------------------------------------------]]--

if SERVER then
	util.AddNetworkString("scv_itmrem")
	util.AddNetworkString("scv_s_time")
end

function ITEM:Remove(silent,pl,ignoredelay) --Calling this on the server will send a net message that calls this same function on the client. If the first argument is true, the server will not inform the client

	local delay = not ignoredelay
	if SERVER then
		if not silent then
			net.Start("scv_itmrem")
				net.WriteInt(self.parent.ID,16)
				net.WriteInt(self.ID,9)
			net.Send(pl or self.parent:GetRecipientFilter())
		end
	end
	
	if self.parent.Owner.OnItemRemoved then
		self.parent.Owner:OnItemRemoved(self)
	end
	
	for k,v in ipairs(self.parent.items) do
		if v == self then
			local postremoved = nil
			local olditem = self.parent.items[k]
			if SERVER and olditem and olditem:GetFiremodeTable() then
				postremoved = olditem:GetFiremodeTable().PostRemove
			end
			if postremoved then
				postremoved(self.parent.Owner,olditem)
			end
			
			--add a slight, client-defined delay between different firemodes
			if SERVER and delay then
				if k == 1 and olditem then
					local newitem = self.parent.items[2]
					if newitem then
						local newfiremode = "???"
						local oldfiremode = "???"
						local oldfiremodedelay = 0

						if olditem:GetFiremodeTable() then
							oldfiremode = olditem:GetFiremodeTable().Name
							oldfiremodedelay = olditem:GetFiremodeTable().Cooldown
						else --gotta figure out its mass
							local prop = nil
					
							if util.IsValidRagdoll(olditem.ammo) then
								prop = ents.Create("prop_ragdoll")
							elseif util.IsValidProp(olditem.ammo) then
								prop = ents.Create("prop_physics")
							elseif string.find(olditem.ammo,"*%d",0,false) then
								prop = ents.Create("func_physbox")
							end

							if prop then
								prop:SetModel(olditem.ammo)
								prop:SetPos(self.parent.Owner.Owner:GetShootPos())
								prop:Spawn()
								local phys = prop:GetPhysicsObject()
								local mass = 0
						
								for i=0,prop:GetPhysicsObjectCount()-1 do --setup bone positions
									local phys = prop:GetPhysicsObjectNum(i)
									if IsValid(phys) then
										mass = mass + phys:GetMass()
									end
								end
								prop:Remove()
								oldfiremodedelay = (math.sqrt(mass) * 0.05) * self.parent.Owner:GetCooldownScale()
							end
						end

						if newitem:GetFiremodeTable() then
							newfiremode = newitem:GetFiremodeTable().Name
						end

						local delaybuffer = self.parent.Owner.Owner:GetInfoNum("cl_scav_autoswitchdelay",.375)
						if oldfiremode ~= newfiremode and oldfiremodedelay < delaybuffer then
							net.Start("scv_s_time")
								net.WriteEntity(self.parent.Owner)
								net.WriteInt(math.floor(delaybuffer),32)
								net.WriteFloat(delaybuffer - math.floor(delaybuffer))
							net.Send(self.parent.Owner.Owner)
							self.parent.Owner.nextfire = self.parent.Owner.nextfire - oldfiremodedelay + delaybuffer
							if self.parent.Owner:IsValid() and self.parent.Owner.Owner:Alive() then
								self.parent.Owner.Owner:EmitSound("npc/dog/dog_pneumatic1.wav",75,80,1)
							end
						end
					end
				end
			end

			table.remove(self.parent.items,k)
			self.valid = false
			break
		end
	end
	
	self.parent.itemids[self.ID] = nil
	self.parent.numberofitems = self.parent.numberofitems - 1
	debugprint("items","dec itemcount to "..self.parent.numberofitems)
	self.parent:Update()
	
end
	
if CLIENT then
	net.Receive("scv_itmrem",function()
		local inv = ScavInventories[net.ReadInt(16)]
		if inv then
			local id = net.ReadInt(9)
				timer.Simple(0.05, function()if inv.itemids[id] then inv.itemids[id]:Remove() end end)
		end
	end)
	net.Receive("scv_s_time", function()

		local ent = net.ReadEntity()
		local stime = net.ReadInt(32) + net.ReadFloat()
		
		if not IsValid(ent) then return end
		
		ent:SetNextPrimaryFire(stime)
		ent.nextfire = stime
		ent.receivednextfire = UnPredictedCurTime()
		
	end)
end

--[[---------------------------------------------------------
   Name: ITEM:IsValid( )
   Desc: Returns whether or not this item is valid
---------------------------------------------------------]]--
	
function ITEM:IsValid()
	return self.valid
end		

--[[---------------------------------------------------------
   Name: ITEM:SetID( id )
   Desc: Sets the ammo type of this item
---------------------------------------------------------]]--

function ITEM:SetID(id) --not networked, also don't use this
	if type(id) ~= "number" then
		error("bad argument #2 to 'SetID' (expected number, got "..type(id)..")",2)
	end
	self.ID = id
	self.parent.itemids[id] = self
end
		
--[[---------------------------------------------------------
   Name: ITEM:SetAmmoType( name )
   Desc: Sets the ammo type of this item
---------------------------------------------------------]]--

function ITEM:SetAmmoType(name) --not networked
	if type(name) ~= "string" then
		error("bad argument #2 to 'SetAmmoType' (expected string, got "..type(name)..")",2)
	end
	self.ammo = name
end

--[[---------------------------------------------------------
   Name: ITEM:SetSubammo( amount )
   Desc: Sets the subammo of this item
---------------------------------------------------------]]--

if SERVER then
	util.AddNetworkString("scv_setsub")
end
	
function ITEM:SetSubammo(amount) --not networked

	if type(amount) ~= "number" then
		error("bad argument #2 to 'SetSubammo' (expected number, got "..type(amount)..")",2)
	end
	
	self.subammo = amount
	
	if game.SinglePlayer() and SERVER then --in singleplayer, we send this to the client because the client doesn't run clientside firing code and can't predict it
		net.Start("scv_setsub")
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			net.WriteInt(self.parent.ID,16)
			net.WriteInt(self.ID,9)
			net.WriteInt(self.subammo,16)
		net.Send(rf)
	end
	
end

--[[---------------------------------------------------------
   Name: ITEM:SetData( data )
   Desc: Sets the ammo type of this item
---------------------------------------------------------]]--

function ITEM:SetData(data) --not networked
	if type(data) ~= "number" then
		error("bad argument #2 to 'SetData' (expected number, got "..type(data)..")",2)
	end
	self.data = data
end
	
--[[---------------------------------------------------------
   Name: ITEM:SetMass( mass )
   Desc: Sets the mass of this item
---------------------------------------------------------]]--

function ITEM:SetMass(mass) --not networked
	if type(mass) ~= "number" then
		error("bad argument #2 to 'SetMass' (expected number, got "..type(mass)..")",2)
	end
	self.mass = mass
end

--[[---------------------------------------------------------
   Name: ITEM:GetAmmoType( )
   Desc: Returns the ammo type of this item
---------------------------------------------------------]]--
	
function ITEM:GetAmmoType()
	return self.ammo
end
	
--[[---------------------------------------------------------
   Name: ITEM:GetData( )
   Desc: Returns the extra data of this item
---------------------------------------------------------]]--
	
function ITEM:GetData()
	return self.data
end

--[[---------------------------------------------------------
   Name: ITEM:GetMass( )
   Desc: Returns the mass of this item
---------------------------------------------------------]]--
	
function ITEM:GetMass()
	return self.mass
end
	
--[[---------------------------------------------------------
   Name: ITEM:GetID( )
   Desc: Returns the ID of this item
---------------------------------------------------------]]--
	
function ITEM:GetID()
	return self.ID
end

--[[---------------------------------------------------------
   Name: ITEM:GetFiremodeTable( )
   Desc: Returns the firemode table associated with this item's ammo type
---------------------------------------------------------]]--
	
function ITEM:GetFiremodeTable()
	return ScavData.models[self.ammo]
end

--[[---------------------------------------------------------
   Name: ITEM:GetInvPosition( )
   Desc: Returns our position in our parent inventory
---------------------------------------------------------]]--
	
function ITEM:GetFiremodeInfo()
	return ScavData.models[self.ammo]
end

--[[---------------------------------------------------------
   Name: ITEM:GetParent( )
   Desc: Returns the inventory to which this item belongs
---------------------------------------------------------]]--

function ITEM:GetParent()
	return self.parent
end
	
--[[---------------------------------------------------------
   Name: ITEM:GetParentID( )
   Desc: Returns the ID of the inventory to which this item belongs
---------------------------------------------------------]]--
	
function ITEM:GetParentID()
	return self.parent.ID
end

--[[---------------------------------------------------------
   Name: ITEM:GetSubammo( )
   Desc: Returns the subammo of this item
---------------------------------------------------------]]--
	
function ITEM:GetSubammo()
	return self.subammo
end

--[[---------------------------------------------------------
   Name: ITEM:TakeSubammo( )
   Desc: Deducts a given amount of subammo from this item, returns true if the remaining amount is greater than zero
---------------------------------------------------------]]--

function ITEM:TakeSubammo(amount)

	if type(amount) ~= "number" then
		error("bad argument #2 to 'TakeSubammo' (expected number, got "..type(callback)..")",2)
	end
	
	self.subammo = self.subammo - amount
	
	if game.SinglePlayer() then --in singleplayer, we send this to the client because the client doesn't run clientside firing code
		net.Start("scv_setsub")
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			net.WriteInt(self.parent.ID,16)
			net.WriteInt(self.ID,9)
			net.WriteInt(self.subammo,16)
		net.Send(rf)
	end
	
	if self.subammo > 0 then
		return true
	end
	
	return false
	
end
	
if CLIENT then
	net.Receive("scv_setsub",function()
		local inv = ScavInventories[net.ReadInt(16)]
		local id = net.ReadInt(9)
		local amt = net.ReadInt(16)
		if inv and id and amt and inv.itemids and inv.itemids[id] then
			inv.itemids[id]:SetSubammo(amt)
		end
	end)
end
	
function SWEP:TakeSubammo(item,amount)
	item.subammo = item.subammo - amount
	if (item == item) and (item.subammo <= 0) then
		self.predicteditem = 2
	else							
		self.predicteditem = 1
	end
	return false
end
