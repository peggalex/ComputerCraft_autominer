local maxSlot = 16
turtle.select(maxSlot)
local storageCrateSlot = 14
local chestSlot = 15
local levelsPerChest = 50

local depth, width, length = ...

assert(depth ~= nil, "please specify depth.")
depth = tonumber(depth)
assert(0 < depth, "depth must be larger than 0.")
if depth % 2 == 1 then
    depth = depth - 1
    print('using even depth:', depth)
end

width = tonumber(width) or 2
assert(1 < width, "width must be larger than 0.")
if width % 2 == 1 then
    width = width - 1
    print('using even width:', width)
end

length = tonumber(length) or 16
assert(1 < length, "length must be larger than 1.")

function checkSlot(slot, nameSubstring, minCount)
    local data = turtle.getItemDetail(slot)
    local count = turtle.getItemCount(slot)
    return data ~= nil and string.find(data.name, nameSubstring) and minCount <= count
end

local requiredChests = math.ceil((depth / levelsPerChest)) * width
--[[ take ceiling because we place a chest at depth-1 regardless of level ]]--

local requiredFuel = depth * length * width + (width * width)
local chestFuel = (depth * requiredChests * 2) + (width * width)
requiredFuel = requiredFuel + chestFuel
local currentFuel = turtle.getFuelLevel()
assert(
    requiredFuel <= currentFuel,
     "not enough fuel, you have " .. currentFuel .. ", you need " .. requiredFuel .. "."
)

assert(
    checkSlot(chestSlot, "chest", requiredChests), 
    "not enough chests, " .. math.floor(requiredChests) .. " required in slot " .. chestSlot .. "."
)

assert(
    checkSlot(storageCrateSlot, "chest", 2), 
    "please add two chests to slot " .. storageCrateSlot .. "."
)

--[[ blacklist for items ]]--
local worthlessNames = {
    "cobblestone",
    "dirt",
    "gravel",
    "granite",
    "diorite",
    "andesite",
    ":stone"
}

function isItemValuable(slotNum)
    slotNum = slotNum or 16
    local data = turtle.getItemDetail(slotNum)
    if data == nil then
        return false
    end
    for _, wothlessName in ipairs(worthlessNames) do
        if string.find(data.name, wothlessName) ~= nil then
            return false
        end
    end
    return true
end

function keepOrDropItem()
    turtle.select(maxSlot)
    if isItemValuable() then
        for i = 1, maxSlot do
            if i ~= chestSlot then
                local transferSuccess = turtle.transferTo(i)
                if transferSuccess then
                    break
                end
            end
        end
    else
        turtle.drop()
    end
    turtle.select(maxSlot)
end

function digAndMove(digFunc, moveFunc)
    --[[ 
        Try to move 3 times, if it doesn't work, throw an error.
        This is important for gravel, bedrock, and players accidentally walking in front.
    ]]--
    local i = 1
    local isGravel = false
    while i < 10 or isGravel do
        i = i + 1
        digFunc()
        local data = turtle.getItemDetail()
        isGravel = data ~= nil and string.find(data.name, "gravel")
        keepOrDropItem()
        local success, error = moveFunc();
        if success then
            return;
        end
        sleep(0.5)  --[[ wait, ie for gravel or player to move ]]--
    end
    error("couldn't move")
end

function digAndMoveForward()
    digAndMove(turtle.dig, turtle.forward)
end

function digAndMoveDown()
    digAndMove(turtle.digDown, turtle.down)
end

function digAndMoveUp()
    digAndMove(turtle.digUp, turtle.up)
end

function turnBack()
    turtle.turnLeft()
    turtle.turnLeft()
end

function depositIntoChest(isUp)
    for i = 1, maxSlot do
        if i ~= chestSlot then
            turtle.select(i)
            if isUp then
                turtle.dropUp()
            else
                turtle.dropDown()
            end
        end
    end
end

function placeChestAndDeposit(isUp)
    turtle.select(chestSlot)
    if isUp then
        turtle.placeUp()
    else
        turtle.placeDown()
    end
    depositIntoChest(isUp)
    turtle.select(maxSlot)
end

function placeMasterChest()
    turtle.select(storageCrateSlot)
    turtle.forward()
    turtle.placeUp()
    turtle.back()
    turtle.placeUp()
end

local startDay = os.day()
function getTimeElapsed()
    return os.day() - startDay
end

placeMasterChest()

for i = 1, width/2 do
    for d = 1, depth, 2 do 
        --[[ Plus one so that it is offset from the chests from the previous loop ]]--
        --[[ This is important because you can't have more than 2 chests side-by-side on the same floor ]]--
        if (d + 1) % levelsPerChest == 0 or d == depth - 1 then
            placeChestAndDeposit(true)
        end
        if not pcall(digAndMoveDown) then 
            break --[[ we throw errors if we cant dig, if we can't dig down (bedrock) just break ]]--
        end
        for i = 1, length - 1 do --[[ length - 1 because when we dig down that is already one block ]]--
            digAndMoveForward()
        end
        if not pcall(digAndMoveDown) then 
            break 
        end    
        turnBack()
        for i = length - 1, 1, -1 do
            digAndMoveForward()
        end
        turnBack()
    end

    turtle.turnRight()
    digAndMoveForward()
    turtle.turnLeft()
    
    for d = 1, depth, 2 do 
        if d % levelsPerChest == 0 or d == depth - 1 then
            placeChestAndDeposit(false)
        end
        for i = 1, length - 1 do
            digAndMoveForward()
        end
        digAndMoveUp()
        turnBack()
        for i = length - 1, 1, -1 do
            digAndMoveForward()
        end
        turnBack()
        digAndMoveUp()
    end

    if i < width/2 then
        turtle.turnRight()
        digAndMoveForward()
        turtle.turnLeft()
    end
end

print("days digging:", getTimeElapsed())

function getBlockName(inspectFunc)
    local success, data = inspectFunc()
    if success then
        return data.name
    end
end

function moveUp(steps)
    for _ = 1, steps do
        turtle.up()
    end
end

function moveDown(steps)
    for _ = 1, steps do
        turtle.down()
    end
end

function moveLeft(steps)
    turtle.turnLeft()
    for _ = 1, steps do
        turtle.forward()
    end
    turtle.turnRight()
end

function moveRight(steps)
    turtle.turnRight()
    for _ = 1, steps do
        turtle.forward()
    end
    turtle.turnLeft()
end

moveLeft(width - 1)

for i = 1, width do
    for j = 1, depth do
        local blockUnder = getBlockName(turtle.inspectDown)
        if blockUnder ~= nil then
            if string.find(blockUnder, "chest") then
                for _ = 1, maxSlot do
                    turtle.select(maxSlot)
                    if not turtle.suckDown() then
                        break
                    end
                    keepOrDropItem()
                end
                turtle.digDown()

                moveUp(j - 1)
                moveLeft(i - 1)
                depositIntoChest(true)
                moveRight(i - 1)
                moveDown(j - 1)

            else
                turtle.select(maxSlot)
                turtle.digDown()
                keepOrDropItem()
            end
        end
        turtle.down()
    end

    moveUp(depth)
    if i < width then
        moveRight(1)
    end
end

print("days to complete:", getTimeElapsed())