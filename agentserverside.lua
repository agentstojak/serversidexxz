-- ╔═══════════════════════════════════════════════════════════╗
-- ║  🌟 ULTIMATE SERVERSIDE HUB V3.0 - PART 1/4             ║
-- ║  The Most Advanced Serverside Executor Ever Created      ║
-- ║  Premium UI | 100+ Features | Smart AI Detection        ║
-- ╚═══════════════════════════════════════════════════════════╝

local UltimateHub = {}

-- ═══════════════════════════════════════════════════════════
--                    SERVICES & GLOBALS
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════
--                    CONFIGURATION
-- ═══════════════════════════════════════════════════════════

UltimateHub.Config = {
	-- UI Settings
	Theme = {
		Primary = Color3.fromRGB(138, 43, 226),      -- Purple
		Secondary = Color3.fromRGB(75, 0, 130),       -- Indigo
		Success = Color3.fromRGB(46, 204, 113),       -- Green
		Warning = Color3.fromRGB(241, 196, 15),       -- Yellow
		Error = Color3.fromRGB(231, 76, 60),          -- Red
		Background = Color3.fromRGB(15, 15, 20),      -- Dark
		Surface = Color3.fromRGB(25, 25, 30),         -- Surface
		Text = Color3.fromRGB(255, 255, 255),         -- White
		TextSecondary = Color3.fromRGB(170, 170, 170) -- Gray
	},

	-- Animation Settings
	Animation = {
		Speed = 0.3,
		Style = Enum.EasingStyle.Back,
		Direction = Enum.EasingDirection.Out
	},

	-- Auto Features
	AutoInject = true,
	AutoScan = true,
	AutoSave = true,
	ShowNotifications = true,

	-- Scanning
	ScanDepth = 10,
	ScanTimeout = 30,
	UseAI = true,

	-- Keybind
	ToggleKey = Enum.KeyCode.RightShift,

	-- Security
	OwnerUserId = LocalPlayer.UserId,
	RequireAuth = false,

	-- Performance
	MaxLogs = 100,
	UpdateInterval = 0.5
}

-- ═══════════════════════════════════════════════════════════
--                    UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local Utility = {}

function Utility:Tween(object, properties, duration, style, direction)
	duration = duration or UltimateHub.Config.Animation.Speed
	style = style or UltimateHub.Config.Animation.Style
	direction = direction or UltimateHub.Config.Animation.Direction

	local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
	tween:Play()
	return tween
end

function Utility:CreateGradient(parent, color1, color2, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2)
	}
	gradient.Rotation = rotation or 90
	gradient.Parent = parent
	return gradient
end

function Utility:CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

function Utility:CreateStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(255, 255, 255)
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

function Utility:CreateShadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = -1
	shadow.Parent = parent
	return shadow
end

function Utility:Notify(title, message, duration, type_)
	local color = UltimateHub.Config.Theme.Primary
	if type_ == "success" then color = UltimateHub.Config.Theme.Success
	elseif type_ == "error" then color = UltimateHub.Config.Theme.Error
	elseif type_ == "warning" then color = UltimateHub.Config.Theme.Warning end

	-- Create notification (implemented in GUI section)
	if UltimateHub.NotificationSystem then
		UltimateHub.NotificationSystem:Show(title, message, duration or 3, color)
	end
end

function Utility:DeepCopy(original)
	local copy
	if type(original) == 'table' then
		copy = {}
		for k, v in pairs(original) do
			copy[Utility:DeepCopy(k)] = Utility:DeepCopy(v)
		end
	else
		copy = original
	end
	return copy
end

function Utility:FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(num)
	end
end

function Utility:GetTimestamp()
	return os.date("%H:%M:%S")
end

UltimateHub.Utility = Utility

-- ═══════════════════════════════════════════════════════════
--                    ENHANCED PATTERN DETECTION
-- ═══════════════════════════════════════════════════════════

UltimateHub.Patterns = {
	-- Critical backdoor patterns
	Critical = {
		"require%s*%(%s*%d+%s*%)",
		"loadstring%s*%(",
		"getfenv%s*%(%s*%)",
		"setfenv%s*%(",
		"_G%[.-%]%s*=%s*function",
		"shared%[.-%]%s*=%s*function",
		"game%.HttpGet",
		"game%.HttpPost"
	},

	-- High risk patterns
	HighRisk = {
		"BreakJoints",
		":Kick%s*%(",
		"MarketplaceService",
		"InsertService",
		"PromptPurchase",
		"TeleportService",
		"DataStoreService"
	},

	-- Obfuscation patterns
	Obfuscation = {
		"\\x%x%x",
		"\\%d%d%d",
		"string%.char%s*%(",
		"string%.byte%s*%(",
		"string%.reverse",
		"bit32%.band",
		"bit32%.bxor"
	},

	-- Network patterns
	Network = {
		"https?://[%w%.%-]+",
		"RequestAsync",
		"GetAsync",
		"PostAsync",
		"JSONDecode",
		"JSONEncode"
	},

	-- Exploit indicators
	Exploits = {
		"Admin",
		"Owner",
		"Backdoor",
		"HD",
		"MainModule",
		"require%(game%.",
		"RemoteEvent:Fire",
		"RemoteFunction:Invoke"
	}
}

-- ═══════════════════════════════════════════════════════════
--                    AI RISK ANALYZER
-- ═══════════════════════════════════════════════════════════

local AIAnalyzer = {}

function AIAnalyzer:CalculateComplexity(source)
	local complexity = 0

	-- Count code elements
	local lines = select(2, source:gsub("\n", "\n")) + 1
	local functions = select(2, source:gsub("function", "function"))
	local loops = select(2, source:gsub("while", "while")) + 
		select(2, source:gsub("for", "for")) +
		select(2, source:gsub("repeat", "repeat"))
	local conditionals = select(2, source:gsub("if", "if"))

	complexity = (lines * 0.1) + (functions * 5) + (loops * 10) + (conditionals * 3)

	return math.min(complexity, 100)
end

function AIAnalyzer:AnalyzeScript(scriptInstance)
	local analysis = {
		RiskScore = 0,
		Complexity = 0,
		Indicators = {},
		Categories = {},
		IsMalicious = false,
		Confidence = 0
	}

	local success, source = pcall(function()
		return scriptInstance.Source
	end)

	if not success or not source then
		return analysis
	end

	-- Calculate complexity
	analysis.Complexity = self:CalculateComplexity(source)

	-- Pattern matching
	local patternMatches = 0
	local criticalMatches = 0

	for category, patterns in pairs(UltimateHub.Patterns) do
		for _, pattern in ipairs(patterns) do
			if source:match(pattern) then
				patternMatches = patternMatches + 1
				table.insert(analysis.Indicators, category .. ": " .. pattern)
				table.insert(analysis.Categories, category)

				if category == "Critical" then
					criticalMatches = criticalMatches + 1
					analysis.RiskScore = analysis.RiskScore + 30
				elseif category == "HighRisk" then
					analysis.RiskScore = analysis.RiskScore + 20
				elseif category == "Obfuscation" then
					analysis.RiskScore = analysis.RiskScore + 15
				elseif category == "Network" then
					analysis.RiskScore = analysis.RiskScore + 10
				else
					analysis.RiskScore = analysis.RiskScore + 5
				end
			end
		end
	end

	-- Complexity factor
	if analysis.Complexity > 50 then
		analysis.RiskScore = analysis.RiskScore + 10
	end

	-- Cap at 100
	analysis.RiskScore = math.min(analysis.RiskScore, 100)

	-- Determine if malicious
	analysis.IsMalicious = analysis.RiskScore >= 60
	analysis.Confidence = math.min((patternMatches * 10) + (criticalMatches * 20), 100)

	return analysis
