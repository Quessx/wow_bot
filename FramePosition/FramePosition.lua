print('start frame')
local AppName = "FramePosition"
local VERSION = AppName .. "-r" .. ("$Revision: 309 $"):match("%d+")
local OptionsAppName = AppName .. "_Options"
local Sections = {
  "crSection",
  "srSection",
  "mrSection",
  "lrSection",
  "defaultSection",
  "oorSection",
}
local rc = LibStub("LibRangeCheck-2.0")
FramePosition = LibStub("AceAddon-3.0"):NewAddon(AppName, "AceEvent-3.0")
local FramePosition = FramePosition
FramePosition:SetDefaultModuleState(false)
FramePosition.version = VERSION
FramePosition.AppName = AppName
FramePosition.OptionsAppName = OptionsAppName
FramePosition.Sections = Sections
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitPower = UnitPower
local UnitCastingInfo = UnitCastingInfo
-- local UnitCanAttack = UnitCanAttack
-- local UnitCanAssist = UnitCanAssist
-- local UnitPowerType = UnitPowerType
-- local UnitPosition = UnitPosition
-- local ipairs = ipairs

-- debug button
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetPoint("LEFT", UIParent, 30, 0)
btn:SetSize(100, 40)
btn:SetText("Reload")
btn:SetScript("OnClick", function(self, button, up)
  return ReloadUI()
end)
btn:RegisterForClicks("AnyUp")

---@param position FramePoint
---@param name string
---@param mainFrame frame
local function createFrames(position, name, mainFrame, sizeFrame)
  local createFrame = CreateFrame("Frame", name, mainFrame)
  if position == "TOP" then
    createFrame:SetSize(100, 50)
  elseif sizeFrame ~= nil then
    createFrame:SetSize(sizeFrame.x, sizeFrame.y)
  else 
    createFrame:SetSize(50, 50)
  end
  createFrame:SetPoint(position, mainFrame);
  createFrame.texture = createFrame:CreateTexture("ARTWORK")
  createFrame.texture:SetAllPoints(true)
  if name == 'mana' then 
    createFrame.texture:SetTexture(0, 0, 166)
  elseif name == 'target' then
    createFrame.texture:SetTexture(0.68, 0.68, 0)
  else
    createFrame.texture:SetTexture(1, 0, 0)
  end
  createFrame.text = createFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  createFrame.text:SetPoint("CENTER")
  createFrame.text:SetText(name)
end

local function setFacingPosition(facing, coord)
  if coord >= 6.15 then
    coord = coord - 0.35
  end

  if (facing <= coord + 0.35 and facing >= coord) then
    up.texture:SetTexture(0, 1, 0);
    left.texture:SetTexture(1, 0, 0);
    right.texture:SetTexture(1, 0, 0)
  elseif ((facing > coord)) then
    up.texture:SetTexture(1, 0, 0);
    left.texture:SetTexture(1, 0, 0);
    right.texture:SetTexture(0, 1, 0)
  elseif (facing < coord) then
    up.texture:SetTexture(1, 0, 0);
    left.texture:SetTexture(0, 1, 0);
    right.texture:SetTexture(1, 0, 0)
  end
end

-- внеднить в setFacingPosition
-- ищет направление в которое нужно дивагаться персонажу чтобы попасть на нужные координаты
local function setNearVector(xPlayer, yPlayer, runCoordX, runCoordY)
  player = {xPlayer, yPlayer}
  toMove = {runCoordX, runCoordY}
  startVector = {player[1], player[2] - 1}
  vect1 = {startVector[1] - player[1], startVector[2] - player[2]}
  vect2 = {toMove[1] - player[1], toMove[2] - player[2]}
  cosA = (vect1[1] * vect2[1] + vect1[2] * vect2[2]) / (
      (math.sqrt((vect1[1] * vect1[1] + vect1[2] * vect1[2]))) * (math.sqrt(vect2[1] * vect2[1] + vect2[2] * vect2[2]))
  )
  angle = math.degrees(math.acos(cosA))
  if toMove[1] > player[1] then
      angle = 360 - angle
  end
  piAngle = angle * math.pi / 180
  distance = math.sqrt(vect2[1] * vect2[1] + vect2[2] * vect2[2])

  print(piAngle, distance)
end

local function shwcrd(x)
  return math.floor(x * 100)
end

local function setCoord(runningCoordinates, posCoord)
  return runningCoordinates - shwcrd(posCoord)
end

-- create main frame
local frame = CreateFrame("Frame", nil, UIParent)
local castFrame = CreateFrame("Frame", 'CastFrame', UIParent)

