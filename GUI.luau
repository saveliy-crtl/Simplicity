--[=[
	Roblox UI Library Bundle
	Generated at: 2026-07-06 20:52:59
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

return Utility
end

-- MODULE: components/Button
modules["components/Button"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")

local Button = {}
Button.__index = Button

function Button.new(text, parent, callback, icon, window)
    local self = setmetatable({}, Button)
    
    self.Text = text or "Button"
    self.Callback = callback or function() end
    self.Window = window
    
    local hasIcon = false
    local iconAsset
    if icon and icon ~= "" then
        pcall(function()
            iconAsset = Lucide.GetAsset(icon, 48)
            if iconAsset then
                hasIcon = true
            end
        end)
    end
    
    -- Main Button Frame
    self.Frame = Utility.Create("TextButton", {
        Name = "Button_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })
    
    if hasIcon then
        Utility.Create("Frame", {
            Name = "Content",
            Parent = self.Frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        }, {
            Utility.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Utility.Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image = iconAsset.Url,
                ImageRectSize = iconAsset.ImageRectSize,
                ImageRectOffset = iconAsset.ImageRectOffset,
                ImageColor3 = Theme.TextPrimary,
                LayoutOrder = 1
            }),
            Utility.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = self.Text,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Theme.FontMedium,
                LayoutOrder = 2
            })
        })
    else
        Utility.Create("TextLabel", {
            Name = "Label",
            Parent = self.Frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    end
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Interaction animations
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    self.Frame.MouseButton1Down:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Accent }, 0.05)
    end)
    
    self.Frame.MouseButton1Up:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.1)
        
        -- Run callback safely in new thread
        task.spawn(function()
            local success, err = pcall(self.Callback)
            if not success then
                warn("Error in button callback: " .. tostring(err))
            end
        end)
    end)
    
    Utility.AddClickEffect(self.Frame)
    
    return self
end

return Button
end

-- MODULE: components/Colorpicker
modules["components/Colorpicker"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local function rgbToHex(color)
    local r = math.clamp(math.round(color.R * 255), 0, 255)
    local g = math.clamp(math.round(color.G * 255), 0, 255)
    local b = math.clamp(math.round(color.B * 255), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function hexToRgb(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    return nil
end

local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(text, parent, options, callback, window)
    local self = setmetatable({}, Colorpicker)
    
    options = options or {}
    self.Text = text or "Colorpicker"
    self.Default = options.default or options.Default or Color3.fromRGB(99, 102, 241) -- Default Accent (Indigo)
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    
    self.Value = self.Default
    
    -- Deconstruct initial Color3 to HSV
    local h, s, v = Color3.toHSV(self.Default)
    self.H = h
    self.S = s
    self.V = v
    
    self.DraggingHue = false
    self.DraggingSat = false
    self.DraggingVal = false
    
    -- Main Container Frame (Constant Height)
    self.Frame = Utility.Create("Frame", {
        Name = "Colorpicker_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Color Preview Box Button
        Utility.Create("TextButton", {
            Name = "Preview",
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -51, 0.5, -10),
            BackgroundColor3 = self.Default,
            Text = "",
            AutoButtonColor = false
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1
            })
        })
    })
    
    self.Label = self.Frame:FindFirstChild("Label")
    self.PreviewBtn = self.Frame:FindFirstChild("Preview")
    self.PreviewStroke = self.PreviewBtn:FindFirstChildOfClass("UIStroke")
    self.Stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Hover effect on Card
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
        Utility.Tween(self.Label, { TextColor3 = Theme.TextPrimary }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
        Utility.Tween(self.Label, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    
    -- Click to Open Colorpicker Dialogue Panel
    self.PreviewBtn.MouseButton1Click:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        self:OpenDialogue()
    end)
    
    Utility.AddClickEffect(self.PreviewBtn)
    
    -- Register Flag (Store as RGB array to allow JSON serialization)
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = {self.Default.R, self.Default.G, self.Default.B}
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Apply Default Color
    self:Set(self.Default, true)
    
    return self
end

function Colorpicker:OpenDialogue()
    local Dialogue = require("components/Dialogue")
    local dialogue = Dialogue.new(self.Text, self.Window, UDim2.new(0, 240, 0, 214))
    
    -- Dialogue Hue Track
    local hueLabel = Utility.Create("TextLabel", {
        Name = "HueLabel",
        Parent = dialogue.Content,
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(0, 15, 0, 15),
        BackgroundTransparency = 1,
        Text = "Hue",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 205
    })
    
    local hueTrack = Utility.Create("Frame", {
        Name = "HueTrack",
        Parent = dialogue.Content,
        Size = UDim2.new(1, -110, 0, 8),
        Position = UDim2.new(0, 95, 0, 21),
        BorderSizePixel = 0,
        ZIndex = 205
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 0))
            })
        })
    })
    
    local hueKnob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = hueTrack,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(self.H, -7, 0.5, -7),
        BackgroundColor3 = Theme.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 206
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
    })
    
    -- Saturation Slider Track
    local satLabel = Utility.Create("TextLabel", {
        Name = "SatLabel",
        Parent = dialogue.Content,
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(0, 15, 0, 50),
        BackgroundTransparency = 1,
        Text = "Saturation",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 205
    })
    
    local satTrack = Utility.Create("Frame", {
        Name = "SatTrack",
        Parent = dialogue.Content,
        Size = UDim2.new(1, -110, 0, 8),
        Position = UDim2.new(0, 95, 0, 56),
        BorderSizePixel = 0,
        ZIndex = 205
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(self.H, 1, 1))
        })
    })
    
    local satGradient = satTrack:FindFirstChildOfClass("UIGradient")
    
    local satKnob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = satTrack,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(self.S, -7, 0.5, -7),
        BackgroundColor3 = Theme.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 206
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
    })
    
    -- Brightness Slider Track
    local valLabel = Utility.Create("TextLabel", {
        Name = "ValLabel",
        Parent = dialogue.Content,
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(0, 15, 0, 85),
        BackgroundTransparency = 1,
        Text = "Brightness",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 205
    })
    
    local valTrack = Utility.Create("Frame", {
        Name = "ValTrack",
        Parent = dialogue.Content,
        Size = UDim2.new(1, -110, 0, 8),
        Position = UDim2.new(0, 95, 0, 91),
        BorderSizePixel = 0,
        ZIndex = 205
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(self.H, self.S, 1))
        })
    })
    
    local valGradient = valTrack:FindFirstChildOfClass("UIGradient")
    
    local valKnob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = valTrack,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(self.V, -7, 0.5, -7),
        BackgroundColor3 = Theme.TextPrimary,
        BorderSizePixel = 0,
        ZI