end

function AIAnalyzer:ScanInstance(instance, results, depth)
	depth = depth or 0
	if depth > UltimateHub.Config.ScanDepth then return end

	results = results or {
		backdoors = {},
		remotes = {},
		modules = {},
		scripts = {},
		hiddenRemotes = {}
	}

	-- Scan ModuleScripts
	if instance:IsA("ModuleScript") then
		local analysis = self:AnalyzeScript(instance)

		local moduleInfo = {
			Name = instance.Name,
			Path = instance:GetFullName(),
			Instance = instance,
			RiskScore = analysis.RiskScore,
			Complexity = analysis.Complexity,
			Indicators = analysis.Indicators,
			Categories = analysis.Categories,
			IsMalicious = analysis.IsMalicious,
			Type = "ModuleScript"
		}

		table.insert(results.modules, moduleInfo)

		if analysis.IsMalicious or analysis.RiskScore > 40 then
			table.insert(results.backdoors, moduleInfo)
		end
	end

	-- Scan Scripts
	if instance:IsA("Script") or instance:IsA("LocalScript") then
		local analysis = self:AnalyzeScript(instance)

		local scriptInfo = {
			Name = instance.Name,
			Path = instance:GetFullName(),
			Instance = instance,
			RiskScore = analysis.RiskScore,
			Complexity = analysis.Complexity,
			Indicators = analysis.Indicators,
			Categories = analysis.Categories,
			IsMalicious = analysis.IsMalicious,
			Type = instance.ClassName
		}

		table.insert(results.scripts, scriptInfo)

		if analysis.IsMalicious or analysis.RiskScore > 40 then
			table.insert(results.backdoors, scriptInfo)
		end
	end

	-- Scan Remotes
	if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
		local remoteInfo = {
			Name = instance.Name,
			Path = instance:GetFullName(),
			Instance = instance,
			Type = instance.ClassName,
			RiskScore = 0,
			IsSuspicious = false
		}

		-- Check if name is suspicious
		local suspiciousNames = {
			"execute", "admin", "owner", "backdoor", "hd", "mainmodule",
			"command", "cmd", "remote", "serverevent", "serverfunction"
		}

		for _, susName in ipairs(suspiciousNames) do
			if instance.Name:lower():find(susName) then
				remoteInfo.IsSuspicious = true
				remoteInfo.RiskScore = 50
				table.insert(results.backdoors, remoteInfo)
				break
			end
		end

		table.insert(results.remotes, remoteInfo)
	end

	-- Recurse children
	for _, child in ipairs(instance:GetChildren()) do
		self:ScanInstance(child, results, depth + 1)
	end

	return results
end

