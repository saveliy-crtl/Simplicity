--[=[
	Roblox UI Library Bundle
	Generated at: 2026-07-07 03:53:04
	Simple, Beautiful, Proper
]=]

local modules = {}
local function require(name)
    local module = modules[name]
    if not module then
        error("Module '" .. tostring(name) .. "' not found in bundle.")
    end
    if type(module) == "function" then
        modules[name] = module()
        return modules[name]
    end
    return module
end

-- MODULE: theme
modules["theme"] = function()local FontRegular = Font.fromEnum(Enum.Font.Gotham)
local FontMedium = Font.fromEnum(Enum.Font.GothamMedium)
local FontSemibold = Font.fromEnum(Enum.Font.GothamBold)

pcall(function()
    FontRegular = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    FontMedium = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    FontSemibold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
end)

local Theme = {
    
    -- Core colors (Deep Charcoal / Royal Purple Dark theme)
    Background = Color3.fromRGB(18, 18, 22),        -- Deep Charcoal Black
    Sidebar = Color3.fromRGB(13, 13, 16),          -- Sleek darker sidebar
    Header = Color3.fromRGB(24, 24, 28),           -- Elevated Header Panel
    Card = Color3.fromRGB(28, 28, 34),             -- Slate Card Surface
    CardHover = Color3.fromRGB(36, 36, 44),        -- Card Surface Hover
    
    -- Accent colors (Emerald Green & Teal gradient)
    Accent = Color3.fromRGB(16, 185, 129),         -- Emerald Green (Vibrant Accent)
    AccentGradientStart = Color3.fromRGB(16, 185, 129),
    AccentGradientEnd = Color3.fromRGB(52, 211, 153), -- Light Mint Green
    
    -- Borders and strokes
    Border = Color3.fromRGB(40, 40, 48),           -- Dark Gray Border
    BorderActive = Color3.fromRGB(16, 185, 129),   -- Active Green Border
    BorderMuted = Color3.fromRGB(24, 24, 28),       -- Muted Sidebar Border
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),   -- Pure White
    TextSecondary = Color3.fromRGB(161, 161, 170), -- Muted Gray (Zinc 400)
    TextMuted = Color3.fromRGB(113, 113, 122),     -- Dark Gray (Zinc 500)
    
    -- Status colors
    Success = Color3.fromRGB(16, 185, 129),        -- Emerald Green
    Failure = Color3.fromRGB(239, 68, 68),         -- Crimson Red
    
    -- Typography
    FontSemibold = FontSemibold,
    FontMedium = FontMedium,
    FontRegular = FontRegular,
    
    -- Sizing & Layouts
    CornerRadius = UDim.new(0, 12),
    CornerRadiusSmall = UDim.new(0, 6),
    
    -- Tweens
    TweenSpeed = 0.25,
    TweenEasing = Enum.EasingStyle.Quad,
    TweenDirection = Enum.EasingDirection.Out
}

return Theme
end

-- MODULE: utility
modules["utility"] = function()local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local spr = require("packages/spr")

local Utility = {}

-- Safely get CoreGui or fallback to PlayerGui
function Utility.GetCoreGui()
    local success, coreGui = pcall(function()
        return CoreGui
    end)
    if success and coreGui then
        return coreGui
    end
    
    local player = Players.LocalPlayer
    if player then
        return player:WaitForChild("PlayerGui")
    end
    
    error("Could not locate CoreGui or PlayerGui")
end

-- Smooth Tween Helper (powered by spr spring physics, critically damped for smooth, non-springy motion)
function Utility.Tween(instance, properties, duration, style, direction)
    -- Critically damped (1.0 damping ratio) ensures smooth deceleration with zero bounce or spring overshoot
    spr.target(instance, 1.0, 5.0, properties)
    
    local completedBindable = Instance.new("BindableEvent")
    spr.completed(instance, function()
        completedBindable:Fire()
    end)
    
    return {
        Completed = completedBindable.Event,
        Cancel = function()
            spr.stop(instance)
        end
    }
end

-- Declarative Instance Creator
function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            if key == "Font" and typeof(value) == "Font" then
                instance.FontFace = value
            else
                instance[key] = value
            end
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    
    -- Assign Parent last for performance optimization
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Make GUI Draggable (Smooth and responsive)
function Utility.MakeDraggable(frame, dragHandle, blockCondition)
    local dragging = false
    local dragStart
    local startPosition

    dragHandle.InputBegan:Connect(function(input)
        if blockCondition and blockCondition() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            
            -- Adjust delta if a UIScale exists in the frame
            local scale = 1
            local uiScale = frame:FindFirstChildOfClass("UIScale")
            if uiScale then
                scale = uiScale.Scale
            end
            
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + (delta.X / scale),
                startPosition.Y.Scale,
                startPosition.Y.Offset + (delta.Y / scale)
            )
        end
    end)
end

-- Safe Filesystem Helpers (for executors)
Utility.IsExecutor = (writefile and readfile and isfile) and true or false

function Utility.WriteConfig(folder, name, data)
    if not Utility.IsExecutor then
        warn("Not running in exploit executor environment. Cannot save config to disk.")
        return false
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if not success then
        warn("Failed to encode config data: " .. tostring(encoded))
        return false
    end
    
    -- Ensure folder exists
    pcall(function()
        if isfolder and not isfolder(folder) then
            makefolder(folder)
        end
    end)
    
    local path = folder .. "/" .. name .. ".json"
    local writeSuccess, err = pcall(function()
        writefile(path, encoded)
    end)
    
    if not writeSuccess then
        warn("Failed to write config file: " .. tostring(err))
        return false
    end
    
    return true
end

function Utility.ReadConfig(folder, name)
    if not Utility.IsExecutor then
        warn("Not running in exploit executor environment. Cannot read config from disk.")
        return nil
    end
    
    local path = folder .. "/" .. name .. ".json"
    
    local fileExists = false
    pcall(function()
        fileExists = isfile(path)
    end)
    
    if not fileExists then
        return nil
    end
    
    local success, content = pcall(function()
        return readfile(path)
    end)
    
    if not success then
        warn("Failed to read config file: " .. tostring(content))
        return nil
    end
    
    local decodeSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    
    if not decodeSuccess then
        warn("Failed to decode config: " .. tostring(decoded))
        return nil
    end
    
    return decoded
end

function Utility.ListConfigs(folder)
    if not Utility.IsExecutor or not listfiles then
        return {}
    end
    
    pcall(function()
        if isfolder and not isfolder(folder) then
            makefolder(folder)
        end
    end)
    
    local configs = {}
    local success, files = pcall(function()
        return listfiles(folder)
    end)
    
    if success and type(files) == "table" then
        for _, file in ipairs(files) do
            -- Extract file name without directory and extension
            -- example: "usefulhub_configs/combat.json" -> "combat"
            local cleanName = file:match("([^/\\]+)%.json$")
            if cleanName then
                table.insert(configs, cleanName)
            end
        end
    end
    
    return configs
end

-- Add a tactile ripple circle effect on click/press
function Utility.AddClickEffect(button)
    button.ClipsDescendants = false
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- Get accumulated UIScale factor
            local scale = 1
            local curr = button
            while curr do
                local uiScale = curr:FindFirstChildOfClass("UIScale")
                if uiScale then
                    scale = scale * uiScale.Scale
                end
                curr = curr.Parent
            end
            
            -- Calculate click relative position
            local localX = (input.Position.X - button.AbsolutePosition.X) / scale
            local localY = (input.Position.Y - button.AbsolutePosition.Y) / scale
            
            -- Create ripple circle
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = UDim2.new(0, localX, 0, localY)
            ripple.Size = UDim2.new(0, 2, 0, 2)
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.92 -- Highly transparent/subtle
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 10
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 9999) -- Huge offset guarantees a perfect circle rendering in Roblox
            corner.Parent = ripple
            
            ripple.Parent = button
            
            -- Localized target size (uses shorter edge to fit within the button, ensuring zero corner clipping)
            local diameter = math.max(math.min(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5, 45)
            
            -- Tween expand and fade (using TweenService directly with 0.35s duration for a snappy response)
            local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(ripple, tweenInfo, {
                Size = UDim2.new(0, diameter, 0, diameter),
                BackgroundTransparency = 1
            })
            tween:Play()
            
            task.delay(0.35, function()
                ripple:Destroy()
            end)
        end
    end)
end

-- Safely add native 2D drop shadow to a GUI object (using Roblox's native UIShadow API)
function Utility.AddShadow(parent, options)
    options = options or {}
    local success, shadow = pcall(function()
        local s = Instance.new("UIShadow")
        s.BlurRadius = options.BlurRadius or UDim.new(0, 16)
        s.Color = options.Color or Color3.fromRGB(0, 0, 0)
        s.Offset = options.Offset or UDim2.new(0, 0, 0, 4)
        s.Spread = options.Spread or UDim2.new(0, 0, 0, 0)
        s.Transparency = options.Transparency or 0.55
        s.Enabled = true
        s.Parent = parent
        return s
    end)
    return success and shadow or nil
end

-- Safely fetch external HTTP data (executor only)
function Utility.HttpGet(url)
    if game.HttpGet then
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            return result
        end
    end
    return nil
end

-- Safely download and get custom asset URL for custom images (executor only)
function Utility.GetCustomAsset(url)
    -- If already an asset URL, local path, or not running in executor, return as is
    if not url or string.find(url, "rbxassetid://") or string.find(url, "asset/%%?id=") or not Utility.IsExecutor or not writefile or not game.HttpGet then
        return url
    end
    
    local success, asset = pcall(function()
        local filename = "uselesshub_assets/" .. string.match(url, "([^/]+)$")
        if not string.find(filename, "%%.") then
            filename = filename .. ".png"
        end
        
        -- Check if file already exists
        local fileExists = false
        pcall(function()
            fileExists = isfile(filename)
        end)
        
        if not fileExists then
            -- Create assets folder if not exists
            pcall(function()
                if isfolder and not isfolder("uselesshub_assets") then
                    makefolder("uselesshub_assets")
                end
            end)
            
            local content = game:HttpGet(url)
            writefile(filename, content)
        end
        
        if getcustomasset then
            return getcustomasset(filename)
        end
        return filename
    end)
    
    return success and asset or url
end

-- Safely set text to executor clipboard
function Utility.SetClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
    elseif toclipboard then
        pcall(toclipboard, text)
    else
        warn("Clipboard copy not supported in this environment.")
    end
end

return Utility
end

-- MODULE: analytics/manager
modules["analytics/manager"] = function()local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local Analytics = {
    WebhookUrl = "https://discord.com/api/webhooks/1498717786732499105/RFlV6H2PyNQHqB3tzbBtV31tDIU4TtBsFM1K2WSIKRvem7NIsGQwDUTOGXTBurPkeOM5",
    StartTime = os.time(),
    SessionId = HttpService:GenerateGUID(false):sub(1, 8)
}

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        LocalPlayer = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    end)
end

