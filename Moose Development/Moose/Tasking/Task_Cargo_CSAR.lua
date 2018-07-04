--- **Tasking** -- Orchestrates the task for players to execute CSAR for downed pilots.
-- 
-- **Specific features:**
-- 
--   * Creates a task to retrieve a pilot @{Cargo.Cargo} from behind enemy lines.
--   * Derived from the TASK_CARGO class, which is derived from the TASK class.
--   * Orchestrate the task flow, so go from Planned to Assigned to Success, Failed or Cancelled.
--   * Co-operation tasking, so a player joins a group of players executing the same task.
-- 
-- 
-- **A complete task menu system to allow players to:**
--   
--   * Join the task, abort the task.
--   * Mark the task location on the map.
--   * Provide details of the target.
--   * Route to the cargo.
--   * Route to the deploy zones.
--   * Load/Unload cargo.
--   * Board/Unboard cargo.
--   * Slingload cargo.
--   * Display the task briefing.
--   
--   
-- **A complete mission menu system to allow players to:**
--   
--   * Join a task, abort the task.
--   * Display task reports.
--   * Display mission statistics.
--   * Mark the task locations on the map.
--   * Provide details of the targets.
--   * Display the mission briefing.
--   * Provide status updates as retrieved from the command center.
--   * Automatically assign a random task as part of a mission.
--   * Manually assign a specific task as part of a mission.
--   
--   
--  **A settings system, using the settings menu:**
--  
--   * Tweak the duration of the display of messages.
--   * Switch between metric and imperial measurement system.
--   * Switch between coordinate formats used in messages: BR, BRA, LL DMS, LL DDM, MGRS.
--   * Different settings modes for A2G and A2A operations.
--   * Various other options.
--
-- ===
-- 
-- Please read through the @{Tasking.Task_Cargo} process to understand the mechanisms of tasking and cargo tasking and handling.
-- 
-- The cargo will be a downed pilot, which is located somwhere on the battlefield. Use the menus system and facilities to 
-- join the CSAR task, and retrieve the pilot from behind enemy lines. The menu system is generic, there is nothing
-- specific on a CSAR task that requires further explanation, than reading the generic TASK_CARGO explanations.
-- 
-- Enjoy!
-- FC
-- 
-- ===
-- 
-- ### Author: **FlightControl**
-- 
-- ### Contributions: 
-- 
-- ===
-- 
-- @module Tasking.Task_Cargo_CSAR
-- @image Task_Cargo_CSAR.JPG