function AIAnalyzer:ScanGame()
	print("[AI ANALYZER] Starting comprehensive scan...")

	local results = {
		backdoors = {},
		remotes = {},
		modules = {},
		scripts = {},
		hiddenRemotes = {}
	}

	-- Scan all accessible locations
	local locations = {
		workspace,
		ReplicatedStorage,
		game.ReplicatedFirst,
		game.StarterGui,
		game.StarterPack,
		game.StarterPlayer,
		game.Lighting
	}

	-- Try to access server-only locations
	pcall(function() table.insert(locations, game.ServerScriptService) end)
	pcall(function() table.insert(locations, game.ServerStorage) end)

	for _, location in ipairs(locations) do
		pcall(function()
			self:ScanInstance(location, results, 0)
		end)
	end

	-- Scan memory for hidden remotes
	self:ScanMemory(results)

	-- Sort backdoors by risk score
	table.sort(results.backdoors, function(a, b)
		return (a.RiskScore or 0) > (b.RiskScore or 0)
	end)

	print(string.format("[AI ANALYZER] Scan complete! Found:"))
	print(string.format("  • Backdoors: %d", #results.backdoors))
	print(string.format("  • Remotes: %d", #results.remotes))
	print(string.format("  • Modules: %d", #results.modules))
	print(string.format("  • Scripts: %d", #results.scripts))
	print(string.format("  • Hidden: %d", #results.hiddenRemotes))

	return results
end

function AIAnalyzer:ScanMemory(results)
	-- Scan _G table
	for key, value in pairs(_G) do
		if type(value) == "userdata" then
			pcall(function()
				if value:IsA("RemoteEvent") or value:IsA("RemoteFunction") then
					table.insert(results.hiddenRemotes, {
						Key = tostring(key),
						Location = "_G",
						Instance = value,
						RiskScore = 75,
						Type = "HiddenRemote"
					})
					table.insert(results.backdoors, {
						Name = tostring(key),
						Path = "_G." .. tostring(key),
						Instance = value,
						RiskScore = 75,
						Type = "HiddenRemote",
						Indicators = {"Found in _G table"}
					})
				end
			end)
		end
	end

	-- Scan shared table
	if shared then
		for key, value in pairs(shared) do
			if type(value) == "userdata" then
				pcall(function()
					if value:IsA("RemoteEvent") or value:IsA("RemoteFunction") then
						table.insert(results.hiddenRemotes, {
							Key = tostring(key),
							Location = "shared",
							Instance = value,
							RiskScore = 75,
							Type = "HiddenRemote"
						})
						table.insert(results.backdoors, {
							Name = tostring(key),
							Path = "shared." .. tostring(key),
							Instance = value,
							RiskScore = 75,
							Type = "HiddenRemote",
							Indicators = {"Found in shared table"}
						})
					end
				end)
			end
		end
	end
end

UltimateHub.AIAnalyzer = AIAnalyzer

-- ═══════════════════════════════════════════════════════════
--                    INJECTION ENGINE
-- ═══════════════════════════════════════════════════════════

local InjectionEngine = {}
InjectionEngine.Injected = false
InjectionEngine.Method = "None"
InjectionEngine.Target = nil

function InjectionEngine:TestRemote(remote, payloads)
	payloads = payloads or {
		function() return remote:FireServer("print('TEST_1')") end,
		function() return remote:FireServer("print('TEST_2')", LocalPlayer) end,
		function() return remote:InvokeServer("print('TEST_3')") end,
		function() return remote:FireServer({code = "print('TEST_4')"}) end,
		function() return remote:FireServer({script = "print('TEST_5')"}) end,
		function() return remote:FireServer({command = "print('TEST_6')"}) end,
		function() return remote:FireServer("", "print('TEST_7')") end,
	}

	for i, payload in ipairs(payloads) do
		local success = pcall(payload)
		if success then
			return true, i
		end
	end

	return false, nil
end

function InjectionEngine:InjectRemote(remote)
	local success, method = self:TestRemote(remote)

	if success then
		self.Injected = true
		self.Method = string.format("Remote:%s (Payload %d)", remote.Name, method)
		self.Target = remote
		return true, self.Method
	end

	return false, "Remote injection failed"
end

function InjectionEngine:InjectModule(moduleScript)
	local success, module = pcall(function()
		return require(moduleScript)
	end)

	if not success then
		return false, "Failed to require module"
	end

	-- Try common backdoor functions
	local functions = {
		"Execute", "Run", "Fire", "Invoke", "Load", "Init",
		"Command", "CMD", "Exec", "RunCode", "ExecuteScript",
		"LoadString", "Loadstring", "exec", "execute"
	}

	if type(module) == "table" then
		for _, funcName in ipairs(functions) do
			if module[funcName] and type(module[funcName]) == "function" then
				self.Injected = true
				self.Method = string.format("Module:%s.%s", moduleScript.Name, funcName)
				self.Target = {Module = module, Function = funcName}
				return true, self.Method
			end
		end
	elseif type(module) == "function" then
		self.Injected = true
		self.Method = string.format("Module:%s (Direct)", moduleScript.Name)
		self.Target = {Module = module, Function = "direct"}
		return true, self.Method
	end

	return false, "No exploitable functions found"
end

function InjectionEngine:AutoInject(scanResults)
	print("[INJECTION] Starting auto-injection...")

	-- Try highest risk backdoors first
	for _, backdoor in ipairs(scanResults.backdoors) do
		if backdoor.Instance then
			if backdoor.Instance:IsA("RemoteEvent") or backdoor.Instance:IsA("RemoteFunction") then
				local success, msg = self:InjectRemote(backdoor.Instance)
				if success then
					return true, msg
				end
			elseif backdoor.Instance:IsA("ModuleScript") then
				local success, msg = self:InjectModule(backdoor.Instance)
				if success then
					return true, msg
				end
			end
		end
	end

	return false, "No injectable backdoors found"
end

function InjectionEngine:Execute(code)
	if not self.Injected then
		return false, "Not injected! Scan and inject first."
	end

	if self.Method:match("^Remote:") then
		local success, err = pcall(function()
			if self.Target:IsA("RemoteEvent") then
				self.Target:FireServer(code)
			else
				self.Target:InvokeServer(code)
			end
		end)

		if success then
			return true, "Executed via " .. self.Method
		else
			return false, "Execution error: " .. tostring(err)
		end

	elseif self.Method:match("^Module:") then
		local success, err = pcall(function()
			if self.Target.Function == "direct" then
				self.Target.Module(code)
			else
				self.Target.Module[self.Target.Function](code)
			end
		end)

		if success then
			return true, "Executed via " .. self.Method
		else
			return false, "Execution error: " .. tostring(err)
		end
	end

	return false, "Unknown injection method"
end

UltimateHub.InjectionEngine = InjectionEngine

-- ╔═══════════════════════════════════════════════════════════╗
-- ║  🌟 ULTIMATE SERVERSIDE HUB V3.0 - PART 2/4             ║
-- ║  Premium UI System with Animations                       ║
-- ╚═══════════════════════════════════════════════════════════╝

-- This file continues from PART 1
-- Paste after: return UltimateHub

-- ═══════════════════════════════════════════════════════════
--                    NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

local NotificationSystem = {}
NotificationSystem.Notifications = {}
NotificationSystem.MaxNotifications = 5

function NotificationSystem:Show(title, message, duration, color)
	duration = duration or 3
	color = color or UltimateHub.Config.Theme.Primary

	local notifContainer = UltimateHub.GUI:FindFirstChild("NotificationContainer")
	if not notifContainer then return end

	-- Remove oldest if too many
	if #self.Notifications >= self.MaxNotifications then
		local oldest = self.Notifications[1]
		table.remove(self.Notifications, 1)
		UltimateHub.Utility:Tween(oldest, {Position = UDim2.new(1, 10, oldest.Position.Y.Scale, 0)}, 0.3)
		task.delay(0.3, function() oldest:Destroy() end)
	end

	-- Create notification
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 90)
	notif.Position = UDim2.new(1, 10, 1, -((#self.Notifications + 1) * 100))
	notif.BackgroundColor3 = UltimateHub.Config.Theme.Surface
	notif.BorderSizePixel = 0
	notif.Parent = notifContainer

	UltimateHub.Utility:CreateCorner(notif, 12)
	UltimateHub.Utility:CreateStroke(notif, color, 2)

	-- Glow effect
	local glow = Instance.new("ImageLabel")
	glow.Size = UDim2.new(1, 40, 1, 40)
	glow.Position = UDim2.new(0, -20, 0, -20)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.ImageColor3 = color
	glow.ImageTransparency = 0.7
	glow.ZIndex = 0
	glow.Parent = notif

	-- Icon
	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 15, 0.5, -25)
	icon.BackgroundColor3 = color
	icon.BorderSizePixel = 0
	icon.Parent = notif

	UltimateHub.Utility:CreateCorner(icon, 25)

	local iconText = Instance.new("TextLabel")
	iconText.Size = UDim2.new(1, 0, 1, 0)
	iconText.BackgroundTransparency = 1
	iconText.Text = "✓"
	iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconText.TextSize = 24
	iconText.Font = Enum.Font.GothamBold
	iconText.Parent = icon

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -85, 0, 25)
	titleLabel.Position = UDim2.new(0, 75, 0, 15)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = UltimateHub.Config.Theme.Text
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	-- Message
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -85, 0, 40)
	messageLabel.Position = UDim2.new(0, 75, 0, 40)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = UltimateHub.Config.Theme.TextSecondary
	messageLabel.TextSize = 13
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notif

	-- Progress bar
	local progress = Instance.new("Frame")
	progress.Size = UDim2.new(0, 0, 0, 3)
	progress.Position = UDim2.new(0, 0, 1, -3)
	progress.BackgroundColor3 = color
	progress.BorderSizePixel = 0
	progress.Parent = notif

	-- Animations
	table.insert(self.Notifications, notif)

	UltimateHub.Utility:Tween(notif, {Position = UDim2.new(1, -360, notif.Position.Y.Scale, 0)}, 0.5, Enum.EasingStyle.Back)
	UltimateHub.Utility:Tween(progress, {Size = UDim2.new(1, 0, 0, 3)}, duration)

	-- Icon pulse
	task.spawn(function()
		while notif.Parent do
			UltimateHub.Utility:Tween(icon, {Size = UDim2.new(0, 55, 0, 55)}, 0.5)
			task.wait(0.5)
			UltimateHub.Utility:Tween(icon, {Size = UDim2.new(0, 50, 0, 50)}, 0.5)
			task.wait(0.5)
		end
	end)

	-- Auto remove
	task.delay(duration, function()
		UltimateHub.Utility:Tween(notif, {Position = UDim2.new(1, 10, notif.Position.Y.Scale, 0)}, 0.3)
		task.wait(0.3)
		notif:Destroy()

		for i, v in ipairs(self.Notifications) do
			if v == notif then
				table.remove(self.Notifications, i)
				break
			end
		end
	end)
end

UltimateHub.NotificationSystem = NotificationSystem

-- ═══════════════════════════════════════════════════════════
--                    LOADING SCREEN
-- ═══════════════════════════════════════════════════════════

local LoadingScreen = {}

function LoadingScreen:Create()
	local loading = Instance.new("ScreenGui")
	loading.Name = "UltimateHubLoading"
	loading.ResetOnSpawn = false
	loading.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loading.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	bg.BorderSizePixel = 0
	bg.Parent = loading

	UltimateHub.Utility:CreateGradient(bg, 
		Color3.fromRGB(15, 15, 20), 
		Color3.fromRGB(30, 15, 45), 
		45)

	-- Logo
	local logo = Instance.new("Frame")
	logo.Size = UDim2.new(0, 120, 0, 120)
	logo.Position = UDim2.new(0.5, -60, 0.5, -100)
	logo.BackgroundColor3 = UltimateHub.Config.Theme.Primary
	logo.BorderSizePixel = 0
	logo.Parent = bg

	UltimateHub.Utility:CreateCorner(logo, 60)

	local logoText = Instance.new("TextLabel")
	logoText.Size = UDim2.new(1, 0, 1, 0)
	logoText.BackgroundTransparency = 1
	logoText.Text = "🌟"
	logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
	logoText.TextSize = 60
	logoText.Font = Enum.Font.GothamBold
	logoText.Parent = logo

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 400, 0, 40)
	title.Position = UDim2.new(0.5, -200, 0.5, 40)
	title.BackgroundTransparency = 1
	title.Text = "ULTIMATE HUB"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 36
	title.Font = Enum.Font.GothamBlack
	title.Parent = bg

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(0, 400, 0, 25)
	subtitle.Position = UDim2.new(0.5, -200, 0.5, 85)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Premium Serverside Executor"
	subtitle.TextColor3 = UltimateHub.Config.Theme.Primary
	subtitle.TextSize = 18
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Parent = bg

	-- Progress bar container
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(0, 400, 0, 6)
	progressBg.Position = UDim2.new(0.5, -200, 0.5, 130)
	progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = bg

	UltimateHub.Utility:CreateCorner(progressBg, 3)

	-- Progress bar
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = UltimateHub.Config.Theme.Primary
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBg

	UltimateHub.Utility:CreateCorner(progressBar, 3)
	UltimateHub.Utility:CreateGradient(progressBar,
		UltimateHub.Config.Theme.Primary,
		UltimateHub.Config.Theme.Secondary,
		0)

	-- Status text
	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(0, 400, 0, 20)
	status.Position = UDim2.new(0.5, -200, 0.5, 145)
	status.BackgroundTransparency = 1
	status.Text = "Initializing..."
	status.TextColor3 = Color3.fromRGB(200, 200, 200)
	status.TextSize = 14
	status.Font = Enum.Font.Gotham
	status.Parent = bg

	-- Version
	local version = Instance.new("TextLabel")
	version.Size = UDim2.new(0, 200, 0, 20)
	version.Position = UDim2.new(0.5, -100, 1, -30)
	version.BackgroundTransparency = 1
	version.Text = "v3.0.0 | Made with ❤️"
	version.TextColor3 = Color3.fromRGB(100, 100, 100)
	version.TextSize = 12
	version.Font = Enum.Font.Gotham
	version.Parent = bg

	-- Animations
	task.spawn(function()
		while loading.Parent do
			UltimateHub.Utility:Tween(logo, {Rotation = 360}, 2, Enum.EasingStyle.Linear)
			task.wait(2)
			logo.Rotation = 0
		end
	end)

	return loading, progressBar, status
end

function LoadingScreen:UpdateProgress(progressBar, status, percent, text)
	UltimateHub.Utility:Tween(progressBar, {Size = UDim2.new(percent, 0, 1, 0)}, 0.3)
	status.Text = text
end

function LoadingScreen:Complete(loading)
	local bg = loading:FindFirstChild("Frame")
	if bg then
		UltimateHub.Utility:Tween(bg, {BackgroundTransparency = 1}, 0.5)
		for _, child in ipairs(bg:GetDescendants()) do
			if child:IsA("GuiObject") then
				UltimateHub.Utility:Tween(child, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				}, 0.5)
			end
		end
	end

	task.delay(0.6, function()
		loading:Destroy()
	end)
end

UltimateHub.LoadingScreen = LoadingScreen

-- ═══════════════════════════════════════════════════════════
--                    UI COMPONENTS
-- ═══════════════════════════════════════════════════════════

local Components = {}

function Components:CreateButton(parent, text, position, size, callback, color)
	color = color or UltimateHub.Config.Theme.Primary

	local button = Instance.new("TextButton")
	button.Size = size or UDim2.new(0, 150, 0, 40)
	button.Position = position or UDim2.new(0, 0, 0, 0)
	button.BackgroundColor3 = color
	button.Text = ""
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Parent = parent

	UltimateHub.Utility:CreateCorner(button, 8)

	-- Gradient
	UltimateHub.Utility:CreateGradient(button, color, 
		Color3.fromRGB(
			math.max(color.R * 255 - 30, 0),
			math.max(color.G * 255 - 30, 0),
			math.max(color.B * 255 - 30, 0)
		), 90)

	-- Text
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 15
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	-- Ripple effect
	button.MouseButton1Click:Connect(function()
		local ripple = Instance.new("Frame")
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ripple.BackgroundTransparency = 0.5
		ripple.BorderSizePixel = 0
		ripple.Parent = button

		UltimateHub.Utility:CreateCorner(ripple, 1000)

		local tween = UltimateHub.Utility:Tween(ripple, {
			Size = UDim2.new(2, 0, 2, 0),
			BackgroundTransparency = 1
		}, 0.5)

		tween.Completed:Connect(function()
			ripple:Destroy()
		end)

		if callback then
			callback()
		end
	end)

	-- Hover effect
	button.MouseEnter:Connect(function()
		UltimateHub.Utility:Tween(button, {
			Size = UDim2.new(size.X.Scale, size.X.Offset + 5, size.Y.Scale, size.Y.Offset + 3)
		}, 0.2)
	end)

	button.MouseLeave:Connect(function()
		UltimateHub.Utility:Tween(button, {Size = size}, 0.2)
	end)

	return button
end

function Components:CreateToggle(parent, text, position, defaultState, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 0, 50)
	container.Position = position or UDim2.new(0, 10, 0, 0)
	container.BackgroundColor3 = UltimateHub.Config.Theme.Surface
	container.BorderSizePixel = 0
	container.Parent = parent

	UltimateHub.Utility:CreateCorner(container, 8)

	-- Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = UltimateHub.Config.Theme.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	-- Toggle background
	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 50, 0, 26)
	toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
	toggleBg.BackgroundColor3 = defaultState and UltimateHub.Config.Theme.Success or Color3.fromRGB(60, 60, 70)
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = container

	UltimateHub.Utility:CreateCorner(toggleBg, 13)

	-- Toggle circle
	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 20, 0, 20)
	toggleCircle.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleCircle.BorderSizePixel = 0
	toggleCircle.Parent = toggleBg

	UltimateHub.Utility:CreateCorner(toggleCircle, 10)

	local state = defaultState

	-- Button
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = container

	button.MouseButton1Click:Connect(function()
		state = not state

		UltimateHub.Utility:Tween(toggleCircle, {
			Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
		}, 0.2)

		UltimateHub.Utility:Tween(toggleBg, {
			BackgroundColor3 = state and UltimateHub.Config.Theme.Success or Color3.fromRGB(60, 60, 70)
		}, 0.2)

		if callback then
			callback(state)
		end
	end)

	return container, state
end

function Components:CreateInput(parent, placeholder, position, size)
	local input = Instance.new("TextBox")
	input.Size = size or UDim2.new(1, -20, 0, 40)
	input.Position = position or UDim2.new(0, 10, 0, 0)
	input.BackgroundColor3 = UltimateHub.Config.Theme.Surface
	input.PlaceholderText = placeholder
	input.PlaceholderColor3 = UltimateHub.Config.Theme.TextSecondary
	input.Text = ""
	input.TextColor3 = UltimateHub.Config.Theme.Text
	input.TextSize = 14
	input.Font = Enum.Font.Gotham
	input.ClearTextOnFocus = false
	input.BorderSizePixel = 0
	input.Parent = parent

	UltimateHub.Utility:CreateCorner(input, 8)
	UltimateHub.Utility:CreateStroke(input, Color3.fromRGB(60, 60, 70), 1)

	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = input

	-- Focus effect
	input.Focused:Connect(function()
		UltimateHub.Utility:Tween(input.UIStroke, {
			Color = UltimateHub.Config.Theme.Primary,
			Thickness = 2
		}, 0.2)
	end)

	input.FocusLost:Connect(function()
		UltimateHub.Utility:Tween(input.UIStroke, {
			Color = Color3.fromRGB(60, 60, 70),
			Thickness = 1
		}, 0.2)
	end)

	return input
end

function Components:CreateTab(parent, icon, name, order)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, 0, 0, 50)
	tab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	tab.BackgroundTransparency = 1
	tab.Text = ""
	tab.AutoButtonColor = false
	tab.BorderSizePixel = 0
	tab.LayoutOrder = order or 0
	tab.Parent = parent

	-- Icon
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 0, 30)
	iconLabel.Position = UDim2.new(0, 15, 0.5, -15)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextColor3 = UltimateHub.Config.Theme.TextSecondary
	iconLabel.TextSize = 20
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = tab

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.Position = UDim2.new(0, 55, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = UltimateHub.Config.Theme.TextSecondary
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = tab

	-- Selection indicator
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 0, 0.7, 0)
	indicator.Position = UDim2.new(0, 0, 0.15, 0)
	indicator.BackgroundColor3 = UltimateHub.Config.Theme.Primary
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = tab

	UltimateHub.Utility:CreateCorner(indicator, 2)

	tab.MouseButton1Click:Connect(function()
		-- Deselect all other tabs
		for _, otherTab in ipairs(parent:GetChildren()) do
			if otherTab:IsA("TextButton") and otherTab ~= tab then
				local otherIcon = otherTab:FindFirstChild("TextLabel")
				local otherName = otherTab:FindFirstChildOfClass("TextLabel")
				local otherIndicator = otherTab:FindFirstChild("Frame")

				if otherIcon then
					UltimateHub.Utility:Tween(otherIcon, {
						TextColor3 = UltimateHub.Config.Theme.TextSecondary
					}, 0.2)
				end

				for _, label in ipairs(otherTab:GetChildren()) do
					if label:IsA("TextLabel") and label ~= otherIcon then
						UltimateHub.Utility:Tween(label, {
							TextColor3 = UltimateHub.Config.Theme.TextSecondary
						}, 0.2)
					end
				end

				if otherIndicator and otherIndicator:IsA("Frame") then
					UltimateHub.Utility:Tween(otherIndicator, {
						Size = UDim2.new(0, 0, 0.7, 0)
					}, 0.2)
					task.wait(0.2)
					otherIndicator.Visible = false
				end

				UltimateHub.Utility:Tween(otherTab, {
					BackgroundTransparency = 1
				}, 0.2)
			end
		end

		-- Select this tab
		indicator.Visible = true
		UltimateHub.Utility:Tween(indicator, {
			Size = UDim2.new(0, 4, 0.7, 0)
		}, 0.3, Enum.EasingStyle.Back)

		UltimateHub.Utility:Tween(iconLabel, {
			TextColor3 = UltimateHub.Config.Theme.Primary
		}, 0.2)

		UltimateHub.Utility:Tween(nameLabel, {
			TextColor3 = UltimateHub.Config.Theme.Text
		}, 0.2)

		UltimateHub.Utility:Tween(tab, {
			BackgroundTransparency = 0.95
		}, 0.2)
	end)

	-- Hover effect
	tab.MouseEnter:Connect(function()
		if indicator.Size.X.Offset == 0 then
			UltimateHub.Utility:Tween(tab, {
				BackgroundTransparency = 0.97
			}, 0.2)
		end
	end)

	tab.MouseLeave:Connect(function()
		if indicator.Size.X.Offset == 0 then
			UltimateHub.Utility:Tween(tab, {
				BackgroundTransparency = 1
			}, 0.2)
		end
	end)

	return tab, iconLabel, nameLabel, indicator
end

UltimateHub.Components = Components

-- ╔═══════════════════════════════════════════════════════════╗
-- ║  🌟 ULTIMATE SERVERSIDE HUB V3.0 - PART 3/4             ║
-- ║  Main GUI Creation and Tab System                        ║
-- ╚═══════════════════════════════════════════════════════════╝

-- This file continues from PART 2

-- ═══════════════════════════════════════════════════════════
--                    MAIN GUI CREATION
-- ═══════════════════════════════════════════════════════════

function UltimateHub:CreateGUI()
	-- Main ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "UltimateHubGUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	self.GUI = gui

	-- Notification container
	local notifContainer = Instance.new("Frame")
	notifContainer.Name = "NotificationContainer"
	notifContainer.Size = UDim2.new(1, 0, 1, 0)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Parent = gui

	-- Main container
	local mainContainer = Instance.new("Frame")
	mainContainer.Size = UDim2.new(0, 0, 0, 0)
	mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	mainContainer.BackgroundColor3 = self.Config.Theme.Background
	mainContainer.BorderSizePixel = 0
	mainContainer.ClipsDescendants = true
	mainContainer.Parent = gui

	self.Utility:CreateCorner(mainContainer, 16)
	self.Utility:CreateStroke(mainContainer, self.Config.Theme.Primary, 2)

	-- Animate open
	self.Utility:Tween(mainContainer, {
		Size = UDim2.new(0, 1100, 0, 650)
	}, 0.6, Enum.EasingStyle.Back)

	-- Topbar
	local topbar = Instance.new("Frame")
	topbar.Size = UDim2.new(1, 0, 0, 60)
	topbar.BackgroundColor3 = self.Config.Theme.Surface
	topbar.BorderSizePixel = 0
	topbar.Parent = mainContainer

	self.Utility:CreateGradient(topbar, 
		self.Config.Theme.Surface,
		self.Config.Theme.Background, 90)

	-- Logo
	local logo = Instance.new("Frame")
	logo.Size = UDim2.new(0, 40, 0, 40)
	logo.Position = UDim2.new(0, 15, 0.5, -20)
	logo.BackgroundColor3 = self.Config.Theme.Primary
	logo.BorderSizePixel = 0
	logo.Parent = topbar

	self.Utility:CreateCorner(logo, 20)

	local logoText = Instance.new("TextLabel")
	logoText.Size = UDim2.new(1, 0, 1, 0)
	logoText.BackgroundTransparency = 1
	logoText.Text = "🌟"
	logoText.TextSize = 20
	logoText.Font = Enum.Font.GothamBold
	logoText.Parent = logo

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 65, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "ULTIMATE HUB"
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topbar

	-- Version
	local version = Instance.new("TextLabel")
	version.Size = UDim2.new(0, 100, 0, 20)
	version.Position = UDim2.new(0, 65, 0, 30)
	version.BackgroundTransparency = 1
	version.Text = "v3.0.0 Premium"
	version.TextColor3 = self.Config.Theme.Primary
	version.TextSize = 11
	version.Font = Enum.Font.GothamBold
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.Parent = topbar

	-- Control buttons
	local closeBtn = self.Components:CreateButton(topbar, "✕", 
		UDim2.new(1, -50, 0.5, -15), UDim2.new(0, 35, 0, 30),
		function()
			self:CloseGUI()
		end, self.Config.Theme.Error)

	local minimizeBtn = self.Components:CreateButton(topbar, "−",
		UDim2.new(1, -95, 0.5, -15), UDim2.new(0, 35, 0, 30),
		function()
			self:ToggleMinimize()
		end, self.Config.Theme.Warning)

	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 220, 1, -60)
	sidebar.Position = UDim2.new(0, 0, 0, 60)
	sidebar.BackgroundColor3 = self.Config.Theme.Surface
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainContainer

	-- Tabs container
	local tabsContainer = Instance.new("ScrollingFrame")
	tabsContainer.Size = UDim2.new(1, 0, 1, -70)
	tabsContainer.Position = UDim2.new(0, 0, 0, 10)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.BorderSizePixel = 0
	tabsContainer.ScrollBarThickness = 4
	tabsContainer.ScrollBarImageColor3 = self.Config.Theme.Primary
	tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabsContainer.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 2)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabsContainer

	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabsContainer.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
	end)

	-- User info at bottom
	local userInfo = Instance.new("Frame")
	userInfo.Size = UDim2.new(1, 0, 0, 60)
	userInfo.Position = UDim2.new(0, 0, 1, -60)
	userInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	userInfo.BorderSizePixel = 0
	userInfo.Parent = sidebar

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 40, 0, 40)
	avatar.Position = UDim2.new(0, 10, 0.5, -20)
	avatar.BackgroundColor3 = self.Config.Theme.Primary
	avatar.BorderSizePixel = 0
	avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	avatar.Parent = userInfo

	self.Utility:CreateCorner(avatar, 20)

	local username = Instance.new("TextLabel")
	username.Size = UDim2.new(1, -60, 0, 20)
	username.Position = UDim2.new(0, 55, 0, 10)
	username.BackgroundTransparency = 1
	username.Text = LocalPlayer.Name
	username.TextColor3 = self.Config.Theme.Text
	username.TextSize = 13
	username.Font = Enum.Font.GothamBold
	username.TextXAlignment = Enum.TextXAlignment.Left
	username.TextTruncate = Enum.TextTruncate.AtEnd
	username.Parent = userInfo

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -60, 0, 20)
	status.Position = UDim2.new(0, 55, 0, 30)
	status.BackgroundTransparency = 1
	status.Text = "🔴 Not Injected"
	status.TextColor3 = self.Config.Theme.TextSecondary
	status.TextSize = 11
	status.Font = Enum.Font.Gotham
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = userInfo

	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, -230, 1, -70)
	contentArea.Position = UDim2.new(0, 225, 0, 65)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainContainer

	-- Store references
	self.MainContainer = mainContainer
	self.TabsContainer = tabsContainer
	self.ContentArea = contentArea
	self.StatusLabel = status

	-- Create tabs
	self:CreateTabs()

	-- Dragging
	self:MakeDraggable(topbar, mainContainer)

	return gui
