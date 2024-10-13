local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "The Strongest Battleground",
    SubTitle = "by zenzoninisback",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    AutoParry = Window:AddTab({ Title = "Combat", Icon = "shield" }),
    CounterAlert = Window:AddTab({ Title = "Counter Alert", Icon = "alert-circle" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local alreadyNotified = false -- ตัวแปรเพื่อตรวจสอบว่าแจ้งเตือนไปแล้วหรือยัง
local counterCooldown = false -- ตัวแปรสำหรับตรวจสอบคูลดาวน์ของ Counter

-- Function to Notify Counter Detected
local function notifyCounterDetected(targetPlayer)
    if not Options.CounterNotify.Value then return end
    if alreadyNotified then return end -- ถ้าแจ้งเตือนไปแล้ว ให้หยุด

    alreadyNotified = true -- แจ้งเตือนครั้งเดียว
    game.StarterGui:SetCore("SendNotification", {
        Title = "Warning!",
        Text = targetPlayer.Name .. " is using Counter!",
        Duration = 5,
        Button1 = "Dismiss"
    })
end

-- Function to Rotate towards the target
local function faceTarget(targetPlayer)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local targetHumanoidRootPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and targetHumanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetHumanoidRootPart.Position)
    end
end

-- Function to Auto Counter for Hero Hunter
local function autoCounterHeroHunter()
    if counterCooldown then return end -- ถ้ากำลังอยู่ในคูลดาวน์ ให้หยุดทำงาน
    local player = game.Players.LocalPlayer
    local character = player.Character
    local tool = player:FindFirstChild("Prey's Peril") or player.Backpack:FindFirstChild("Prey's Peril")

    if tool then
        local args = {
            [1] = {
                ["Tool"] = tool,
                ["Goal"] = "Console Move",
                ["ToolName"] = "Prey's Peril"
            }
        }

        character.Communicate:FireServer(unpack(args))
        counterCooldown = true
        wait() -- ตั้งคูลดาวน์ 5 วินาที (ปรับได้ตามต้องการ)
        counterCooldown = false
    else
        warn("Tool 'Prey's Peril' not found!")
    end
end

-- Function to Auto Counter for Blade Master
local function autoCounterBladeMaster()
    if counterCooldown then return end -- ถ้ากำลังอยู่ในคูลดาวน์ ให้หยุดทำงาน
    local player = game.Players.LocalPlayer
    local character = player.Character
    local tool = player:FindFirstChild("Split Second Counter") or player.Backpack:FindFirstChild("Split Second Counter")

    if tool then
        local args = {
            [1] = {
                ["Tool"] = tool,
                ["Goal"] = "Console Move",
                ["ToolName"] = "Split Second Counter"
            }
        }

        character.Communicate:FireServer(unpack(args))
        counterCooldown = true
        wait() -- ตั้งคูลดาวน์ 5 วินาที (ปรับได้ตามต้องการ)
        counterCooldown = false
    else
        warn("Tool 'Split Second Counter' not found!")
    end
end

-- Function to Dodge Block when HunterFists is detected
local function dodgeBlock(targetPlayer)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    -- ตรวจสอบว่าผู้เล่นมีตัวละครและ Humanoid ก่อนดำเนินการ
    if not character or not humanoid or humanoid.Health <= 0 then return end -- หยุดทำงานเมื่อผู้เล่นตายหรือไม่มีตัวละคร

    local targetCharacter = targetPlayer.Character
    local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local distance = (humanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude

        if distance <= Options.DodgeBlockDistance.Value and targetCharacter:FindFirstChild("HunterFists") then
            -- ทำการบล็อคเมื่อเจอ HunterFists
            local args = {
                [1] = {
                    ["Goal"] = "KeyPress",
                    ["Key"] = Enum.KeyCode.F
                }
            }
            game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))
            wait(Options.DodgeBlockCooldown.Value) -- รอคูลดาวน์ที่กำหนด

            -- ปล่อยบล็อค
            local argsRelease = {
                [1] = {
                    ["Goal"] = "KeyRelease",
                    ["Key"] = Enum.KeyCode.F
                }
            }
            game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(argsRelease))
        end
    end
end