frame:SetMovable(true)
frame:EnableMouse(true)

castFrame:SetMovable(true)
castFrame:EnableMouse(true)

-- The code below makes the frame visible, and is not necessary to enable dragging.
frame:SetPoint("TOPLEFT", UIParent, 50, -120)
frame:SetSize(100, 150)

-- spell frame
castFrame:SetPoint("LEFT", UIParent, 50, 90)
castFrame:SetSize(100, 30)

createFrames('CENTER', 'castSpell', castFrame, {x = 100, y = 30})
createFrames('TOP', 'up', frame)
createFrames('LEFT', 'left', frame)
createFrames('RIGHT', 'right', frame)
createFrames('BOTTOMLEFT', 'mana', frame)
createFrames('BOTTOMRIGHT', 'target', frame)
  
local xFacingCoordLeft = 1.49
local xFacingCoordRight = 4.68
local yFacingCoordUp = 6.26
local yFacingCoordDown = 3.06

local minPossiblePower = UnitPowerMax("player", 0) / 100 * 30
local unit = 'playertarget'

local posCurrentX, posCurrentY = GetPlayerMapPosition("player")
local currentCoordIndex = 0
-- set coordinates for farming mobs
local runningCoordinates = {[0] = {[0] = {x = 41, y = 56}, [1] = {x = 42, y = 57}}, [1] = {x = 38, y = 57}, [2] = {x = 37, y = 54}, [3] = {x = 39, y = 53}};

function FramePosition:OnInitialize()
  -- set near position coord
  local nearNumberX = math.abs(setCoord(runningCoordinates[0].x, posCurrentX))
  local nearNumberY = math.abs(setCoord(runningCoordinates[0].y, posCurrentY))
  for k in next, runningCoordinates do
    if (nearNumberX >= math.abs(runningCoordinates[k].x - shwcrd(posCurrentX)) and nearNumberY >= math.abs(runningCoordinates[k].y - shwcrd(posCurrentY))) then
      currentCoordIndex = k
    end
  end
end

UIParent:SetScript("OnUpdate", function(self)
  local facing = GetPlayerFacing()
  local minRange, maxRange = rc:GetRange(unit)
  local isTarget = 0
  local spell = UnitCastingInfo("player")
  if spell then
    castSpell.texture:SetTexture(0, 1, 0)
  else
    castSpell.texture:SetTexture(1, 0, 0)
  end

  -- local isEnemyPlayer = UnitIsPlayer(unit) and UnitCanAssist(unit, 'player') ~= 1
  local posX, posY = GetPlayerMapPosition("player")
  -- print(shwcrd(posX).." / "..shwcrd(posY), facing)
  if UnitExists(unit) and UnitIsPlayer(unit) == nil and UnitIsUnit(unit, 'target') and UnitCanAssist(unit, 'player') ~= 1 and maxRange < 30 then
    target.texture:SetTexture(0, 1, 0)
    isTarget = 1
  else
    target.texture:SetTexture(0.68, 0.68, 0)
    isTarget = 0
  end

  if minPossiblePower > UnitPower("player", 0) then
    mana.texture:SetTexture(1, 0, 0)
  else
    mana.texture:SetTexture(0, 0, 166)
  end

  print(facing)
  if tonumber(runningCoordinates[currentCoordIndex].y) ~= shwcrd(posY) and tonumber(runningCoordinates[currentCoordIndex].y) <= shwcrd(posY) then
    setFacingPosition(facing, yFacingCoordUp)
  elseif tonumber(runningCoordinates[currentCoordIndex].y) ~= shwcrd(posY) and tonumber(runningCoordinates[currentCoordIndex].y) >= shwcrd(posY) then
    setFacingPosition(facing, yFacingCoordDown)
  elseif tonumber(runningCoordinates[currentCoordIndex].x) ~= shwcrd(posX) and tonumber(runningCoordinates[currentCoordIndex].x) <= shwcrd(posX) then
    setFacingPosition(facing, xFacingCoordLeft)
  elseif tonumber(runningCoordinates[currentCoordIndex].x) ~= shwcrd(posX) and tonumber(runningCoordinates[currentCoordIndex].x) >= shwcrd(posX) then
    setFacingPosition(facing, xFacingCoordRight)
  elseif tonumber(runningCoordinates[currentCoordIndex].x) == shwcrd(posX) and tonumber(runningCoordinates[currentCoordIndex].y) == shwcrd(posY) then
    if (runningCoordinates[currentCoordIndex + 1]) then
      currentCoordIndex = currentCoordIndex + 1
    else
      currentCoordIndex = 0
    end
  end
end)
