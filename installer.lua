-- ask user if program should overwrite existing folder
if fs.exists("/SmartMine/") then
    local response = ""
    while response ~= "n" and response ~= "y" do
        io.write('\nFolder "SmartMine" already exists. Overwrite?(y/n):')
        response = io.read()
    end

    if response == "n" then
        print("Stopping installation.")
        return
    end
end

-- ask user if program should overwrite existing shortcut file
if fs.exists("/smartMine.lua") then
    local response = ""
    while response ~= "n" and response ~= "y" do
        io.write('\nShortcut file "smartMine.lua" already exists. Overwrite?(y/n):')
        response = io.read()
    end

    if response == "n" then
        print("Stopping installation.")
        return
    end
end

-- ask user if program should overwrite existing startup file
if fs.exists("/startup/smartMineAutoResume.lua") then
    local response = ""
    while response ~= "n" and response ~= "y" do
        io.write('\nStartup file "smartMineAutoResume.lua" already exists in startup. Overwrite?(y/n):')
        response = io.read()
    end

    if response == "n" then
        print("Stopping installation.")
        return
    end
end

-- make startup folder if one does not exist
if not fs.exists("/startup") then
    fs.makeDir("/startup/")
end

-- make program folder if one does not exist
if not fs.exists("/SmartMine/") then
    fs.makeDir("/SmartMine/")
end

-- delete main file if one already exists
if fs.exists("/SmartMine/main.lua") then
    fs.delete("/SmartMine/main.lua")
end

-- delete basalt file if one already exists
if fs.exists("/SmartMine/basalt.lua") then
    fs.delete("/SmartMine/basalt.lua")
end

-- delete startup file if one already exists
if fs.exists("/startup/smartMineAutoResume.lua") then
    fs.delete("/startup/smartMineAutoResume.lua")
end

-- delete shortcut file if one already exists
if fs.exists("/smartMine.lua") then
    fs.delete("/smartMine.lua")
end

-- download main file to program folder
shell.run("wget https://github.com/SalmonJarl87100/ComputerCraft-Turtle-GUI-Miner/raw/main/main.lua /SmartMine/main.lua")

-- download basalt file to program folder
shell.run("wget https://github.com/SalmonJarl87100/ComputerCraft-Turtle-GUI-Miner/raw/main/basalt.lua /SmartMine/basalt.lua")

-- download shortcut file
shell.run("wget https://github.com/SalmonJarl87100/ComputerCraft-Turtle-GUI-Miner/raw/main/smartMine.lua /smartMine.lua")

-- download startup file
shell.run("wget https://github.com/SalmonJarl87100/ComputerCraft-Turtle-GUI-Miner/raw/main/smartMineAutoResume.lua /startup/smartMineAutoResume.lua")
