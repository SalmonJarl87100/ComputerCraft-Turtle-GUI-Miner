local basalt = require("basalt")

-- stop program if machine is not a turtle
if not turtle then
    print("Program must be run on a turtle.")
    return
end

-- get the current working directory from arguments table
local CWD = arg[1]

-- function to abreviate large numbers
local function shortenNumber(number)
    if number >= 10^9 then
        return string.format("%.1fb", number / 10^9)
    elseif number >= 10^6 then
        return string.format("%.1fm", number / 10^6)
    elseif number >= 10^3 then
        return string.format("%.1fk", number / 10^3)
    else
        return tostring(number)
    end
end

-- function to create turtle instructions
local function createInstructions(length, width, height, widthDirection, heightDirection)
    -- table to store turtle instructions
    local instructions = {}

    -- create instructions for dimensions with height greater than or equal to 3
    if height > 2 then
        local fullLayers = math.floor(height / 3)
        local finalLayerHeight = height - fullLayers * 3

        for x = 1, fullLayers, 1 do -- vertical layers
            for y = 1, width, 1 do -- layer columns
                for z = 1, length, 1 do -- layer rows
                    -- instructions for last row of length
                    if z == length then
                        table.insert(instructions, "dig_up")
                        table.insert(instructions, "dig_down")
                    else
                        -- add instructions for length row
                        table.insert(instructions, "dig_up")
                        table.insert(instructions, "dig_down")
                        table.insert(instructions, "dig")
                        table.insert(instructions, "forward")
                    end
                end

                -- instructions for changing layers
                if y == width then
                    -- instructions for changing to last layer
                    if x == fullLayers and finalLayerHeight > 0 then
                        for i = 1, 2 do
                            table.insert(instructions, "dig_up")
                            table.insert(instructions, "up")
                        end

                        -- turn turtle to face towards where it needs to mine
                        table.insert(instructions, "left")
                        table.insert(instructions, "left")

                    -- transition to next layer
                    elseif x < fullLayers then
                        -- instructions for transitioning to next layer
                        table.insert(instructions, string.lower(heightDirection))
                        table.insert(instructions, "dig_" .. string.lower(heightDirection))
                        table.insert(instructions, string.lower(heightDirection))
                        table.insert(instructions, "dig_" .. string.lower(heightDirection))
                        table.insert(instructions, string.lower(heightDirection))
                        table.insert(instructions, "left")
                        table.insert(instructions, "left")
                    end

                else -- instructions for changing to next coloum
                    -- instructions for turning left
                    if (
                        (width % 2 ~= 0 and (widthDirection == "Left" and y % 2 ~= 0 or widthDirection == "Right" and y % 2 == 0))
                        or
                        (width % 2 == 0 and x % 2 == 0 and (widthDirection == "Left" and y % 2 == 0 or widthDirection == "Right" and y % 2 ~= 0))
                        or
                        (width % 2 == 0 and x % 2 ~= 0 and (widthDirection == "Left" and y % 2 ~= 0 or widthDirection == "Right" and y % 2 == 0))
                    ) then
                        table.insert(instructions, "left")
                        table.insert(instructions, "dig")
                        table.insert(instructions, "forward")
                        table.insert(instructions, "left")

                    -- instructions for turning right
                    else
                        table.insert(instructions, "right")
                        table.insert(instructions, "dig")
                        table.insert(instructions, "forward")
                        table.insert(instructions, "right")
                    end
                end
            end
        end

        -- create instructions for last layer
        if finalLayerHeight ~= 0 then
            for x = 1, width, 1 do
                for y = 1, length, 1 do
                    if y == length and finalLayerHeight > 1 then
                        table.insert(instructions, "dig_up")
                    end

                    if y < length then
                        table.insert(instructions, "dig")

                        -- only dig up if last layer is 2 blocks tall
                        if finalLayerHeight == 2 then
                            table.insert(instructions, "dig_up")
                        end

                        table.insert(instructions, "forward")
                    end
                end

                -- instructions for changing columns
                if x < width then
                    if (
                        (width % 2 ~= 0 and (widthDirection == "Left" and x % 2 ~= 0 or widthDirection == "Right" and x % 2 == 0))
                        or
                        (width % 2 == 0 and (widthDirection == "Left" and x % 2 == 0 or widthDirection == "Right" and x % 2 ~= 0))
                    ) then
                        table.insert(instructions, "left")
                        table.insert(instructions, "dig")
                        table.insert(instructions, "forward")
                        table.insert(instructions, "left")

                    else
                        table.insert(instructions, "right")
                        table.insert(instructions, "dig")
                        table.insert(instructions, "forward")
                        table.insert(instructions, "right")
                    end
                end
            end
        end

    -- create instructions for dimensions with height of less than 2
    else
        for x = 1, width, 1 do
            for y = 1, length, 1 do
                if y == length and height > 1 then
                    table.insert(instructions, "dig_up")
                end

                if y < length then
                    table.insert(instructions, "dig")

                    -- only dig up if last layer is 2 blocks tall
                    if height == 2 then
                        table.insert(instructions, "dig_up")
                    end

                    table.insert(instructions, "forward")
                end
            end

            -- instructions for changing columns
            if x < width then
                if (widthDirection == "Left" and x % 2 ~= 0 or widthDirection == "Right" and x % 2 == 0) then
                    table.insert(instructions, "left")
                    table.insert(instructions, "dig")
                    table.insert(instructions, "forward")
                    table.insert(instructions, "left")

                elseif widthDirection == "Left" and x % 2 == 0 or widthDirection == "Right" and x % 2 ~= 0 then
                    table.insert(instructions, "right")
                    table.insert(instructions, "dig")
                    table.insert(instructions, "forward")
                    table.insert(instructions, "right")
                end
            end
        end
    end

    return instructions
