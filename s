-- GUI + TABS + HEADER
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- GUI BASE
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ZenClosetUI"
ScreenGui.ResetOnSpawn = false

-- MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 360)
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- HEADER LABEL
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZEN CLOSET CHEAT"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextStrokeTransparency = 0.8

-- TABS HOLDER
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.Padding = UDim.new(0, 6)

-- PAGES HOLDER
local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, 0, 1, -60)
Pages.Position = UDim2.new(0, 0, 0, 60)
Pages.BackgroundTransparency = 1

local Tabs = {}

local function createTabButton(name)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Size = UDim2.new(0, 80, 1, 0)
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = TabButtons
	return btn
end

local function createTabPage()
	local page = Instance.new("Frame", Pages)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
	return page
end

local function switchToTab(tabName)
	for name, tab in pairs(Tabs) do
		tab.Page.Visible = (name == tabName)
		tab.Button.BackgroundColor3 = (name == tabName) and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(45, 45, 45)
	end
end

for _, tabName in ipairs({ "Main", "Misc", "Settings" }) do
	local button = createTabButton(tabName)
	local page = createTabPage()
	Tabs[tabName] = { Button = button, Page = page }
	button.MouseButton1Click:Connect(function()
		switchToTab(tabName)
	end)
end
switchToTab("Main")

-- CAMLOCK SETTINGS
local camlockKey = Enum.KeyCode.Q
local lockPartName = "HumanoidRootPart"
local fov = 100
local prediction = 0.13
local smoothness = 0.05
local hitboxSize = Vector3.new(12, 12, 12)

local camlockOn = false
local camlockEnabled = false
local target = nil
local originalSize = {}

local function expandHitbox(char)
	if not char then return end
	local root = char:FindFirstChild(lockPartName)
	if not root then return end
	if not originalSize[char] then
		originalSize[char] = root.Size
	end
	root.Size = hitboxSize
	root.Transparency = 1
	root.CanCollide = false
	root.Material = Enum.Material.Plastic
end

local function resetHitbox(char)
	if not char then return end
	local root = char:FindFirstChild(lockPartName)
	if not root or not originalSize[char] then return end
	root.Size = originalSize[char]
	root.Transparency = 1
	root.CanCollide = false
	root.Material = Enum.Material.Plastic
	originalSize[char] = nil
end

local function getClosest()
	local closest = nil
	local shortestDist = fov
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild(lockPartName) then
			local part = plr.Character[lockPartName]
			local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(LP:GetMouse().X, LP:GetMouse().Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closest = plr
				end
			end
		end
	end
	return closest
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not camlockEnabled then return end
	if input.KeyCode == camlockKey then
		if camlockOn and target and target.Character then
			resetHitbox(target.Character)
		end
		camlockOn = not camlockOn
		target = camlockOn and getClosest() or nil
		if camlockOn and target and target.Character then
			expandHitbox(target.Character)
		end
	end
end)

local triggerKey = Enum.KeyCode.Z
local triggerEnabled = false
local hitboxExpanderEnabled = false

local function createChecklistToggle(name, callback, withKeybind)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 120, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local box = Instance.new("TextButton", container)
	box.Size = UDim2.new(0, 24, 0, 24)
	box.Position = UDim2.new(0, 135, 0.5, -12)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Text = ""
	box.AutoButtonColor = false
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local toggled = false
	box.MouseButton1Click:Connect(function()
		toggled = not toggled
		local colorGoal = toggled and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(50, 50, 50)
		TweenService:Create(box, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = colorGoal
		}):Play()
		if callback then callback(toggled) end
	end)

	if withKeybind then
		local keybind = Instance.new("TextButton", container)
		keybind.Size = UDim2.new(0, 50, 0, 24)
		keybind.Position = UDim2.new(0, 165, 0.5, -12)
		keybind.Text = name == "Camlock" and camlockKey.Name or triggerKey.Name
		keybind.TextColor3 = Color3.fromRGB(200, 200, 200)
		keybind.Font = Enum.Font.Gotham
		keybind.TextSize = 12
		keybind.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		keybind.BorderSizePixel = 0
		Instance.new("UICorner", keybind).CornerRadius = UDim.new(0, 4)

		local waitingForKey = false
		keybind.MouseButton1Click:Connect(function()
			keybind.Text = "..."
			waitingForKey = true
		end)

		UIS.InputBegan:Connect(function(input)
			if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
				if name == "Camlock" then
					camlockKey = input.KeyCode
				else
					triggerKey = input.KeyCode
				end
				keybind.Text = input.KeyCode.Name
				waitingForKey = false
			end
		end)
	end

	container.Parent = Tabs.Main.Page
