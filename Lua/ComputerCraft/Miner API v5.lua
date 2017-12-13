-- ### Function List ### --

-- ### General and Initialization ### --
-- initialize() : Initializes the program. Call once and call first.

-- ### Movement ### --
-- Move in the direction given. Calls sub-movement methods. Mine, attack, refuel and check for falling blocks based on boolean parameters.
-- miningBehavior is a mining cross-section function that preserves location and direction.
-- bool, int move       (int distance, bool autoMine, bool checkFalling, bool autoAttack, bool autoRefuel, int direction, function miningBehavior, ...)
-- bool, int moveUp     (int distance, bool autoMine, bool checkFalling, bool autoAttack, bool autoRefuel               , function miningBehavior, ...)
-- bool, int moveDown   (int distance, bool autoMine,                    bool autoAttack, bool autoRefuel               , function miningBehavior, ...)
-- bool, int moveForward(int distance, bool autoMine, bool checkFalling, bool autoAttack, bool autoRefuel               , function miningBehavior, ...)

-- ### Directional ### --
-- void orient      (int direction) -- Orient the turtle in the direction specified.
-- int  getLeftOf   (int direction) -- Get the left of the direction specified.
-- int  getRightOf  (int direction) -- Get the right of the direction specified.
-- int  getReverseOf(int direction) -- Get the opposite of the direction specified.

-- ### Inventory ### --
-- int  cycleSlot          (int distance)                                      -- Cycles the inventory slot, wrapping around.
-- void setSlot            (int slot)                                          -- Sets the current inventory slot to parameter.
-- bool refuelInventory    (int distance, int slot, bool search, bool tryOnce) -- Refuel for distance given. It will start its search, if cycleSlots is true, at the given slot. Otherwise assumes fuel is in slot.
-- bool refuelAtChest      (int distance, int direction)                       -- Refuel for distance given at a chest adjacent to the turtle in a specified direction.
-- bool refuelInvOrChest   (int distance, int direction)                       -- Refuel from inventory and, if more is needed, from an adjacent chest.
-- void dumpInventory      (int direction, bool keepFuel)                      -- Dumps everything in inventory into chest positions adjacent to the turtle in a specified direction.
-- bool isInventoryOccupied()                                                  -- Returns true if there is an item in every inventory slot.



-- ### Constants ### --

UP    = -1
DOWN  = -2
SOUTH = 0
WEST  = 1
NORTH = 2
EAST  = 3

LEFT   = "left"
RIGHT  = "right"
FRONT  = "front"
BACK   = "back"
TOP    = "top"
BOTTOM = "bottom"

checkFallingSleep = 0.5 -- Length of time to sleep for falling block checking

-- ### Globals ### --

currentSlot = nil -- Current inventory slot
compass = nil

-- ### General and Initialization ### --

function initialize()
  -- Enable use of the compass
  for i,v in ipairs(rs.getSides()) do
    if peripheral.getType(v) == "compass" then
      compass = peripheral.wrap(v)
    end
  end

  -- Set up inventory data
  currentSlot = 1
end

-- ### Movement ### --

function move(distance, autoMine, checkFalling, autoAttack, autoRefuel, direction, miningBehavior, ...)
  if direction == UP then
    return moveUp(distance, autoMine, checkFalling, autoAttack, autoRefuel, miningBehavior, ...)
  elseif direction == DOWN then
    return moveDown(distance, autoMine, autoAttack, autoRefuel, miningBehavior, ...)
  else -- Cardinal directions
    orient(direction)

    return moveForward(distance, autoMine, checkFalling, autoAttack, autoRefuel, miningBehavior, ...)
  end
end

