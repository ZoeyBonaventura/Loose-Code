-- TODO: Put information how to use this here!
-- Assume dropoff chest behind turtle, fuel chest left of turtle.

-- Length == N/S == Number of rows
-- Width  == E/W == Length of rows
-- Height == U/D == Number of layers

-- MineRoom N/S E/W U/D length>0 width>0 height>0

os.loadAPI("api")

-- Mine layer of size lengthXwidth at height offset in direction
function mineLayer(NS, EW, UD, length, width, height, layer)
  -- Chest information
  local chestDirection = api.getReverseOf(api.compass.getFacing()) -- Assume start with chest behind.
  
  -- Misc variables
  local layerDistance = layer -- For down
  if UD == api.UP then -- For up
    layerDistance = height+1-layer
  end
  
  -- Re-used variables
  local numMined = 0 -- Keep track of how far we mined each time.
  local success = false -- True if a mining cycle succeeds.
  
  -- Flags
  local mineSecondLayer = (layer < height)
  local topLayer = (layer == 1)
  
  function mineBelow(mineSecondLayer)
    if mineSecondLayer and turtle.detectDown() then
      turtle.digDown()
    end
  end
  
  -- Check if we will have enough fuel for entire layer, assume returning after each row.
  local totalFuelNeeded = 0
  totalFuelNeeded = totalFuelNeeded + (length * width - 1) -- Total area mined.
  totalFuelNeeded = totalFuelNeeded + (2 * layerDistance * length) -- Go to and from the chest row # of times.
  totalFuelNeeded = totalFuelNeeded + ((length - 1) * length) -- To get to the row each time along the layer. Do this twice. (n(n+1)/2)*2
  totalFuelNeeded = totalFuelNeeded + (2 * width * math.ceil(length / 2)) -- Odd rows go along row to get to the return point
  
  api.refuelInvOrChest(totalFuelNeeded, api.getRightOf(chestDirection)) -- Assume chest is on the left of turtle.
  
  -- Position itself at top corner of layer. Don't sleep if we've already mined this far.
  success, numMined = api.move(layerDistance, true, (UD == api.UP and topLayer), true, true, UD, mineBelow, (mineSecondLayer and UD == api.DOWN))
  
   -- Can't get to the required layer, so we need to return to the chest.
  if not success then
    api.move(numMined, true, (UD == api.DOWN), true, true, api.getReverseOf(UD))
    return false
  end
  
  for row=1,length do -- Loop through the rows
    -- Mine the row
    if (row % 2) == 0 then
      success, numMined = api.move(width-1, true, topLayer, true, true, api.getReverseOf(EW), mineBelow, mineSecondLayer)
    else
      success, numMined = api.move(width-1, true, topLayer, true, true, EW, mineBelow, mineSecondLayer)
    end
    
    if not success then
      -- Failed mining the entire row so we must return to the chest.
      api.move(row - 1, true, topLayer, true, true, api.getReverseOf(NS)) -- Return to first row.
      if (row % 2) == 0 then
        api.move(width - 1 - numMined, true, topLayer, true, true, api.getReverseOf(EW)) -- Return to first column.
      else
        api.move(numMined, true, topLayer, true, true, EW) -- Return to layer column.
      end
      api.move(layerDistance, true, (UD == api.DOWN), true, true, api.getReverseOf(UD)) -- Return to chest.
      
      return false -- After this assume general failure.
    end
    
    -- Assume success.
    
    -- Check if we need to unload loot or return to the chest for end of the layer.
    if api.isInventoryOccupied() or (row == length) then
      -- Return to the chest
      api.move(row - 1, true, topLayer, true, true, api.getReverseOf(NS)) -- Return to first row.
      if (row % 2) == 1 then
        api.move(width - 1, true, topLayer, true, true, api.getReverseOf(EW)) -- Return to layer column.
      end
      -- If we are on an even row then we are already at the correct column.
      api.move(layerDistance, true, (UD == api.DOWN), true, true, api.getReverseOf(UD)) -- Return to chest.
      
      -- Unload loot
      api.dumpInventory(chestDirection, true)
      
      -- Return to the row or terminate the loop if necessary.
      if row == length then
        break
      else
        -- Return to the row
        api.move(layerDistance, true, (UD == api.DOWN), true, true, UD) -- Return to layer.
        if (row % 2) == 1 then
          api.move(width - 1, true, topLayer, true, true, EW) -- Return to row's starting column.
        end
        -- If we are on an even row then we are already at the correct column.
        api.move(row - 1, true, topLayer, true, true, NS) -- Return to row.
      end
    end
    
    -- Go to next row.
    success, numMined = api.move(1, true, topLayer, true, true, NS, mineBelow, mineSecondLayer)
  end
  
  -- Prepare for next layer
  api.orient(api.getReverseOf(chestDirection))
end

-- MineRoom N/S E/W U/D length>0 width>0 height>0
-- N/S    = N or S
-- E/W    = E or W
-- U/D    = U or D
-- length = >0 along N/S
-- width  = >0 along E/W
-- height = >0 along U/D
local args = { ... }

if #args == 0 then
  -- Print out usage
  print("MineRoom N/S E/W U/D length>0 width>0 height>0")
  print("MineRoom DEFAULT - N E U 5 5 5")
  return
end

-- Set up defaults for missing values
if not args[1] or args[1]:upper() == "DEFAULT" then
  args = {}
  args[1] = "N"
end
if not args[2] then
  args[2] = "E"
end
if not args[3] then
  args[3] = "U"
end
if not args[4] or tonumber(args[4]) < 1 then
  args[4] = 5
end
if not args[5] or tonumber(args[5]) < 1 then
  args[5] = 5
end
if not args[6] or tonumber(args[6]) < 1 then
  args[6] = 5
end

args[4] = tonumber(args[4])
args[5] = tonumber(args[5])
args[6] = tonumber(args[6])

-- Convert text to directions
if args[1]:upper() == "N" then
  args[1] = api.NORTH
elseif args[1]:upper() == "S" then
  args[1] = api.SOUTH
else
  error("NS")
end

if args[2]:upper() == "E" then
  args[2] = api.EAST
elseif args[2]:upper() == "W" then
  args[2] = api.WEST
else
  error("EW")
end

if args[3]:upper() == "U" then
  args[3] = api.UP
elseif args[3]:upper() == "D" then
  args[3] = api.DOWN
else
  error("UD")
end

-- Mine layers
for layer=1,args[6],2 do
  local success = mineLayer(args[1], args[2], args[3], args[4], args[5], args[6], layer)
  if success == false then
    break
  end
end