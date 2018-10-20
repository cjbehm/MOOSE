--- **Wrapper** -- AIRBASE is a wrapper class to handle the DCS Airbase objects.
-- 
-- ===
-- 
-- ### Author: **FlightControl**
-- 
-- ### Contributions: **funkyfranky**
-- 
-- ===
-- 
-- @module Wrapper.Airbase
-- @image Wrapper_Airbase.JPG


--- @type AIRBASE
-- @extends Wrapper.Positionable#POSITIONABLE

--- Wrapper class to handle the DCS Airbase objects:
-- 
--  * Support all DCS Airbase APIs.
--  * Enhance with Airbase specific APIs not in the DCS Airbase API set.
--  
-- ## AIRBASE reference methods
-- 
-- For each DCS Airbase object alive within a running mission, a AIRBASE wrapper object (instance) will be created within the _@{DATABASE} object.
-- This is done at the beginning of the mission (when the mission starts).
--  
-- The AIRBASE class **does not contain a :New()** method, rather it provides **:Find()** methods to retrieve the object reference
-- using the DCS Airbase or the DCS AirbaseName.
-- 
-- Another thing to know is that AIRBASE objects do not "contain" the DCS Airbase object. 
-- The AIRBASE methods will reference the DCS Airbase object by name when it is needed during API execution.
-- If the DCS Airbase object does not exist or is nil, the AIRBASE methods will return nil and log an exception in the DCS.log file.
--  
-- The AIRBASE class provides the following functions to retrieve quickly the relevant AIRBASE instance:
-- 
--  * @{#AIRBASE.Find}(): Find a AIRBASE instance from the _DATABASE object using a DCS Airbase object.
--  * @{#AIRBASE.FindByName}(): Find a AIRBASE instance from the _DATABASE object using a DCS Airbase name.
--  
-- IMPORTANT: ONE SHOULD NEVER SANATIZE these AIRBASE OBJECT REFERENCES! (make the AIRBASE object references nil).
-- 
-- ## DCS Airbase APIs
-- 
-- The DCS Airbase APIs are used extensively within MOOSE. The AIRBASE class has for each DCS Airbase API a corresponding method.
-- To be able to distinguish easily in your code the difference between a AIRBASE API call and a DCS Airbase API call,
-- the first letter of the method is also capitalized. So, by example, the DCS Airbase method @{DCSWrapper.Airbase#Airbase.getName}()
-- is implemented in the AIRBASE class as @{#AIRBASE.GetName}().
-- 
-- @field #AIRBASE AIRBASE
AIRBASE = {
  ClassName="AIRBASE",
  CategoryName = { 
    [Airbase.Category.AIRDROME]   = "Airdrome",
    [Airbase.Category.HELIPAD]    = "Helipad",
    [Airbase.Category.SHIP]       = "Ship",
    },
  }

--- Enumeration to identify the airbases in the Caucasus region.
-- 
-- These are all airbases of Caucasus:
-- 
--   * AIRBASE.Caucasus.Gelendzhik
--   * AIRBASE.Caucasus.Krasnodar_Pashkovsky
--   * AIRBASE.Caucasus.Sukhumi_Babushara
--   * AIRBASE.Caucasus.Gudauta
--   * AIRBASE.Caucasus.Batumi
--   * AIRBASE.Caucasus.Senaki_Kolkhi
--   * AIRBASE.Caucasus.Kobuleti
--   * AIRBASE.Caucasus.Kutaisi
--   * AIRBASE.Caucasus.Tbilisi_Lochini
--   * AIRBASE.Caucasus.Soganlug
--   * AIRBASE.Caucasus.Vaziani
--   * AIRBASE.Caucasus.Anapa_Vityazevo
--   * AIRBASE.Caucasus.Krasnodar_Center
--   * AIRBASE.Caucasus.Novorossiysk
--   * AIRBASE.Caucasus.Krymsk
--   * AIRBASE.Caucasus.Maykop_Khanskaya
--   * AIRBASE.Caucasus.Sochi_Adler
--   * AIRBASE.Caucasus.Mineralnye_Vody
--   * AIRBASE.Caucasus.Nalchik
--   * AIRBASE.Caucasus.Mozdok
--   * AIRBASE.Caucasus.Beslan
--   
-- @field Caucasus
AIRBASE.Caucasus = {
  ["Gelendzhik"] = "Gelendzhik",
  ["Krasnodar_Pashkovsky"] = "Krasnodar-Pashkovsky",
  ["Sukhumi_Babushara"] = "Sukhumi-Babushara",
  ["Gudauta"] = "Gudauta",
  ["Batumi"] = "Batumi",
  ["Senaki_Kolkhi"] = "Senaki-Kolkhi",
  ["Kobuleti"] = "Kobuleti",
  ["Kutaisi"] = "Kutaisi",
  ["Tbilisi_Lochini"] = "Tbilisi-Lochini",
  ["Soganlug"] = "Soganlug",
  ["Vaziani"] = "Vaziani",
  ["Anapa_Vityazevo"] = "Anapa-Vityazevo",
  ["Krasnodar_Center"] = "Krasnodar-Center",
  ["Novorossiysk"] = "Novorossiysk",
  ["Krymsk"] = "Krymsk",
  ["Maykop_Khanskaya"] = "Maykop-Khanskaya",
  ["Sochi_Adler"] = "Sochi-Adler",
  ["Mineralnye_Vody"] = "Mineralnye Vody",
  ["Nalchik"] = "Nalchik",
  ["Mozdok"] = "Mozdok",
  ["Beslan"] = "Beslan",
  }

--- These are all airbases of Nevada:
-- 
--   * AIRBASE.Nevada.Creech_AFB
--   * AIRBASE.Nevada.Groom_Lake_AFB
--   * AIRBASE.Nevada.McCarran_International_Airport
--   * AIRBASE.Nevada.Nellis_AFB
--   * AIRBASE.Nevada.Beatty_Airport
--   * AIRBASE.Nevada.Boulder_City_Airport
--   * AIRBASE.Nevada.Echo_Bay
--   * AIRBASE.Nevada.Henderson_Executive_Airport
--   * AIRBASE.Nevada.Jean_Airport
--   * AIRBASE.Nevada.Laughlin_Airport
--   * AIRBASE.Nevada.Lincoln_County
--   * AIRBASE.Nevada.Mellan_Airstrip
--   * AIRBASE.Nevada.Mesquite
--   * AIRBASE.Nevada.Mina_Airport_3Q0
--   * AIRBASE.Nevada.North_Las_Vegas
--   * AIRBASE.Nevada.Pahute_Mesa_Airstrip
--   * AIRBASE.Nevada.Tonopah_Airport
--   * AIRBASE.Nevada.Tonopah_Test_Range_Airfield
-- @field Nevada 
AIRBASE.Nevada = {
  ["Creech_AFB"] = "Creech AFB",
  ["Groom_Lake_AFB"] = "Groom Lake AFB",
  ["McCarran_International_Airport"] = "McCarran International Airport",
  ["Nellis_AFB"] = "Nellis AFB",
  ["Beatty_Airport"] = "Beatty Airport",
  ["Boulder_City_Airport"] = "Boulder City Airport",
  ["Echo_Bay"] = "Echo Bay",
  ["Henderson_Executive_Airport"] = "Henderson Executive Airport",
  ["Jean_Airport"] = "Jean Airport",
  ["Laughlin_Airport"] = "Laughlin Airport",
  ["Lincoln_County"] = "Lincoln County",
  ["Mellan_Airstrip"] = "Mellan Airstrip",
  ["Mesquite"] = "Mesquite",
  ["Mina_Airport_3Q0"] = "Mina Airport 3Q0",
  ["North_Las_Vegas"] = "North Las Vegas",
  ["Pahute_Mesa_Airstrip"] = "Pahute Mesa Airstrip",
  ["Tonopah_Airport"] = "Tonopah Airport",
  ["Tonopah_Test_Range_Airfield"] = "Tonopah Test Range Airfield",
  }

--- These are all airbases of Normandy:
-- 
--   * AIRBASE.Normandy.Saint_Pierre_du_Mont
--   * AIRBASE.Normandy.Lignerolles
--   * AIRBASE.Normandy.Cretteville
--   * AIRBASE.Normandy.Maupertus
--   * AIRBASE.Normandy.Brucheville
--   * AIRBASE.Normandy.Meautis
--   * AIRBASE.Normandy.Cricqueville_en_Bessin
--   * AIRBASE.Normandy.Lessay
--   * AIRBASE.Normandy.Sainte_Laurent_sur_Mer
--   * AIRBASE.Normandy.Biniville
--   * AIRBASE.Normandy.Cardonville
--   * AIRBASE.Normandy.Deux_Jumeaux
--   * AIRBASE.Normandy.Chippelle
--   * AIRBASE.Normandy.Beuzeville
--   * AIRBASE.Normandy.Azeville
--   * AIRBASE.Normandy.Picauville
--   * AIRBASE.Normandy.Le_Molay
--   * AIRBASE.Normandy.Longues_sur_Mer
--   * AIRBASE.Normandy.Carpiquet
--   * AIRBASE.Normandy.Bazenville
--   * AIRBASE.Normandy.Sainte_Croix_sur_Mer
--   * AIRBASE.Normandy.Beny_sur_Mer
--   * AIRBASE.Normandy.Rucqueville
--   * AIRBASE.Normandy.Sommervieu
--   * AIRBASE.Normandy.Lantheuil
--   * AIRBASE.Normandy.Evreux
--   * AIRBASE.Normandy.Chailey
--   * AIRBASE.Normandy.Needs_Oar_Point
--   * AIRBASE.Normandy.Funtington
--   * AIRBASE.Normandy.Tangmere
--   * AIRBASE.Normandy.Ford
-- @field Normandy
AIRBASE.Normandy = {
  ["Saint_Pierre_du_Mont"] = "Saint Pierre du Mont",
  ["Lignerolles"] = "Lignerolles",
  ["Cretteville"] = "Cretteville",
  ["Maupertus"] = "Maupertus",
  ["Brucheville"] = "Brucheville",
  ["Meautis"] = "Meautis",
  ["Cricqueville_en_Bessin"] = "Cricqueville-en-Bessin",
  ["Lessay"] = "Lessay",
  ["Sainte_Laurent_sur_Mer"] = "Sainte-Laurent-sur-Mer",
  ["Biniville"] = "Biniville",
  ["Cardonville"] = "Cardonville",
  ["Deux_Jumeaux"] = "Deux Jumeaux",
  ["Chippelle"] = "Chippelle",
  ["Beuzeville"] = "Beuzeville",
  ["Azeville"] = "Azeville",
  ["Picauville"] = "Picauville",
  ["Le_Molay"] = "Le Molay",
  ["Longues_sur_Mer"] = "Longues-sur-Mer",
  ["Carpiquet"] = "Carpiquet",
  ["Bazenville"] = "Bazenville",
  ["Sainte_Croix_sur_Mer"] = "Sainte-Croix-sur-Mer",
  ["Beny_sur_Mer"] = "Beny-sur-Mer",
  ["Rucqueville"] = "Rucqueville",
  ["Sommervieu"] = "Sommervieu",
  ["Lantheuil"] = "Lantheuil",
  ["Evreux"] = "Evreux",
  ["Chailey"] = "Chailey",
  ["Needs_Oar_Point"] = "Needs Oar Point",
  ["Funtington"] = "Funtington",
  ["Tangmere"] = "Tangmere",
  ["Ford"] = "Ford",
  }

--- These are all airbases of the Persion Gulf Map:
-- 
-- * AIRBASE.PersianGulf.Fujairah_Intl
-- * AIRBASE.PersianGulf.Qeshm_Island
-- * AIRBASE.PersianGulf.Sir_Abu_Nuayr
-- * AIRBASE.PersianGulf.Abu_Musa_Island_Airport
-- * AIRBASE.PersianGulf.Bandar_Abbas_Intl
-- * AIRBASE.PersianGulf.Bandar_Lengeh
-- * AIRBASE.PersianGulf.Tunb_Island_AFB
-- * AIRBASE.PersianGulf.Havadarya
-- * AIRBASE.PersianGulf.Lar_Airbase
-- * AIRBASE.PersianGulf.Sirri_Island
-- * AIRBASE.PersianGulf.Tunb_Kochak
-- * AIRBASE.PersianGulf.Al_Dhafra_AB
-- * AIRBASE.PersianGulf.Dubai_Intl
-- * AIRBASE.PersianGulf.Al_Maktoum_Intl
-- * AIRBASE.PersianGulf.Khasab
-- * AIRBASE.PersianGulf.Al_Minhad_AB
-- * AIRBASE.PersianGulf.Sharjah_Intl
-- * AIRBASE.PersianGulf.Shiraz_International_Airport
-- * AIRBASE.PersianGulf.Kerman_Airport
-- @field PersianGulf
AIRBASE.PersianGulf = {
  ["Fujairah_Intl"] = "Fujairah Intl",
  ["Qeshm_Island"] = "Qeshm Island",
  ["Sir_Abu_Nuayr"] = "Sir Abu Nuayr",
  ["Abu_Musa_Island_Airport"] = "Abu Musa Island Airport",
  ["Bandar_Abbas_Intl"] = "Bandar Abbas Intl",
  ["Bandar_Lengeh"] = "Bandar Lengeh",
  ["Tunb_Island_AFB"] = "Tunb Island AFB",
  ["Havadarya"] = "Havadarya",
  ["Lar_Airbase"] = "Lar Airbase",
  ["Sirri_Island"] = "Sirri Island",
  ["Tunb_Kochak"] = "Tunb Kochak",
  ["Al_Dhafra_AB"] = "Al Dhafra AB",
  ["Dubai_Intl"] = "Dubai Intl",
  ["Al_Maktoum_Intl"] = "Al Maktoum Intl",
  ["Khasab"] = "Khasab",
  ["Al_Minhad_AB"] = "Al Minhad AB",
  ["Sharjah_Intl"] = "Sharjah Intl",
  ["Shiraz_International_Airport"] = "Shiraz International Airport",
  ["Kerman_Airport"] = "Kerman Airport",
  }
  
--- AIRBASE.ParkingSpot ".Coordinate, ".TerminalID", ".TerminalType", ".TOAC", ".Free", ".TerminalID0", ".DistToRwy".
-- @type AIRBASE.ParkingSpot
-- @field Core.Point#COORDINATE Coordinate Coordinate of the parking spot.
-- @field #number TerminalID Terminal ID of the spot. Generally, this is not the same number as displayed in the mission editor.
-- @field #AIRBASE.TerminalType TerminalType Type of the spot, i.e. for which type of aircraft it can be used.
-- @field #boolean TOAC Takeoff or landing aircarft. I.e. this stop is occupied currently by an aircraft until it took of or until it landed.
-- @field #boolean Free This spot is currently free, i.e. there is no alive aircraft on it at the present moment.
-- @field #number TerminalID0 Unknown what this means. If you know, please tell us!
-- @field #number DistToRwy Distance to runway in meters. Currently bugged and giving the same number as the TerminalID.
 
--- Terminal Types of parking spots. See also https://wiki.hoggitworld.com/view/DCS_func_getParking
-- 
-- Supported types are:
-- 
-- * AIRBASE.TerminalType.Runway = 16: Valid spawn points on runway.
-- * AIRBASE.TerminalType.HelicopterOnly = 40: Special spots for Helicopers.
-- * AIRBASE.TerminalType.Shelter = 68: Hardened Air Shelter. Currently only on Caucaus map.
-- * AIRBASE.TerminalType.OpenMed = 72: Open/Shelter air airplane only.
-- * AIRBASE.TerminalType.OpenBig = 104: Open air spawn points. Generally larger but does not guarantee large aircraft are capable of spawning there.
-- * AIRBASE.TerminalType.OpenMedOrBig = 176: Combines OpenMed and OpenBig spots.
-- * AIRBASE.TerminalType.HelicopterUnsable = 216: Combines HelicopterOnly, OpenMed and OpenBig.
-- * AIRBASE.TerminalType.FighterAircraft = 244: Combines Shelter. OpenMed and OpenBig spots. So effectively all spots usable by fixed wing aircraft.
-- 
-- @type AIRBASE.TerminalType
-- @field #number Runway 16: Valid spawn points on runway.
-- @field #number HelicopterOnly 40: Special spots for Helicopers.
-- @field #number Shelter 68: Hardened Air Shelter. Currently only on Caucaus map.
-- @field #number OpenMed 72: Open/Shelter air airplane only.
-- @field #number OpenBig 104: Open air spawn points. Generally larger but does not guarantee large aircraft are capable of spawning there.
-- @field #number OpenMedOrBig 176: Combines OpenMed and OpenBig spots.
-- @field #number HelicopterUnsable 216: Combines HelicopterOnly, OpenMed and OpenBig.
-- @field #number FighterAircraft 244: Combines Shelter. OpenMed and OpenBig spots. So effectively all spots usable by fixed wing aircraft.
AIRBASE.TerminalType = {
  Runway=16,
  HelicopterOnly=40,
  Shelter=68,
  OpenMed=72,
  OpenBig=104,
  OpenMedOrBig=176,
  HelicopterUsable=216,
  FighterAircraft=244,
}

-- Registration.
  
--- Create a new AIRBASE from DCSAirbase.
-- @param #AIRBASE self
-- @param #string AirbaseName The name of the airbase.
-- @return Wrapper.Airbase#AIRBASE
function AIRBASE:Register( AirbaseName )

  local self = BASE:Inherit( self, POSITIONABLE:New( AirbaseName ) )
  self.AirbaseName = AirbaseName
  self.AirbaseZone = ZONE_RADIUS:New( AirbaseName, self:GetVec2(), 2500 )
  return self
end

-- Reference methods.

--- Finds a AIRBASE from the _DATABASE using a DCSAirbase object.
-- @param #AIRBASE self
-- @param DCS#Airbase DCSAirbase An existing DCS Airbase object reference.
-- @return Wrapper.Airbase#AIRBASE self
function AIRBASE:Find( DCSAirbase )

  local AirbaseName = DCSAirbase:getName()
  local AirbaseFound = _DATABASE:FindAirbase( AirbaseName )
  return AirbaseFound
end

--- Find a AIRBASE in the _DATABASE using the name of an existing DCS Airbase.
-- @param #AIRBASE self
-- @param #string AirbaseName The Airbase Name.
-- @return #AIRBASE self
function AIRBASE:FindByName( AirbaseName )
  
  local AirbaseFound = _DATABASE:FindAirbase( AirbaseName )
  return AirbaseFound
end

--- Get the DCS object of an airbase
-- @param #AIRBASE self
-- @return DCS#Airbase DCS airbase object.
function AIRBASE:GetDCSObject()
  local DCSAirbase = Airbase.getByName( self.AirbaseName )
  
  if DCSAirbase then
    return DCSAirbase
  end
    
  return nil
end

--- Get the airbase zone.
-- @param #AIRBASE self
-- @return Core.Zone#ZONE_RADIUS The zone radius of the airbase.
function AIRBASE:GetZone()
  return self.AirbaseZone
end

--- Get all airbases of the current map. This includes ships and FARPS.
-- @param DCS#Coalition coalition (Optional) Return only airbases belonging to the specified coalition. By default, all airbases of the map are returned.
-- @return #table Table containing all airbase objects of the current map.
function AIRBASE.GetAllAirbases(coalition)
  
  local airbases={}
  for _,airbase in pairs(_DATABASE.AIRBASES) do
    if (coalition~=nil and airbase:GetCoalition()==coalition) or coalition==nil then
      table.insert(airbases, airbase)
    end
  end
  
  return airbases
end


--- Returns a table of parking data for a given airbase. If the optional parameter *available* is true only available parking will be returned, otherwise all parking at the base is returned. Term types have the following enumerated values:
-- 
-- * 16 : Valid spawn points on runway
-- * 40 : Helicopter only spawn  
-- * 68 : Hardened Air Shelter
-- * 72 : Open/Shelter air airplane only
-- * 104: Open air spawn
-- 
-- Note that only Caucuses will return 68 as it is the only map currently with hardened air shelters.
-- 104 are also generally larger, but does not guarantee a large aircraft like the B-52 or a C-130 are capable of spawning there.
-- 
-- Table entries:
-- 
-- * Term_index is the id for the parking
-- * vTerminal pos is its vec3 position in the world
-- * fDistToRW is the distance to the take-off position for the active runway from the parking.
-- 
-- @param #AIRBASE self
-- @param #boolean available If true, only available parking spots will be returned.
-- @return #table Table with parking data. See https://wiki.hoggitworld.com/view/DCS_func_getParking
function AIRBASE:GetParkingData(available)
  self:F2(available)

  -- Get DCS airbase object.
  local DCSAirbase=self:GetDCSObject()
  
  -- Get parking data.
  local parkingdata=nil
  if DCSAirbase then
    parkingdata=DCSAirbase:getParking(available)
  end
  
  self:T2({parkingdata=parkingdata})
  return parkingdata
end

--- Get number of parking spots at an airbase. Optionally, a specific terminal type can be requested.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type of which the number of spots is counted. Default all spots but spawn points on runway.
-- @return #number Number of parking spots at this airbase.
function AIRBASE:GetParkingSpotsNumber(termtype)

  -- Get free parking spots data.
  local parkingdata=self:GetParkingData(false)
  
  local nspots=0
  for _,parkingspot in pairs(parkingdata) do
    if AIRBASE._CheckTerminalType(parkingspot.Term_Type, termtype) then
      nspots=nspots+1
    end
  end
  
  return nspots
end

--- Get number of free parking spots at an airbase.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type.
-- @param #boolean allowTOAC If true, spots are considered free even though TO_AC is true. Default is off which is saver to avoid spawning aircraft on top of each other. Option might be enabled for FARPS and ships. 
-- @return #number Number of free parking spots at this airbase.
function AIRBASE:GetFreeParkingSpotsNumber(termtype, allowTOAC)

  -- Get free parking spots data.
  local parkingdata=self:GetParkingData(true)
  
  local nfree=0
  for _,parkingspot in pairs(parkingdata) do
    -- Spots on runway are not counted unless explicitly requested.
    if AIRBASE._CheckTerminalType(parkingspot.Term_Type, termtype) then
      if (allowTOAC and allowTOAC==true) or parkingspot.TO_AC==false then
        nfree=nfree+1
      end
    end
  end
  
  return nfree
end

--- Get the coordinates of free parking spots at an airbase.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type.
-- @param #boolean allowTOAC If true, spots are considered free even though TO_AC is true. Default is off which is saver to avoid spawning aircraft on top of each other. Option might be enabled for FARPS and ships.
-- @return #table Table of coordinates of the free parking spots.
function AIRBASE:GetFreeParkingSpotsCoordinates(termtype, allowTOAC)

  -- Get free parking spots data.
  local parkingdata=self:GetParkingData(true)
  
  -- Put coordinates of free spots into table.
  local spots={}
  for _,parkingspot in pairs(parkingdata) do
    -- Coordinates on runway are not returned unless explicitly requested.
    if AIRBASE._CheckTerminalType(parkingspot.Term_Type, termtype) then
      if (allowTOAC and allowTOAC==true) or parkingspot.TO_AC==false then
        table.insert(spots, COORDINATE:NewFromVec3(parkingspot.vTerminalPos))
      end
    end
  end
  
  return spots
end

--- Get the coordinates of all parking spots at an airbase. Optionally only those of a specific terminal type. Spots on runways are excluded if not explicitly requested by terminal type.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype (Optional) Terminal type. Default all.
-- @return #table Table of coordinates of parking spots.
function AIRBASE:GetParkingSpotsCoordinates(termtype)

  -- Get all parking spots data.
  local parkingdata=self:GetParkingData(false)
  
  -- Put coordinates of free spots into table.
  local spots={}
  for _,parkingspot in pairs(parkingdata) do
  
    -- Coordinates on runway are not returned unless explicitly requested.
    if AIRBASE._CheckTerminalType(parkingspot.Term_Type, termtype) then
    
      -- Get coordinate from Vec3 terminal position.
      local _coord=COORDINATE:NewFromVec3(parkingspot.vTerminalPos)
      
      -- Add to table.
      table.insert(spots, _coord)
    end
    
  end
  
  return spots
end


--- Get a table containing the coordinates, terminal index and terminal type of free parking spots at an airbase.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type.
-- @return #table Table free parking spots. Table has the elements ".Coordinate, ".TerminalID", ".TerminalType", ".TOAC", ".Free", ".TerminalID0", ".DistToRwy".
function AIRBASE:GetParkingSpotsTable(termtype)

  -- Get parking data of all spots (free or occupied) 
  local parkingdata=self:GetParkingData(false)
  -- Get parking data of all free spots.
  local parkingfree=self:GetParkingData(true)
  
  -- Function to ckeck if any parking spot is free.
  local function _isfree(_tocheck)
    for _,_spot in pairs(parkingfree) do
      if _spot.Term_Index==_tocheck.Term_Index then
        return true
      end
    end
    return false
  end
  
  -- Put coordinates of parking spots into table.
  local spots={}
  for _,_spot in pairs(parkingdata) do
    if AIRBASE._CheckTerminalType(_spot.Term_Type, termtype) then
      local _free=_isfree(_spot)
      local _coord=COORDINATE:NewFromVec3(_spot.vTerminalPos)
      table.insert(spots, {Coordinate=_coord, TerminalID=_spot.Term_Index, TerminalType=_spot.Term_Type, TOAC=_spot.TO_AC, Free=_free, TerminalID0=_spot.Term_Index_0, DistToRwy=_spot.fDistToRW})
    end
  end
  
  return spots
end

--- Get a table containing the coordinates, terminal index and terminal type of free parking spots at an airbase.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type.
-- @param #boolean allowTOAC If true, spots are considered free even though TO_AC is true. Default is off which is saver to avoid spawning aircraft on top of each other. Option might be enabled for FARPS and ships. 
-- @return #table Table free parking spots. Table has the elements ".Coordinate, ".TerminalID", ".TerminalType", ".TOAC", ".Free", ".TerminalID0", ".DistToRwy".
function AIRBASE:GetFreeParkingSpotsTable(termtype, allowTOAC)

  -- Get parking data of all free spots.
  local parkingfree=self:GetParkingData(true)
    
  -- Put coordinates of free spots into table.
  local freespots={}
  for _,_spot in pairs(parkingfree) do
    if AIRBASE._CheckTerminalType(_spot.Term_Type, termtype) then
      if (allowTOAC and allowTOAC==true) or _spot.TO_AC==false then
        local _coord=COORDINATE:NewFromVec3(_spot.vTerminalPos)
        table.insert(freespots, {Coordinate=_coord, TerminalID=_spot.Term_Index, TerminalType=_spot.Term_Type, TOAC=_spot.TO_AC, Free=true, TerminalID0=_spot.Term_Index_0, DistToRwy=_spot.fDistToRW})
      end
    end
  end
  
  return freespots
end

--- Place markers of parking spots on the F10 map.
-- @param #AIRBASE self
-- @param #AIRBASE.TerminalType termtype Terminal type for which marks should be placed.
-- @param #boolean mark If false, do not place markers but only give output to DCS.log file. Default true.
function AIRBASE:MarkParkingSpots(termtype, mark)

  -- Default is true.
  if mark==nil then
    mark=true
  end

  -- Get parking data from getParking() wrapper function.
  local parkingdata=self:GetParkingSpotsTable(termtype)

  -- Get airbase name.
  local airbasename=self:GetName()
  self:E(string.format("Parking spots at %s for termial type %s:", airbasename, tostring(termtype)))
  
  for _,_spot in pairs(parkingdata) do
    
    -- Mark text.
    local _text=string.format("Term Index=%d, Term Type=%d, Free=%s, TOAC=%s, Term ID0=%d, Dist2Rwy=%.1f m",
    _spot.TerminalID, _spot.TerminalType,tostring(_spot.Free),tostring(_spot.TOAC),_spot.TerminalID0,_spot.DistToRwy)
    
    -- Create mark on the F10 map.
    if mark then
      _spot.Coordinate:MarkToAll(_text)
    end
    
    -- Info to DCS.log file.
    local _text=string.format("%s, Term Index=%3d, Term Type=%03d, Free=%5s, TOAC=%5s, Term ID0=%3d, Dist2Rwy=%.1f m",
    airbasename, _spot.TerminalID, _spot.TerminalType,tostring(_spot.Free),tostring(_spot.TOAC),_spot.TerminalID0,_spot.DistToRwy)
    self:E(_text)
  end
end

--- Seach unoccupied parking spots at the airbase for a specific group of aircraft. The routine also optionally checks for other unit, static and scenery options in a certain radius around the parking spot.
-- The dimension of the spawned aircraft and of the potential obstacle are taken into account. Note that the routine can only return so many spots that are free.
-- @param #AIRBASE self
-- @param Wrapper.Group#GROUP group Aircraft group for which the parking spots are requested.
-- @param #AIRBASE.TerminalType terminaltype (Optional) Only search spots at a specific terminal type. Default is all types execpt on runway.
-- @param #number scanradius (Optional) Radius in meters around parking spot to scan for obstacles. Default 50 m.
-- @param #boolean scanunits (Optional) Scan for units as obstacles. Default true.
-- @param #boolean scanstatics (Optional) Scan for statics as obstacles. Default true.
-- @param #boolean scanscenery (Optional) Scan for scenery as obstacles. Default false. Can cause problems with e.g. shelters.
-- @param #boolean verysafe (Optional) If true, wait until an aircraft has taken off until the parking spot is considered to be free. Defaul false.
-- @param #number nspots (Optional) Number of freeparking spots requested. Default is the number of aircraft in the group. 
-- @param #table parkingdata (Optional) Parking spots data table. If not given it is automatically derived from the GetParkingSpotsTable() function.
-- @return #table Table of coordinates and terminal IDs of free parking spots. Each table entry has the elements .Coordinate and .TerminalID.
function AIRBASE:FindFreeParkingSpotForAircraft(group, terminaltype, scanradius, scanunits, scanstatics, scanscenery, verysafe, nspots, parkingdata)

  -- Init default
  scanradius=scanradius or 50
  if scanunits==nil then
    scanunits=true
  end
  if scanstatics==nil then
    scanstatics=true
  end
  if scanscenery==nil then
    scanscenery=false
  end
  if verysafe==nil then
    verysafe=false
  end  
  
  -- Get the size of an object.
  local function _GetObjectSize(unit,mooseobject)
    if mooseobject then
      unit=unit:GetDCSObject()
    end
    if unit and unit:isExist() then
      local DCSdesc=unit:getDesc()
      if DCSdesc.box then
        local x=DCSdesc.box.max.x+math.abs(DCSdesc.box.min.x)
        local y=DCSdesc.box.max.y+math.abs(DCSdesc.box.min.y)  --height
        local z=DCSdesc.box.max.z+math.abs(DCSdesc.box.min.z)
        return math.max(x,z), x , y, z
      end
    end
    return 0,0,0,0
  end
  
  -- Function calculating the overlap of two (square) objects.
  local function _overlap(object1, mooseobject1, object2, mooseobject2, dist)
    local l1=_GetObjectSize(object1, mooseobject1)
    local l2=_GetObjectSize(object2, mooseobject2)
    local safedist=(l1/2+l2/2)*1.1    
    local safe = (dist > safedist)
    self:T3(string.format("l1=%.1f l2=%.1f s=%.1f d=%.1f ==> safe=%s", l1,l2,safedist,dist,tostring(safe)))
    return safe    
  end
  
  -- Get airport name.
  local airport=self:GetName()
  
  -- Get parking spot data table. This contains free and "non-free" spots.
  -- Note that there are three major issues with the DCS getParking() function:
  -- 1. A spot is considered as NOT free until an aircraft that is present has finally taken off. This might be a bit long especiall at smaller airports.
  -- 2. A "free" spot does not take the aircraft size into accound. So if two big aircraft are spawned on spots next to each other, they might overlap and get destroyed.
  -- 3. The routine return a free spot, if there a static objects placed on the spot.
  parkingdata=parkingdata or self:GetParkingSpotsTable(terminaltype)
  
  -- Get the aircraft size, i.e. it's longest side of x,z.
  local aircraft=group:GetUnit(1)
  local _aircraftsize, ax,ay,az=_GetObjectSize(aircraft, true)
  
  -- Number of spots we are looking for. Note that, e.g. grouping can require a number different from the group size!
  local _nspots=nspots or group:GetSize()
  
  -- Debug info.
  self:E(string.format("%s: Looking for %d parking spot(s) for aircraft of size %.1f m (x=%.1f,y=%.1f,z=%.1f) at termial type %s.", airport, _nspots, _aircraftsize, ax, ay, az, tostring(terminaltype)))
  
  -- Table of valid spots.
  local validspots={}
  local nvalid=0
  
  -- Test other stuff if no parking spot is available.
  local _test=false
  if _test then
    return validspots
  end
  
  -- Mark all found obstacles on F10 map for debugging.
  local markobstacles=false
  
  -- Loop over all known parking spots
  for _,parkingspot in pairs(parkingdata) do
  
    -- Coordinate of the parking spot.
    local _spot=parkingspot.Coordinate   -- Core.Point#COORDINATE
    local _termid=parkingspot.TerminalID
    
    if AIRBASE._CheckTerminalType(parkingspot.TerminalType, terminaltype) then
    
      -- Very safe uses the DCS getParking() info to check if a spot is free. Unfortunately, the function returns free=false until the aircraft has actually taken-off.
      if verysafe and (parkingspot.Free==false or parkingspot.TOAC==true) then
          
        -- DCS getParking() routine returned that spot is not free.
        self:E(string.format("%s: Parking spot id %d NOT free (or aircraft has not taken off yet). Free=%s, TOAC=%s.", airport, parkingspot.TerminalID, tostring(parkingspot.Free), tostring(parkingspot.TOAC)))
    
      else
            
        -- Scan a radius of 50 meters around the spot.
        local _,_,_,_units,_statics,_sceneries=_spot:ScanObjects(scanradius, scanunits, scanstatics, scanscenery)
      
        -- Loop over objects within scan radius.
        local occupied=false
    
        -- Check all units.    
        for _,unit in pairs(_units) do
          -- Unis are now returned as MOOSE units not DCS units!
          --local _vec3=unit:getPoint()
          --local _coord=COORDINATE:NewFromVec3(_vec3)
          local _coord=unit:GetCoordinate()
          local _dist=_coord:Get2DDistance(_spot)      
          local _safe=_overlap(aircraft, true, unit, true,_dist)
          
          if markobstacles then
            local l,x,y,z=_GetObjectSize(unit)      
            _coord:MarkToAll(string.format("Unit %s\nx=%.1f y=%.1f z=%.1f\nl=%.1f d=%.1f\nspot %d safe=%s", unit:getName(),x,y,z,l,_dist, _termid, tostring(_safe)))
          end
          
          if scanunits and not _safe then
            occupied=true
          end      
        end
      
        -- Check all statics.
        for _,static in pairs(_statics) do
          local _vec3=static:getPoint()
          local _coord=COORDINATE:NewFromVec3(_vec3)
          local _dist=_coord:Get2DDistance(_spot)      
          local _safe=_overlap(aircraft, true, static, false,_dist)
          
          if markobstacles then
            local l,x,y,z=_GetObjectSize(static)
            _coord:MarkToAll(string.format("Static %s\nx=%.1f y=%.1f z=%.1f\nl=%.1f d=%.1f\nspot %d safe=%s", static:getName(),x,y,z,l,_dist, _termid, tostring(_safe)))
          end
          
          if scanstatics and not _safe then
            occupied=true
          end            
        end
        
        -- Check all scenery.
        for _,scenery in pairs(_sceneries) do
          local _vec3=scenery:getPoint()
          local _coord=COORDINATE:NewFromVec3(_vec3)
          local _dist=_coord:Get2DDistance(_spot)
          local _safe=_overlap(aircraft, true, scenery, false,_dist)
          
          if markobstacles then
            local l,x,y,z=_GetObjectSize(scenery)
            _coord:MarkToAll(string.format("Scenery %s\nx=%.1f y=%.1f z=%.1f\nl=%.1f d=%.1f\nspot %d safe=%s", scenery:getTypeName(),x,y,z,l,_dist, _termid, tostring(_safe)))
          end
          
          if scanscenery and not _safe then
            occupied=true
          end                  
        end
        
        -- Now check the already given spots so that we do not put a large aircraft next to one we already assigned a nearby spot.
        for _,_takenspot in pairs(validspots) do
          local _dist=_takenspot.Coordinate:Get2DDistance(_spot)
          local _safe=_overlap(aircraft, true, aircraft, true,_dist)
          if not _safe then
            occupied=true
          end
        end
              
        --_spot:MarkToAll(string.format("Parking spot %d free=%s", parkingspot.TerminalID, tostring(not occupied)))
        if occupied then
          self:T(string.format("%s: Parking spot id %d occupied.", airport, _termid))
        else
          self:E(string.format("%s: Parking spot id %d free.", airport, _termid))      
          if nvalid<_nspots then
            table.insert(validspots, {Coordinate=_spot, TerminalID=_termid})
          end
          nvalid=nvalid+1
        end
        
      end -- loop over units
         
      -- We found enough spots.
      if nvalid>=_nspots then
        return validspots
      end
    end -- check terminal type
  end  
    
  -- Retrun spots we found, even if there were not enough.
  return validspots
end

--- Function that checks if at leat one unit of a group has been spawned close to a spawn point on the runway.
-- @param #AIRBASE self
-- @param Wrapper.Group#GROUP group Group to be checked.
-- @param #number radius Radius around the spawn point to be checked. Default is 50 m.
-- @param #boolean despawn If true, the group is destroyed. 
-- @return #boolean True if group is within radius around spawn points on runway.
function AIRBASE:CheckOnRunWay(group, radius, despawn)

  -- Default radius.
  radius=radius or 50
  
  -- We only check at real airbases (not FARPS or ships).
  if self:GetDesc().category~=Airbase.Category.AIRDROME then
    return false
  end

  if group and group:IsAlive() then
  
    -- Debug.
    self:T(string.format("%s, checking if group %s is on runway?",self:GetName(), group:GetName()))
  
    -- Get coordinates on runway.
    local runwaypoints=self:GetParkingSpotsCoordinates(AIRBASE.TerminalType.Runway)
    
    -- Mark runway spawn points.
    --[[
    for _i,_coord in pairs(runwaypoints) do
      _coord:MarkToAll(string.format("runway %d",_i))
    end
    ]]
    
    -- Get units of group.
    local units=group:GetUnits()
    
    -- Loop over units.
    for _,_unit in pairs(units) do
    
      local unit=_unit --Wrapper.Unit#UNIT
      
      -- Check if unit is alive and not in air.
      if unit and unit:IsAlive() and not unit:InAir() then
        self:T(string.format("%s, checking if unit %s is on runway?",self:GetName(), unit:GetName()))
        
        -- Loop over runway spawn points.
        for _i,_coord in pairs(runwaypoints) do

          -- Distance between unit and spawn pos.
          local dist=unit:GetCoordinate():Get2DDistance(_coord)
          
          -- Mark unit spawn points for debugging.
          --unit:GetCoordinate():MarkToAll(string.format("unit %s distance to rwy %d = %d",unit:GetName(),_i, dist))
          
          -- Check if unit is withing radius.
          if dist<radius  then
            self:E(string.format("%s, unit %s of group %s was spawned on runway #%d. Distance %.1f < radius %.1f m. Despawn = %s.", self:GetName(), unit:GetName(), group:GetName(),_i, dist, radius, tostring(despawn)))
            --unit:FlareRed()
            if despawn then
              group:Destroy(true)
            end
            return true
          else
            self:T(string.format("%s, unit %s of group %s was NOT spawned on runway #%d. Distance %.1f > radius %.1f m. Despawn = %s.", self:GetName(), unit:GetName(), group:GetName(),_i, dist, radius, tostring(despawn)))
            --unit:FlareGreen()
          end
                    
        end
      else
        self:T(string.format("%s, checking if unit %s of group %s is on runway. Unit is NOT alive.",self:GetName(), unit:GetName(), group:GetName()))  
      end      
    end
  else
    self:T(string.format("%s, checking if group %s is on runway. Group is NOT alive.",self:GetName(), group:GetName()))
  end
  
  return false
end

--- Helper function to check for the correct terminal type including "artificial" ones.
-- @param #number Term_Type Termial type from getParking routine.
-- @param #AIRBASE.TerminalType termtype Terminal type from AIRBASE.TerminalType enumerator.
-- @return #boolean True if terminal types match.
function AIRBASE._CheckTerminalType(Term_Type, termtype)

  -- Nill check for Term_Type.
  if Term_Type==nil then
    return false
  end

  -- If no terminal type is requested, we return true. BUT runways are excluded unless explicitly requested.
  if termtype==nil then
    if Term_Type==AIRBASE.TerminalType.Runway then
      return false
    else
      return true
    end
  end
  
  -- Init no match.
  local match=false
  
  -- Standar case.  
  if Term_Type==termtype then
    match=true
  end
  
  -- Artificial cases. Combination of terminal types.
  if termtype==AIRBASE.TerminalType.OpenMedOrBig then
    if Term_Type==AIRBASE.TerminalType.OpenMed or Term_Type==AIRBASE.TerminalType.OpenBig then
      match=true
    end
  elseif termtype==AIRBASE.TerminalType.HelicopterUsable then
    if Term_Type==AIRBASE.TerminalType.OpenMed or Term_Type==AIRBASE.TerminalType.OpenBig or Term_Type==AIRBASE.TerminalType.HelicopterOnly then
      match=true
     end
  elseif termtype==AIRBASE.TerminalType.FighterAircraft then
    if Term_Type==AIRBASE.TerminalType.OpenMed or Term_Type==AIRBASE.TerminalType.OpenBig or Term_Type==AIRBASE.TerminalType.Shelter then
      match=true
    end
  end
  
  return match
end