local placeName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then
        placeName = info.Name
    end
end)

local function getExecutor()
    if identifyexecutor then
        local name, version = identifyexecutor()
        return name .. (version and (" " .. version) or "")
    elseif getexecutorname then
        return getexecutorname()
    end
    if syn then return "Synapse" end
    if KRNL_LOADED then return "Krnl" end
    if fluxus then return "Fluxus" end
    if Sentinel then return "Sentinel" end
    return "Unknown Executor"
end

local function getProfile()
    return {
        Username = LocalPlayer and LocalPlayer.Name or "N/A",
        DisplayName = LocalPlayer and LocalPlayer.DisplayName or "N/A",
        UserId = LocalPlayer and LocalPlayer.UserId or 0,
        AccountAge = LocalPlayer and LocalPlayer.AccountAge or 0,
        Membership = LocalPlayer and tostring(LocalPlayer.MembershipType):gsub("Enum.MembershipType.", "") or "None",
        PlaceName = placeName,
        PlaceId = game.PlaceId,
        UniverseId = game.GameId,
        JobId = game.JobId ~= "" and game.JobId or "N/A",
        PlayersCount = #Players:GetPlayers(),
        MaxPlayers = Players.MaxPlayers,
        Executor = getExecutor(),
        SessionId = Analytics.SessionId,
        Duration = os.time() - Analytics.StartTime
    }
end

function Analytics:SetWebhook(url)
    self.WebhookUrl = url
end

