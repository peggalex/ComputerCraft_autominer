local bucketSlot = 16
local maxDist = turtle.getFuelLimit()/1000 * 1.1
--[[ 10% multiplier in case some of the lava is already taken ]]--

local currentFuel = turtle.getFuelLevel()
local requiredFuel = maxDist * 2
assert(requiredFuel <= currentFuel, "at least " .. requiredFuel .. " required, you only have " .. currentFuel)

function checkSlot(slot, nameSubstring, minCount)
    local data = turtle.getItemDetail(slot)
    local count = turtle.getItemCount(slot)
    return data ~= nil and string.find(data.name, nameSubstring) and minCount <= count
end

function getBlockName(inspectFunc)
    local success, data = inspectFunc()
    if success then
        return data.name
    end
end

assert(checkSlot(bucketSlot, "bucket", 1), "put bucket in slot " .. bucketSlot)
turtle.digDown()
turtle.down()

turtle.select(bucketSlot)
local i = 1
while true do
    if maxDist < i then
        print("stopped by max iter")
        break
    end

    local blockInFront = getBlockName(turtle.inspect)

    if not string.find(blockInFront, "lava") then
        print("stopped by non-lava")
        break
    end

    turtle.place() --[[ pickup with bucket ]]--
    turtle.refuel()

    turtle.placeDown()
    turtle.refuel()

    turtle.turnLeft()
    turtle.place()
    turtle.refuel()
    turtle.turnRight()

    turtle.turnRight()
    turtle.place()
    turtle.refuel()
    turtle.turnLeft()

    if turtle.getFuelLevel() == turtle.getFuelLimit() then
        print("stopped by max fuel")
        break
    end

    turtle.forward()    

    i = i + 1
end

turtle.turnLeft()
turtle.turnLeft()

for _ = 1, i do
    turtle.forward()
end

print(turtle.getFuelLevel())