end

function UltimateHub:CreateTabs()
	local tabs = {
		{icon = "🏠", name = "Home", order = 1},
		{icon = "💻", name = "Executor", order = 2},
		{icon = "🔍", name = "Scanner", order = 3},
		{icon = "📦", name = "Scripts", order = 4},
		{icon = "👥", name = "Players", order = 5},
		{icon = "🌍", name = "Workspace", order = 6},
		{icon = "⚡", name = "Quick Actions", order = 7},
		{icon = "📊", name = "Console", order = 8},
		{icon = "⚙️", name = "Settings", order = 9}
	}

	self.TabContents = {}

	for _, tabInfo in ipairs(tabs) do
		local tab = self.Components:CreateTab(self.TabsContainer, tabInfo.icon, tabInfo.name, tabInfo.order)

		-- Create content for this tab
		local content = Instance.new("ScrollingFrame")
		content.Name = tabInfo.name .. "Content"
		content.Size = UDim2.new(1, 0, 1, 0)
		content.BackgroundTransparency = 1
		content.BorderSizePixel = 0
		content.ScrollBarThickness = 6
		content.ScrollBarImageColor3 = self.Config.Theme.Primary
		content.Visible = false
		content.Parent = self.ContentArea

		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 15)
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Parent = content

		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
		end)

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 10)
		padding.PaddingLeft = UDim.new(0, 10)
		padding.PaddingRight = UDim.new(0, 10)
		padding.PaddingBottom = UDim.new(0, 10)
		padding.Parent = content

		self.TabContents[tabInfo.name] = content

		tab.MouseButton1Click:Connect(function()
			self:SwitchTab(tabInfo.name)
		end)
	end

	-- Populate tabs with content
	self:PopulateTabs()

	-- Select first tab
	task.wait(0.1)
	self:SwitchTab("Home")