function moveUp(distance, autoMine, checkFalling, autoAttack, autoRefuel, miningBehavior, ...)
  local didMineAction = false
  local i = 0
  while i < distance do
    if not turtle.up() then
      -- Mine if there is a block ahead
      if autoMine and turtle.detectUp() then
        -- Bedrock 2 stronk
        if not turtle.digUp() then
          return false, i
        end
      end

      -- Monster in the way (Don't stand in front of it btw)
      if autoAttack then
        turtle.attackUp()
      end

      -- No fuel
      if autoRefuel and turtle.getFuelLevel() == 0 then
        refuel(1, 1, true)
      end

      -- Catch any extraneous items
      turtle.suck()
      turtle.suckUp()
      turtle.suckDown()
    else
      i = i + 1
      didMineAction = false
    end
    
    -- Always use the mining behavior if supplied
    if miningBehavior ~= nil then
      miningBehavior(...)
      didMineAction = true
    end
    
    -- Wait for falling blocks if we are told that is a possibility
    if checkFalling then
      sleep(checkFallingSleep)
    end
  end
  return true, i
end

function moveDown(distance, autoMine, autoAttack, autoRefuel, miningBehavior, ...)
  local didMineAction = false
  local i = 0
  while i < distance do
    if not turtle.down() then
      -- Mine if there is a block ahead
      if autoMine and turtle.detectDown() then
        -- Bedrock 2 stronk
        if not turtle.digDown() then
          return false, i
        end
      end

      -- Monster in the way (Don't stand in front of it btw)
      if autoAttack then
        turtle.attackDown()
      end

      -- No fuel
      if autoRefuel and turtle.getFuelLevel() == 0 then
        refuel(1, 1, true)
      end

      -- Catch any extraneous items
      turtle.suck()
      turtle.suckUp()
      turtle.suckDown()
    else
      i = i + 1
      didMineAction = false
    end
    
    -- Always use the mining behavior if supplied
    if miningBehavior ~= nil then
      miningBehavior(...)
      didMineAction = true
    end
    
    -- Wait for falling blocks if we are told that is a possibility
    if checkFalling then
      sleep(checkFallingSleep)
    end
  end
  return true, i
end

function moveForward(distance, autoMine, checkFalling, autoAttack, autoRefuel, miningBehavior, ...)
  local didMineAction = false
  local i = 0
  while i < distance do
    if not turtle.forward() then
      -- Mine if there is a block ahead
      if autoMine and turtle.detect() then
        -- Bedrock 2 stronk
        if not turtle.dig() then
          return false, i
        end
      end

      -- Monster in the way (Don't stand in front of it btw)
      if autoAttack then
        turtle.attack()
      end

      -- No fuel
      if autoRefuel and turtle.getFuelLevel() == 0 then
        refuel(1, 1, true)
      end

      -- Catch any extraneous items
      turtle.suck()
      turtle.suckUp()
      turtle.suckDown()
    else
      i = i + 1
      didMineAction = false
    end
    
    -- Always use the mining behavior if supplied
    if miningBehavior ~= nil then
      miningBehavior(...)
      didMineAction = true
    end
    
    -- Wait for falling blocks if we are told that is a possibility
    if checkFalling then
      sleep(checkFallingSleep)
    end
  end
  return true, i
end

-- ### Directional ### --

function orient(direction)
  local facing = compass.getFacing()
  if (direction >= 0) and not (facing == direction) then
    if getLeftOf(facing) == direction then
      turtle.turnLeft()
    elseif getRightOf(facing) == direction then
      turtle.turnRight()
    else
      turtle.turnRight()
      turtle.turnRight()
    end
  end
end

function getLeftOf(direction)
  if direction < 0 then
    return direction
  end
  return (direction - 1) % 4
end

function getRightOf(direction)
  if direction < 0 then
    return direction
  end
  return (direction + 1) % 4
end

function getReverseOf(direction)
  if direction == DOWN then
    return UP
  elseif direction == UP then
    return DOWN
  else
    return (direction + 2) % 4
  end
end

-- ### Inventory ### --

function cycleSlot(distance)
  currentSlot = ((currentSlot - 1 + distance) % 16) + 1
  turtle.select(currentSlot)
  return currentSlot
end

function setSlot(slot)
  currentSlot = slot
  turtle.select(currentSlot)
end

function refuelInventory(distance, slot, search, tryOnce)
  distance = distance or 1 -- If distance not defined, then just refuel once.
  slot = slot or currentSlot -- If slot is not defined, start at the current slot.
  search = search or false
  tryOnce = tryOnce or false
  local slotStore = currentSlot -- Previous currentSlot

  setSlot(slot)

  -- Refuel until we have enough
  while turtle.getFuelLevel() < distance do
    local startSlot = currentSlot -- Slot where we started the search
    -- Find the first fuel slot
    while not turtle.refuel(1) do
      if not search then
        setSlot(slotStore)
        return false
      end

      cycleSlot(1)

      -- Means no fuel
      if currentSlot == slot then
        print("Out of fuel. Units required: " .. (distance - turtle.getFuelLevel()))
        if tryOnce then
          return false
        else
          sleep(10)
        end
      end
    end
  end

  setSlot(slotStore)
  return true
end

function refuelAtChest(distance, direction)
  distance = distance or 1 -- If distance not defined, then just refuel once.
  direction = direction or compass.getFacing() -- If direction not defined, then assume chest in front of us.
  inventoryFuel = inventoryFuel or false
  
  local startFacing = compass.getFacing()
  
  orient(direction)
  
  if not turtle.detect(direction) then
    print("No chest found at desired direction. Assuming fuel will be thrown on ground (works the same either way).")
  end
  
  while turtle.getFuelLevel() < distance do
    turtle.suck()
    refuelInventory(distance, currentSlot, true, true)
    if turtle.getFuelLevel() < distance then
      print("Out of fuel. Units required: " .. (distance - turtle.getFuelLevel()))
      sleep(2)
    end
  end
  
  orient(startFacing)
  return true
end

function refuelInvOrChest(distance, direction)
  refuelInventory(distance, nil, true, true) -- Attempt once from inventory first
  
  while turtle.getFuelLevel() < distance do
    if not refuelAtChest(distance, direction) then
      print("Please put fuel in the chest or my inventory.")
    end
  end
  
  return true
end

function dumpInventory(direction, keepFuel)
  orient(direction)

  for i=1,16 do
    if (not turtle.refuel(1)) or (not keepFuel) then
      if direction == UP then
        turtle.dropUp(turtle.getItemCount(currentSlot))
      elseif direction == DOWN then
        turtle.dropDown(turtle.getItemCount(currentSlot))
      else
        turtle.drop(turtle.getItemCount(currentSlot))
      end
    end
    cycleSlot(1)
  end
end

function isInventoryOccupied()
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      return false
    end
  end
  return true
end

-- ###  ### --

initialize()