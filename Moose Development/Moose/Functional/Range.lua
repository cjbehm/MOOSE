-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- **Functional** - RANGE
--  
-- ![Banner Image](..\Presentations\RAT\RAT.png)
-- 
-- ====
-- 
-- Range practice.
-- 
-- Implementation is bases on the DCS Simple Range Script by Ciribob [see here](https://forums.eagle.ru/showthread.php?t=157991 which itself was motivated)
-- by a script by SNAFU [see here](https://forums.eagle.ru/showthread.php?t=109174).
-- 
-- ## Features
--
-- * Results of all bombing and strafing runs are stored and top 10 results can be displayed. 
-- * Rocket or bomb impact point from target is measured and reported to the player.
-- * Range targets can be marked by smoke.
-- * Rocket or bomb impact points can be marked by smoke.
-- * Direct hits on target can trigger flares.
-- * Distance from rocket/bomb impact point to closest target is calculated and reported to the player.
-- * Hits on strafing passes are counted.
-- 
-- ====
-- 
-- # Demo Missions
--
-- ### [ALL Demo Missions pack of the last release](https://github.com/FlightControl-Master/MOOSE_MISSIONS/releases)
-- 
-- ====
-- 
-- # YouTube Channel
-- 
-- ### [MOOSE YouTube Channel](https://www.youtube.com/playlist?list=PL7ZUrU4zZUl1jirWIo4t4YxqN-HxjqRkL)
-- 
-- ===
-- 
-- ### Author: **[funkyfranky](https://forums.eagle.ru/member.php?u=115026)**
-- 
-- ### Contributions: **Sven van de Velde ([FlightControl](https://forums.eagle.ru/member.php?u=89536))**
-- 
-- ====
-- @module Range

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- RANGE class
-- @type RANGE
-- @field #string ClassName Name of the Class.
-- @field #boolean Debug If true, print debug info to dcs.log file.
-- @field #table strafeTargets Table of strafing targets.
-- @field #table bombingTargets Table of targets to bomb.
-- @field #table addTo Table for monitoring which players already got an F10 menu.
-- @field #table strafeStatus Table containing the current strafing target a player as assigned to.
-- @field #table strafePlayerResults Table containing the strafing results of each player.
-- @field #table bombPlayerResults Table containing the bombing results of each player.
-- @field #table planes Table for administration.
-- @field Core.Point#COORDINATE location Coordinate of the range.
-- @field #string rangename Name of the range.
-- @field #number nbombtargets Number of bombing targets.
-- @field #number nstrafetargets Number of strafing targets.
-- @field #table PlayerSettings Indiviual player settings.
-- @field #number dtBombtrack Time step [sec] used for tracking released bomb/rocket positions. Default 0.005 seconds.
-- @field #number Tmsg Time [sec] messages to players are displayed. Default 30 sec.
-- @field #number strafemaxalt Maximum altitude above ground for registering for a strafe run. Default is 500 m = 1650 ft. 
-- @field #number ndisplayresult Number of (player) results that a displayed. Default is 10.
-- @extends Core.Base#BASE

---# RANGE class, extends @{Base#BASE}
-- The RANGE class
-- 
--
-- ## Usage
-- 
-- ![Process](..\Presentations\RAT\RAT_Airport_Selection.png)
-- 
-- ### Coding:
-- 
-- * Simply write PSEUDOATC:New() anywhere into your script.
-- 
-- 
-- @field #RANGE
RANGE={
  ClassName = "RANGE",
  Debug=false,
  rangename=nil,
  location=nil,
  strafeTargets={},
  bombingTargets={},
  nbombtargets=0,
  nstrafetargets=0,
  MenuAddedTo = {},
  planes = {},
  strafeStatus = {},
  strafePlayerResults = {},
  bombPlayerResults = {},
  PlayerSettings = {},
  dtBombtrack=0.005,
  Tmsg=30,
  strafemaxalt=500,
  ndisplayresult=10,
}

--- Some ID to identify who we are in output of the DCS.log file.
-- @field #string id
RANGE.id="RANGE | "

--- Range script version.
-- @field #number id
RANGE.version="0.7.0"

--TODO list
--TODO: Add statics.
--TODO: Add user function.
--TODO: Rename private functions, i.e. start with _functionname.
--DONE: number of displayed results variable.
--TODO: Add tire option for strafe pits. ==> No really feasible since tires are very small and cannot be seen.
--TODO: Check that menu texts are short enough to be correctly displayed in VR.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- RANGE contructor.
-- @param #RANGE self
-- @param #string name
-- @return #RANGE RANGE object.
function RANGE:New(name)

  -- Inherit BASE.
  local self=BASE:Inherit(self, BASE:New()) -- #RANGE
  
  -- Get range name.
  self.rangename=name or "Practice Range"
  
  -- Debug info.
  local text=string.format("Creating new RANGE object. RANGE script version %s. Range name: %s", RANGE.version, self.rangename)
  env.info(RANGE.id..text)
  MESSAGE:New(text, 10):ToAllIf(self.Debug)
  
  self.eventmoose=false
  
  -- Event handling.
  if self.eventmoose then
    env.info(RANGE.id.."Events are handled by MOOSE.")
    -- Events are handled my MOOSE.
    self:HandleEvent(EVENTS.Birth, self._OnBirth)
    self:HandleEvent(EVENTS.Hit,   self._OnHit)
    self:HandleEvent(EVENTS.Shot,  self._OnShot)
  else
    env.info(RANGE.id.."Events are handled by DCS.")
    -- Events are handled directly by DCS.
    self.Eventhandler=world.addEventHandler(self)
  end
  
  -- Return object.
  return self
end

--- Initializes number of targets and location of the range and starts the RANGE training.
-- @param #RANGE self
function RANGE:Start()

  -- Location/coordinate of range.
  local _location=nil
  
  -- Count bomb targets.
  local _count=0
  for _,_target in pairs(self.bombingTargets) do
    _count=_count+1
    --_target.name
    if _location==nil then
      _location=_target.point --Core.Point#COORDINATE
    end
  end
  self.nbombtargets=_count
  
  -- Count strafing targets.
  _count=0
  for _,_target in pairs(self.strafeTargets) do
    _count=_count+1
    for _,_unit in pairs(_target.targets) do
      if _location==nil then
        _location=_unit:GetCoordinate()
      end
    end
  end
  self.nstrafetargets=_count
  
  -- Location of the range. We simply take the first unit/target we find.
  self.location=_location
  
  if self.location==nil then
    local text=string.format("ERROR! No range location found. Number of strafe targets = %d. Number of bomb targets = %d.", self.rangename, self.nstrafetargets, self.nbombtargets)
    env.info(RANGE.id..text)
    return nil
  end
  
  -- Starting range.
  local text=string.format("Starting RANGE %s. Number of strafe targets = %d. Number of bomb targets = %d.", self.rangename, self.nstrafetargets, self.nbombtargets)
  env.info(RANGE.id..text)
  MESSAGE:New(text,10):ToAllIf(self.Debug)
  
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- User Functions

--- Add a unit as strafe target. For a strafe target hits from guns are counted. One pit can consist of several units.
-- Note, an approach is only valid, if the player enters a zone in front of the pit defined by boxlength and boxheading.
-- Also the player must not be too heigh and fly in the direction of the pit to make a valid target apporoach.
-- @param #RANGE self
-- @param #table Table of unit names defining the strafe targets. The first target in the list determines the approach zone (heading and box).
-- @param #number boxlength (Optional) Length of the approach box in meters. Default is 3000 m.
-- @param #number boxwidth (Optional) Width of the approach box in meters. Default is 300 m.
-- @param #number heading (Optional) Approach heading in Degrees. Default is heading of the unit as defined in the mission editor.
-- @param #boolean inverseheading (Optional) Take inverse heading (heading --> heading - 180 Degrees). Default is false.
-- @param #number goodpass (Optional) Number of hits for a "good" strafing pass. Default is 20.
-- @param #number foulline (Optional) Foul line distance. Hits from closer than this distance are not counted. Default 610 m = 2000 ft. Set to 0 for no foul line.
function RANGE:AddStrafeTarget(unitnames, boxlength, boxwidth, heading, inverseheading, goodpass, foulline)

  -- Create table if necessary.  
  if type(unitnames) ~= "table" then
    unitnames={unitnames}
  end
  
  -- Make targets
  local _targets={}
  local center=nil --Wrapper.Unit#UNIT
  local ntargets=0
  
  for _i,_name in ipairs(unitnames) do
  
    env.info(RANGE.id..string.format("Adding strafe target #%d %s", _i, _name))
    local unit=UNIT:FindByName(_name)
    
    if unit then
      table.insert(_targets, unit)
      -- Define center as the first unit we find
      if center==nil then
        center=unit 
      end
      ntargets=ntargets+1
    else
      local text=string.format("ERROR! Could not find strafe target with name %s.", _name)
      env.info(RANGE.id..text)
      MESSAGE:New(text, 10):ToAllIf(self.Debug)
    end
    
  end
  env.info(RANGE.id..string.format("Center unit is %s.", center:GetName())) 

  -- Approach box dimensions.
  local l=boxlength or 3000
  local w=(boxwidth or 300)/2
  
  -- Heading: either manually entered or automatically taken from unit heading.
  local heading=heading or center:GetHeading()
  
  -- Invert the heading since some units point in the "wrong" direction. In particular the strafe pit from 476th range objects.
  if inverseheading ~= nil then
    if inverseheading then
      heading=heading-180
    end
  end
  if heading<0 then
    heading=heading+360
  end
  if heading>360 then
    heading=heading-360
  end
  
  -- Number of hits called a "good" pass.
  local goodpass=goodpass or 20
  
  -- Foule line distance.
  local foulline=foulline or 0
  
  -- Coordinate of the range.
  local Ccenter=center:GetCoordinate()
  
  -- Name of the target defined as its unit name.
  local _name=center:GetName()

  -- Points defining the approach area.  
  local p={}
  p[#p+1]=Ccenter:Translate(  w, heading+90)
  p[#p+1]=  p[#p]:Translate(  l, heading)
  p[#p+1]=  p[#p]:Translate(2*w, heading-90)
  p[#p+1]=  p[#p]:Translate( -l, heading)
  
  local pv2={}
  for i,p in ipairs(p) do
    pv2[i]={x=p.x, y=p.z}
  end
  
  -- Create polygon zone.
  local _polygon=ZONE_POLYGON_BASE:New(_name, pv2)
  
  -- Create tires
  --_polygon:BoundZone()
    
  -- Add zone to table.
  table.insert(self.strafeTargets, {name=_name, polygon=_polygon, goodPass=goodpass, targets=_targets, foulline=foulline, smokepoints=p, heading=heading})
  
  -- Debug info
  local text=string.format("Adding new strafe target %s with %d targets: heading = %03d, box_L = %.1f, box_W = %.1f, goodpass = %d, foul line = %.1f", _name, ntargets, heading, boxlength, boxwidth, goodpass, foulline)
  if self.Debug then  
    env.info(RANGE.id..text)
  end
  MESSAGE:New(text, 5):ToAllIf(self.Debug)
end

--- Add bombing target(s) to range using their unit names.
-- @param #RANGE self
-- @param #table unitnames Table containing the unit names acting as bomb targets.
-- @param #number goodhitrange (Optional) Max distance from target unit (in meters) which is considered as a good hit. Default is 20 m.
-- @param #boolean static (Optional) Target is static. Default false.
function RANGE:AddBombingTargetsByName(unitnames, goodhitrange, static)

  -- Create a table if necessary.
  if type(unitnames) ~= "table" then
    unitnames={unitnames}
  end
  
  if static == nil or static == false then
    static=false
  else
    static=true
  end
  
  -- Default range is 20 m.
  goodhitrange=goodhitrange or 20
  
  for _,name in pairs(unitnames) do
    local _unit
    local _static
    
    if static then
     
      -- Add static object. Workaround since cargo objects are not yet in database because DCS function does not add those.
      local _DCSstatic=StaticObject.getByName(name)
      if _DCSstatic and _DCSstatic:isExist() then
        env.info("DCS static exists")
        _DATABASE:AddStatic(name)
      else
        env.info("DCS static DOES NOT exist")
      end
      
      -- Now we can find it
      _static=STATIC:FindByName(name)
      if _static then
        self:AddBombingTargetUnit(_static, goodhitrange)
        env.info(RANGE.id.."Adding static bombing target "..name.." with hit range "..goodhitrange)
      else
        env.info(RANGE.id.."ERROR! Cound not find static bombing target "..name)
      end
      
    else
    
      _unit=UNIT:FindByName(name)
      if _unit then
        self:AddBombingTargetUnit(_unit, goodhitrange)
        env.info(RANGE.id.."Adding bombing target "..name.." with hit range "..goodhitrange)
      else
        env.info(RANGE.id.."ERROR! Could not find bombing target "..name)
      end
      
    end

  end
end

--- Add a unit as bombing target.
-- @param #RANGE self
-- @param Wrapper.Unit#UNIT unit Unit of the strafe target.
-- @param #number goodhitrange Max distance from unit which is considered as a good hit.
function RANGE:AddBombingTargetUnit(unit, goodhitrange)
  
  local coord=unit:GetCoordinate()
  local name=unit:GetName()
  
  -- Default range is 20 m.
  goodhitrange=goodhitrange or 20  
  
  -- Create a zone around the unit.
  local Vec2=coord:GetVec2()
  local Rzone=ZONE_RADIUS:New(name, Vec2, goodhitrange)
  
  -- Insert target to table.
  table.insert(self.bombingTargets, {name=name, point=coord, zone=Rzone, target=unit})
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event Handling

--- General event handler.
-- @param #RANGE self
function RANGE:onEvent(Event)

  if Event == nil or Event.initiator == nil or Unit.getByName(Event.initiator:getName()) == nil then
    return true
  end

  local DCSiniunit = Event.initiator
  local DCStgtunit = Event.target
  local DCSweapon  = Event.weapon

  local EventData={}
  local _playerunit=nil
  local _playername=nil
  
  if Event.initiator then
    EventData.IniUnitName  = Event.initiator:getName()
    EventData.IniDCSGroup  = Event.initiator:getGroup()
    EventData.IniGroupName = Event.initiator:getGroup():getName()
    -- Get player unit and name. This returns nil,nil if the event was not fired by a player unit. And these are the only events we are interested in. 
    _playerunit, _playername = self:_GetPlayerUnitAndName(EventData.IniUnitName)  
  end

  if Event.target then  
    EventData.TgtUnitName  = Event.target:getName()
    EventData.TgtDCSGroup  = Event.target:getGroup()
    EventData.TgtGroupName = Event.target:getGroup():getName()
    EventData.TgtGroup     = GROUP:FindByName(EventData.TgtGroupName)
  end
  
  if Event.weapon then
    EventData.Weapon         = Event.weapon
    EventData.weapon         = Event.weapon
    EventData.WeaponTypeName = Event.weapon:getTypeName()
  end  
  
  -- Event info.
  if self.Debug then
    env.info(RANGE.id..string.format("EVENT: Event in onEvent with ID = %s", tostring(Event.id)))
    env.info(RANGE.id..string.format("EVENT: Ini unit   = %s" , tostring(EventData.IniUnitName)))
    env.info(RANGE.id..string.format("EVENT: Ini group  = %s" , tostring(EventData.IniGroupName)))
    env.info(RANGE.id..string.format("EVENT: Ini player = %s" , tostring(_playername)))
    env.info(RANGE.id..string.format("EVENT: Tgt unit   = %s" , tostring(EventData.TgtUnitName)))
    env.info(RANGE.id..string.format("EVENT: Tgt group  = %s" , tostring(EventData.IniGroupName)))
    env.info(RANGE.id..string.format("EVENT: Wpn type   = %s" , tostring(EventData.WeapoinTypeName)))
  end
    
  -- Call event Birth function.
  if Event.id==world.event.S_EVENT_BIRTH and _playername then
    self:_OnBirth(EventData)
  end
  
  -- Call event Shot function.
  if Event.id==world.event.S_EVENT_SHOT and _playername and Event.weapon then
    self:_OnShot(EventData)
  end
  
  -- Call event Hit function.
  if Event.id==world.event.S_EVENT_HIT and _playername and DCStgtunit then
    self:_OnHit(EventData)
  end
  
end


--- Range event handler for envent birth.
-- @param #RANGE self
-- @param Core.Event#EVENTDATA EventData
function RANGE:_OnBirth(EventData)
  self:E({eventbirth = EventData})
  
  local _unitName=EventData.IniUnitName  
  local _unit, _playername=self:_GetPlayerUnitAndName(_unitName)
  
  if self.Debug then
    env.info(RANGE.id.."BIRTH: unit   = "..tostring(EventData.IniUnitName))
    env.info(RANGE.id.."BIRTH: group  = "..tostring(EventData.IniGroupName))
    env.info(RANGE.id.."BIRTH: player = "..tostring(_playername)) 
  end
      
  if _unit and _playername then
  
    local _uid=_unit:GetID()
    local _group=_unit:GetGroup()
    local _gid=_group:GetID()
    local _callsign=_unit:GetCallsign()
    
    -- Debug output.
    local text=string.format("Player %s, callsign %s entered unit %s (UID %d) of group %s (GID %d)", _playername, _callsign, _unitName, _uid, _group:GetName(), _gid)
    env.info(RANGE.id..text)
    MESSAGE:New(text, 5):ToAllIf(self.Debug)
    
    -- Reset current strafe status.
    self.strafeStatus[_uid] = nil
  
    -- Add Menu commands.
    self:AddF10Commands(_unitName)
    
    -- By default, some bomb impact points and do not flare each hit on target.
    self.PlayerSettings[_playername]={}
    self.PlayerSettings[_playername].smokebombimpact=true
    self.PlayerSettings[_playername].flaredirecthits=false
  
    -- Start check in zone timer.
    if self.planes[_uid] ~= true then
      SCHEDULER:New(nil,self.CheckInZone, {self, EventData.IniUnitName}, 1, 1)
      self.planes[_uid] = true
    end
  
  end
  
end

--- Range event handler for event hit.
-- @param #RANGE self
-- @param Core.Event#EVENTDATA EventData
function RANGE:_OnHit(EventData)
  self:E({eventhit = EventData})

  -- Player info
  local _unitName = EventData.IniUnitName
  local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
  local _unitID   = _unit:GetID()

  -- Target
  local target     = EventData.TgtUnit
  local targetname = EventData.TgtUnitName
  
  -- Debug info.
  if self.Debug then
    env.info(RANGE.id.."HIT: Ini unit   = "..tostring(EventData.IniUnitName))
    env.info(RANGE.id.."HIT: Ini group  = "..tostring(EventData.IniGroupName))
    env.info(RANGE.id.."HIT: Tgt target = "..tostring(EventData.TgtUnitName))
    env.info(RANGE.id.."HIT: Tgt group  = "..tostring(EventData.TgtGroupName))
  end
  
  -- Current strafe target of player.
  local _currentTarget = self.strafeStatus[_unitID]

  -- Player has rolled in on a strafing target.
  if _currentTarget then
  
    local playerPos = _unit:GetCoordinate()
    local targetPos = target:GetCoordinate()

    -- Loop over valid targets for this run.
    for _,_target in pairs(_currentTarget.zone.targets) do
    
      -- Check the the target is the same that was actually hit.
      if _target:GetName() == targetname then
      
        -- Get distance between player and target.
        local dist=playerPos:Get2DDistance(targetPos)
        
        if dist > _currentTarget.zone.foulline then 
          -- Increase hit counter of this run.
          _currentTarget.hits =  _currentTarget.hits + 1
          
          -- Flare target.
          if _unit and _playername and self.PlayerSettings[_playername].flaredirecthits then
            targetPos:FlareRed()
          end
        else
          -- Too close to the target.
          if _currentTarget.pastfoulline==false and _unit and _playername then 
            local _d=_currentTarget.zone.foulline           
            local text=string.format("%s, Invalid hit!\nYou already passed foul line distance of %d m for target %s.", self:_myname(_unitName), _d, targetname)
            self:DisplayMessageToGroup(_unit, text, 10)
            env.info(RANGE.id..text)
            _currentTarget.pastfoulline=true
          end
        end
        
      end
    end
  end
  
  -- Bombing Targets
  for _,_target in pairs(self.bombingTargets) do
  
    -- Check if one of the bomb targets was hit.
    if _target.name == targetname then      
      
      if _unit and _playername then
      
        local playerPos = _unit:GetCoordinate()
        local targetPos = target:GetCoordinate()
      
        -- Message to player.
        --local text=string.format("%s, direct hit on target %s.", self:_myname(_unitName), targetname)
        --self:DisplayMessageToGroup(_unit, text, 10, true)
        --env.info(RANGE.id..text)
      
        -- Flare target.
        if self.PlayerSettings[_playername].flaredirecthits then
          targetPos:FlareRed()
        end
        
      end
    end
  end
end

--- Range event handler for event shot, i.e. when a unit releases a rocket or bomb (but not a fast firing gun). 
-- @param #RANGE self
-- @param Core.Event#EVENTDATA EventData
function RANGE:_OnShot(EventData)
  self:E({eventshot = EventData})
  
  -- Weapon data.
  local _weapon = EventData.Weapon:getTypeName()  -- should be the same as Event.WeaponTypeName
  local _weaponStrArray = self:_split(_weapon,"%.")
  local _weaponName = _weaponStrArray[#_weaponStrArray]
  
  if self.Debug then
    env.info(RANGE.id.."EVENT SHOT: Ini unit    = "..EventData.IniUnitName)
    env.info(RANGE.id.."EVENT SHOT: Ini group   = "..EventData.IniGroupName)
    env.info(RANGE.id.."EVENT SHOT: Weapon type = ".._weapon)
    env.info(RANGE.id.."EVENT SHOT: Weapon name = ".._weaponName)
  end
  
  -- Monitor only bombs and rockets.
  if (string.match(_weapon, "weapons.bombs") or string.match(_weapon, "weapons.nurs")) then

    -- Weapon
    local _ordnance =  EventData.weapon

    -- Tracking info and init of last bomb position.
    env.info(RANGE.id.."Tracking ".._weapon.." - ".._ordnance:getName())
    
    -- Init bomb position.
    local _lastBombPos = {x=0,y=0,z=0}

    -- Get unit name.
    local _unitName = EventData.IniUnitName
        
    -- Function monitoring the position of a bomb until impact.
    local function trackBomb(_previousPos)
      
      -- Get player unit and name.
      local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
      local _callsign=self:_myname(_unitName)

      -- env.info("Checking...")
      if _unit and _playername then

        -- when the pcall returns a failure the weapon has hit
        local _status,_bombPos =  pcall(
        function()
          -- env.info("protected")
          return _ordnance:getPoint()
        end)

        if _status then
        
          -- Still in the air. Remember this position.
          _lastBombPos = {x = _bombPos.x, y = _bombPos.y, z= _bombPos.z }
  
          -- Check again in 0.005 seconds.
          return timer.getTime() + self.dtBombtrack
          
        else
        
          -- Bomb did hit the ground.
          -- Get closet target to last position.
          local _closetTarget = nil
          local _distance = nil
          
          -- Coordinate of impact point.
          local impactcoord=COORDINATE:NewFromVec3(_lastBombPos)
          
          -- Smoke impact point of bomb.
          if self.PlayerSettings[_playername].smokebombimpact then  
            impactcoord:SmokeBlue()
          end
              
          -- Loop over defined bombing targets.
          for _,_bombtarget in pairs(self.bombingTargets) do
  
            -- Distance between bomb and target.
            local _temp = impactcoord:Get2DDistance(_bombtarget.point)
  
            -- Find closest target to last known position of the bomb.
            if _distance == nil or _temp < _distance then
                _distance = _temp
                _closetTarget = _bombtarget
            end
          end

          -- Count if bomb fell less than 1 km away from the target.
          if _distance <= 1000 then
  
            -- Init bomb player results.
            if not self.bombPlayerResults[_playername] then
              self.bombPlayerResults[_playername]  = {}
            end
  
            -- Local results.
            local _results =  self.bombPlayerResults[_playername]
            
            -- Add to table.
            table.insert(_results, {name=_closetTarget.name, distance =_distance, weapon = _weaponName })

            -- Send message to player.
            local _message = string.format("%s, impact %i m from bullseye of target %s.", _callsign, _distance, _closetTarget.name)

            -- Sendmessage.
            self:DisplayMessageToGroup(_unit, _message, nil, true)
          else
            -- Sendmessage
            local _message=string.format("%s, weapon fell more than 1 km away from nearest range target. No score.", _callsign)
            self:DisplayMessageToGroup(_unit, _message, nil, true)
          end
  
        end -- _status
          
      end -- end unit ~= nil
      
      return nil --Terminate the timer
    end -- end function bombtrack

    timer.scheduleFunction(trackBomb, nil, timer.getTime() + 1)
    
  end --if string.match
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Display Messages

--- Display best 10 stafing results of a specific player.
-- @param #RANGE self
-- @param #string _unitName Name of the player unit.
function RANGE:DisplayMyStrafePitResults(_unitName)
  
  -- Get player unit and name
  local _unit,_playername = self:_GetPlayerUnitAndName(_unitName)
  
  if _unit and _playername then
  
    -- Message header.
    local _message = string.format("My Top %d Strafe Pit Results:\n", self.ndisplayresult)
  
    -- Get player results.
    local _results = self.strafePlayerResults[_playername]
  
    -- Create message.
    if _results == nil then
        -- No score yet.
        _message = string.format("%s: No Score yet.", _playername)
    else
  
      -- Sort results table wrt number of hits.
      local _sort = function( a,b ) return a.hits > b.hits end
      table.sort(_results,_sort)
  
      -- Prepare message of best results.
      local _bestMsg = ""
      local _count = 1
      
      -- Loop over results
      for _,_result in pairs(_results) do
  
        -- Message text.
        _message = _message..string.format("\n[%d] %s - Hits %i - %s", _count, _result.zone.name, _result.hits, _result.text)
      
        -- Best result.
        if _bestMsg == "" then 
          _bestMsg = string.format("%s - Hits %i - %s", _result.zone.name, _result.hits, _result.text)
        end
  
        -- 10 runs
        if _count == self.ndisplayresult then
            break
        end
    
        -- Increase counter
        _count = _count+1
      end
  
      -- Message text.
      _message = _message .."\n\nBEST: ".._bestMsg
    end

    -- Send message to group.  
    self:DisplayMessageToGroup(_unit, _message, nil, true)
  end
end

--- Display top 10 strafing results of all players.
-- @param #RANGE self
-- @param #string _unitName Name fo the player unit.
function RANGE:DisplayStrafePitResults(_unitName)
  
  -- Get player unit and name.
  local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
  
  -- Check if we have a unit which is a player.
  if _unit and _playername then
  
    -- Results table.
    local _playerResults = {}
  
    -- Message text.
    local _message = string.format("Strafe Pit Results - Top %d Players:\n", self.ndisplayresult)
  
    -- Loop over player results.
    for _playerName,_results in pairs(self.strafePlayerResults) do
  
      -- Get the best result of the player.
      local _best = nil
      for _,_result in pairs(_results) do  
        if _best == nil or _result.hits > _best.hits then
          _best = _result
        end
      end
  
      -- Add best result to table. 
      if _best ~= nil then
        local text=string.format("%s: %s - Hits %i - %s", _playerName, _best.zone.name, _best.hits, _best.text)
        table.insert(_playerResults,{msg = text, hits = _best.hits})
      end
  
    end
  
    --Sort list!
    local _sort = function( a,b ) return a.hits > b.hits end
    table.sort(_playerResults,_sort)
  
    -- Add top 10 results.
    for _i = 1, math.min(#_playerResults, self.ndisplayresult) do
      _message = _message..string.format("\n[%d] %s", _i, _playerResults[_i].msg)
    end
  
    -- Send message.
    self:DisplayMessageToGroup(_unit, _message, nil, true)
  end
end

--- Display last 20 bombing run results of specific player.
-- @param #RANGE self
-- @param #string _unitName Name of the player unit.
function RANGE:DisplayMyBombingResults(_unitName)

  -- Get player unit and name.  
  local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
  
  if _unit and _playername then
  
    -- Init message.
    local _message = string.format("My Top %d Bombing Results:\n", self.ndisplayresult)
  
    -- Results from player.
    local _results = self.bombPlayerResults[_playername]
  
    -- No score so far.
    if _results == nil then
      _message = _playername..": No Score yet."
    else
  
      -- Sort results wrt to distance.
      local _sort = function( a,b ) return a.distance < b.distance end
      table.sort(_results,_sort)
  
      -- Loop over results.
      local _bestMsg = ""
      local _count = 1
      for _,_result in pairs(_results) do
  
        -- Message with name, weapon and distance.
        _message = _message.."\n"..string.format("[%d] %s - %s - %i m", _count, _result.name, _result.weapon, _result.distance)
  
        -- Store best/first result.
        if _bestMsg == "" then
            _bestMsg = string.format("%s - %s - %i m",_result.name,_result.weapon,_result.distance)
        end
  
        -- Best 10 runs only.
        if _count == self.ndisplayresult then
          break
        end
  
        -- Increase counter.
        _count = _count+1
      end
  
      -- Message.
      _message = _message .."\n\nBEST: ".._bestMsg
    end
  
    -- Send message.
    self:DisplayMessageToGroup(_unit, _message, nil, true)
  end
end

--- Display best bombing results of top 10 players.
-- @param #RANGE self
-- @param #string _unitName Name of player unit.
function RANGE:DisplayBombingResults(_unitName)
  
  -- Results table.
  local _playerResults = {}
  
  -- Get player unit and name.
  local _unit, _player = self:_GetPlayerUnitAndName(_unitName)
  
  -- Check if we have a unit with a player.
  if _unit and _player then
  
    -- Message header.
    local _message = string.format("Bombing Results - Top %d Players:\n", self.ndisplayresult)
  
    -- Loop over players.
    for _playerName,_results in pairs(self.bombPlayerResults) do
  
      -- Find best result of player.
      local _best = nil
      for _,_result in pairs(_results) do
        if _best == nil or _result.distance < _best.distance then
            _best = _result
        end
      end
  
      -- Put best result of player into table.
      if _best ~= nil then
        local bestres=string.format("%s: %s - %s - %i m", _playerName, _best.name, _best.weapon, _best.distance)
        table.insert(_playerResults, {msg = bestres, distance = _best.distance})
      end
  
    end
  
    -- Sort list of player results.
    local _sort = function( a,b ) return a.distance < b.distance end
    table.sort(_playerResults,_sort)
  
    -- Loop over player results.
    for _i = 1, math.min(#_playerResults, self.ndisplayresult) do  
      _message = _message..string.format("\n[%d] %s", _i, _playerResults[_i].msg)
    end
  
    -- Send message.
    self:DisplayMessageToGroup(_unit, _message, nil, true)
  end
end

--- Report information like bearing and range from player unit to range.
-- @param #RANGE self
-- @param #string _unitname Name of the player unit.
function RANGE:RangeInfo(_unitname)

  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Message text.
    local text=""
   
    -- Current coordinates.
    local coord=unit:GetCoordinate()
    
    if self.location then
    
      -- Direction vector from current position (coord) to target (position).
      local position=self.location --Core.Point#COORDINATE
      local rangealt=position:GetLandHeight()
      local vec3=coord:GetDirectionVec3(position)
      local angle=coord:GetAngleDegrees(vec3)
      local range=coord:Get2DDistance(position)
      
      -- Bearing string.
      local Bs=string.format('%03d°', angle)
      
      local textbomb
      if self.PlayerSettings[playername].smokebombimpact then
        textbomb=string.format("Smoke bomb impact points: ON\n")
      else
        textbomb=string.format("Smoke bomb impact points: OFF\n")
      end
      local texthit
      if self.PlayerSettings[playername].flaredirecthits then
        texthit=string.format("Flare direct hits: ON\n")
      else
        texthit=string.format("Flare direct hits: OFF\n")
      end
      
      -- Message.
      text=text..string.format("Information on %s:\n", self.rangename)
      text=text..string.format("--------------------------------------------------\n")
      text=text..string.format("Bearing %s, Range %.1f km.\n", Bs, range/1000)
      text=text..string.format("Range altitude ASL: %d m", rangealt)
      text=text..string.format("Max strafing alt: %d m\n", self.strafemaxalt)
      text=text..string.format("# of strafe targets: %d\n", self.nstrafetargets)
      text=text..string.format("# of bomb targets: %d\n", self.nbombtargets)
      text=text..texthit
      text=text..textbomb
      
      -- Send message to player group.
      self:DisplayMessageToGroup(unit, text, nil, true)
      
      if self.Debug then
        env.info(RANGE.id..text)
      end

    end
  end
end

--- Report weather conditions at range.
-- @param #RANGE self
-- @param #string _unitname Name of the player unit.
function RANGE:RangeWeather(_unitname)

  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Message text.
    local text=""
   
    -- Current coordinates.
    local coord=unit:GetCoordinate()
    
    if self.location then
    
      -- Get atmospheric data at range location.
      local position=self.location --Core.Point#COORDINATE
      local T=position:GetTemperature()
      local P=position:GetPressure()
      local Wd,Ws=position:GetWind()
      
      -- Get Beaufort wind scale.
      local Bn,Bd=UTILS.BeaufortScale(Ws)  
      
      local WD=string.format('%03d°', Wd)
      local Ts=string.format("%d°C",T)
      
      local hPa2inHg=0.0295299830714
      local hPa2mmHg=0.7500615613030
             
      -- Message text.
      text=text..string.format("Weather Report at %s:\n", self.rangename)
      text=text..string.format("--------------------------------------------------\n")
      text=text..string.format("Temperature %s\n", Ts)
      text=text..string.format("Wind from %s at %.1f m/s (%s)\n", WD, Ws, Bd)
      text=text..string.format("QFE %.1f hPa = %.1f mmHg = %.0f inHg\n", P, P*hPa2mmHg, P*hPa2inHg)
    else
      text=string.format("No range location defined for range %s.", self.rangename)
    end
    
    -- Send message to player group.
    self:DisplayMessageToGroup(unit, text, nil, true)
    
    if self.Debug then
      env.info(RANGE.id..text)
    end
  else
    env.info(RANGE.id.."ERROR! Could not find player unit in RangeInfo! Name = ".._unitname)
  end      
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Timer Functions

--- Check if player is inside a strafing zone. If he is, we start looking for hits. If he was and left the zone again, the result is stored.
-- @param #RANGE self
-- @param #string _unitName Name of player unit.
function RANGE:CheckInZone(_unitName)

  -- Get player unit and name.
  local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)

  if _unit and _playername then

    -- Current position of player unit.
    local _unitID  = _unit:GetID()

    -- Currently strafing? (strafeStatus is nil if not)
    local _currentStrafeRun = self.strafeStatus[_unitID]

    if _currentStrafeRun then  -- player has already registered for a strafing run.
    
      -- Get the current approach zone and check if player is inside.
      local zone=_currentStrafeRun.zone.polygon  --Core.Zone#ZONE_POLYGON_BASE
      
      local unitheading = _unit:GetHeading()
      local pitheading  = _currentStrafeRun.zone.heading - 180
      local towardspit  = math.abs(unitheading-pitheading)<=90
      local unitalt=_unit:GetHeight()-_unit:GetCoordinate():GetLandHeight()       
      
      -- Check if unit is inside zone and below max height AGL.
      local unitinzone=_unit:IsInZone(zone) and unitalt <= self.strafemaxalt and towardspit
      
      if self.Debug then
        local text=string.format("Checking zone. Unit = %s, player = %s in zone = %s", _unitName, _playername, tostring(unitinzone))
        env.info(RANGE.id..text)
      end
    
      -- Check if player is in strafe zone and below max alt.
      if unitinzone then 
        
        -- Still in zone, keep counting hits. Increase counter.
        _currentStrafeRun.time = _currentStrafeRun.time+1
    
      else
    
        -- Increase counter
        _currentStrafeRun.time = _currentStrafeRun.time+1
    
        if _currentStrafeRun.time <= 3 then
        
          -- Reset current run.
          self.strafeStatus[_unitID] = nil
    
          -- Message text.
          local _msg = string.format("%s left strafing zone %s too quickly. No Score.", _playername, _currentStrafeRun.zone.name)
          
          -- Send message.
          self:DisplayMessageToGroup(_unit, _msg, nil, true)
          
        else
        
          -- Result.
          local _result = self.strafeStatus[_unitID]

          -- Judge this pass. Text is displayed on summary.
          if _result.hits >= _result.zone.goodPass*2 then
            _result.text = "EXCELLENT PASS"    
          elseif _result.hits >= _result.zone.goodPass then
            _result.text = "GOOD PASS"
          elseif _result.hits >= _result.zone.goodPass/2 then
            _result.text = "INEFFECTIVE PASS"
          else
            _result.text = "POOR PASS"
          end
    
          -- Message text.      
          local _text=string.format("%s, %s with %d hits on target %s.", self:_myname(_unitName), _result.text, _result.hits, _result.zone.name)
          
          -- Send message.
          self:DisplayMessageToGroup(_unit, _text)
    
          -- Set strafe status to nil.
          self.strafeStatus[_unitID] = nil
    
          -- Save stats so the player can retrieve them.
          local _stats = self.strafePlayerResults[_playername] or {}
          table.insert(_stats, _result)
          self.strafePlayerResults[_playername] = _stats
        end
        
      end

    else
    
      -- Check to see if we're in any of the strafing zones (first time).
      for _,_targetZone in pairs(self.strafeTargets) do
        
        -- Get the current approach zone and check if player is inside.
        local zonenname=_targetZone.name
        local zone=_targetZone.polygon  --Core.Zone#ZONE_POLYGON_BASE
      
        -- Check if player is in zone and below
        --local unitinzone=_unit:IsInZone(zone) and _unit:GetHeight()-_unit:GetCoordinate():GetLandHeight() <= self.strafemaxalt
        
        local unitheading = _unit:GetHeading()
        local pitheading  = _targetZone.heading - 180
        local towardspit  = math.abs(unitheading-pitheading)<=90
        local unitalt=_unit:GetHeight()-_unit:GetCoordinate():GetLandHeight()       
      
        -- Check if unit is inside zone and below max height AGL.
        local unitinzone=_unit:IsInZone(zone) and unitalt <= self.strafemaxalt and towardspit
           
        if self.Debug then
          local text=string.format("Checking zone %s. Unit = %s, player = %s in zone = %s", _targetZone.name, _unitName, _playername, tostring(unitinzone))
          --MESSAGE:New(text, 10):ToAllIf(self.Debug)
          env.info(RANGE.id..text)
        end
        
        -- Player is inside zone.
        if unitinzone then

          -- Init strafe status for this player.
          self.strafeStatus[_unitID] = {hits = 0, zone = _targetZone, time = 1, pastfoulline=false }
  
          -- Rolling in!
          local _msg=string.format("%s, rolling in on strafe pit %s.", self:_myname(_unitName), _targetZone.name)
          
          -- TODO: MOOSE message.
          self:DisplayMessageToGroup(_unit, _msg, 10, true)

          -- We found our player. Skip remaining checks.
          break
          
        end -- unit in zone check 
        
      end -- loop over zones
    end
  end
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Menu Functions

--- Add menu commands for player.
-- @param #RANGE self
-- @param #string _unitName Name of player unit.
function RANGE:AddF10Commands(_unitName)
  
  -- Get player unit and name.
  local _unit, playername = self:_GetPlayerUnitAndName(_unitName)
  
  -- Check for player unit.
  if _unit and playername then

    -- Get group and ID.
    local group=_unit:GetGroup()
    local _gid=group:GetID()
  
    if group and _gid then
  
      if not self.MenuAddedTo[_gid] then
      
        -- Enable switch so we don't do this twice.
        self.MenuAddedTo[_gid] = true
  
        -- Main F10 menu: F10/On the Range
        local _rootPath = missionCommands.addSubMenuForGroup(_gid, "On the Range")
        -- Submenu for this range: F10/On the Range/<Range Name>
        local _rangePath = missionCommands.addSubMenuForGroup(_gid, self.rangename, _rootPath)
        local _smokePath = missionCommands.addSubMenuForGroup(_gid, "Mark Targets", _rangePath)
        local _statsPath = missionCommands.addSubMenuForGroup(_gid, "Stats", _rangePath)

        --TODO: Convert to MOOSE menu.
        -- Commands
        missionCommands.addCommandForGroup(_gid, "Mark On Map",         _smokePath, self.MarkTargetsOnMap, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Illuminate Range",    _smokePath, self.IlluminateBombTargets, self)        
        missionCommands.addCommandForGroup(_gid, "Smoke Strafe Pits",    _smokePath, self.SmokeStrafeTargetBoxes, self)        
        missionCommands.addCommandForGroup(_gid, "Smoke Straf Tgts",   _smokePath, self.SmokeStrafeTargets, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Smoke Bomb Tgts",  _smokePath, self.SmokeBombTargets, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "All Strafe Results",  _statsPath, self.DisplayStrafePitResults, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "All Bombing Results", _statsPath, self.DisplayBombingResults, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "My Strafe Results",   _statsPath, self.DisplayMyStrafePitResults, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "My Bomb Results",  _statsPath, self.DisplayMyBombingResults, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Reset Stats",         _statsPath, self.ResetRangeStats, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Range Information",   _rangePath, self.RangeInfo, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Range Weather",       _rangePath, self.RangeWeather, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Smoke Impact On/Off", _rangePath, self.SmokeBombImpactOnOff, self, _unitName)
        missionCommands.addCommandForGroup(_gid, "Flare Hits On/Off",   _rangePath, self.FlareDirectHitsOnOff, self, _unitName)
      end
    else
      env.info(RANGE.id.."ERROR! Could not find group or group ID in AddF10Menu() function. Unit name: ".._unitName)
    end
  else
    env.info(RANGE.id.."ERROR! Player unit does not exist in AddF10Menu() function. Unit name: ".._unitName)
  end

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper Functions

--- Mark targets on F10 map.
-- @param #RANGE self
-- @param #string _unitName Name of the player unit.
function RANGE:MarkTargetsOnMap(_unitName)
  -- Get group.
  local group=UNIT:FindByName(_unitName):GetGroup()

  if group then
  
    -- Mark bomb targets.
    for _,_target in pairs(self.bombingTargets) do
      local coord=_target.point --Core.Point#COORDINATE
      coord:MarkToGroup("Bomb target ".._target.name, group)
    end
    
    -- Mark strafe targets.
    for _,_strafepit in pairs(self.strafeTargets) do
      for _,_target in pairs(_strafepit.targets) do
        local coord=_target:GetCoordinate() --Core.Point#COORDINATE
        coord:MarkToGroup("Strafe target ".._target:GetName(), group)
      end
    end
    
  end
end

--- Illuminate targets. Fires illumination bombs at one random bomb and one random strafe target at a random altitude between 400 and 800 m.
-- @param #RANGE self
-- @param #string _unitName (Optional) Name of the player unit.
function RANGE:IlluminateBombTargets(_unitName)

  local bomb={}

  for _,_target in pairs(self.bombingTargets) do
    local coord=_target.point --Core.Point#COORDINATE
    table.insert(bomb, coord)
  end
  
  if #bomb>0 then
    local coord=bomb[math.random(#bomb)] --Core.Point#COORDINATE
    local c=COORDINATE:New(coord.x,coord.y+math.random(400,800),coord.z)
    c:IlluminationBomb()
  end
  
  -- All strafe target coordinates.
  local strafe={}
  
  for _,_strafepit in pairs(self.strafeTargets) do
    for _,_target in pairs(_strafepit.targets) do
      local coord=_target:GetCoordinate() --Core.Point#COORDINATE
      table.insert(strafe, coord)
    end
  end
  
  -- Pick a random strafe target.
  if #strafe>0 then
    local coord=strafe[math.random(#strafe)] --Core.Point#COORDINATE
    local c=COORDINATE:New(coord.x,coord.y+math.random(400,800),coord.z)
    c:IlluminationBomb()
  end
  
  if _unitName then
    local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
    local text=string.format("%s, range targets are illuminated.", self.rangename)
    self:DisplayMessageToGroup(_unit, text, 5)
  end
end

--- Reset statistics.
-- @param #RANGE self
-- @param #string _unitName Name of the player unit.
function RANGE:ResetRangeStats(_unitName)

  -- Get player unit and name.  
  local _unit, _playername = self:_GetPlayerUnitAndName(_unitName)
  
  if _unit and _playername then  
    self.strafePlayerResults[_playername] = nil
    self.bombPlayerResults[_playername] = nil
    local text=string.format("%s, all range stats cleared.", self.rangename)
    self:DisplayMessageToGroup(_unit, text, 5)
  end
end

--- Display message to group.
-- @param #RANGE self
-- @param Wrapper.Unit#UNIT _unit Player unit.
-- @param #string _text Message text.
-- @param #number _time Duration how long the message is displayed.
-- @param #boolean _clear Clear up old messages.
function RANGE:DisplayMessageToGroup(_unit, _text, _time, _clear)
  
  _time=_time or self.Tmsg
  if _clear==nil then
    _clear=false
  end
  
    -- Group ID.
  local _gid=_unit:GetGroup():GetID()
  
  if _gid then
    if _clear == true then
      trigger.action.outTextForGroup(_gid, _text, _time, _clear)
    else
      trigger.action.outTextForGroup(_gid, _text, _time)
    end
  end
end

--- Toggle status of smoking bomb impact points.
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:SmokeBombImpactOnOff(unitname)
  local unit, playername = self:_GetPlayerUnitAndName(unitname)
  if unit and playername then
    local text
    if self.PlayerSettings[playername].smokebombimpact==true then
      self.PlayerSettings[playername].smokebombimpact=false
      text=string.format("%s, smoking impact points of bombs is now OFF.", self.rangename)
    else
      self.PlayerSettigs[playername].smokebombimpact=true
      text=string.format("%s, smoking impact points of bombs is now ON.", self.rangename)
    end
    self:DisplayMessageToGroup(unit, text, 5)
  end
end

--- Toggle status of flaring direct hits of range targets.
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:FlareDirectHitsOnOff(unitname)
  local unit, playername = self:_GetPlayerUnitAndName(unitname)
  if unit and playername then
    local text
    if self.PlayerSettings[playername].flaredirecthits==true then
      self.PlayerSettings[playername].flaredirecthits=false
      text=string.format("%s, flaring direct hits is now OFF.", self.rangename)
    else
      self.PlayerSettings[playername].flaredirecthits=true
      text=string.format("%s, flaring direct hits is now ON.", self.rangename)
    end
    self:DisplayMessageToGroup(unit, text, 5)
  end
end

--- Get distance in meters assuming a Flat world.
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:SmokeBombTargets(unitname)
  for _,_target in pairs(self.bombingTargets) do
    local coord = _target.point --Core.Point#COORDINATE
    coord:SmokeRed()
  end
  if unitname then
    local unit, playername = self:_GetPlayerUnitAndName(unitname)
    local text=string.format("%s, bombing targets are now marked with red smoke.", self.rangename)
    self:DisplayMessageToGroup(unit, text, 5)
  end
end

--- Get distance in meters assuming a Flat world.
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:SmokeStrafeTargets(unitname)
  for _,_target in pairs(self.strafeTargets) do
    for _,_unit in pairs(_target.targets) do
      local coord = _unit:GetCoordinate() --Core.Point#COORDINATE
      coord:SmokeGreen()
    end
  end
  if unitname then
    local unit, playername = self:_GetPlayerUnitAndName(unitname)
    local text=string.format("%s, strafing tragets are now marked with green smoke.", self.rangename)
    self:DisplayMessageToGroup(unit, text, 5)
  end
end

--- Smoke approach boxes of strafe targets.
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:SmokeStrafeTargetBoxes(unitname)
  for _,_target in pairs(self.strafeTargets) do
    local zone=_target.polygon --Core.Zone#ZONE
    zone:SmokeZone(SMOKECOLOR.White)
    for _,_point in pairs(_target.smokepoints) do
      _point:SmokeOrange()
    end
  end
  if unitname then
    local unit, playername = self:_GetPlayerUnitAndName(unitname)
    local text=string.format("%s, strafing pit approach boxes are now marked with white smoke.", self.rangename)
    self:DisplayMessageToGroup(unit, text, 5)
  end  
end

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #RANGE self
-- @param #string _unitName Name of the player unit.
-- @return Wrapper.Unit#UNIT Unit of player.
-- @return #string Name of the player.
-- @return nil If player does not exist.
function RANGE:_GetPlayerUnitAndName(_unitName)

  if _unitName ~= nil then
    local DCSunit=Unit.getByName(_unitName)
    local playername=DCSunit:getPlayerName()
    local unit=UNIT:Find(DCSunit)
    
    if DCSunit and unit and playername then
      return unit, playername
    end
  end
    
  return nil,nil
end

--- Returns a string which consits of this callsign and the player name.  
-- @param #RANGE self
-- @param #string unitname Name of the player unit.
function RANGE:_myname(unitname)
  local unit=UNIT:FindByName(unitname)
  local pname=unit:GetPlayerName()
  local csign=unit:GetCallsign()
  return string.format("%s (%s)", csign, pname)
end


--- http://stackoverflow.com/questions/1426954/split-string-in-lua
-- @param #RANGE self
-- @param #string str Sting to split.
-- @param #string sep Speparator for split.
-- @return #table Split text.
function RANGE:_split(str, sep)
  local result = {}
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
      table.insert(result, each)
  end
  return result
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
