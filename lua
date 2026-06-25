if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then warn("Hindi mahanap ang PlayerGui!") return end

if PlayerGui:FindFirstChild("VisualItemResizer") then
	PlayerGui.VisualItemResizer:Destroy()
end

-- ===================== UI SETUP =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualItemResizer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 300, 0, 160)
panel.Position = UDim2.new(0.5, -150, 0.5, -80)
panel.BackgroundColor3 = Color3.fromRGB(13, 15, 26)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(130, 80, 255)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.65
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(19, 21, 37)
header.BorderSizePixel = 0
header.Parent = panel

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Color3.fromRGB(19, 21, 37)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
headerLine.BackgroundTransparency = 0.8
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙ PET CHANGER BUG SCRIPT"
titleLabel.TextColor3 = Color3.fromRGB(160, 130, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -28, 0, 110)
body.Position = UDim2.new(0, 14, 0, 44)
body.BackgroundTransparency = 1
body.Parent = panel

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Padding = UDim.new(0, 8)
bodyLayout.Parent = body

local itemRow = Instance.new("Frame")
itemRow.Size = UDim2.new(1, 0, 0, 36)
itemRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
itemRow.BackgroundTransparency = 0.96
itemRow.LayoutOrder = 1
itemRow.Parent = body
Instance.new("UICorner", itemRow).CornerRadius = UDim.new(0, 10)

local itemStroke = Instance.new("UIStroke")
itemStroke.Color = Color3.fromRGB(255, 255, 255)
itemStroke.Thickness = 1
itemStroke.Transparency = 0.9
itemStroke.Parent = itemRow

local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(1, -20, 1, 0)
itemLabel.Position = UDim2.new(0, 10, 0, 0)
itemLabel.BackgroundTransparency = 1
itemLabel.Text = "❌ No pet equipped"
itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
itemLabel.Font = Enum.Font.Gotham
itemLabel.TextSize = 12
itemLabel.TextXAlignment = Enum.TextXAlignment.Left
itemLabel.Parent = itemRow

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 0, 42)
button.BackgroundColor3 = Color3.fromRGB(80, 40, 200)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Text = "🎲 Random Size"
button.LayoutOrder = 2
button.Parent = body
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 11)

local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 20)
footer.BackgroundTransparency = 1
footer.LayoutOrder = 3
footer.Parent = body

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(1, 0, 1, 0)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Made by Mark L."
creditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditsLabel.TextTransparency = 0.5
creditsLabel.Font = Enum.Font.GothamBold
creditsLabel.TextSize = 10
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.Parent = footer

-- ===================== DRAG LOGIC =====================
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging  = true
		dragStart = input.Position
		startPos  = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ===================== CORE STATE =====================
local scaledToolName = nil
local scaledMult     = 1
local scaleData      = nil
local visualClone    = nil
local activeTool     = nil
local renderConn     = nil
local partMap        = {}

local allowedSizes = {
	{name = "NORMAL", mult = 1, color = Color3.fromRGB(160, 160, 180)},
	{name = "BIG",    mult = 3, color = Color3.fromRGB(100, 220, 150)},
	{name = "MEGA",   mult = 6, color = Color3.fromRGB(255, 180,  50)},
}

local function destroyVisual()
	if renderConn then renderConn:Disconnect() renderConn = nil end
	if visualClone then visualClone:Destroy() visualClone = nil end
	if activeTool then
		pcall(function()
			for _, p in ipairs(activeTool:GetDescendants()) do
				if p:IsA("BasePart") then
					p.LocalTransparencyModifier = 0
				end
			end
		end)
	end
	partMap    = {}
	activeTool = nil
end