end

function UltimateHub:SwitchTab(tabName)
	for name, content in pairs(self.TabContents) do
		if name == tabName then
			content.Visible = true
			self.Utility:Tween(content, {
				GroupTransparency = 0
			}, 0.3)
		else
			self.Utility:Tween(content, {
				GroupTransparency = 1
			}, 0.2)
			task.delay(0.2, function()
				content.Visible = false
			end)
		end
	end
end

function UltimateHub:MakeDraggable(handle, object)
	local dragging = false
	local dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

function UltimateHub:ToggleMinimize()
	if self.Minimized then
		self.Utility:Tween(self.MainContainer, {
			Size = UDim2.new(0, 1100, 0, 650)
		}, 0.3)
		self.Minimized = false
	else
		self.Utility:Tween(self.MainContainer, {
			Size = UDim2.new(0, 1100, 0, 60)
		}, 0.3)
		self.Minimized = true
	end
end

function UltimateHub:CloseGUI()
	self.Utility:Tween(self.MainContainer, {
		Size = UDim2.new(0, 0, 0, 0)
	}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

	task.delay(0.5, function()
		self.GUI:Destroy()
	end)
end

-- ╔═══════════════════════════════════════════════════════════╗
-- ║  🌟 ULTIMATE SERVERSIDE HUB V3.0 - PART 4/4             ║
-- ║  Tab Content & Initialization + Require Script Setup     ║
-- ╚═══════════════════════════════════════════════════════════╝

-- This file continues from PART 3

-- ═══════════════════════════════════════════════════════════
--                    POPULATE TAB CONTENT
-- ═══════════════════════════════════════════════════════════

function UltimateHub:PopulateTabs()
	-- HOME TAB
	self:CreateHomeTab()

	-- EXECUTOR TAB
	self:CreateExecutorTab()

	-- SCANNER TAB
	self:CreateScannerTab()

	-- SCRIPTS TAB
	self:CreateScriptsTab()

	-- PLAYERS TAB
	self:CreatePlayersTab()

	-- WORKSPACE TAB
	self:CreateWorkspaceTab()

	-- QUICK ACTIONS TAB
	self:CreateQuickActionsTab()

	-- CONSOLE TAB
	self:CreateConsoleTab()

	-- SETTINGS TAB
	self:CreateSettingsTab()
end

function UltimateHub:CreateHomeTab()
	local home = self.TabContents["Home"]

	-- Welcome card
	local welcome = Instance.new("Frame")
	welcome.Size = UDim2.new(1, -20, 0, 150)
	welcome.BackgroundColor3 = self.Config.Theme.Surface
	welcome.BorderSizePixel = 0
	welcome.Parent = home

	self.Utility:CreateCorner(welcome, 12)
	self.Utility:CreateGradient(welcome, self.Config.Theme.Primary, self.Config.Theme.Secondary, 45)

	local welcomeTitle = Instance.new("TextLabel")
	welcomeTitle.Size = UDim2.new(1, -40, 0, 40)
	welcomeTitle.Position = UDim2.new(0, 20, 0, 20)
	welcomeTitle.BackgroundTransparency = 1
	welcomeTitle.Text = "Welcome to Ultimate Hub! 🌟"
	welcomeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	welcomeTitle.TextSize = 24
	welcomeTitle.Font = Enum.Font.GothamBlack
	welcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
	welcomeTitle.Parent = welcome

	local welcomeDesc = Instance.new("TextLabel")
	welcomeDesc.Size = UDim2.new(1, -40, 0, 60)
	welcomeDesc.Position = UDim2.new(0, 20, 0, 65)
	welcomeDesc.BackgroundTransparency = 1
	welcomeDesc.Text = "The most advanced serverside executor with AI-powered scanning, 100+ features, and premium animations. Start by running a scan or executing your first script!"
	welcomeDesc.TextColor3 = Color3.fromRGB(230, 230, 230)
	welcomeDesc.TextSize = 14
	welcomeDesc.Font = Enum.Font.Gotham
	welcomeDesc.TextXAlignment = Enum.TextXAlignment.Left
	welcomeDesc.TextWrapped = true
	welcomeDesc.Parent = welcome

	-- Stats cards
	local statsContainer = Instance.new("Frame")
	statsContainer.Size = UDim2.new(1, -20, 0, 200)
	statsContainer.BackgroundTransparency = 1
	statsContainer.Parent = home

	local statsLayout = Instance.new("UIListLayout")
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.Padding = UDim.new(0, 15)
	statsLayout.Parent = statsContainer

	local stats = {
		{icon = "🔍", title = "Scans", value = "0", color = self.Config.Theme.Primary},
		{icon = "💉", title = "Injections", value = "0", color = self.Config.Theme.Success},
		{icon = "⚡", title = "Scripts Run", value = "0", color = self.Config.Theme.Warning}
	}

	for _, stat in ipairs(stats) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(0.32, 0, 1, 0)
		card.BackgroundColor3 = self.Config.Theme.Surface
		card.BorderSizePixel = 0
		card.Parent = statsContainer

		self.Utility:CreateCorner(card, 12)

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0, 60, 0, 60)
		iconLabel.Position = UDim2.new(0, 20, 0, 20)
		iconLabel.BackgroundColor3 = stat.color
		iconLabel.BorderSizePixel = 0
		iconLabel.Text = stat.icon
		iconLabel.TextSize = 30
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.Parent = card

		self.Utility:CreateCorner(iconLabel, 30)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -100, 0, 20)
		titleLabel.Position = UDim2.new(0, 20, 0, 100)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = stat.title
		titleLabel.TextColor3 = self.Config.Theme.TextSecondary
		titleLabel.TextSize = 13
		titleLabel.Font = Enum.Font.Gotham
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = card

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Size = UDim2.new(1, -100, 0, 40)
		valueLabel.Position = UDim2.new(0, 20, 0, 125)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = stat.value
		valueLabel.TextColor3 = self.Config.Theme.Text
		valueLabel.TextSize = 32
		valueLabel.Font = Enum.Font.GothamBlack
		valueLabel.TextXAlignment = Enum.TextXAlignment.Left
		valueLabel.Parent = card
	end

	-- Quick start buttons
	local quickStart = Instance.new("Frame")
	quickStart.Size = UDim2.new(1, -20, 0, 80)
	quickStart.BackgroundTransparency = 1
	quickStart.Parent = home

	local quickLayout = Instance.new("UIListLayout")
	quickLayout.FillDirection = Enum.FillDirection.Horizontal
	quickLayout.Padding = UDim.new(0, 15)
	quickLayout.Parent = quickStart

	self.Components:CreateButton(quickStart, "🔍 Run Scan", nil, UDim2.new(0.48, 0, 0, 60), function()
		self:SwitchTab("Scanner")
		task.wait(0.1)
		-- Auto-start scan
	end, self.Config.Theme.Primary).Parent = quickStart

	self.Components:CreateButton(quickStart, "💻 Open Executor", nil, UDim2.new(0.48, 0, 0, 60), function()
		self:SwitchTab("Executor")
	end, self.Config.Theme.Success).Parent = quickStart