function Analytics:Send(eventType, details)
    if not self.WebhookUrl or self.WebhookUrl == "" then
        return
    end
    
    local profile = getProfile()
    local embed = {
        title = "Useless Key System - " .. eventType,
        color = 16737380, -- Hex: #FF0264 (Nice reddish pink accent for Key System)
        thumbnail = {
            url = "https://i.ibb.co/67yYjfG6/Group-2.png"
        },
        fields = {
            {
                name = "Player Profile",
                value = string.format(
                    "**Username:** %s\n**Display:** %s\n**ID:** %d\n**Age:** %d days\n**Membership:** %s",
                    profile.Username,
                    profile.DisplayName,
                    profile.UserId,
                    profile.AccountAge,
                    profile.Membership
                ),
                inline = true
            },
            {
                name = "Game Session",
                value = string.format(
                    "**Game:** %s\n**ID:** [%d](https://www.roblox.com/games/%d)\n**Players:** %d/%d\n**JobId:** `%s`",
                    profile.PlaceName,
                    profile.PlaceId,
                    profile.PlaceId,
                    profile.PlayersCount,
                    profile.MaxPlayers,
                    profile.JobId
                ),
                inline = true
            },
            {
                name = "Client Details",
                value = string.format(
                    "**Executor:** %s\n**Time Spent:** %d seconds\n**Session ID:** `%s`",
                    profile.Executor,
                    profile.Duration,
                    profile.SessionId
                ),
                inline = false
            }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    if details then
        table.insert(embed.fields, 2, {
            name = "Action / Event",
            value = details,
            inline = false
        })
    end
    
    local payload = {
        username = "Useless Key System Logger",
        avatar_url = "https://i.ibb.co/67yYjfG6/Group-2.png",
        embeds = { embed }
    }
    
    local json = HttpService:JSONEncode(payload)
    
    task.spawn(function()
        local success, err = pcall(function()
            local requestFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
            if requestFunc then
                requestFunc({
                    Url = self.WebhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = json
                })
            elseif game.HttpPost then
                game:HttpPost(self.WebhookUrl, json, "application/json")
            end
        end)
        if not success then
            warn("Failed to send KeySystem Discord webhook: " .. tostring(err))
        end
    end)
end

return Analytics
end

-- MODULE: components/Window
modules["components/Window"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

function Window.new(title, options)
    local self = setmetatable({}, Window)
    
    -- Support passing options as the first argument or second argument
    if type(title) == "table" then
        options = title
        title = "Useless Hub"
    end
    
    options = options or {}
    self.Title = title or "Useless Hub"
    self.CorrectKey = options.key or options.Key or "UselessFihz0"
    self.Discord = options.discord or options.Discord or "https://discord.gg/24fsRNH5K"
    self.Callback = options.callback or options.Callback or function() end
    self.Closed = false
    
    -- Main ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "UselessKeySystem_Gui",
        Parent = Utility.GetCoreGui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Centered pivot container for scaling & positioning
    self.Container = Utility.Create("Frame", {
        Name = "WindowContainer",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 340, 0, 240),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius })
    })
    
    -- Native drop shadow
    Utility.AddShadow(self.Container, {
        BlurRadius = UDim.new(0, 24),
        Transparency = 0.5
    })
    
    -- Main Frame (CanvasGroup for seamless group transparency fading)
    self.MainFrame = Utility.Create("CanvasGroup", {
        Name = "MainFrame",
        Parent = self.Container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })
    
    -- Header
    self.Header = Utility.Create("Frame", {
        Name = "Header",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    -- Cover bottom corners of the header to only keep top corners rounded
    Utility.Create("Frame", {
        Name = "HeaderOverlap",
        Parent = self.Header,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 1
    })
    
    -- Divider line
    Utility.Create("Frame", {
        Name = "Divider",
        Parent = self.Header,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    local headerContent = Utility.Create("Frame", {
        Name = "HeaderContent",
        Parent = self.Header,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    
    -- Key Icon
    Lucide.ImageLabel("vpn_key", 16, {
        Name = "KeyIcon",
        Parent = headerContent,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 15, 0.5, -8),
        ImageColor3 = Theme.Accent
    })
    
    -- Title Label
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = headerContent,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title .. " | Key Verification",
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        Font = Theme.FontSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close Button
    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseButton",
        Parent = headerContent,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0.5, -15),
        BackgroundTransparency = 1,
        Text = ""
    }, {
        Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = Lucide.GetAsset("x", 48).Url,
            ImageRectSize = Lucide.GetAsset("x", 48).ImageRectSize,
            ImageRectOffset = Lucide.GetAsset("x", 48).ImageRectOffset,
            ImageColor3 = Theme.TextSecondary
        })
    })
    
    local closeIcon = closeBtn:FindFirstChild("Icon")
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeIcon, { ImageColor3 = Theme.Failure }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeIcon, { ImageColor3 = Theme.TextSecondary }, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Close(false)
    end)
    Utility.AddClickEffect(closeBtn)
    
    -- Make window draggable via Header
    Utility.MakeDraggable(self.Container, self.Header)
    
    -- Content container
    local content = Utility.Create("Frame", {
        Name = "Content",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16)
        })
    })
    
    -- Info Card
    local infoCard = Utility.Create("Frame", {
        Name = "InfoCard",
        Parent = content,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        LayoutOrder = 1
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12)
        })
    })
    
    -- Info Icon
    Lucide.ImageLabel("info", 16, {
        Name = "InfoIcon",
        Parent = infoCard,
        ImageColor3 = Theme.Accent,
        LayoutOrder = 1
    })
    
    -- Info Label
    Utility.Create("TextLabel", {
        Name = "InfoLabel",
        Parent = infoCard,
        Size = UDim2.new(1, -26, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "To access the script interface, join our Discord server to copy the verification key.",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2
    })
    
    -- Textbox holder for key
    local inputHolder = Utility.Create("Frame", {
        Name = "InputHolder",
        Parent = content,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        LayoutOrder = 2
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Name = "Stroke",
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12)
        })
    })
    
    local inputStroke = inputHolder:FindFirstChild("Stroke")
    
    local keyIcon = Lucide.ImageLabel("vpn_key", 16, {
        Name = "KeyIcon",
        Parent = inputHolder,
        ImageColor3 = Theme.TextMuted,
        LayoutOrder = 1
    })
    
    local keyTextBox = Utility.Create("TextBox", {
        Name = "KeyInput",
        Parent = inputHolder,
        Size = UDim2.new(1, -26, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Enter key here...",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        LayoutOrder = 2
    })
    
    -- CanvasGroup Textbox Focus Bug Workaround
    inputHolder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            keyTextBox:CaptureFocus()
        end
    end)
    
    keyTextBox.Focused:Connect(function()
        Utility.Tween(inputStroke, { Color = Theme.Accent }, 0.15)
        Utility.Tween(keyIcon, { ImageColor3 = Theme.Accent }, 0.15)
    end)
    keyTextBox.FocusLost:Connect(function()
        Utility.Tween(inputStroke, { Color = Theme.Border }, 0.15)
        Utility.Tween(keyIcon, { ImageColor3 = Theme.TextMuted }, 0.15)
    end)
    
    -- Action buttons container
    local buttonsContainer = Utility.Create("Frame", {
        Name = "Buttons",
        Parent = content,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        LayoutOrder = 3
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    
    -- Get Key Button
    local getKeyBtn = Utility.Create("TextButton", {
        Name = "GetKey",
        Parent = buttonsContainer,
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "Get Key",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemibold,
        AutoButtonColor = false,
        LayoutOrder = 1
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", { Color = Theme.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    })
    
    local getKeyStroke = getKeyBtn:FindFirstChildOfClass("UIStroke")
    
    getKeyBtn.MouseEnter:Connect(function()
        Utility.Tween(getKeyBtn, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    getKeyBtn.MouseLeave:Connect(function()
        Utility.Tween(getKeyBtn, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    getKeyBtn.MouseButton1Down:Connect(function()
        Utility.Tween(getKeyBtn, { BackgroundColor3 = Theme.Card }, 0.05)
    end)
    getKeyBtn.MouseButton1Up:Connect(function()
        Utility.Tween(getKeyBtn, { BackgroundColor3 = Theme.CardHover }, 0.1)
        Utility.SetClipboard(self.Discord)
        getKeyBtn.Text = "Invite Copied!"
        task.delay(1.5, function()
            getKeyBtn.Text = "Get Key"
        end)
        
        -- Trigger analytics
        local Analytics = require("analytics/manager")
        Analytics:Send("Discord Link Copied", "Player clicked the Get Key button to copy the Discord invitation link.")
    end)
    Utility.AddClickEffect(getKeyBtn)
    
    -- Verify Button
    local verifyBtn = Utility.Create("TextButton", {
        Name = "Verify",
        Parent = buttonsContainer,
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Verify Key",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemibold,
        AutoButtonColor = false,
        LayoutOrder = 2
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius })
    })
    
    local accentHover = Theme.AccentHover or Color3.fromRGB(5, 150, 105)
    
    local function verify()
        local inputKey = keyTextBox.Text
        if inputKey == self.CorrectKey then
            verifyBtn.Text = "Key Verified!"
            verifyBtn.BackgroundColor3 = Theme.Success
            self:ShowNotification("Key verified! Loading...", 2.5, "verified")
            task.delay(0.5, function()
                self:Close(true)
            end)
        else
            verifyBtn.Text = "Incorrect Key!"
            verifyBtn.BackgroundColor3 = Theme.Failure
            Utility.Tween(inputStroke, { Color = Theme.Failure }, 0.1)
            Utility.Tween(keyIcon, { ImageColor3 = Theme.Failure }, 0.1)
            self:ShowNotification("Incorrect key. Access denied!", 3, "cancel", Theme.Failure)
            
            -- Trigger analytics
            local Analytics = require("analytics/manager")
            Analytics:Send("Incorrect Key Entered", string.format("Attempted verification with key: `\"%s\"`", inputKey))
            
            -- Shake animation
            local origPos = inputHolder.Position
            task.spawn(function()
                for i = 1, 6 do
                    local offset = (i % 2 == 0) and 4 or -4
                    inputHolder.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + offset, origPos.Y.Scale, origPos.Y.Offset)
                    task.wait(0.04)
                end
                inputHolder.Position = origPos
            end)
            
            task.delay(1.5, function()
                verifyBtn.Text = "Verify Key"
                verifyBtn.BackgroundColor3 = Theme.Accent
                local targetColor = keyTextBox.Focused and Theme.Accent or Theme.Border
                local targetIconColor = keyTextBox.Focused and Theme.Accent or Theme.TextMuted
                Utility.Tween(inputStroke, { Color = targetColor }, 0.15)
                Utility.Tween(keyIcon, { ImageColor3 = targetIconColor }, 0.15)
            end)
        end
    end
    
    verifyBtn.MouseEnter:Connect(function()
        if verifyBtn.Text == "Verify Key" then
            Utility.Tween(verifyBtn, { BackgroundColor3 = accentHover }, 0.15)
        end
    end)
    verifyBtn.MouseLeave:Connect(function()
        if verifyBtn.Text == "Verify Key" then
            Utility.Tween(verifyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
        end
    end)
    verifyBtn.MouseButton1Up:Connect(function()
        verify()
    end)
    Utility.AddClickEffect(verifyBtn)
    
    keyTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verify()
        end
    end)
    
    -- Animations & Responsive Scale Setup
    self.UIScale = Utility.Create("UIScale", {
        Name = "UIScale",
        Parent = self.Container,
        Scale = 0.94
    })
    
    self.AppearScaleValue = Instance.new("NumberValue")
    self.AppearScaleValue.Name = "AppearScaleValue"
    self.AppearScaleValue.Value = 0.94
    self.AppearScaleValue.Parent = self.Container
    
    self.ResponsiveScale = 1
    
    local function updateActualScale()
        self.UIScale.Scale = self.ResponsiveScale * self.AppearScaleValue.Value
    end
    
    self.AppearScaleValue.Changed:Connect(updateActualScale)
    
    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewportSize = camera.ViewportSize
        local width = viewportSize.X
        local height = viewportSize.Y
        
        local scale = 1
        -- Only scale down on smaller mobile/tablet viewports (PC is kept at 1)
        if width < 1000 or height < 600 then
            local scaleX = width / 1000
            local scaleY = height / 600
            scale = math.min(scaleX, scaleY)
            -- Clamp scale so it doesn't get ridiculously small (min 0.65)
            scale = math.clamp(scale, 0.65, 1)
        end
        self.ResponsiveScale = scale
        updateActualScale()
    end

    updateScale()
    self.ViewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    
    -- Show UI
    local shadow = self.Container:FindFirstChild("Shadow")
    if shadow then shadow.Transparency = 1 end
    
    TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = 1.0 }):Play()
    Utility.Tween(self.MainFrame, { GroupTransparency = 0 }, 0.15)
    if shadow then
        Utility.Tween(shadow, { Transparency = 0.5 }, 0.15)
    end
    
    -- Trigger analytics
    local Analytics = require("analytics/manager")
    Analytics:Send("KeySystem Opened", "The player opened the Key Verification interface.")
    
    return self
end

function Window:Close(success)
    if self.Closed then return end
    self.Closed = true
    
    if self.ViewportConnection then
        self.ViewportConnection:Disconnect()
    end
    
    -- Trigger analytics before closing
    local Analytics = require("analytics/manager")
    if success then
        Analytics:Send("Successful Verification", "Key successfully verified. Proceeding to load main script.")
    else
        Analytics:Send("KeySystem Closed", "Player manually closed/cancelled the Key System.")
    end
    
    local shadow = self.Container:FindFirstChild("Shadow")
    local tween = TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 0.94 })
    tween:Play()
    Utility.Tween(self.MainFrame, { GroupTransparency = 1 }, 0.1)
    if shadow then
        Utility.Tween(shadow, { Transparency = 1 }, 0.1)
    end
    
    tween.Completed:Wait()
    self.ScreenGui:Destroy()
    
    if success and self.Callback then
        task.spawn(self.Callback)
    end
end

function Window:ShowNotification(text, duration, iconName, iconColor)
    duration = duration or 3
    iconName = iconName or "info"
    iconColor = iconColor or Theme.Accent
    
    local notificationHeight = 34
    
    -- Animate out any existing notification
    if self.ActiveNotification then
        local oldNotification = self.ActiveNotification
        self.ActiveNotification = nil
        
        local slideUp = TweenService:Create(oldNotification, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 0, 0, 45 - notificationHeight)
        })
        slideUp:Play()
        task.spawn(function()
            slideUp.Completed:Wait()
            oldNotification:Destroy()
        end)
    end
    
    -- Create new notification banner
    local notification = Utility.Create("Frame", {
        Name = "NotificationBanner",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, notificationHeight),
        Position = UDim2.new(0, 0, 0, 45 - notificationHeight), -- Hidden under header
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        ZIndex = 2
    }, {
        -- Bottom separating line
        Utility.Create("Frame", {
            Name = "BottomBorder",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 3
        }),
        -- Left Icon
        Lucide.ImageLabel(iconName, 14, {
            Name = "Icon",
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 15, 0.5, -7),
            ImageColor3 = iconColor,
            ZIndex = 3
        }),
        -- Right Text
        Utility.Create("TextLabel", {
            Name = "Message",
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 36, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 3
        })
    })
    
    self.ActiveNotification = notification
    
    -- Slide down animation
    local slideDown = TweenService:Create(notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 45)
    })
    slideDown:Play()
    
    -- Auto-dismiss after duration
    task.spawn(function()
        task.wait(duration)
        if self.ActiveNotification == notification then
            self.ActiveNotification = nil
            local slideUp = TweenService:Create(notification, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 0, 0, 45 - notificationHeight)
            })
            slideUp:Play()
            slideUp.Completed:Wait()
            notification:Destroy()
        end
    end)
    
    return notification
end

function Window:Notification(text, duration, iconName, iconColor)
    return self:ShowNotification(text, duration, iconName, iconColor)
end

return Window
end

-- MODULE: guard/init
modules["guard/init"] = function()--[=[
    Guard Module - Anti-HTTP Spy & Hook Blocker
    Protects network functions from being hooked or monitored by HTTP Spies.
]=]

local Theme = require("theme")

-- Cache original exploit APIs if available
local hookfunc = hookfunction or detour_function or replaceclosure
local hookmetamethod = hookmetamethod or hookmetamethods
local clonefunc = clonefunction

local protected = {}

-- Safely identify target functions to protect
local function registerProtected(func)
    if type(func) == "function" then
        protected[func] = true
    elseif type(func) == "table" and type(rawget(func, "request")) == "function" then
        protected[func.request] = true
    end
end

-- Populate target functions
registerProtected(game.HttpGet)
registerProtected(game.HttpGetAsync)
registerProtected(game.HttpPost)

if request then registerProtected(request) end
if http_request then registerProtected(http_request) end
if syn and syn.request then registerProtected(syn.request) end
if fluxus and fluxus.request then registerProtected(fluxus.request) end
if http and http.request then registerProtected(http.request) end

-- Cache clean clones of network functions for internal secure requests (if clonefunction exists)
local secure = {}
if clonefunc then
    pcall(function() secure.HttpGet = clonefunc(game.HttpGet) end)
    pcall(function() secure.HttpGetAsync = clonefunc(game.HttpGetAsync) end)
    pcall(function() secure.HttpPost = clonefunc(game.HttpPost) end)
    if request then pcall(function() secure.request = clonefunc(request) end) end
    if http_request then pcall(function() secure.http_request = clonefunc(http_request) end) end