local function buildVisual(tool, mult)
	destroyVisual()
	if mult <= 1 then return end

	activeTool = tool

	local clone = tool:Clone()
	clone.Name  = "__BigVisual__"
	pcall(function() clone:ScaleTo(mult) end)

	for _, p in ipairs(clone:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored    = true
			p.CanCollide  = false
			p.CanTouch    = false
			p.CanQuery    = false
			p.Massless    = true
			p.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			p.LocalTransparencyModifier = 0
		elseif p:IsA("Script") or p:IsA("LocalScript") or p:IsA("TouchTransmitter") then
			p:Destroy()
		end
	end

	for _, orig in ipairs(tool:GetDescendants()) do
		if orig:IsA("BasePart") then
			local cp = clone:FindFirstChild(orig.Name, true)
			if cp and cp:IsA("BasePart") then
				partMap[orig] = cp
			end
		end
	end

	clone.Parent = Workspace.CurrentCamera
	visualClone  = clone

	for _, p in ipairs(tool:GetDescendants()) do
		if p:IsA("BasePart") then
			p.LocalTransparencyModifier = 1
		end
	end

	renderConn = RunService.RenderStepped:Connect(function()
		if not tool or not tool.Parent or not visualClone then
			destroyVisual()
			return
		end
		local pivot = tool:GetPivot()
		for orig, cp in pairs(partMap) do
			if orig and orig.Parent and cp and cp.Parent then
				pcall(function()
					local rel   = pivot:ToObjectSpace(orig.CFrame)
					local scaledPos = rel.Position * mult
					cp.CFrame = pivot:ToWorldSpace(
						CFrame.new(scaledPos) * CFrame.Angles(rel:ToEulerAnglesXYZ())
					)
					cp.Anchored   = true
					cp.CanCollide = false
				end)
			end
		end
	end)
end

-- ===================== CHECKER LOOP =====================
task.spawn(function()
	local lastTool = nil

	while screenGui and screenGui.Parent do
		task.wait(0.05)
		local character = LocalPlayer.Character
		if not character then
			lastTool = nil
			continue
		end

		local tool = character:FindFirstChildOfClass("Tool")

		if tool then
			if tool ~= lastTool then
				lastTool = tool

				if scaledToolName and tool.Name == scaledToolName then
					buildVisual(tool, scaledMult)
					panelStroke.Color    = scaleData.color
					itemLabel.Text       = "✅ " .. tool.Name .. "  [" .. scaleData.name .. "]"
					itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
				else
					destroyVisual()
					itemLabel.Text       = "✅ " .. tool.Name .. "  [NORMAL]"
					itemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					panelStroke.Color    = Color3.fromRGB(130, 80, 255)
				end
			else
				if scaledToolName and tool.Name == scaledToolName then
					if not visualClone or activeTool ~= tool then
						buildVisual(tool, scaledMult)
						panelStroke.Color    = scaleData.color
						itemLabel.Text       = "✅ " .. tool.Name .. "  [" .. scaleData.name .. "]"
						itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
					end
				end
			end

		else
			-- Walang tool na hawak
			if lastTool ~= nil then
				lastTool = nil
				destroyVisual()
			end

			-- Palaging ganito kapag walang equipped pet
			itemLabel.Text       = "❌ No pet equipped"
			itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
			panelStroke.Color    = Color3.fromRGB(130, 80, 255)
		end
	end
end)

-- ===================== BUTTON =====================
local function doRandomSize()
	local character = LocalPlayer.Character
	if not character then return end
	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		local data = allowedSizes[math.random(1, #allowedSizes)]

		scaledToolName = tool.Name
		scaledMult     = data.mult
		scaleData      = data

		buildVisual(tool, data.mult)
		panelStroke.Color    = data.color
		itemLabel.Text       = "✅ " .. tool.Name .. "  [" .. data.name .. "]"
		itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)

		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 60, 220)}):Play()
		task.wait(0.1)
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 40, 200)}):Play()
	else
		itemLabel.Text       = "❌ No pet equipped"
		itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		button.Text          = "❗ Hold a pet first!"
		task.wait(1.2)
		button.Text = "🎲 Random Size"
	end
end

button.MouseButton1Click:Connect(doRandomSize)

button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(100, 55, 220)}):Play()
end)
button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 40, 200)}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R then doRandomSize() end
end)

LocalPlayer.CharacterAdded:Connect(function()
	destroyVisual()
	scaledToolName = nil
	scaledMult     = 1
	scaleData      = nil
	itemLabel.Text       = "❌ No pet equipped"
	itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	panelStroke.Color    = Color3.fromRGB(130, 80, 255)
end)

print("✅ READY: Clean UI - Only No pet / NORMAL / BIG / MEGA")