do -- TASK_CARGO_CSAR

  --- @type TASK_CARGO_CSAR
  -- @extends Tasking.Task_Cargo#TASK_CARGO
  
  --- Orchestrates the task for players to execute CSAR for downed pilots.
  -- 
  -- CSAR tasks are suited to govern the process of return downed pilots behind enemy lines back to safetly.
  -- Typically, this task is executed by helicopter pilots, but it can also be executed by ground forces!
  -- 
  -- ===
  -- 
  -- A CSAR task can be created manually, but actually, it is better to **GENERATE** these tasks using the 
  -- @{Tasking.Task_Cargo_Dispatcher} module.
  -- 
  -- Using the dispatcher, CSAR tasks will be created **automatically** when a pilot ejects from a damaged AI aircraft.
  -- When this happens, the pilot actually will survive, but needs to be retrieved from behind enemy lines.
  -- 
  -- # 1) Create a CSAR task manually (code it).
  -- 
  -- Although it is recommended to use the dispatcher, you can create a CSAR task yourself as a mission designer.
  -- It is easy, as it works just like any other task setup.
  -- 
  -- ## 1.1) Create a command center.
  -- 
  -- First you need to create a command center using the @{Tasking.CommandCenter#COMMANDCENTER.New}() constructor.
  -- 
  --     local CommandCenter = COMMANDCENTER
  --        :New( HQ, "Lima" ) -- Create the CommandCenter.
  --     
  -- ## 1.2) Create a mission.
  -- 
  -- Tasks work in a mission, which groups these tasks to achieve a joint mission goal.
  -- A command center can govern multiple missions.
  -- Create a new mission, using the @{Tasking.Mission#MISSION.New}() constructor.
  -- 
  --     -- Declare the Mission for the Command Center.
  --     local Mission = MISSION
  --       :New( CommandCenter, 
  --             "Overlord", 
  --             "High", 
  --             "Retrieve the downed pilots.", 
  --             coalition.side.RED 
  --           ) 
  -- 
  -- ## 1.3) Create the CSAR cargo task.
  -- 
  -- So, now that we have a command center and a mission, we now create the CSAR task.
  -- We create the CSAR task using the @{#TASK_CARGO_CSAR.New}() constructor.
  -- 
  -- Because a CSAR task will not generate the cargo itself, you'll need to create it first.
  -- The cargo in this case will be the downed pilot!
  -- 
  --     -- Here we define the "cargo set", which is a collection of cargo objects.
  --     -- The cargo set will be the input for the cargo transportation task.
  --     -- So a transportation object is handling a cargo set, which is automatically refreshed when new cargo is added/deleted.
  --     local CargoSet = SET_CARGO:New():FilterTypes( "Pilots" ):FilterStart()
  --    
  --     -- Now we add cargo into the battle scene.
  --     local PilotGroup = GROUP:FindByName( "Pilot" )
  --      
  --     -- CARGO_GROUP can be used to setup cargo with a GROUP object underneath.
  --     -- We name this group Engineers.
  --     -- Note that the name of the cargo is "Engineers".
  --     -- The cargoset "CargoSet" will embed all defined cargo of type "Pilots" (prefix) into its set.
  --     local CargoGroup = CARGO_GROUP:New( PilotGroup, "Pilots", "Downed Pilot", 500 )
  -- 
  -- What is also needed, is to have a set of @{Core.Group}s defined that contains the clients of the players.
  -- 
  --     -- Allocate the Transport, which are the helicopter to retrieve the pilot, that can be manned by players.
  --     local GroupSet = SET_GROUP:New():FilterPrefixes( "Transport" ):FilterStart()
  -- 
  -- Now that we have a CargoSet and a GroupSet, we can now create the CSARTask manually.
  -- 
  --     -- Declare the CSAR task.
  --     local CSARTask = TASK_CARGO_CSAR
  --       :New( Mission, 
  --             GroupSet, 
  --             "CSAR Pilot", 
  --             CargoSet, 
  --             "Fly behind enemy lines, and retrieve the downed pilot." 
  --           )
  -- 
  -- So you can see, setting up a CSAR task manually is a lot of work.
  -- It is better you use the cargo dispatcher to generate CSAR tasks and it will work as it is intended.
  -- By doing this, CSAR tasking will become a dynamic experience.
  -- 
  -- ===
  -- 
  -- @field #TASK_CARGO_CSAR
  TASK_CARGO_CSAR = {
    ClassName = "TASK_CARGO_CSAR",
  }
  
  --- Instantiates a new TASK_CARGO_CSAR.
  -- @param #TASK_CARGO_CSAR self
  -- @param Tasking.Mission#MISSION Mission
  -- @param Core.Set#SET_GROUP SetGroup The set of groups for which the Task can be assigned.
  -- @param #string TaskName The name of the Task.
  -- @param Core.Set#SET_CARGO SetCargo The scope of the cargo to be transported.
  -- @param #string TaskBriefing The Cargo Task briefing.
  -- @return #TASK_CARGO_CSAR self
  function TASK_CARGO_CSAR:New( Mission, SetGroup, TaskName, SetCargo, TaskBriefing )
    local self = BASE:Inherit( self, TASK_CARGO:New( Mission, SetGroup, TaskName, SetCargo, "CSAR", TaskBriefing ) ) -- #TASK_CARGO_CSAR
    self:F()
    
    Mission:AddTask( self )
    
    
    -- Events
    
    self:AddTransition( "*", "CargoPickedUp", "*" )
    self:AddTransition( "*", "CargoDeployed", "*" )
    
    self:F( { CargoDeployed = self.CargoDeployed ~= nil and "true" or "false" } )
    
      --- OnBefore Transition Handler for Event CargoPickedUp.
      -- @function [parent=#TASK_CARGO_CSAR] OnBeforeCargoPickedUp
      -- @param #TASK_CARGO_CSAR self
      -- @param #string From The From State string.
      -- @param #string Event The Event string.
      -- @param #string To The To State string.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that PickedUp the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      -- @return #boolean Return false to cancel Transition.
      
      --- OnAfter Transition Handler for Event CargoPickedUp.
      -- @function [parent=#TASK_CARGO_CSAR] OnAfterCargoPickedUp
      -- @param #TASK_CARGO_CSAR self
      -- @param #string From The From State string.
      -- @param #string Event The Event string.
      -- @param #string To The To State string.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that PickedUp the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
        
      --- Synchronous Event Trigger for Event CargoPickedUp.
      -- @function [parent=#TASK_CARGO_CSAR] CargoPickedUp
      -- @param #TASK_CARGO_CSAR self
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that PickedUp the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      
      --- Asynchronous Event Trigger for Event CargoPickedUp.
      -- @function [parent=#TASK_CARGO_CSAR] __CargoPickedUp
      -- @param #TASK_CARGO_CSAR self
      -- @param #number Delay The delay in seconds.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that PickedUp the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
    
      --- OnBefore Transition Handler for Event CargoDeployed.
      -- @function [parent=#TASK_CARGO_CSAR] OnBeforeCargoDeployed
      -- @param #TASK_CARGO_CSAR self
      -- @param #string From The From State string.
      -- @param #string Event The Event string.
      -- @param #string To The To State string.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that Deployed the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      -- @param Core.Zone#ZONE DeployZone The zone where the Cargo got Deployed or UnBoarded.
      -- @return #boolean Return false to cancel Transition.
      
      --- OnAfter Transition Handler for Event CargoDeployed.
      -- @function [parent=#TASK_CARGO_CSAR] OnAfterCargoDeployed
      -- @param #TASK_CARGO_CSAR self
      -- @param #string From The From State string.
      -- @param #string Event The Event string.
      -- @param #string To The To State string.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that Deployed the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      -- @param Core.Zone#ZONE DeployZone The zone where the Cargo got Deployed or UnBoarded.
        
      --- Synchronous Event Trigger for Event CargoDeployed.
      -- @function [parent=#TASK_CARGO_CSAR] CargoDeployed
      -- @param #TASK_CARGO_CSAR self
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that Deployed the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      -- @param Core.Zone#ZONE DeployZone The zone where the Cargo got Deployed or UnBoarded.
      
      --- Asynchronous Event Trigger for Event CargoDeployed.
      -- @function [parent=#TASK_CARGO_CSAR] __CargoDeployed
      -- @param #TASK_CARGO_CSAR self
      -- @param #number Delay The delay in seconds.
      -- @param Wrapper.Unit#UNIT TaskUnit The Unit (Client) that Deployed the cargo. You can use this to retrieve the PlayerName etc.
      -- @param Core.Cargo#CARGO Cargo The Cargo that got PickedUp by the TaskUnit. You can use this to check Cargo Status.
      -- @param Core.Zone#ZONE DeployZone The zone where the Cargo got Deployed or UnBoarded.

    local Fsm = self:GetUnitProcess()

    local CargoReport = REPORT:New( "Rescue a downed pilot from the following position:")
    
    SetCargo:ForEachCargo(
      --- @param Core.Cargo#CARGO Cargo
      function( Cargo )
        local CargoType = Cargo:GetType()
        local CargoName = Cargo:GetName()
        local CargoCoordinate = Cargo:GetCoordinate()
        CargoReport:Add( string.format( '- "%s" (%s) at %s', CargoName, CargoType, CargoCoordinate:ToStringMGRS() ) )
      end
    )
    
    self:SetBriefing( 
      TaskBriefing or 
      CargoReport:Text()
    )

    
    return self
  end 

  function TASK_CARGO_CSAR:ReportOrder( ReportGroup ) 
    
    return 0
  end

  
  --- 
  -- @param #TASK_CARGO_CSAR self
  -- @return #boolean
  function TASK_CARGO_CSAR:IsAllCargoTransported()
  
    local CargoSet = self:GetCargoSet()
    local Set = CargoSet:GetSet()
    
    local DeployZones = self:GetDeployZones()
    
    local CargoDeployed = true
    
    -- Loop the CargoSet (so evaluate each Cargo in the SET_CARGO ).
    for CargoID, CargoData in pairs( Set ) do
      local Cargo = CargoData -- Core.Cargo#CARGO
      
      self:F( { Cargo = Cargo:GetName(), CargoDeployed = Cargo:IsDeployed() } )

      if Cargo:IsDeployed() then
      
--        -- Loop the DeployZones set for the TASK_CARGO_CSAR.
--        for DeployZoneID, DeployZone in pairs( DeployZones ) do
--        
--          -- If all cargo is in one of the deploy zones, then all is good.
--          self:T( { Cargo.CargoObject } )
--          if Cargo:IsInZone( DeployZone ) == false then
--            CargoDeployed = false
--          end
--        end
      else
        CargoDeployed = false
      end
    end

    self:F( { CargoDeployed = CargoDeployed } )
    
    return CargoDeployed
  end
  
  --- @param #TASK_CARGO_CSAR self
  function TASK_CARGO_CSAR:onafterGoal( TaskUnit, From, Event, To )
    local CargoSet = self.CargoSet
    
    if self:IsAllCargoTransported() then
      self:Success()
    end
    
    self:__Goal( -10 )
  end

end