end

-- UI Toggles
createChecklistToggle("Camlock", function(on)
	camlockEnabled = on
	if not on and target and target.Character then
		resetHitbox(target.Character)
		camlockOn = false
		target = nil
	end
end, true)

createChecklistToggle("Triggerbot", function(on)
	triggerEnabled = on
end, true)

createChecklistToggle("Hitbox Expander", function(on)
	hitboxExpanderEnabled = on
	if not on then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LP then
				resetHitbox(plr.Character)
			end
		end
	end
end)

-- Triggerbot logic
local function isDead(player)
	local character = player.Character
	if not character then return false end
	local bodyEffects = character:FindFirstChild("BodyEffects")
	if not bodyEffects then return false end
	local ko = bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO")
	return ko and ko.Value or false
end

local function getTargetUnderCursor()
	local mouse = LP:GetMouse()
	local target = mouse.Target
	if target then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LP and player.Character and target:IsDescendantOf(player.Character) then
				if not isDead(player) then
					return player
				end
			end
		end
	end
	return nil
end

local function isHoldingKnife()
	local character = LP.Character
	if not character then return false end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		for _, blacklisted in ipairs({"Knife", "Combat", "Fists"}) do
			if string.find(tool.Name:lower(), blacklisted:lower()) then
				return true
			end
		end
	end
	return false
end

local triggerOn = false
local lastShot = 0

local function triggerLoop()
	RS.RenderStepped:Connect(function()
		if not triggerOn or not triggerEnabled then return end
		local now = tick()
		local targetPlayer = getTargetUnderCursor()
		if targetPlayer and LP.Character and not isHoldingKnife() then
			local tool = LP.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				if now - lastShot >= 0.003 then
					lastShot = now
					tool:Activate()
				end
			end
		end
	end)
end

UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == triggerKey then
		triggerOn = not triggerOn
		if triggerOn then
			triggerLoop()
		end
	end
end)

RS.RenderStepped:Connect(function()
	if camlockEnabled and camlockOn and target and target.Character and target.Character:FindFirstChild(lockPartName) then
		local part = target.Character[lockPartName]
		local predictedPos = part.Position + (part.Velocity * prediction)
		local camPos = workspace.CurrentCamera.CFrame.Position
		local currentLook = workspace.CurrentCamera.CFrame.LookVector
		local desiredLook = (predictedPos - camPos).Unit
		local smoothLook = currentLook:Lerp(desiredLook, smoothness)
		workspace.CurrentCamera.CFrame = CFrame.new(camPos, camPos + smoothLook)
	end

	if hitboxExpanderEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				expandHitbox(plr.Character)
			end
		end
	end
end)
local uiToggleKey = Enum.KeyCode.RightShift
local uiVisible = true

local function createSettingsToggle(name, callback, withKeybind)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 120, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local box = Instance.new("TextButton", container)
	box.Size = UDim2.new(0, 24, 0, 24)
	box.Position = UDim2.new(0, 135, 0.5, -12)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Text = ""
	box.AutoButtonColor = false
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local toggled = false
	box.MouseButton1Click:Connect(function()
		toggled = not toggled
		local colorGoal = toggled and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(50, 50, 50)
		TweenService:Create(box, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = colorGoal
		}):Play()
		if callback then callback(toggled) end
	end)

	if withKeybind then
		local keybind = Instance.new("TextButton", container)
		keybind.Size = UDim2.new(0, 50, 0, 24)
		keybind.Position = UDim2.new(0, 165, 0.5, -12)
		keybind.Text = uiToggleKey.Name
		keybind.TextColor3 = Color3.fromRGB(200, 200, 200)
		keybind.Font = Enum.Font.Gotham
		keybind.TextSize = 12
		keybind.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		keybind.BorderSizePixel = 0
		Instance.new("UICorner", keybind).CornerRadius = UDim.new(0, 4)

		local waitingForKey = false
		keybind.MouseButton1Click:Connect(function()
			keybind.Text = "..."
			waitingForKey = true
		end)

		UIS.InputBegan:Connect(function(input)
			if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
				uiToggleKey = input.KeyCode
				keybind.Text = input.KeyCode.Name
				waitingForKey = false
			end
		end)
	end

	container.Parent = Tabs.Settings.Page
end

createSettingsToggle("UI Toggle", function(on)
	uiVisible = on
	MainFrame.Visible = uiVisible
end, true)

-- Monitor for hiding/unhiding the UI
UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == uiToggleKey then
		uiVisible = not uiVisible
		MainFrame.Visible = uiVisible
	end
end)
