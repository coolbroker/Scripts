----------------------------make sure that weapon in your hand
-----by coolbroker with love. Join discord server: https://discord.gg/Q3BCvcmZfM
----------------------------

if not getgenv().coolbroker then
    getgenv().coolbroker = {}
end

if getgenv().coolbroker then
    getgenv().coolbroker.working = true
    getgenv().coolbroker.targetSelectedBrainrots = true
    getgenv().coolbroker.selectedBrainrotsProperties = {
        ["rarity"] = {
            ["Rare"] = true,
            ["Legendary"] = false,
            ["Godly"] = false,
            ["Limited"] = false,
            ["Epic"] = false,
            ["Mythic"] = false,
            ["Secret"] = false
        },
        ["mutations"] = {
            ["Neon"] = false,
            ["Magma"] = false,
            ["Gold"] = false,
            ["Diamond"] = false,
            ["Rainbow"] = false,
            ["Ruby"] = false,
            ["Underworld"] = false,
            ["Galactic"] = false,
            ["UpsideDown"] = false,
            ["Frozen"] = false
        }
    }
end
-------------------------------
Players = game:GetService("Players")

local playerUtil = {}

function playerUtil.getPlayer():Player
    return Players.LocalPlayer
end

function playerUtil.getPlayerUsername()
    local player = playerUtil.getPlayer()

    return player.Name
end

function playerUtil.getRootPart():Part
    local player = playerUtil.getPlayer()

    return player.Character.HumanoidRootPart
end

function playerUtil.getPlayerPlot()
    local playerName = playerUtil.getPlayer().Name

    local playerPlot = nil

    for plot in workspace.Plots:GetChildren() do
        local hitbox = workspace.Plots[plot]
        local hitboxOwnerUsername = hitbox:GetAttribute("Owner")
        local playerUsername = playerUtil.getPlayerUsername()
        if hitboxOwnerUsername == playerUsername then
            playerPlot = workspace.Plots[plot]
            break
        end
    end

    return playerPlot.Name
end
-------------------------------
local configUtil = {}

function configUtil.hasSelectedMutations(selectedBrainrotsProperties)
    local hasSelectedMutations = false

    for mutation, enabled in selectedBrainrotsProperties["mutations"] do
        if enabled then
            hasSelectedMutations = true
            break
        end
    end

    return hasSelectedMutations
end

function configUtil.hasSelectedRarity(selectedBrainrotsProperties)
    local hasSelectedRarity = false

    for rarity, enabled in selectedBrainrotsProperties["rarity"] do
        if enabled then
            hasSelectedRarity = true
            break
        end
    end

    return hasSelectedRarity
end
-------------------------------
local brainrotUtil = {}

function brainrotUtil.getRarity(brainrot)
    if not brainrot then return end

    return brainrot:GetAttribute("Rarity")
end

function brainrotUtil.getMutation(brainrot)
    if not brainrot then return end

    return brainrot:GetAttribute("Mutation")
end

function brainrotUtil.getPlot(brainrot)
    if not brainrot then return end

    return brainrot:GetAttribute("Plot")
end

function brainrotUtil.isAssociatedWithLocalPlayer(brainrot)
    local playerPlot = playerUtil.getPlayerPlot()
    local brainrotPlot = brainrotUtil.getPlot(brainrot)

    return playerPlot == brainrotPlot
end

function brainrotUtil.getByProperties(selectedBrainrotsProperties:table)
    local hasSelectedMutations = configUtil.hasSelectedMutations(selectedBrainrotsProperties)
    local hasSelectedRarity = configUtil.hasSelectedRarity(selectedBrainrotsProperties)

    for _, brainrot in workspace.ScriptedMap.MissionBrainrots:GetChildren() do
        if brainrotUtil.isAssociatedWithLocalPlayer(brainrot) then
            local brainrotRarity = brainrotUtil.getRarity(brainrot)
            local brainrotMutation = brainrotUtil.getMutation(brainrot)

            if hasSelectedMutations and not brainrotMutation then return end

            local isAppropriatesRarity = false
            local isAppropriatesMutation = false

            if hasSelectedRarity then
                for rarity, enabled in selectedBrainrotsProperties["rarity"] do
                    if enabled then
                        if brainrotRarity == rarity then
                            isAppropriatesRarity = true
                            break
                        end
                    end
                end
            else
                isAppropriatesRarity = true
            end

            if hasSelectedMutations then
                for mutation, enabled in selectedBrainrotsProperties["mutations"] do
                    if enabled then
                        if brainrotMutation == mutation then
                            isAppropriatesMutation = true
                            break
                        end
                    end 
                end
            else
                isAppropriatesMutation = true
            end

            if isAppropriatesRarity and isAppropriatesMutation then
                return brainrot
            end
        end
    end
end

-------------------------------
local teleportUtil = {}

function teleportUtil.teleportPlayer(newPosition)
    playerUtil.getRootPart().CFrame = newPosition
end

function teleportUtil.teleportToBrainrot(brainrotPosition, offset: Vector3)
    offset = offset or Vector3.new(0, 0, 0)

    local newPosition = brainrotPosition * CFrame.new(offset)

    teleportUtil.teleportPlayer(newPosition)
end
-------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local attackUtil = {}

function attackUtil.attackBrainrot(brainrot)
    local args = {
        {
            NormalBrainrots = {},
            MissionBrainrots = {
                brainrot:GetAttribute("ID")
            }
        }
    }

    Remotes.AttacksServer.WeaponAttack:FireServer(unpack(args))
end
-------------------------------
config = getgenv().coolbroker

function targetSelectedBrainrots()
    local brainrot = brainrotUtil.getByProperties(config.selectedBrainrotsProperties)
    local teleportPoint = nil
    
    if not brainrot then return end

    for _, part in brainrot:GetChildren() do
        if part:IsA("Part") then
            teleportPoint = part
        end
    end

    while workspace.ScriptedMap.MissionBrainrots[brainrot.Name]:GetAttribute("ID") == brainrot:GetAttribute("ID") do
        teleportUtil.teleportToBrainrot(teleportPoint.CFrame, Vector3.new(0, 0, 0))
        attackUtil.attackBrainrot(brainrot)
        
        task.wait()
        
        if not workspace.ScriptedMap.MissionBrainrots:FindFirstChild(brainrot.Name) then
            break
        end
    end
end

while config.working do
    while config.targetSelectedBrainrots do
        targetSelectedBrainrots()

        task.wait()
    end

end

----------------------------make sure that weapon in your hand
-----by coolbroker with love. Join discord server: https://discord.gg/Q3BCvcmZfM
----------------------------
