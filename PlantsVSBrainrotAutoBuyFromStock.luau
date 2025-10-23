if not getgenv().coolbroker then
    getgenv().coolbroker = {}
end

if getgenv().coolbroker then
    getgenv().coolbroker.working = true
    getgenv().coolbroker.buySelectedSeeds = true
    getgenv().coolbroker.selectedSeeds = {
        ["Cactus Seed"] = true,
        ["Strawberry Seed"] = true,
        ["Pumpkin Seed"] = true,
        ["Sunflower Seed"] = true,
        ["Dragon Fruit Seed"] = true,
        ["Eggplant Seed"] = true,
        ["Watermelon Seed"] = true,
        ["Grape Seed"] = true,
        ["Cocotank Seed"] = false,
        ["Carnivorous Plant Seed"] = false,
        ["Mr Carrot Seed"] = false,
        ["Tomatrio Seed"] = false,
        ["Shroombino Seed"] = false,
        ["Mango Seed"] = false,
        ["King Limone Seed"] = false
    }
end
--------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local modules = ReplicatedStorage.Modules
local seedRegistryModule = require(modules.Registries.SeedRegistry)
local remotes = ReplicatedStorage.Remotes

--------------------------------------------------------------------------
local playerUtil = {}

function playerUtil.getPlayer()
    return Players.LocalPlayer
end

function playerUtil.getBackpack()
    local player = playerUtil.getPlayer()

    return player.Backpack
end

function playerUtil.getSeedRestockTime()
    local player = playerUtil.getPlayer()

    return player:GetAttribute("NextSeedRestock")
end

function playerUtil.getBalance()
    local player = playerUtil.getPlayer()
    local leaderstats = player.leaderstats

    return leaderstats.Money.Value
end
--------------------------------------------------------------------------
local remoteUtil = {}

function remoteUtil.callCommand(rName: string, args: table) 
    local remote = remotes:FindFirstChild(rName)

    if remote then
        remote:FireServer(unpack(args))
    end
end
--------------------------------------------------------------------------
local seedRegistryUtil = {}

function seedRegistryUtil.isHidden(seedName: string)
    return seedRegistryModule[seedName].Hidden or false
end

function seedRegistryUtil.getPlant(seedName: string)
    return seedRegistryModule[seedName].Plant or ""
end

function seedRegistryUtil.getPrice(seedName: string)
    return seedRegistryModule[seedName].Price or 0
end

function seedRegistryUtil.getProductID(seedName: string)
    return seedRegistryModule[seedName].ProductID or 1
end
--------------------------------------------------------------------------
local seedUtil = {}

seedUtil.allSeeds = {
        ["Cactus Seed"] = 0,
        ["Strawberry Seed"] = 0,
        ["Pumpkin Seed"] = 0,
        ["Sunflower Seed"] = 0,
        ["Dragon Fruit Seed"] = 0,
        ["Eggplant Seed"] = 0,
        ["Watermelon Seed"] = 0,
        ["Grape Seed"] = 0,
        ["Cocotank Seed"] = 0,
        ["Carnivorous Plant Seed"] = 0,
        ["Mr Carrot Seed"] = 0,
        ["Tomatrio Seed"] = 0,
        ["Shroombino Seed"] = 0,
        ["Mango Seed"] = 0,
        ["King Limone Seed"] = 0,
}

function seedUtil.getSeedsFromStock()
    local seeds = {}

    for name in seedUtil.allSeeds do
        if playerUtil.getPlayer().PlayerGui.Main.Seeds.Frame.ScrollingFrame[name].Stock.ContentText ~= "x0 in stock" then
            seeds[name] = true;
        else 
            seeds[name] = false;
        end
    end

    return seeds
end

function seedUtil.isInStock(seedName)
    return seedUtil.getSeedsFromStock()[seedName]
end
--------------------------------------------------------------------------
function buyItem(name: string)
    local args = {
        name,
        true
    }

    remoteUtil.callCommand("BuyItem", args)
end

function buySelectedSeeds(selectedSeeds: table)
    for seed, enabled in selectedSeeds do
        if enabled then
            local playerBalance = playerUtil.getBalance()
            local seedPrice = seedRegistryUtil.getPrice(seed)

            if seedPrice <= playerBalance and seedUtil.isInStock(seed) then
                buyItem(seed)
                print("bought: ", seed)
            end
        end
    end
end
--------------------------------------------------------------------------
local config = getgenv().coolbroker

print("selected:")
for key, seed in config.selectedSeeds do
    if seed then
        print(key)
    end
end

while config.working do
    while config.buySelectedSeeds do
        buySelectedSeeds(config.selectedSeeds)
        task.wait(.2)
    end
    task.wait(.2)
end