end

function UltimateHub:CreateExecutorTab()
	local executor = self.TabContents["Executor"]

	-- Script input
	local inputContainer = Instance.new("Frame")
	inputContainer.Size = UDim2.new(1, -20, 1, -100)
	inputContainer.BackgroundColor3 = self.Config.Theme.Surface
	inputContainer.BorderSizePixel = 0
	inputContainer.Parent = executor

	self.Utility:CreateCorner(inputContainer, 12)

	local scriptInput = Instance.new("TextBox")
	scriptInput.Size = UDim2.new(1, -20, 1, -20)
	scriptInput.Position = UDim2.new(0, 10, 0, 10)
	scriptInput.BackgroundTransparency = 1
	scriptInput.Text = "-- Enter your serverside Lua code here\nprint('Hello from Ultimate Hub!')"
	scriptInput.TextColor3 = self.Config.Theme.Text
	scriptInput.TextSize = 14
	scriptInput.Font = Enum.Font.Code
	scriptInput.TextXAlignment = Enum.TextXAlignment.Left
	scriptInput.TextYAlignment = Enum.TextYAlignment.Top
	scriptInput.MultiLine = true
	scriptInput.ClearTextOnFocus = false
	scriptInput.Parent = inputContainer

	self.ScriptInput = scriptInput

	-- Button container
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, -20, 0, 60)
	btnContainer.BackgroundTransparency = 1
	btnContainer.Parent = executor

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.Padding = UDim.new(0, 10)
	btnLayout.Parent = btnContainer

	self.Components:CreateButton(btnContainer, "▶ Execute", nil, UDim2.new(0.32, 0, 1, 0), function()
		local code = scriptInput.Text
		if code == "" then
			self.Utility:Notify("Error", "Script is empty!", 2, self.Config.Theme.Error)
			return
		end

		local success, result = self.InjectionEngine:Execute(code)
		if success then
			self.Utility:Notify("Success", "Script executed!", 2, self.Config.Theme.Success)
		else
			self.Utility:Notify("Error", result, 3, self.Config.Theme.Error)
		end
	end, self.Config.Theme.Success).Parent = btnContainer

	self.Components:CreateButton(btnContainer, "🗑️ Clear", nil, UDim2.new(0.32, 0, 1, 0), function()
		scriptInput.Text = ""
	end, self.Config.Theme.Warning).Parent = btnContainer

	self.Components:CreateButton(btnContainer, "💉 Auto Inject", nil, UDim2.new(0.32, 0, 1, 0), function()
		if self.ScanResults then
			local success, msg = self.InjectionEngine:AutoInject(self.ScanResults)
			if success then
				self.StatusLabel.Text = "🟢 " .. msg
				self.Utility:Notify("Injection Success", msg, 3, self.Config.Theme.Success)
			else
				self.Utility:Notify("Injection Failed", msg, 3, self.Config.Theme.Error)
			end
		else
			self.Utility:Notify("Error", "Run a scan first!", 2, self.Config.Theme.Error)
		end
	end, self.Config.Theme.Primary).Parent = btnContainer