else
    -- Fallback to originals
    secure.HttpGet = game.HttpGet
    secure.HttpGetAsync = game.HttpGetAsync
    secure.HttpPost = game.HttpPost
    secure.request = request
    secure.http_request = http_request
end

-- Hook 'hookfunction' to prevent external scripts from hooking network calls
if hookfunc then
    local oldHookFunction
    pcall(function()
        oldHookFunction = hookfunc(hookfunc, function(target, hook)
            if protected[target] then
                -- Silently bypass the hook: return the original function so the HTTP Spy thinks it succeeded,
                -- but do NOT actually replace the original closure.
                return target
            end
            return oldHookFunction(target, hook)
        end)
    end)
end

-- Hook 'hookmetamethod' to prevent namecall/index hooks on network calls of game
if hookmetamethod and hookfunc then
    local oldHookMetamethod
    pcall(function()
        oldHookMetamethod = hookfunc(hookmetamethod, function(object, metamethod, hook)
            if object == game and (metamethod == "__namecall" or metamethod == "__index") then
                local originalHook = hook
                if metamethod == "__namecall" then
                    hook = function(self, ...)
                        local method = getnamecallmethod()
                        if self == game and (method == "HttpGet" or method == "HttpGetAsync" or method == "HttpPost") then
                            -- Bypass the hook and use our secure cache to service the call directly
                            local secureFunc = secure[method] or game[method]
                            return secureFunc(self, ...)
                        end
                        return originalHook(self, ...)
                    end
                elseif metamethod == "__index" then
                    hook = function(self, key)
                        if self == game and (key == "HttpGet" or key == "HttpGetAsync" or key == "HttpPost") then
                            -- Return our secure cached function
                            return secure[key] or game[key]
                        end
                        return originalHook(self, key)
                    end
                end
            end
            return oldHookMetamethod(object, metamethod, hook)
        end)
    end)
end

-- Run anti-sandboxing / detection guard self-checks
local function performSelfChecks()
    -- 1. Invalid method call check
    local invalidMethodSuccess = pcall(function()
        Instance.new("Part"):InvalidMethod("a")
    end)
    if invalidMethodSuccess then
        while true do
            task.spawn()
        end
    end

    -- 2. Function exploration detection
    game:GetChildren(function()
        while true do
            ({})[nil] = true
        end
    end)

    -- 3. Service amount checking
    if #game:GetChildren() <= 4 then
        while true do
            buffer.writei8(buffer.fromstring("a"), 1, 2)
        end
    end

    -- 4. HttpService JSONDecode behavior check
    local decodeSuccess, decodeResult = pcall(function()
        return game:GetService("HttpService"):JSONDecode('[68, "getgold.cc", true, 123, false, [321, null, "goldtm"], null, ["a"]]')
    end)
    if not decodeSuccess then
        while true do
            task()
        end
    end
    if decodeResult[6][2] ~= nil then
        while true do
            (true)()
        end
    end

    -- 5. Service indexing verification
    local serviceIndexSuccess = pcall(function()
        return game.HttpService
    end)
    if not serviceIndexSuccess then
        while true do
            local _ = (nil).Parent
        end
    end

    -- 6. _G vs getfenv separation test
    _G.getgoldcc = "goldtm"
    if getfenv().getgoldcc ~= nil then
        while true do
            game()
        end
    end
    _G.getgoldcc = nil

    -- 7. Game object identity validation
    local _, gameCallMessage = pcall(function()
        game()
    end)
    if not gameCallMessage or not gameCallMessage:find("attempt to call a Instance value") then
        while true do
            table.create(9e9)
        end
    end
end

pcall(performSelfChecks)

return secure
end

-- MODULE: packages/lucide-roblox
modules["packages/lucide-roblox"] = function()--!strict
-- Material Roblox Wrapper pretending to be Lucide-Roblox for convenience and compatibility

local material = require("packages/material-roblox/init")
local sheet = material.outlined.dp_48.scale_2

local iconMapping = {
    ["x"] = "close",
    ["minus"] = "remove",
    ["chevron-down"] = "keyboard_arrow_down",
    ["search"] = "search"
}

local function translateIconName(name)
    name = string.lower(name)
    if iconMapping[name] then
        return iconMapping[name]
    end
    return string.gsub(name, "%-", "_")
end

local Lucide = {}

function Lucide.GetAsset(iconName: string, iconSize: number?)
    local targetName = translateIconName(iconName)
    local size = iconSize or 24
    
    local iconData = sheet[targetName]
    if not iconData then
        -- Fallback to help icon if not found
        iconData = sheet.help or sheet.info
    end
    
    if iconData then
        return {
            IconName = iconName,
            Id = tonumber(string.match(iconData.Image, "%d+")) or 0,
            Url = iconData.Image,
            ImageRectSize = iconData.ImageRectSize,
            ImageRectOffset = iconData.ImageRectOffset
        }
    end
    
    error("Material Icon not found: " .. tostring(iconName))
end

function Lucide.ImageLabel(iconName: string, iconSize: number?, propertyOverrides: {[string]: any}?)
    local size = iconSize or 24
    local props = propertyOverrides or {}
    local r = Lucide.GetAsset(iconName, size)
    
    local label = Instance.new("ImageLabel")
    label.Name = r.IconName
    label.Size = UDim2.fromOffset(size, size)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Image = r.Url
    label.ImageRectSize = r.ImageRectSize
    label.ImageRectOffset = r.ImageRectOffset
    label.ScaleType = Enum.ScaleType.Fit
    
    for k, v in pairs(props) do
        if k ~= "Parent" then
            label[k] = v
        end
    end
    if props.Parent then
        label.Parent = props.Parent
    end
    
    return label
end

return Lucide
end

-- MODULE: packages/spr
modules["packages/spr"] = function()---------------------------------------------------------------------
-- spr - Spring-driven motion library
--
-- Copyright (c) 2023 Fractality. All rights reserved.
-- Released under the MIT license.
--
-- Docs & license can be found at https://github.com/Fraktality/spr
--
-- API Summary:
--
-- spr.target(
--    Instance obj,
--    number dampingRatio,
--    number undampedFrequency,
--    dict<string, Variant> targetProperties)
--
--    Animates the given properties towardes the target values,
--    given damping ratio and undamped frequency.
--
--
-- spr.stop(
--    Instance obj[,
--    string property])
--
--    Stops the specified property on an Instance from animating.
--    If no property is specified, all properties of the Instance
--    will stop animating.
--
-- Visualizer: https://www.desmos.com/calculator/rzvw27ljh9
---------------------------------------------------------------------

local STRICT_RUNTIME_TYPES = true -- assert on parameter and property type mismatch
local SLEEP_OFFSET_SQ_LIMIT = (1/3840)^2 -- square of the offset sleep limit
local SLEEP_VELOCITY_SQ_LIMIT = 1e-2^2 -- square of the velocity sleep limit
local SLEEP_ROTATION_OFFSET = math.rad(0.01) -- rad
local SLEEP_ROTATION_VELOCITY = math.rad(0.1) -- rad/s
local EPS = 1e-5 -- epsilon for stability checks around pathological frequency/damping values
local AXIS_MATRIX_EPS = 1e-6 -- epsilon for converting from axis-angle to matrix

local RunService = game:GetService("RunService")

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local min = math.min
local sqrt = math.sqrt
local round = math.round

local function magnitudeSq(vec)
	local out = 0
	for _, v in ipairs(vec) do
		out = out + v^2
	end
	return out
end

local function distanceSq(vec0, vec1)
	local out = 0
	for i0, v0 in ipairs(vec0) do
		out = out + (vec1[i0] - v0)^2
	end
	return out
end

-- Spring for an array of linear values
local LinearSpring = {}

