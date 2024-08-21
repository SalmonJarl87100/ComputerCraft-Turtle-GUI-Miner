-- change this to the path of the folder that contains the main script
local fileLocation = "/Programs/SmartMine"

if fs.exists(fileLocation .. "/instructions.txt") then
    shell.run("/smartMine.lua")
end