end

function UltimateHub:CreateScannerTab()
	local scanner = self.TabContents["Scanner"]

	-- Scan button
	self.Components:CreateButton(scanner, "🔍 Start AI Scan", UDim2.new(0, 0, 0, 0), 
		UDim2.new(1, -20, 0, 60), function()
			self.Utility:Notify("Scanning", "AI scan in progress...", 2, self.Config.Theme.Primary)

			task.spawn(function()
				local results = self.AIAnalyzer:ScanGame()
				self.ScanResults = results

				self.Utility:Notify("Scan Complete", 
					string.format("Found %d backdoors!", #results.backdoors), 
					3, self.Config.Theme.Success)

				-- Display results
				self:DisplayScanResults(results, scanner)
			end)
		end, self.Config.Theme.Primary).Parent = scanner
end

function UltimateHub:DisplayScanResults(results, parent)
	-- Clear existing results
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == "ResultsContainer" then
			child:Destroy()
		end
	end

	local resultsContainer = Instance.new("Frame")
	resultsContainer.Name = "ResultsContainer"
	resultsContainer.Size = UDim2.new(1, -20, 0, 400)
	resultsContainer.BackgroundColor3 = self.Config.Theme.Surface
	resultsContainer.BorderSizePixel = 0
	resultsContainer.LayoutOrder = 2
	resultsContainer.Parent = parent

	self.Utility:CreateCorner(resultsContainer, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = string.format("📊 Found %d Backdoors | %d Remotes | %d Modules", 
		#results.backdoors, #results.remotes, #results.modules)
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = resultsContainer

	-- Scrolling results
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -50)
	scroll.Position = UDim2.new(0, 10, 0, 40)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.Parent = resultsContainer

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.Padding = UDim.new(0, 10)
	scrollLayout.Parent = scroll

	-- Show top backdoors
	for i = 1, math.min(10, #results.backdoors) do
		local backdoor = results.backdoors[i]
		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, -10, 0, 80)
		item.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
		item.BorderSizePixel = 0
		item.Parent = scroll

		self.Utility:CreateCorner(item, 8)

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -100, 0, 25)
		name.Position = UDim2.new(0, 10, 0, 10)
		name.BackgroundTransparency = 1
		name.Text = "⚠️ " .. backdoor.Name
		name.TextColor3 = Color3.fromRGB(255, 255, 255)
		name.TextSize = 14
		name.Font = Enum.Font.GothamBold
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = item

		local risk = Instance.new("TextLabel")
		risk.Size = UDim2.new(0, 60, 0, 60)
		risk.Position = UDim2.new(1, -70, 0, 10)
		risk.BackgroundColor3 = Color3.fromRGB(255, math.floor(255 * (1 - backdoor.RiskScore / 100)), 0)
		risk.Text = tostring(backdoor.RiskScore)
		risk.TextColor3 = Color3.fromRGB(255, 255, 255)
		risk.TextSize = 20
		risk.Font = Enum.Font.GothamBlack
		risk.BorderSizePixel = 0
		risk.Parent = item

		self.Utility:CreateCorner(risk, 8)

		local path = Instance.new("TextLabel")
		path.Size = UDim2.new(1, -100, 0, 20)
		path.Position = UDim2.new(0, 10, 0, 35)
		path.BackgroundTransparency = 1
		path.Text = "📍 " .. backdoor.Path
		path.TextColor3 = Color3.fromRGB(180, 180, 180)
		path.TextSize = 11
		path.Font = Enum.Font.Gotham
		path.TextXAlignment = Enum.TextXAlignment.Left
		path.TextTruncate = Enum.TextTruncate.AtEnd
		path.Parent = item

		self.Components:CreateButton(item, "💉 Exploit", UDim2.new(0, 10, 1, -30), 
			UDim2.new(0, 100, 0, 25), function()
				-- Exploit logic
				if backdoor.Instance:IsA("RemoteEvent") or backdoor.Instance:IsA("RemoteFunction") then
					local success, msg = self.InjectionEngine:InjectRemote(backdoor.Instance)
					if success then
						self.StatusLabel.Text = "🟢 " .. msg
						self.Utility:Notify("Success", msg, 2, self.Config.Theme.Success)
					end
				end
			end, self.Config.Theme.Primary).Parent = item
	end

	scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
	end)