do
	LinearSpring.__index = LinearSpring

	function LinearSpring.new(dampingRatio, frequency, pos, rawGoal, typedat)
		local linearPos = typedat.toIntermediate(pos)
		return setmetatable(
			{
				d = dampingRatio,
				f = frequency,
				g = linearPos,
				p = linearPos,
				v = table.create(#linearPos, 0),
				typedat = typedat,
				rawGoal = rawGoal
			},
			LinearSpring
		)
	end

	function LinearSpring.setGoal(self, goal)
		self.rawGoal = goal
		self.g = self.typedat.toIntermediate(goal)
	end

	function LinearSpring.setDampingRatio(self, dampingRatio)
		self.d = dampingRatio
	end

	function LinearSpring.setFrequency(self, frequency)
		self.f = frequency
	end

	function LinearSpring.canSleep(self)
		if magnitudeSq(self.v) > SLEEP_VELOCITY_SQ_LIMIT then
			return false
		end

		if distanceSq(self.p, self.g) > SLEEP_OFFSET_SQ_LIMIT then
			return false
		end

		return true
	end

	function LinearSpring.step(self, dt)
		-- Advance the spring simulation by dt seconds.
		-- Take the damped harmonic oscillator ODE:
		--    f^2*(X[t] - g) + 2*d*f*X'[t] + X''[t] = 0
		-- Where X[t] is position at time t, g is target position,
		-- f is undamped angular frequency, and d is damping ratio.
		-- Apply constant initial conditions:
		--    X[0] = p0
		--    X'[0] = v0
		-- Solve the IVP to get analytic expressions for X[t] and X'[t].
		-- The solution takes one of three forms for 0<=d<1, d=1, and d>1

		local d = self.d
		local f = self.f*2*pi -- Hz -> Rad/s
		local g = self.g
		local p = self.p
		local v = self.v

		if d == 1 then -- critically damped
			local q = exp(-f*dt)
			local w = dt*q

			local c0 = q + w*f
			local c2 = q - w*f
			local c3 = w*f*f

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				p[idx] = o*c0 + v[idx]*w + g[idx]
				v[idx] = v[idx]*c2 - o*c3
			end

		elseif d < 1 then -- underdamped
			local q = exp(-d*f*dt)
			local c = sqrt(1 - d*d)

			local i = cos(dt*f*c)
			local j = sin(dt*f*c)

			-- Damping ratios approaching 1 can cause division by very small numbers.
			-- To mitigate that, group terms around z=j/c and find an approximation for z.
			-- Start with the definition of z:
			--    z = sin(dt*f*c)/c
			-- Substitute a=dt*f:
			--    z = sin(a*c)/c
			-- Take the Maclaurin expansion of z with respect to c:
			--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
			--    z ~= a - (a^3*c^2)/6 + (a^5*c^4)/120
			-- Rewrite in Horner form:
			--    z ~= a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

			local z
			if c > EPS then
				z = j/c
			else
				local a = dt*f
				z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
			end

			-- Frequencies approaching 0 present a similar problem.
			-- We want an approximation for y as f approaches 0, where:
			--    y = sin(dt*f*c)/(f*c)
			-- Substitute b=dt*c:
			--    y = sin(b*c)/b
			-- Now reapply the process from z.

			local y
			if f*c > EPS then
				y = j/(f*c)
			else
				local b = f*c
				y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
			end

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				p[idx] = (o*(i + z*d) + v[idx]*y)*q + g[idx]
				v[idx] = (v[idx]*(i - z*d) - o*(z*f))*q
			end

		else -- overdamped
			local c = sqrt(d*d - 1)

			local r1 = -f*(d - c)
			local r2 = -f*(d + c)

			local ec1 = exp(r1*dt)
			local ec2 = exp(r2*dt)

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				local co2 = (v[idx] - o*r1)/(2*f*c)
				local co1 = ec1*(o - co2)

				p[idx] = co1 + co2*ec2 + g[idx]
				v[idx] = co1*r1 + co2*ec2*r2
			end
		end

		return self.typedat.fromIntermediate(self.p)
	end
end

local RotationSpring = {} 

do
	RotationSpring.__index = RotationSpring

	local function angleBetween(c0, c1)
		local _, angle = (c1:ToObjectSpace(c0)):ToAxisAngle()
		return math.abs(angle)
	end

	local function matrixToAxis(m)
		local axis, angle = m:ToAxisAngle()
		return axis*angle
	end

	local function axisToMatrix(v)
		local mag = v.Magnitude
		if mag > AXIS_MATRIX_EPS then
			return CFrame.fromAxisAngle(v.Unit, mag)
		end
		return CFrame.identity
	end

	function RotationSpring.new(d, f, p, g)
		return setmetatable(
			{
				d = d,
				f = f,
				g = g,
				p = p,
				v = Vector3.zero
			},
			RotationSpring
		)
	end

	function RotationSpring.setGoal(self, value)
		self.g = value
	end

	function RotationSpring.setDampingRatio(self, dampingRatio)
		self.d = dampingRatio
	end

	function RotationSpring.setFrequency(self, frequency)
		self.f = frequency
	end

	function RotationSpring.canSleep(self)
		local sleepP = angleBetween(self.p, self.g) < SLEEP_ROTATION_OFFSET
		local sleepV = self.v.Magnitude < SLEEP_ROTATION_VELOCITY
		return sleepP and sleepV
	end

	function RotationSpring.step(self, dt)
		local d = self.d
		local f = self.f*2*pi
		local g = self.g
		local p0 = self.p
		local v0 = self.v

		local offset = matrixToAxis(p0*g:Inverse())
		local decay = exp(-d*f*dt)

		local pt
		local vt

		if d == 1 then -- critically damped
			local w = dt*decay

			pt = axisToMatrix((offset*(1 + f*dt) + v0*dt)*decay)*g
			vt = (v0*(1 - dt*f) - offset*(dt*f*f))*decay

		elseif d < 1 then -- underdamped
			local c = sqrt(1 - d*d)

			local i = cos(dt*f*c)
			local j = sin(dt*f*c)

			local y = j/(f*c)
			local z = j/c

			pt = axisToMatrix((offset*(i + z*d) + v0*y)*decay)*g
			vt = (v0*(i - z*d) - offset*(z*f))*decay

		else -- overdamped
			local c = sqrt(d*d - 1)

			local r1 = -f*(d - c)
			local r2 = -f*(d + c)

			local co2 = (v0 - offset*r1)/(2*f*c)
			local co1 = offset - co2

			local e1 = co1*exp(r1*dt)
			local e2 = co2*exp(r2*dt)

			pt = axisToMatrix(e1 + e2)*g
			vt = e1*r1 + e2*r2
		end

		self.p = pt
		self.v = vt

		return pt
	end
end

-- Defined early to be used by CFrameSpring
local typeMetadata_Vector3 = {
	springType = LinearSpring.new,

	toIntermediate = function(value)
		return {value.X, value.Y, value.Z}
	end,

	fromIntermediate = function(value)
		return Vector3.new(value[1], value[2], value[3])
	end,
}

-- Encapsulates a CFrame - Separates translation from rotation
local CFrameSpring = {}
do
	CFrameSpring.__index = CFrameSpring

	function CFrameSpring.new(
		dampingRatio,
		frequency,
		valueCurrent,
		valueGoal,
		_
	)
		return setmetatable(
			{
				rawGoal = valueGoal,
				_position = LinearSpring.new(dampingRatio, frequency, valueCurrent.Position, valueGoal.Position, typeMetadata_Vector3),
				_rotation = RotationSpring.new(dampingRatio, frequency, valueCurrent.Rotation, valueGoal.Rotation)
			},
			CFrameSpring
		)
	end

	function CFrameSpring:setGoal(value)
		self.rawGoal = value
		self._position:setGoal(value.Position)
		self._rotation:setGoal(value.Rotation)
	end

	function CFrameSpring:setDampingRatio(value)
		self._position:setDampingRatio(value)
		self._rotation:setDampingRatio(value)
	end

	function CFrameSpring:setFrequency(value)
		self._position:setFrequency(value)
		self._rotation:setFrequency(value)
	end

	function CFrameSpring:canSleep()
		return self._position:canSleep() and self._rotation:canSleep()
	end

	function CFrameSpring:step(dt)
		local p = self._position:step(dt)
		local r = self._rotation:step(dt)
		return r + p
	end
end

-- Color conversions
local rgbToLuv
local luvToRgb
do
	local function inverseGammaCorrectD65(c)
		return c < 0.0404482362771076 and c/12.92 or 0.87941546140213*(c + 0.055)^2.4
	end

	local function gammaCorrectD65(c)
		return c < 3.1306684425e-3 and 12.92*c or 1.055*c^(1/2.4) - 0.055
	end

	function rgbToLuv(value)
		-- convert RGB to a variant of cieluv space
		local r, g, b = value.R, value.G, value.B

		-- D65 sRGB inverse gamma correction
		r = inverseGammaCorrectD65(r)
		g = inverseGammaCorrectD65(g)
		b = inverseGammaCorrectD65(b)

		-- sRGB -> xyz
		local x = 0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b
		local y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
		local z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b

		-- xyz -> scaled cieluv
		local l = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y

		local u, v
		if z > 1e-14 then
			u = l*x/z
			v = l*(9*y/z - 0.46832)
		else
			u = -0.19783*l
			v = -0.46832*l
		end

		return {l, u, v}
	end

	function luvToRgb(value)
		-- convert back from modified cieluv to rgb space
		local l = value[1]
		if l < 0.0197955 then
			return Color3.new(0, 0, 0)
		end
		local u = value[2]/l + 0.19783
		local v = value[3]/l + 0.46832

		-- cieluv -> xyz
		local y = (l + 16)/116
		y = y > 0.206896551724137931 and y*y*y or 0.12841854934601665*y - 0.01771290335807126
		local x = y*u/v
		local z = y*((3 - 0.75*u)/v - 5)

		-- xyz -> D65 sRGB
		local r =  7.2914074*x - 1.5372080*y - 0.4986286*z
		local g = -2.1800940*x + 1.8757561*y + 0.0415175*z
		local b =  0.1253477*x - 0.2040211*y + 1.0569959*z

		-- clamp minimum sRGB component
		if r < 0 and r < g and r < b then
			r, g, b = 0, g - r, b - r
		elseif g < 0 and g < b then
			r, g, b = r - g, 0, b - g
		elseif b < 0 then
			r, g, b = r - b, g - b, 0
		end

		-- gamma correction from D65
		-- clamp to avoid undesirable overflow wrapping behavior on certain properties (e.g. BasePart.Color)
		return Color3.new(
			min(gammaCorrectD65(r), 1),
			min(gammaCorrectD65(g), 1),
			min(gammaCorrectD65(b), 1)
		)
	end
end

-- Type definitions
-- Transforms Roblox types into intermediate types, converting
-- between spaces as necessary to preserve perceptual linearity
local typeMetadata = {
	boolean = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value and 1 or 0}
		end,

		fromIntermediate = function(value)
			return value[1] >= 0.5
		end,
	},

	number = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value}
		end,

		fromIntermediate = function(value)
			return value[1]
		end,
	},

	NumberRange = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.Min, value.Max}
		end,

		fromIntermediate = function(value)
			return NumberRange.new(value[1], value[2])
		end,
	},

	UDim = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.Scale, value.Offset}
		end,

		fromIntermediate = function(value)
			return UDim.new(value[1], round(value[2]))
		end,
	},

	UDim2 = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			local x = value.X
			local y = value.Y
			return {x.Scale, x.Offset, y.Scale, y.Offset}
		end,

		fromIntermediate = function(value)
			return UDim2.new(value[1], round(value[2]), value[3], round(value[4]))
		end,
	},

	Vector2 = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.X, value.Y}
		end,

		fromIntermediate = function(value)
			return Vector2.new(value[1], value[2])
		end,
	},

	Vector3 = typeMetadata_Vector3,

	Color3 = {
		springType = LinearSpring.new,
		toIntermediate = rgbToLuv,
		fromIntermediate = luvToRgb,
	},

	-- Only interpolates start and end keypoints
	ColorSequence = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			local keypoints = value.Keypoints

			local luv0 = rgbToLuv(keypoints[1].Value)
			local luv1 = rgbToLuv(keypoints[#keypoints].Value)

			return {
				luv0[1], luv0[2], luv0[3],
				luv1[1], luv1[2], luv1[3],
			}
		end,

		fromIntermediate = function(value)
			return ColorSequence.new(
				luvToRgb{value[1], value[2], value[3]},
				luvToRgb{value[4], value[5], value[6]}
			)
		end,
	},

	CFrame = {
		springType = CFrameSpring.new,
		toIntermediate = error, -- custom (CFrameSpring)
		fromIntermediate = error, -- custom (CFrameSpring)
	}
}