-- Function to Check for M1ing and Auto Block
local function checkPlayersForM1ing()
    if not Options.AutoParry.Value then return end
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    -- ตรวจสอบว่าผู้เล่นมีตัวละครและ Humanoid ก่อนดำเนินการ
    if not character or not humanoid or humanoid.Health <= 0 then return end -- หยุดทำงานเมื่อผู้เล่นตายหรือไม่มีตัวละคร

    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetCharacter = targetPlayer.Character
            local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                
                if distance <= Options.Distance.Value and targetCharacter:FindFirstChild("M1ing") then
                    print("block now")

                    -- หันหน้าใส่ศัตรูเมื่อทำการบล็อค
                    if Options.FaceTargetBlock.Value then
                        faceTarget(targetPlayer)
                    end

                    -- หันหน้าใส่ศัตรูเมื่อศัตรูใช้ M1
                    if Options.FaceTargetM1.Value then
                        faceTarget(targetPlayer)
                    end

                    -- ถ้าเปิด Auto Counter จะทำงานก่อน Auto Block
                    if Options.AutoCounter.Value then
                        -- ตรวจสอบว่าเป็น Hero Hunter หรือ Blade Master
                        if player:FindFirstChild("Prey's Peril") or player.Backpack:FindFirstChild("Prey's Peril") then
                            autoCounterHeroHunter()
                        elseif player:FindFirstChild("Split Second Counter") or player.Backpack:FindFirstChild("Split Second Counter") then
                            autoCounterBladeMaster()
                        end
                    end

                    -- Auto Parry logic to block ถ้า Counter ไม่สำเร็จหรืออยู่ในคูลดาวน์
                    if not counterCooldown then
                        local args = {
                            [1] = {
                                ["Goal"] = "KeyPress",
                                ["Key"] = Enum.KeyCode.F
                            }
                        }
                        game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))
                        wait(Options.Cooldown.Value)
                        
                        -- Auto Parry logic to release block
                        local argsRelease = {
                            [1] = {
                                ["Goal"] = "KeyRelease",
                                ["Key"] = Enum.KeyCode.F
                            }
                        }
                        game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(argsRelease))
                    end
                end

                -- ตรวจจับ HunterFists เพื่อทำ Dodge Block
                if Options.DodgeBlockEnabled.Value then
                    dodgeBlock(targetPlayer)
                end
            end
        end
    end
end

-- Function to check Counter for all players
local function checkPlayersForCounter()
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer.Character then
            local counter = targetPlayer.Character:FindFirstChild("Counter")
            if counter then
                notifyCounterDetected(targetPlayer)
            else
                alreadyNotified = false -- รีเซ็ตเมื่อ Counter หายไป
            end
        end
    end
end

-- Auto Parry Section
local AutoParrySection = Tabs.AutoParry:AddSection("Auto Parry Settings")
AutoParrySection:AddToggle("AutoParry", {
    Title = "Enable Auto Parry",
    Default = false
}):OnChanged(function()
    print("Auto Parry changed:", Options.AutoParry.Value)
end)

AutoParrySection:AddSlider("Distance", {
    Title = "Auto Parry Distance",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        print("Distance changed:", Value)
    end
}):SetValue(10)

AutoParrySection:AddSlider("Cooldown", {
    Title = "Cooldown after Block",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Cooldown changed:", Value)
    end
}):SetValue(0.5)

-- Face Target Section
local FaceTargetSection = Tabs.AutoParry:AddSection("Face Target Settings")
FaceTargetSection:AddToggle("FaceTargetBlock", {
    Title = "Face Target while Blocking",
    Default = false
}):OnChanged(function()
    print("Face Target while Blocking changed:", Options.FaceTargetBlock.Value)
end)

FaceTargetSection:AddToggle("FaceTargetM1", {
    Title = "Face Target when Enemy uses M1",
    Default = false
}):OnChanged(function()
    print("Face Target when Enemy uses M1 changed:", Options.FaceTargetM1.Value)
end)

-- Auto Counter Section
local AutoCounterSection = Tabs.AutoParry:AddSection("Auto Counter (Supports Hero Hunter & Blade Master)")
AutoCounterSection:AddToggle("AutoCounter", {
    Title = "Enable Auto Counter",
    Default = false
}):OnChanged(function()
    print("Auto Counter changed:", Options.AutoCounter.Value)
end)

AutoCounterSection:AddSlider("CounterDistance", {
    Title = "Auto Counter Distance",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        print("Counter Distance changed:", Value)
    end
}):SetValue(10)

-- Dodge Block Section
local DodgeBlockSection = Tabs.AutoParry:AddSection("Dodge Block Settings")
DodgeBlockSection:AddToggle("DodgeBlockEnabled", {
    Title = "Enable Dodge Block",
    Default = false
}):OnChanged(function()
    print("Dodge Block changed:", Options.DodgeBlockEnabled.Value)
end)

DodgeBlockSection:AddSlider("DodgeBlockDistance", {
    Title = "Dodge Block Distance",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        print("Dodge Block Distance changed:", Value)
    end
}):SetValue(10)

DodgeBlockSection:AddSlider("DodgeBlockCooldown", {
    Title = "Dodge Block Cooldown",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        print("Dodge Block Cooldown changed:", Value)
    end
}):SetValue(0.5)

-- Counter Alert Section
local CounterAlertSection = Tabs.CounterAlert:AddSection("Counter Alert Settings")
CounterAlertSection:AddToggle("CounterNotify", {
    Title = "Enable Counter Notification",
    Default = false
}):OnChanged(function()
    print("Counter Notification changed:", Options.CounterNotify.Value)
end)

-- Running Auto Parry and Counter Check in Loop
task.spawn(function()
    while true do
        checkPlayersForM1ing()
        checkPlayersForCounter()
        wait()
    end
end)

-- Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Thank you for using",
    Content = "https://discord.gg/uz7YbqZRY4",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