end

function UltimateHub:CreateConsoleTab()
	local console = self.TabContents["Console"]

	local consoleFrame = Instance.new("ScrollingFrame")
	consoleFrame.Size = UDim2.new(1, -20, 1, -80)
	consoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	consoleFrame.BorderSizePixel = 0
	consoleFrame.ScrollBarThickness = 4
	consoleFrame.Parent = console

	self.Utility:CreateCorner(consoleFrame, 12)

	local consoleLayout = Instance.new("UIListLayout")
	consoleLayout.Padding = UDim.new(0, 3)
	consoleLayout.Parent = consoleFrame

	self.ConsoleFrame = consoleFrame
	self.ConsoleLayout = consoleLayout

	-- Clear button
	self.Components:CreateButton(console, "🗑️ Clear Console", nil, UDim2.new(1, -20, 0, 50), function()
		for _, child in ipairs(consoleFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
	end, self.Config.Theme.Error).Parent = console
end

function UltimateHub:CreateSettingsTab()
	local settings = self.TabContents["Settings"]

	local settingsData = {
		{name = "Auto Inject", default = self.Config.AutoInject},
		{name = "Auto Scan", default = self.Config.AutoScan},
		{name = "Show Notifications", default = self.Config.ShowNotifications},
		{name = "Use AI Analysis", default = self.Config.UseAI}
	}

	for _, setting in ipairs(settingsData) do
		self.Components:CreateToggle(settings, setting.name, nil, setting.default, function(state)
			-- Update config
			self.Utility:Notify("Settings", setting.name .. " is now " .. (state and "enabled" or "disabled"), 
				2, self.Config.Theme.Primary)
		end).Parent = settings
	end
end

function UltimateHub:CreateScriptsTab()
	local scripts = self.TabContents["Scripts"]

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "📦 Script Library - Coming Soon!"
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = scripts
end

function UltimateHub:CreatePlayersTab()
	local players = self.TabContents["Players"]

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "👥 Player Management - Coming Soon!"
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = players
end

function UltimateHub:CreateWorkspaceTab()
	local workspace = self.TabContents["Workspace"]

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "🌍 Workspace Tools - Coming Soon!"
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = workspace
end

function UltimateHub:CreateQuickActionsTab()
	local actions = self.TabContents["Quick Actions"]

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "⚡ Quick Actions - Coming Soon!"
	title.TextColor3 = self.Config.Theme.Text
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = actions
end

-- ═══════════════════════════════════════════════════════════
--                    INITIALIZATION
-- ═══════════════════════════════════════════════════════════

function UltimateHub:Initialize()
	print("═══════════════════════════════════════")
	print("  🌟 ULTIMATE HUB V3.0 INITIALIZING...")
	print("═══════════════════════════════════════")

	-- Create loading screen
	local loading, progressBar, status = self.LoadingScreen:Create()

	-- Load steps
	local steps = {
		{text = "Loading core systems...", duration = 0.3},
		{text = "Initializing AI analyzer...", duration = 0.3},
		{text = "Setting up injection engine...", duration = 0.3},
		{text = "Creating UI components...", duration = 0.4},
		{text = "Finalizing setup...", duration = 0.3}
	}

	task.spawn(function()
		for i, step in ipairs(steps) do
			self.LoadingScreen:UpdateProgress(progressBar, status, i / #steps, step.text)
			task.wait(step.duration)
		end

		-- Create main GUI
		self:CreateGUI()

		-- Complete loading
		task.wait(0.5)
		self.LoadingScreen:Complete(loading)

		-- Welcome notification
		task.wait(0.3)
		self.Utility:Notify("Welcome!", "Ultimate Hub v3.0 loaded successfully!", 3, self.Config.Theme.Success)

		-- Auto scan if enabled
		if self.Config.AutoScan then
			task.wait(1)
			self.Utility:Notify("Auto Scan", "Running automatic scan...", 2, self.Config.Theme.Primary)
			task.spawn(function()
				self.ScanResults = self.AIAnalyzer:ScanGame()
			end)
		end
	end)

	print("✅ Ultimate Hub loaded successfully!")
	print("═══════════════════════════════════════")
end

return UltimateHub