end

-- function to safely copy table contents
local function copyTable(tableToCopy)
    local coppiedTable = {}

    for key, value in ipairs(tableToCopy) do
        coppiedTable[key] = value
    end

    return coppiedTable
end

-- function to execute given turtle instructions
local function mineVolume(instructionsTable)
    -- table of turtle actions
    local actions = {
        ["up"] = turtle.up,
        ["down"] = turtle.down,
        ["forward"] = turtle.forward,
        ["back"] = turtle.back,
        ["left"] = turtle.turnLeft,
        ["right"] = turtle.turnRight,
        ["dig_up"] = turtle.digUp,
        ["dig_down"] = turtle.digDown,
        ["dig"] = turtle.dig,
        ["dig_up_detect"] = turtle.detectUp,
        ["dig_down_detect"] = turtle.detectDown,
        ["dig_detect"] = turtle.detect
    }

    basalt.log("From mineVolume: " .. textutils.serialise(instructionsTable), "LOG")

    -- copy of instructionsTable for use in updating unstructions save file
    local instructionsToSave = copyTable(instructionsTable)

    -- complete all commands in instructions table
    for index, command in ipairs(instructionsTable) do
        basalt.log("Executing command: " .. command .. ". At index: " .. index)

        -- if current command is a dig command, execute dig until there are no block to dig
        if string.find(command, "dig") then
            while actions[command .. "_detect"]() do
                actions[command]()
            end

        else
            actions[command]()
        end

        basalt.log("Command succeeded.")

        table.remove(instructionsToSave, 1)

        -- update instructions save file
        local writer = fs.open(CWD .. "/instructions.txt", "w")
        writer.write(textutils.serialise(instructionsToSave))
        writer.close()

        -- yeild to main loop
        os.sleep()
    end
end