local PSEUDO_PROPERTIES = {
	Pivot = {
		class = "PVInstance",
		get = function(inst)
			return inst:GetPivot()
		end,
		set = function(inst, value)
			inst:PivotTo(value)
		end
	},
	Scale = {
		class = "Model",
		get = function(inst)
			return inst:GetScale()
		end,
		set = function(inst, value)
			inst:ScaleTo(value)
		end
	}
}

-- Frame loop
local springStates = {} -- {[instance] = {[property] = spring}
local completedCallbacks = {}

RunService.Heartbeat:Connect(function(dt)
	for instance, state in pairs(springStates) do
		for propName, spring in pairs(state) do
			local override = PSEUDO_PROPERTIES[propName]
			
			if override and instance:IsA(override.class) then
				if spring:canSleep() then
					state[propName] = nil
					override.set(instance, spring.rawGoal)
				else
					override.set(instance, spring:step(dt))
				end
			else
				if spring:canSleep() then
					state[propName] = nil
					instance[propName] = spring.rawGoal
				else
					instance[propName] = spring:step(dt)
				end
			end
		end

		if not next(state) then
			springStates[instance] = nil

			-- trigger completed callbacks when all properties finish animating
			local callbackList = completedCallbacks[instance]
			if callbackList then
				-- flush callback list before we run any callbacks in case
				-- one of the callbacks recursively adds another callback
				completedCallbacks[instance] = nil

				for _, callback in ipairs(callbackList) do
					task.spawn(callback)
				end
			end
		end
	end
end)

-- API
local spr = {}
do
	local function assertType(argNum, fnName, expectedType, value)
		if not expectedType:find(typeof(value)) then
			error("bad argument #" .. tostring(argNum) .. " to " .. tostring(fnName) .. " (" .. tostring(expectedType) .. " expected, got " .. typeof(value) .. ")", 3)
		end
	end

	function spr.target(instance, dampingRatio, frequency, properties)
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.target", "Instance", instance)
			assertType(2, "spr.target", "number", dampingRatio)
			assertType(3, "spr.target", "number", frequency)
			assertType(4, "spr.target", "table", properties)
		end

		if dampingRatio ~= dampingRatio or dampingRatio < 0 then
			error(("expected damping ratio >= 0; got %.2f"):format(dampingRatio), 2)
		end

		if frequency ~= frequency or frequency < 0 then
			error(("expected undamped frequency >= 0; got %.2f"):format(frequency), 2)
		end

		local state = springStates[instance]
		if not state then
			state = {}
			springStates[instance] = state
		end

		for propName, propTarget in pairs(properties) do
			local propValue
			local override = PSEUDO_PROPERTIES[propName]
			if override and instance:IsA(override.class) then
				propValue = override.get(instance)
			else
				propValue = instance[propName]
			end

			if STRICT_RUNTIME_TYPES and typeof(propTarget) ~= typeof(propValue) then
				error("bad property " .. tostring(propName) .. " to spr.target (" .. typeof(propValue) .. " expected, got " .. typeof(propTarget) .. ")", 2)
			end

			-- Special case infinite frequency for an instantaneous change
			if frequency == math.huge then
				instance[propName] = propTarget
				state[propName] = nil
				continue
			end

			local spring = state[propName]
			if not spring then
				local md = typeMetadata[typeof(propTarget)]
				if not md then
					error("unsupported type: " .. typeof(propTarget), 2)
				end

				spring = md.springType(dampingRatio, frequency, propValue, propTarget, md)
				state[propName] = spring
			end

			spring:setGoal(propTarget)
			spring:setDampingRatio(dampingRatio)
			spring:setFrequency(frequency)
		end

		if not next(state) then
			springStates[instance] = nil
		end
	end

	function spr.stop(instance, property)
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.stop", "Instance", instance)
			assertType(2, "spr.stop", "string|nil", property)
		end

		if property then
			local state = springStates[instance]
			if state then
				state[property] = nil
			end
		else
			springStates[instance] = nil
		end
	end

	function spr.completed(instance, callback)
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.completed", "Instance", instance)
			assertType(2, "spr.completed", "function", callback)
		end

		local callbackList = completedCallbacks[instance]
		if callbackList then
			table.insert(callbackList, callback)
		else
			completedCallbacks[instance] = {callback}
		end
	end
end

return table.freeze(spr)
end

-- MODULE: packages/material-roblox/init
modules["packages/material-roblox/init"] = function()--!strict
return {
	["outlined"] = {
		["dp_48"] = {
			["scale_2"] = require("packages/material-roblox/Outlined_48_2"),
		},
	},
}
end

-- MODULE: packages/material-roblox/Outlined_48_2
modules["packages/material-roblox/Outlined_48_2"] = function()--!strict
-- this script is auto generated, don't manually change it please
return {
	["3d_rotation"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["accessibility"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["accessibility_new"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["accessible"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["accessible_forward"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["account_balance"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["account_balance_wallet"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["account_box"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["account_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["addchart"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_shopping_cart"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_task"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["admin_panel_settings"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alarm"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alarm_add"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alarm_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alarm_on"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["all_inbox"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["all_out"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["analytics"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["anchor"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["android"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["announcement"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["api"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["app_blocking"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_circle_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_circle_up"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_right_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["article"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["aspect_ratio"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assessment"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment_ind"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment_late"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment_return"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment_returned"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assignment_turned_in"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["autorenew"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["backup"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["backup_table"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["batch_prediction"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["book"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bookmark"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bookmarks"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bookmark_border"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["book_online"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bug_report"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["build"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["build_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cached"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["calendar_today"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["calendar_view_day"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera_enhance"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cancel_schedule_send"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["card_giftcard"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["card_membership"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["card_travel"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["change_history"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["check_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["check_circle_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chrome_reader_mode"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["class"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["close_fullscreen"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["code"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["comment_bank"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["commute"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["compare_arrows"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contactless"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contact_page"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contact_support"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["copyright"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["credit_card"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dashboard"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["date_range"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["delete"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["delete_forever"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["delete_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["description"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["disabled_by_default"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dns"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["done"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["done_all"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["done_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["donut_large"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["donut_small"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["drag_indicator"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dynamic_form"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["eco"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["eject"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["euro_symbol"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["event"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["event_seat"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exit_to_app"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["explore"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["explore_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["extension"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["face"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["face_unlock"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fact_check"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["favorite"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["favorite_border"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["feedback"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["find_in_page"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["find_replace"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fingerprint"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flaky"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flight_land"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flight_takeoff"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flip_to_back"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flip_to_front"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gavel"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["get_app"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gif"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grade"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grading"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["group_work"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["g_translate"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["help"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["help_center"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["help_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["highlight_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["highlight_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["history"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["history_toggle_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["home"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["horizontal_split"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hourglass_disabled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hourglass_empty"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hourglass_full"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["http"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["https"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["important_devices"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["info"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["input"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["integration_instructions"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["invert_colors"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["label"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["label_important"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["label_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["language"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["launch"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["leaderboard"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["lightbulb"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["line_style"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["line_weight"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["list"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["lock"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["lock_open"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["login"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["loyalty"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["markunread_mailbox"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["maximize"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mediation"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["minimize"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["model_training"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["next_plan"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["note_add"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["not_accessible"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["not_started"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["offline_bolt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["offline_pin"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["online_prediction"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["opacity"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["open_in_browser"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["open_in_full"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["open_in_new"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["open_with"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["outbond"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["outlet"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pageview"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pan_tool"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["payment"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pending"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pending_actions"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_camera_mic"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_contact_calendar"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_data_setting"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_device_information"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_identity"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_media"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_phone_msg"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["perm_scan_wifi"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pets"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["picture_in_picture"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["picture_in_picture_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["plagiarism"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["play_for_work"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["polymer"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["power_settings_new"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["preview"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["print"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["privacy_tip"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["published_with_changes"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["query_builder"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["question_answer"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["quickreply"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["receipt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["record_voice_over"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["redeem"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove_shopping_cart"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["reorder"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["report_problem"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["request_page"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["restore"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["restore_from_trash"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["restore_page"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["room"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rounded_corner"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rowing"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rule"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["schedule"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["search"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["search_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_applications"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_backup_restore"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_bluetooth"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_brightness"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_cell"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_ethernet"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_input_antenna"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_input_component"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_input_composite"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_input_hdmi"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_input_svideo"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_overscan"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_phone"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_power"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_remote"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_voice"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shop"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shopping_bag"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shopping_basket"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shopping_cart"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shop_two"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["smart_button"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["source"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speaker_notes"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speaker_notes_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["spellcheck"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stars"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_rate"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sticky_note_2"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["store"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subject"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subtitles_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["supervised_user_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["supervisor_account"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["support"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["swap_horiz"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["swap_horizontal_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["swap_vert"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["swap_vertical_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sync_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["system_update_alt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tab"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["table_view"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tab_unselected"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotate_up"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotate_vertical"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotation_angledown"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotation_angleup"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotation_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_rotation_none"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["theaters"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thumbs_up_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thumb_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thumb_up"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timeline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["toc"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["today"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["toll"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["touch_app"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tour"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["track_changes"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["translate"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["trending_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["trending_flat"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["trending_up"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["turned_in"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["turned_in_not"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["unpublished"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["update"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["upgrade"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["verified"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["verified_user"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vertical_split"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_agenda"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_array"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_carousel"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_column"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_day"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_headline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_list"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_module"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_quilt"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_sidebar"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_stream"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_week"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["visibility"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["visibility_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["voice_over_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["watch_later"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi_protected_setup"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["work"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["work_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["work_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wysiwyg"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["youtube_searched_for"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["zoom_in"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["zoom_out"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_alert"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["auto_delete"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["error"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["error_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notification_important"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["warning"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["warning_amber"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["4k"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["5g"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_to_queue"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airplay"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["album"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["art_track"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["av_timer"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["branding_watermark"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_to_action"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["closed_caption"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["closed_caption_disabled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["control_camera"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["equalizer"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fast_forward"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fast_rewind"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["featured_play_list"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["featured_video"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fiber_dvr"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fiber_manual_record"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fiber_new"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fiber_pin"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fiber_smart_record"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forward_10"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forward_30"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forward_5"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["games"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hd"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hearing"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hearing_disabled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["high_quality"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["library_add"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["library_add_check"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["library_books"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["library_music"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["loop"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mic"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mic_none"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mic_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["missed_video_call"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["movie"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["music_video"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["new_releases"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["note"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["not_interested"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pause"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pause_circle_filled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pause_circle_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["playlist_add"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["playlist_add_check"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["playlist_play"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["play_arrow"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["play_circle_filled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["play_circle_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["queue"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["queue_music"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["queue_play_next"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["radio"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["recent_actors"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove_from_queue"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["repeat"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["repeat_one"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["replay"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["replay_10"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["replay_30"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["replay_5"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shuffle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["skip_next"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["skip_previous"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["slow_motion_video"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["snooze"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sort_by_alpha"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speed"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stop"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stop_circle"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subscriptions"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subtitles"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["surround_sound"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["videocam"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["videocam_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["video_call"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["video_label"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["video_library"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["video_settings"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["volume_down"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["volume_mute"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["volume_off"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["volume_up"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["web"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["web_asset"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_ic_call"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alternate_email"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["business"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_end"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_made"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_merge"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_missed"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_missed_outgoing"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_received"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["call_split"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cancel_presentation"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chat"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(0, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chat_bubble"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(48, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chat_bubble_outline"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(96, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["clear_all"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(144, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["comment"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(192, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contacts"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(240, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contact_mail"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(288, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["contact_phone"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(336, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["desktop_access_disabled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(384, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dialer_sip"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(432, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dialpad"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(480, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["domain_disabled"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(528, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["domain_verification"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(576, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["duo"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(624, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["email"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(672, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forum"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(720, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forward_to_inbox"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(768, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hourglass_bottom"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(816, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hourglass_top"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(864, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["import_contacts"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(912, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["import_export"] = {
		["Image"] = "rbxassetid://15530169371",
		["ImageRectOffset"] = Vector2.new(960, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["invert_colors_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["list_alt"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["live_help"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["location_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["location_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mail_outline"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mark_chat_read"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mark_chat_unread"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mark_email_read"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mark_email_unread"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["message"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mobile_screen_share"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["more_time"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["nat"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_sim"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pause_presentation"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_add_disabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_search"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink_erase"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink_lock"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink_ring"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink_setup"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_disabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_enabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["portable_wifi_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["present_to_all"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["print_disabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["qr_code"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["qr_code_scanner"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["read_more"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ring_volume"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rss_feed"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["screen_share"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_satisfied_alt"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speaker_phone"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stay_current_landscape"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stay_current_portrait"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stay_primary_landscape"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stay_primary_portrait"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stop_screen_share"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["swap_calls"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["textsms"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["unsubscribe"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["voicemail"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vpn_key"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi_calling"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_box"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_circle"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_circle_outline"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["amp_stories"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["archive"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["attribution"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["backspace"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ballot"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["biotech"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["block"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["calculate"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["clear"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["content_copy"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["content_cut"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["content_paste"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["create"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["delete_sweep"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["drafts"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dynamic_feed"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["file_copy"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_list"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flag"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["font_download"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["forward"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gesture"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["how_to_reg"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["how_to_vote"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["inbox"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insights"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["link"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["link_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["low_priority"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mail"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["markunread"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["move_to_inbox"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["next_week"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["outlined_flag"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["policy"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["push_pin"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["redo"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove_circle"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove_circle_outline"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["reply"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["reply_all"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["report"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["report_gmailerrorred"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["report_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["save"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["save_alt"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["select_all"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["send"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sort"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["square_foot"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_format"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["unarchive"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["undo"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["waves"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["weekend"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["where_to_vote"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["access_alarm"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["access_alarms"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["access_time"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_alarm"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_to_home_screen"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ad_units"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airplanemode_active"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airplanemode_inactive"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["battery_alert"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["battery_charging_full"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["battery_full"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["battery_std"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["battery_unknown"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bluetooth"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bluetooth_connected"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bluetooth_disabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bluetooth_searching"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_auto"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_high"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_low"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_medium"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["data_usage"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["developer_mode"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["devices"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dvr"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gps_fixed"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gps_not_fixed"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gps_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["graphic_eq"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["location_disabled"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["location_searching"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mobile_friendly"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mobile_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["nfc"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["screen_lock_landscape"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["screen_lock_portrait"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["screen_lock_rotation"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["screen_rotation"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sd_storage"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["settings_system_daydream"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_4_bar"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_alt"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_connected_no_internet_4_bar"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_no_sim"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_null"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_cellular_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_wifi_4_bar"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_wifi_4_bar_lock"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["signal_wifi_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["storage"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thermostat"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["usb"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wallpaper"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["widgets"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi_lock"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi_tethering"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_comment"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["attach_file"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["attach_money"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bar_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_all"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_bottom"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_clear"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_horizontal"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_inner"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_left"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_outer"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_right"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_style"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_top"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["border_vertical"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bubble_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["drag_handle"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_align_center"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_align_justify"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_align_left"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_align_right"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_bold"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_clear"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_color_reset"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_indent_decrease"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_indent_increase"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_italic"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_line_spacing"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_list_bulleted"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_list_numbered"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_list_numbered_rtl"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_paint"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_quote"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_shapes"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_size"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_strikethrough"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_textdirection_l_to_r"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_textdirection_r_to_l"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["format_underlined"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["functions"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["height"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["highlight"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["horizontal_rule"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_chart_outlined"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_comment"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_drive_file"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_emoticon"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_invitation"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_link"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["insert_photo"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["linear_scale"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["merge_type"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mode"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mode_comment"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["monetization_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["money_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["money_off_csred"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["multiline_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notes"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pie_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pie_chart_outline"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["post_add"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["publish"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["scatter_plot"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["score"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["short_text"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["show_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["space_bar"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stacked_line_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["strikethrough_s"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subscript"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["superscript"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["table_chart"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["table_rows"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_fields"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["title"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vertical_align_bottom"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vertical_align_center"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vertical_align_top"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wrap_text"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["attachment"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["attach_email"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_circle"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_done"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_download"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_queue"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cloud_upload"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["create_new_folder"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["download"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["download_done"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["folder"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["folder_open"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["folder_shared"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["request_quote"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rule_folder"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["snippet_folder"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["text_snippet"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["topic"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["upload"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["browser_not_supported"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cast"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cast_connected"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cast_for_education"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["computer"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["desktop_mac"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["desktop_windows"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["developer_board"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["devices_other"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["device_hub"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["device_unknown"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dock"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gamepad"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["headset"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["headset_mic"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_arrow_down"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_arrow_left"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_arrow_right"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_arrow_up"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_backspace"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_capslock"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_hide"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_return"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_tab"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["keyboard_voice"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["laptop"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["laptop_chromebook"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["laptop_mac"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["laptop_windows"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["memory"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mouse"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phonelink_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_android"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_iphone"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["point_of_sale"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["power_input"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["router"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["scanner"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["security"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sim_card"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["smartphone"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speaker"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["speaker_group"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tablet"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tablet_android"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tablet_mac"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["toys"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tv"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["videogame_asset"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["watch"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sensor_door"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sensor_window"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_a_photo"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_photo_alternate"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_to_photos"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["adjust"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assistant"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["assistant_photo"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["audiotrack"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bedtime"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["blur_circular"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["blur_linear"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["blur_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["blur_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_1"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_2"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_3"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_4"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_5"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_6"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brightness_7"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["broken_image"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["brush"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["burst_mode"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera_alt"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera_front"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera_rear"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["camera_roll"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["center_focus_strong"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["center_focus_weak"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["collections"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["collections_bookmark"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["colorize"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["color_lens"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["compare"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["control_point"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["control_point_duplicate"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_16_9"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_3_2"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_5_4"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_7_5"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_din"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_free"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_landscape"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_original"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_portrait"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_rotate"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["crop_square"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dehaze"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["details"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["edit"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["euro"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure_neg_1"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure_neg_2"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure_plus_1"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure_plus_2"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["exposure_zero"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_1"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_2"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_3"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_4"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_5"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_6"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_7"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_8"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_9"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_9_plus"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_b_and_w"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_center_focus"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_drama"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_frames"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_hdr"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_none"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_tilt_shift"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["filter_vintage"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flare"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flash_auto"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flash_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flash_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flip"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flip_camera_android"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flip_camera_ios"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["gradient"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grain"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grid_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grid_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hdr_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hdr_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hdr_strong"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hdr_weak"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["healing"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["image"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["image_aspect_ratio"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["image_not_supported"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["image_search"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["iso"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["landscape"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["leak_add"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["leak_remove"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(0, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["lens"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(48, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["linked_camera"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(96, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(144, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_3"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(192, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_4"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(240, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_5"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(288, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_6"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(336, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_one"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(384, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["looks_two"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(432, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["loupe"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(480, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["monochrome_photos"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(528, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["motion_photos_on"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(576, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["motion_photos_pause"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(624, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["motion_photos_paused"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(672, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["movie_creation"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(720, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["movie_filter"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(768, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["music_note"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(816, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["music_off"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(864, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["nature"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(912, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["nature_people"] = {
		["Image"] = "rbxassetid://15530169697",
		["ImageRectOffset"] = Vector2.new(960, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["navigate_before"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["navigate_next"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["palette"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["panorama"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["panorama_fish_eye"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["panorama_horizontal"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["panorama_vertical"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["panorama_wide_angle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_album"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_camera"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_filter"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_library"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_size_select_actual"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_size_select_large"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["photo_size_select_small"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["picture_as_pdf"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["portrait"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["receipt_long"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["remove_red_eye"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rotate_90_degrees_ccw"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 0),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rotate_left"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rotate_right"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["shutter_speed"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["slideshow"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["straighten"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["style"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["switch_camera"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["switch_video"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tag_faces"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["texture"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timelapse"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timer"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timer_10"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timer_3"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["timer_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tonality"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["transform"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tune"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_comfy"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["view_compact"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vignette"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 48),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wb_auto"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wb_cloudy"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wb_incandescent"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wb_iridescent"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wb_sunny"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["360"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_business"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_location"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_location_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["add_road"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["agriculture"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["alt_route"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["atm"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["beenhere"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bike_scooter"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["category"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cleaning_services"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["compass_calibration"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["departure_board"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["design_services"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 96),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_bike"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_boat"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_bus"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_car"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_railway"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_run"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_subway"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_transit"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_walk"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["edit_attributes"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["edit_location"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["edit_road"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["electrical_services"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["electric_bike"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["electric_car"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["electric_moped"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["electric_scooter"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ev_station"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fastfood"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["flight"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["handyman"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 144),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["home_repair_service"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hotel"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hvac"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["layers"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["layers_clear"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_activity"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_airport"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_atm"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_cafe"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_car_wash"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_convenience_store"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_dining"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_drink"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_fire_department"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_florist"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_gas_station"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_grocery_store"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_hospital"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_hotel"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_laundry_service"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_library"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 192),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_mall"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_movies"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_offer"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_parking"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_pharmacy"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_phone"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_pizza"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_play"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_police"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_post_office"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_printshop"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_see"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_shipping"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["local_taxi"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["map"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["maps_ugc"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["medical_services"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["menu_book"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["miscellaneous_services"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["money"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["moped"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 240),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["multiple_stop"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["museum"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["my_location"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["navigation"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["near_me"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["near_me_disabled"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["not_listed_location"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_meals"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_transfer"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pedal_bike"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_pin"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_pin_circle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pest_control"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pest_control_rodent"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pin_drop"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["place"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["plumbing"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rate_review"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["restaurant"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["restaurant_menu"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["run_circle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 288),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["satellite"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["set_meal"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["store_mall_directory"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["streetview"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subway"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["terrain"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["traffic"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["train"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tram"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["transfer_within_a_station"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["transit_enterexit"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["trip_origin"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["two_wheeler"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wrong_location"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["zoom_out_map"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["apps"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["app_settings_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_back"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_back_ios"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_downward"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_drop_down"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 336),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_drop_down_circle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_drop_up"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_forward"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_forward_ios"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_left"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_right"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["arrow_upward"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["campaign"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cancel"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["check"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chevron_left"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["chevron_right"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["close"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["double_arrow"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["east"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["expand_less"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["expand_more"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["first_page"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fullscreen"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fullscreen_exit"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["home_work"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 384),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["last_page"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["legend_toggle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["menu"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["menu_open"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["more_horiz"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["more_vert"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["north"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["north_east"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["north_west"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["payments"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["refresh"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["south"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["south_east"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["south_west"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subdirectory_arrow_left"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["subdirectory_arrow_right"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["switch_left"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["switch_right"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["unfold_less"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["unfold_more"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["west"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 432),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["account_tree"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["adb"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_flat"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_flat_angled"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_individual_suite"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_legroom_extra"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_legroom_normal"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_legroom_reduced"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_recline_extra"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airline_seat_recline_normal"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bluetooth_audio"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["confirmation_number"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["directions_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["disc_full"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_disturb"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_disturb_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_disturb_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_disturb_on"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["drive_eta"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["enhanced_encryption"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["event_available"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 480),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["event_busy"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["event_note"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["folder_special"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["live_tv"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mms"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["more"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["network_check"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["network_locked"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_encryption"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_encryption_gmailerrorred"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ondemand_video"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["personal_video"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_bluetooth_speaker"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_callback"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_forwarded"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_in_talk"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_locked"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_missed"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["phone_paused"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["power"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["power_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 528),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["priority_high"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sd_card"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sd_card_alert"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sms"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sms_failed"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["support_agent"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sync"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sync_disabled"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sync_problem"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["system_update"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tap_and_play"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["time_to_leave"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tv_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vibration"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["voice_chat"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["vpn_lock"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wc"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wifi_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["ac_unit"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["airport_shuttle"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 576),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["all_inclusive"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["apartment"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["baby_changing_station"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["backpack"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bathtub"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["beach_access"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["bento"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["business_center"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["carpenter"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["casino"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["charging_station"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["checkroom"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["child_care"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["child_friendly"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["corporate_fare"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["countertops"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_not_step"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["do_not_touch"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["dry"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["elevator"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["escalator"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 624),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["escalator_warning"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["family_restroom"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fence"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fire_extinguisher"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fitness_center"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["food_bank"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["foundation"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["free_breakfast"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["golf_course"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["grass"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["hot_tub"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["house"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["house_siding"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["kitchen"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["meeting_room"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["microwave"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["night_shelter"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_backpack"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_cell"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_flash"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_food"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 672),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_meeting_room"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_photography"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_stroller"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pool"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rice_bowl"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["roofing"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["room_preferences"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["room_service"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["rv_hookup"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["soap"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["spa"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stairs"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["storefront"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["stroller"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tapas"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["tty"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["umbrella"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wash"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["water_damage"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["wheelchair_pickup"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["6_ft_apart"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 720),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["architecture"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["cake"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["clean_hands"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["connect_without_contact"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["construction"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["coronavirus"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["deck"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["domain"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["elderly"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_emotions"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_events"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_flags"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_food_beverage"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_nature"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_objects"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_people"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_symbols"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["emoji_transportation"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["engineering"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["facebook"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["fireplace"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 768),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["follow_the_signs"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["group"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["groups"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["group_add"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["history_edu"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["king_bed"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["location_city"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["luggage"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["masks"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["military_tech"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mood"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["mood_bad"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["nights_stay"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notifications"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notifications_active"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notifications_none"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notifications_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["notifications_paused"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["no_luggage"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["outdoor_grill"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["pages"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 816),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["party_mode"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["people"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["people_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["people_outline"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_add"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_add_alt_1"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_outline"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_remove"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["person_remove_alt_1"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["plus_one"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["poll"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["precision_manufacturing"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["psychology"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["public"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["public_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["reduce_capacity"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sanitizer"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["school"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["science"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["self_improvement"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 864),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_dissatisfied"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_neutral"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_satisfied"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_very_dissatisfied"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sentiment_very_satisfied"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["share"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sick"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["single_bed"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_baseball"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_basketball"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_cricket"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_esports"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_football"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_golf"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_handball"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_hockey"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_kabaddi"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_mma"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_motorsports"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(912, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_rugby"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(960, 912),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_soccer"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(0, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_tennis"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(48, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["sports_volleyball"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(96, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thumb_down_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(144, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["thumb_up_alt"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(192, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["whatshot"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(240, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["check_box"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(288, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["check_box_outline_blank"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(336, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["indeterminate_check_box"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(384, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["radio_button_checked"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(432, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["radio_button_unchecked"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(480, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(528, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_border"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(576, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_border_purple500"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(624, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_half"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(672, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_outline"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(720, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["star_purple500"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(768, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["toggle_off"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(816, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
	["toggle_on"] = {
		["Image"] = "rbxassetid://15530170172",
		["ImageRectOffset"] = Vector2.new(864, 960),
		["ImageRectSize"] = Vector2.new(48, 48),
	},
}
end

-- MODULE: init (ENTRY POINT)
modules["init"] = function()require("guard/init")

local Theme = require("theme")
local Window = require("components/Window")

-- Directly construct and show the Key System window!
Window.new("Useless Hub", {
    Key = "UselessFihz0",
    Discord = "https://discord.gg/24fsRNH5K",
    Callback = function()
        -- On success, load and execute the main cheat hub
        local success, err = pcall(function()
            local Library
            
            -- 1. Try local dev paths
            if isfile and readfile then
                if isfile("UIlibrary/dist/library.lua") then
                    Library = loadstring(readfile("UIlibrary/dist/library.lua"))()
                elseif isfile("dist/library.lua") then
                    Library = loadstring(readfile("dist/library.lua"))()
                elseif isfile("library.lua") then
                    Library = loadstring(readfile("library.lua"))()
                end
            end
            
            -- 2. Fallback to production repository URL
            if not Library then
                local fetch = HttpGet or function(url) return game:HttpGet(url) end
                local cacheBuster = "?cb=" .. tostring(math.random(1, 9999999))
                Library = loadstring(fetch("https://raw.githubusercontent.com/saveliy-crtl/Simplicity/main/GUI.luau" .. cacheBuster))()
            end
            
            if not Library then
                error("Could not load main UI library.")
            end
            
            -- Create the main hub Window
            local MainWin = Library:CreateWindow("Useless Hub | Private", "uselesshub_configs")
            
            -- Add basic default configurations
            local CombatTab = MainWin:AddTab("Combat", "flash_on")
            CombatTab:AddSection("Aimbot Settings")
            CombatTab:AddToggle("Silent Aim", { flag = "silent_aim", default = false }, function(state)
                print("Silent Aim toggled to:", state)
            end)
            
            CombatTab:AddSlider("Field of View", {
                min = 10,
                max = 360,
                default = 90,
                step = 5,
                flag = "aim_fov"
            }, function(value)
                print("Aim FOV set to:", value)
            end)
            
            MainWin:AddConfigTab()
            MainWin:AddAboutTab()
        end)
        
        if not success then
            warn("Failed to load Useless Hub: " .. tostring(err))
        end
    end
})
end

return require("init")
