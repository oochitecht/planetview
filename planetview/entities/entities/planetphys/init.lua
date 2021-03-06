/*
This entity handles the gravity from planets
Keyvalues from map are handled here
*/
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

//grab values from map
function ENT:KeyValue( key, value )
	if ( key == "type" ) then
		self.ptype = value || "planet"
	end
	if ( key == "radius" ) then
		self.prad = tonumber(value,10) || 1
	end
	if ( key == "mass" ) then
		self.pmass = tonumber(value,10) || 1
	end
	if ( key == "atmosphere" ) then
		self.atmos = tonumber(value,10) || prad
	end
	if ( key == "Name" ) then
		self:SetName(value)
	end
	if ( key == "parent" ) then
		self:SetParent(value)
	end
end

--main loop
function ENT:Think()	
	for k, v in pairs( ents.FindInSphere( self:GetPos(), self.prad ) ) do
		//Finds the super parent
		parent = v:GetParent()
		while(parent != NULL && parent != nil && parent:IsValid()) do
			v = parent
			parent = v:GetParent()
		end
		
		//make sure physics is enabled
		phys = v:GetPhysicsObject()
		if (phys != NULL && phys != nil && phys:IsValid()) then
			--apply gravity
			--applies gravity to the center of mass, scaled by the object's mass and towards the local planetoid.
			--this assumes the planetoid is at our center.
			mult = GetConVar("planetview_gravConst"):GetFloat() * self.pmass / (self:GetPos() - v:GetPos()):Length()^2
			direction = (self:GetPos() - v:GetPos()):GetNormalized()
			if (v:GetClass() != "pcam" && v:GetClass() != "pdummy") then
				if (v:IsPlayer()) then
					v:SetVelocity( direction * (mult * v:GetMass()) ) 
				else
					phys:ApplyForceCenter( direction * (mult * phys:GetMass()) )
				end
			end
		end
	end
end

function ENT:OnRemove()
  --nothing to do yet
end