local function main()
    local root = basalt.createFrame()

    -- nil check root
    if not root then
        return
    end

    local mineThread = root:addThread()

    -- get fuel levels
    local fuelLevel = turtle.getFuelLevel()
    local maxFuel = turtle.getFuelLimit()
    local fuelCost = 0

    -- length input widgets
    local lengthInputLabel = root:addLabel():setText("Length:"):setPosition(2, 1)
    local lengthInput = root:addInput():setInputType("number"):setPosition(9, 1)

    -- width input widgets
    local widthInputLabel = root:addLabel():setText("Width:"):setPosition(2, 3)
    local widthInput = root:addInput():setInputType("number"):setPosition(9, 3)

    -- width direction dropdown widgets
    local widthDirectionLabel = root:addLabel():setText("Left/Right:"):setPosition(20, 3)
    local widthDirectionDropdown = root:addDropdown():addItem("Left"):addItem("Right"):setSize(8, 1):setDropdownSize(7, 3):setZIndex(4):setPosition(31, 3)

    -- height input widgets
    local heightInputLabel = root:addLabel():setText("Height:"):setPosition(2, 5)
    local heightInput = root:addInput():setInputType("number"):setPosition(9, 5)
    -- height direction dropdown widgets
    local heightDirectionLabel = root:addLabel():setText("Up/Down:"):setPosition(20, 5)
    local heightDirectionDropdown = root:addDropdown():addItem("Up"):addItem("Down"):setSize(8, 1):setDropdownSize(7, 2):setZIndex(3):setPosition(31, 5)

    -- fuel indicator widgets
    local fuelLevelLabel = root:addLabel():setText("Fuel:"):setPosition(20, 7)
    local fuelAmountLabel = root:addLabel():setText(shortenNumber(fuelLevel) .. "/" .. shortenNumber(maxFuel)):setZIndex(2):setPosition(25, 7)
    local fuelLevelBar = root:addProgressbar():setDirection("right"):setProgressBar(colors.green):setSize(14, 1):setProgress(math.ceil(fuelLevel / maxFuel * 100)):setZIndex(1):setPosition(25, 7)
    -- need fuel widgets
    local neededFuelLabel = root:addLabel():setText("Need:"):setPosition(20, 9)
    local neededFuelProgressBar = root:addProgressbar():setDirection("right"):setProgressBar(colors.green):setSize(14, 1):setZIndex(1):setPosition(25, 9)
    local neededFuelAmountLabel = root:addLabel():setText("0"):setZIndex(2):setPosition(25, 9)

    -- widgets for refueling
    local refuelingLabel = root:addLabel():setText(tostring(turtle.getItemCount(turtle.getSelectedSlot))):setPosition(27, 11)
    local refuelSlider = root:addSlider():setIndex(1):setSize(10, 1):setPosition(29, 11):onChange(function (self, event, value)
        refuelingLabel:setText(tostring(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * self:getIndex())))
    end)
    local refuelButton = root:addButton():setText("Refuel"):setSize(6, 1):setPosition(20, 11)

    -- button to cancel mining
    local cancelMiningButton = root:addButton():setText("Cancel"):setBackground(colors.red):hide():setPosition(4, 8):onClick(function (self, event, button, x, y)
        if(event=="mouse_click")and(button==1)then
            self:setBackground(colors.lightGray)
            mineThread:stop()

            -- delete instructions save file if one was made
            if fs.exists(CWD .. "/instructions.txt") then
                fs.delete(CWD .. "/instructions.txt")
            end

            -- update fuel level variable
            fuelLevel = turtle.getFuelLevel()

            -- update fuel level bar
            fuelLevelBar:setProgress(math.ceil(fuelLevel / maxFuel * 100))

            -- update refuel amount label
            refuelingLabel:setText(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * refuelSlider:getIndex()))

            -- update current fuel level label
            fuelAmountLabel:setText(shortenNumber(fuelLevel) .. "/" .. shortenNumber(maxFuel))
        end
    end):onRelease(function (self, event, button, x, y)
        self:setBackground(colors.red)
        self:hide()
    end)

    -- button to start mining
    local startBtn = root:addButton():setText("Start!"):setBackground(colors.lime):hide():setPosition(4, 8):onClick(function (self, event, button, x, y)
        if(event=="mouse_click")and(button==1)then
            -- change button color to green
            self:setBackground(colors.green)

            -- default values of mining directions
            local widthDirection = "Left"
            local heightDirection = "Up"

            -- if mining direction was set use it
            if widthDirectionDropdown:getValue() then
                widthDirection = widthDirectionDropdown:getValue()["text"]
            end
            if heightDirectionDropdown:getValue() then
                heightDirection = heightDirectionDropdown:getValue()["text"]
            end

            -- create turtle instructions
            local instructions = createInstructions(math.floor(lengthInput:getValue()), math.floor(widthInput:getValue()), math.floor(heightInput:getValue()), widthDirection, heightDirection)

            -- create instructions save file
            local writer = fs.open(CWD .. "/instructions.txt", "w")
            writer.write(textutils.serialise(instructions))
            writer.close()

            basalt.log("instructions saved to " .. CWD .. "/instructions.txt", "LOG")

            -- log instructions table
            -- basalt.log(textutils.serialise(instructions), "LOG")

            -- start the mining thread
            mineThread:start(function ()
                -- execute instructions
                mineVolume(instructions)

                -- delete instructions save file
                fs.delete(CWD .. "/instructions.txt")

                -- remove cancel button after mining is done
                cancelMiningButton:hide()

                -- update fuel level variable
                fuelLevel = turtle.getFuelLevel()

                -- update fuel level bar
                fuelLevelBar:setProgress(math.ceil(fuelLevel / maxFuel * 100))

                -- update refuel amount label
                refuelingLabel:setText(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * refuelSlider:getIndex()))

                -- update current fuel level label
                fuelAmountLabel:setText(shortenNumber(fuelLevel) .. "/" .. shortenNumber(maxFuel))
            end)

            -- clear all inputs
            lengthInput:setValue("")
            widthInput:setValue("")
            heightInput:setValue("")
            widthDirectionDropdown:setValue("")
            heightDirectionDropdown:setValue("")

            -- show cancel button
            cancelMiningButton:show()
        end
    end):onRelease(function (self)
        self:setBackground(colors.lime)
    end)

    -- function to update needed fuel bar on mine dimension change
    local function displayNeededFuel()
        -- get dimensions from inputs
        local length = lengthInput:getValue()
        local width = widthInput:getValue()
        local height = heightInput:getValue()

        -- nil check dimensions
        if length ~= "" and length > 0 and width ~= "" and width > 0 and height ~= "" and height > 0 then
            -- calculate needed fuel
            fuelCost = length * width * math.ceil(height / 3) + math.ceil(height / 3) * 3

            -- if needed fuel is greater than max fuel set needed fuel bar to red
            if fuelCost > maxFuel then
                neededFuelProgressBar:setProgressBar(colors.red)
                neededFuelProgressBar:setProgress(100)
            else
                neededFuelProgressBar:setProgressBar(colors.green)
                neededFuelProgressBar:setProgress(math.ceil(fuelCost / maxFuel * 100))
            end

            neededFuelAmountLabel:setText(shortenNumber(fuelCost))
        else
            neededFuelAmountLabel:setText("0")
        end
    end

    -- function to check inputs
    local function onDimentionChange()
        -- display needed fuel level if all dimension inputs have data
        displayNeededFuel()

        local hasVerticalDirection = false

        -- determine if user given dimensions need mining directions
        if (
            (
                (
                    heightDirectionDropdown:getValue() == nil
                    and
                    heightInput:getValue() ~= "" and heightInput:getValue() < 4
                )
                or
                (heightDirectionDropdown:getValue())
            )
            and
            (
                (
                    widthDirectionDropdown:getValue() == nil
                    and
                    widthInput:getValue() ~= "" and widthInput:getValue() < 2
                )
                or
                (widthDirectionDropdown:getValue())
            )
        ) then
            hasVerticalDirection = true
        end

        if (
            lengthInput:getValue() ~= "" and lengthInput:getValue() > 1
            and
            widthInput:getValue() ~= "" and widthInput:getValue() > 0
            and
            heightInput:getValue() ~= "" and heightInput:getValue() > 0
            and
            hasVerticalDirection
            and
            fuelLevel >= fuelCost
        ) then
            startBtn:show()
        else
            startBtn:hide()
        end
    end

    lengthInput:onChar(function (_, _, char)
        -- filter out any input that isn't a number
        if not (tonumber(char)) then
            return false

        else
            -- update ui elements
            onDimentionChange()
            return true
        end
    end)
    widthInput:onChar(function (_, _, char)
        -- filter out any input that isn't a number
        if not (tonumber(char)) then
            return false

        else
            -- update ui elements
            onDimentionChange()
            return true
        end
    end)
    heightInput:onChar(function (_, _, char)
        -- filter out any input that isn't a number
        if not (tonumber(char)) then
            return false

        else
            -- update ui elements
            onDimentionChange()
            return true
        end
    end)
    lengthInput:onChange(onDimentionChange)
    widthInput:onChange(onDimentionChange)
    heightInput:onChange(onDimentionChange)
    widthDirectionDropdown:onChange(onDimentionChange)
    heightDirectionDropdown:onChange(onDimentionChange)
    refuelButton:onClick(function (self, event, button, x, y)
        if(event=="mouse_click")and(button==1)then
            -- change colors of button to indicate a click
            self:setBackground(colors.black)
            self:setForeground(colors.white)

            -- refuel turtle based on slider position
            turtle.refuel(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * refuelSlider:getIndex()))

            -- update fuel level variable
            fuelLevel = turtle.getFuelLevel()

            -- update fuel level bar
            fuelLevelBar:setProgress(math.ceil(fuelLevel / maxFuel * 100))

            -- update refuel amount label
            refuelingLabel:setText(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * refuelSlider:getIndex()))

            -- update current fuel level label
            fuelAmountLabel:setText(shortenNumber(fuelLevel) .. "/" .. shortenNumber(maxFuel))
            end

            onDimentionChange()
    end):onRelease(function (self)
        -- set button to default colors
        self:setBackground(colors.gray)
        self:setForeground(colors.black)
    end)

    -- resume mining if instructions save file exists
    if fs.exists(CWD .. "/instructions.txt") then
        -- get instructions from file
        local reader = fs.open(CWD .. "/instructions.txt", "r")
        local mineInstructions = textutils.unserialise(reader.readAll())

        -- start mining thread
        mineThread:start(function ()
            mineVolume(mineInstructions)

            -- delete instructions save file
            fs.delete(CWD .. "/instructions.txt")

            -- update fuel level variable
            fuelLevel = turtle.getFuelLevel()

            -- update fuel level bar
            fuelLevelBar:setProgress(math.ceil(fuelLevel / maxFuel * 100))

            -- update refuel amount label
            refuelingLabel:setText(math.ceil(turtle.getItemCount(turtle.getSelectedSlot) / 10 * refuelSlider:getIndex()))

            -- update current fuel level label
            fuelAmountLabel:setText(shortenNumber(fuelLevel) .. "/" .. shortenNumber(maxFuel))
        end)
    end

    basalt.autoUpdate()
end

main()