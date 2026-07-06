--[=[
	Roblox UI Library Bundle
	Generated at: 2026-07-06 21:30:07
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    self.Frame.MouseButton1Down:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.05)
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
        ZIndex = 206
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
    })
    
    -- Color Preview Bar
    local previewBar = Utility.Create("Frame", {
        Name = "PreviewBar",
        Parent = dialogue.Content,
        Size = UDim2.new(1, -30, 0, 8),
        Position = UDim2.new(0, 15, 0, 122),
        BackgroundColor3 = self.Value,
        BorderSizePixel = 0,
        ZIndex = 205
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
    })
    
    -- Hex Code Label
    local hexLabel = Utility.Create("TextLabel", {
        Name = "HexLabel",
        Parent = dialogue.Content,
        Size = UDim2.new(0, 80, 0, 22),
        Position = UDim2.new(0, 15, 0, 145),
        BackgroundTransparency = 1,
        Text = "Hex Code",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 205
    })
    
    -- Hex Code Input Box
    local hexInputHolder = Utility.Create("Frame", {
        Name = "HexInputHolder",
        Parent = dialogue.Content,
        Size = UDim2.new(1, -110, 0, 22),
        Position = UDim2.new(0, 95, 0, 145),
        BackgroundColor3 = Theme.BorderMuted,
        BorderSizePixel = 0,
        ZIndex = 205
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
        Utility.Create("UIStroke", {
            Name = "Stroke",
            Color = Theme.Border,
            Thickness = 1
        }),
        Utility.Create("TextBox", {
            Name = "Input",
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = rgbToHex(self.Value),
            PlaceholderText = "#FFFFFF",
            PlaceholderColor3 = Theme.TextMuted,
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 206
        })
    })
    
    local hexInput = hexInputHolder:FindFirstChild("Input")
    local hexStroke = hexInputHolder:FindFirstChild("Stroke")
    
    self.DialogueHexInput = hexInput
    
    -- Focus effect
    local connFocus = hexInput.Focused:Connect(function()
        Utility.Tween(hexStroke, { Color = Theme.Accent }, 0.15)
    end)
    
    local connFocusLost = hexInput.FocusLost:Connect(function(enterPressed)
        Utility.Tween(hexStroke, { Color = Theme.Border }, 0.15)
        
        local text = hexInput.Text
        local newColor = hexToRgb(text)
        if newColor then
            self:Set(newColor)
        else
            -- Revert invalid hex code
            hexInput.Text = rgbToHex(self.Value)
        end
    end)
    
    -- Register local controls to the object
    self.DialogueHueTrack = hueTrack
    self.DialogueHueKnob = hueKnob
    self.DialogueSatTrack = satTrack
    self.DialogueSatGradient = satGradient
    self.DialogueSatKnob = satKnob
    self.DialogueValTrack = valTrack
    self.DialogueValGradient = valGradient
    self.DialogueValKnob = valKnob
    self.DialoguePreviewBar = previewBar
    
    -- Real-time dragging calculations
    local function updateHue(input)
        local relativeX = math.clamp(input.Position.X - hueTrack.AbsolutePosition.X, 0, hueTrack.AbsoluteSize.X)
        local percentage = relativeX / hueTrack.AbsoluteSize.X
        self.H = percentage
        hueKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    local function updateSat(input)
        local relativeX = math.clamp(input.Position.X - satTrack.AbsolutePosition.X, 0, satTrack.AbsoluteSize.X)
        local percentage = relativeX / satTrack.AbsoluteSize.X
        self.S = percentage
        satKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    local function updateVal(input)
        local relativeX = math.clamp(input.Position.X - valTrack.AbsolutePosition.X, 0, valTrack.AbsoluteSize.X)
        local percentage = relativeX / valTrack.AbsoluteSize.X
        self.V = percentage
        valKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    -- Mouse Input Events
    local connBeganHue = hueTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = true
            updateHue(input)
        end
    end)
    
    local connBeganSat = satTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingSat = true
            updateSat(input)
        end
    end)
    
    local connBeganVal = valTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingVal = true
            updateVal(input)
        end
    end)
    
    local connChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if self.DraggingHue then
                updateHue(input)
            elseif self.DraggingSat then
                updateSat(input)
            elseif self.DraggingVal then
                updateVal(input)
            end
        end
    end)
    
    local connEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = false
            self.DraggingSat = false
            self.DraggingVal = false
        end
    end)
    
    -- Cleanup on close
    dialogue.Backdrop.Destroying:Connect(function()
        connBeganHue:Disconnect()
        connBeganSat:Disconnect()
        connBeganVal:Disconnect()
        connChanged:Disconnect()
        connEnded:Disconnect()
        connFocus:Disconnect()
        connFocusLost:Disconnect()
        
        self.DialogueHueTrack = nil
        self.DialogueHueKnob = nil
        self.DialogueSatTrack = nil
        self.DialogueSatGradient = nil
        self.DialogueSatKnob = nil
        self.DialogueValTrack = nil
        self.DialogueValGradient = nil
        self.DialogueValKnob = nil
        self.DialoguePreviewBar = nil
        self.DialogueHexInput = nil
    end)
end

function Colorpicker:UpdateHSV()
    local color = Color3.fromHSV(self.H, self.S, self.V)
    self.Value = color
    
    -- Update Preview Box Color on Card
    self.PreviewBtn.BackgroundColor3 = color
    
    -- Update active dialogue controls if open
    if self.DialogueSatGradient then
        self.DialogueSatGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(self.H, 1, 1))
    end
    if self.DialogueValGradient then
        self.DialogueValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(self.H, self.S, 1))
    end
    if self.DialoguePreviewBar then
        self.DialoguePreviewBar.BackgroundColor3 = color
    end
    if self.DialogueHexInput and not self.DialogueHexInput:IsFocused() then
        self.DialogueHexInput.Text = rgbToHex(color)
    end
    
    -- Update Flags array
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = {color.R, color.G, color.B}
    end
    
    -- Fire Callback
    task.spawn(function()
        local success, err = pcall(self.Callback, color)
        if not success then
            warn("Error in colorpicker callback: " .. tostring(err))
        end
    end)
end

function Colorpicker:Set(color, force)
    if type(color) == "table" then
        color = Color3.new(color[1] or 1, color[2] or 1, color[3] or 1)
    end
    
    if self.Value == color and not force then return end
    
    self.Value = color
    
    local h, s, v = Color3.toHSV(color)
    self.H = h
    self.S = s
    self.V = v
    
    self.PreviewBtn.BackgroundColor3 = color
    
    -- If dialogue is open, update knobs & gradients
    if self.DialogueHueKnob then
        self.DialogueHueKnob.Position = UDim2.new(h, -7, 0.5, -7)
    end
    if self.DialogueSatKnob then
        self.DialogueSatKnob.Position = UDim2.new(s, -7, 0.5, -7)
    end
    if self.DialogueValKnob then
        self.DialogueValKnob.Position = UDim2.new(v, -7, 0.5, -7)
    end
    if self.DialogueSatGradient then
        self.DialogueSatGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(h, 1, 1))
    end
    if self.DialogueValGradient then
        self.DialogueValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, s, 1))
    end
    if self.DialoguePreviewBar then
        self.DialoguePreviewBar.BackgroundColor3 = color
    end
    if self.DialogueHexInput and not self.DialogueHexInput:IsFocused() then
        self.DialogueHexInput.Text = rgbToHex(color)
    end
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = {color.R, color.G, color.B}
    end
    
    task.spawn(function()
        local success, err = pcall(self.Callback, color)
        if not success then
            warn("Error in colorpicker callback: " .. tostring(err))
        end
    end)
end

return Colorpicker
end

-- MODULE: components/Dialogue
modules["components/Dialogue"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")

local Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue.new(title, window, size)
    local self = setmetatable({}, Dialogue)
    
    self.Window = window
    self.Size = size or UDim2.new(0, 240, 0, 200)
    self.Title = title or "Dialogue"
    
    self.Window.ActiveDialogue = self
    
    -- Dialogue Backdrop parented to self.Window.Container (blackout covers ONLY the window!)
    self.Backdrop = Utility.Create("Frame", { -- Using Frame to prevent button-drag release gotchas in Roblox
        Name = "DialogueBackdrop",
        Parent = self.Window.Container,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1, -- Start transparent for fade-in
        ZIndex = 200,
        Active = true
    }, {
        -- Rounded corners matching the main window container shape
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius })
    })
    
    -- Detect clicks OUTSIDE the dialogue box to close it
    self.Backdrop.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local frame = self.Frame
            if frame then
                local framePos = frame.AbsolutePosition
                local frameSize = frame.AbsoluteSize
                
                -- Check if click is outside dialogue frame bounds
                if pos.X < framePos.X or pos.X > (framePos.X + frameSize.X) or
                   pos.Y < framePos.Y or pos.Y > (framePos.Y + frameSize.Y) then
                    self:Close()
                end
            end
        end
    end)
    
    -- Dialogue Body Container (handles shadow, centering, and UIScale)
    self.FrameContainer = Utility.Create("Frame", {
        Name = "DialogueFrameContainer",
        Parent = self.Backdrop,
        Size = self.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Centered inside the blackout backdrop
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 201,
        ClipsDescendants = false
    }, {
        -- Sizing to UIScale as requested!
        Utility.Create("UIScale", {
            Name = "UIScale",
            Scale = 0
        })
    })
    
    self.UIScale = self.FrameContainer:FindFirstChild("UIScale")
    
    -- Add native drop shadow using UIShadow API
    Utility.AddShadow(self.FrameContainer, {
        BlurRadius = UDim.new(0, 20),
        Transparency = 0.5
    })
    
    -- Dialogue Body Frame (styled visual frame, clips descendants so contents don't overflow during zoom!)
    self.Frame = Utility.Create("Frame", {
        Name = "DialogueFrame",
        Parent = self.FrameContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 202,
        ClipsDescendants = true
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Header Bar
        Utility.Create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            ZIndex = 203
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
            Utility.Create("Frame", {
                Name = "Overlap",
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0, 16),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                ZIndex = 1
            }),
            Utility.Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = self.Title,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Theme.FontSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            }),
            -- Close Button
            Utility.Create("TextButton", {
                Name = "Close",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -28, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 2
            }, {
                Utility.Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0.5, -6, 0.5, -6),
                    BackgroundTransparency = 1,
                    Image = Lucide.GetAsset("x", 48).Url,
                    ImageRectSize = Lucide.GetAsset("x", 48).ImageRectSize,
                    ImageRectOffset = Lucide.GetAsset("x", 48).ImageRectOffset,
                    ImageColor3 = Theme.TextSecondary,
                    ZIndex = 3
                })
            })
        }),
        -- Content Area (shifted down by 32px to accommodate header)
        Utility.Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, 0, 1, -32),
            Position = UDim2.new(0, 0, 0, 32),
            BackgroundTransparency = 1,
            ZIndex = 203
        })
    })
    
    self.Header = self.Frame:FindFirstChild("Header")
    self.Content = self.Frame:FindFirstChild("Content")
    self.CloseBtn = self.Header:FindFirstChild("Close")
    
    -- Close button logic
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Hover effect on Close
    local closeIcon = self.CloseBtn:FindFirstChild("Icon")
    self.CloseBtn.MouseEnter:Connect(function()
        Utility.Tween(closeIcon, { ImageColor3 = Theme.Failure }, 0.15)
    end)
    self.CloseBtn.MouseLeave:Connect(function()
        Utility.Tween(closeIcon, { ImageColor3 = Theme.TextSecondary }, 0.15)
    end)
    
    -- Opening Animations (Fade dim & Zoom pop using UIScale!)
    Utility.Tween(self.Backdrop, { BackgroundTransparency = 0.65 }, 0.2)
    Utility.Tween(self.UIScale, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
    
    return self
end

function Dialogue:Close()
    if self.Window and self.Window.ActiveDialogue == self then
        self.Window.ActiveDialogue = nil
    end
    
    local closeTween = Utility.Tween(self.UIScale, { Scale = 0 }, 0.15)
    Utility.Tween(self.Backdrop, { BackgroundTransparency = 1 }, 0.15)
    
    closeTween.Completed:Connect(function()
        self.Backdrop:Destroy()
    end)
end

return Dialogue
end

-- MODULE: components/Dropdown
modules["components/Dropdown"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")
local TweenService = game:GetService("TweenService")

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(text, parent, options, callback, window)
    local self = setmetatable({}, Dropdown)
    
    options = options or {}
    self.Text = text or "Dropdown"
    self.List = options.list or options.List or {}
    self.Default = options.default or options.Default
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    
    self.Value = self.Default or (self.List[1] or "")
    self.Backdrop = nil
    self.PopupContainer = nil
    self.Popup = nil
    
    local chevron = Lucide.GetAsset("chevron-down", 48)
    
    -- Main Card Container (styled card frame)
    self.Frame = Utility.Create("Frame", {
        Name = "Dropdown_" .. self.Text,
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
        -- Label on the left
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -170, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility.Create("TextButton", {
            Name = "SelectBox",
            Size = UDim2.new(0, 140, 0, 26),
            Position = UDim2.new(1, -155, 0.5, -13),
            BackgroundColor3 = Theme.BorderMuted,
            Text = "",
            AutoButtonColor = false
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }),
            -- Selected Value Label
            Utility.Create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(self.Value),
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            -- Chevron Arrow
            Utility.Create("ImageLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -18, 0.5, -6),
                BackgroundTransparency = 1,
                Image = chevron.Url,
                ImageRectSize = chevron.ImageRectSize,
                ImageRectOffset = chevron.ImageRectOffset,
                ImageColor3 = Theme.TextSecondary,
                ZIndex = 2
            })
        })
    })
    
    self.Label = self.Frame:FindFirstChild("Label")
    self.SelectBox = self.Frame:FindFirstChild("SelectBox")
    self.ValueLabel = self.SelectBox:FindFirstChild("ValueLabel")
    self.Arrow = self.SelectBox:FindFirstChild("Arrow")
    self.SelectStroke = self.SelectBox:FindFirstChildOfClass("UIStroke")
    self.Stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
        Utility.Tween(self.Label, { TextColor3 = Theme.TextPrimary }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
        Utility.Tween(self.Label, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    
    -- Click toggle
    self.SelectBox.MouseButton1Click:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        if self.PopupContainer then
            self:ClosePopup()
        else
            self:OpenPopup()
        end
    end)
    
    Utility.AddClickEffect(self.SelectBox)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Value
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Initialize displayed text
    self:Set(self.Value, true)
    
    return self
end

function Dropdown:OpenPopup()
    if self.PopupContainer then return end
    
    -- Close any other open dropdown in this window
    if self.Window and self.Window.OpenDropdown and self.Window.OpenDropdown ~= self then
        self.Window.OpenDropdown:ClosePopup()
    end
    if self.Window then
        self.Window.OpenDropdown = self
    end
    
    -- Align width to select box (140px)
    local targetWidth = 140
    local popupHeight = 200
    
    -- Calculate positioning relative to self.Window.Container
    local triggerPos = self.SelectBox.AbsolutePosition
    local containerPos = self.Window.Container.AbsolutePosition
    local scale = self.Window.UIScale.Scale
    
    local relX = (triggerPos.X - containerPos.X) / scale
    local relY = (triggerPos.Y - containerPos.Y) / scale
    
    -- Dropdown always appears below the selector
    local popupY = relY + 28
    
    -- Backdrop on ScreenGui for click-outside detection
    self.Backdrop = Utility.Create("TextButton", {
        Name = "DropdownBackdrop",
        Parent = self.Window.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 99999,
        Active = true
    })
    
    self.Backdrop.MouseButton1Click:Connect(function()
        self:ClosePopup()
    end)
    
    -- Popup Container parented to self.Window.Container (enables scaling and placement without clipping)
    self.PopupContainer = Utility.Create("Frame", {
        Name = "DropdownPopupContainer",
        Parent = self.Window.Container,
        Size = UDim2.new(0, targetWidth, 0, popupHeight),
        Position = UDim2.new(0, relX + 70, 0, popupY), -- Centered at X offset
        AnchorPoint = Vector2.new(0.5, 0), -- Scaled from center-top
        BackgroundTransparency = 1,
        ZIndex = 100,
        ClipsDescendants = false
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIScale", {
            Name = "UIScale",
            Scale = 0
        })
    })
    
    self.UIScale = self.PopupContainer:FindFirstChild("UIScale")
    
    -- Add drop shadow using native UIShadow API
    Utility.AddShadow(self.PopupContainer, {
        BlurRadius = UDim.new(0, 12),
        Transparency = 0.6
    })
    
    -- Inner Visual Popup frame (clips descendants so content animates size cleanly)
    self.Popup = Utility.Create("Frame", {
        Name = "DropdownPopup",
        Parent = self.PopupContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 101,
        ClipsDescendants = true
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })
    
    -- Search Input Container
    local searchContainer = Utility.Create("Frame", {
        Name = "SearchContainer",
        Parent = self.Popup,
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 102
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1
        })
    })
    
    local searchIconAsset = Lucide.GetAsset("search", 48)
    local searchIcon = Utility.Create("ImageLabel", {
        Name = "SearchIcon",
        Parent = searchContainer,
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 8, 0.5, -5),
        BackgroundTransparency = 1,
        Image = searchIconAsset.Url,
        ImageRectSize = searchIconAsset.ImageRectSize,
        ImageRectOffset = searchIconAsset.ImageRectOffset,
        ImageColor3 = Theme.TextSecondary,
        ZIndex = 103
    })
    
    local searchBox = Utility.Create("TextBox", {
        Name = "SearchBox",
        Parent = searchContainer,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 103
    })
    
    -- Scrolling frame for options
    local optionsContainer = Utility.Create("ScrollingFrame", {
        Name = "OptionsContainer",
        Parent = self.Popup,
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 102
    }, {
        Utility.Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })
    
    local uiListLayout = optionsContainer:FindFirstChildOfClass("UIListLayout")
    
    -- Function to populate items
    local function populateOptions(filterQuery)
        filterQuery = filterQuery and string.lower(filterQuery) or ""
        
        -- Clear current list items
        for _, child in ipairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local index = 0
        for _, option in ipairs(self.List) do
            local optStr = tostring(option)
            if filterQuery == "" or string.find(string.lower(optStr), filterQuery) then
                index = index + 1
                local isSelected = (option == self.Value)
                
                local optionBtn = Utility.Create("TextButton", {
                    Name = "Option_" .. optStr,
                    Parent = optionsContainer,
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.Card,
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = index,
                    ZIndex = 103
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Utility.Create("TextLabel", {
                        Name = "OptionLabel",
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = optStr,
                        TextColor3 = isSelected and Theme.Accent or Theme.TextSecondary,
                        TextSize = 12,
                        Font = Theme.FontMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 104
                    })
                })
                
                local optLabel = optionBtn:FindFirstChild("OptionLabel")
                
                optionBtn.MouseEnter:Connect(function()
                    Utility.Tween(optionBtn, { BackgroundTransparency = 0 }, 0.1)
                    if not isSelected then
                        Utility.Tween(optLabel, { TextColor3 = Theme.TextPrimary }, 0.1)
                    end
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Utility.Tween(optionBtn, { BackgroundTransparency = 1 }, 0.1)
                    if not isSelected then
                        Utility.Tween(optLabel, { TextColor3 = Theme.TextSecondary }, 0.1)
                    end
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    self:Set(option)
                    self:ClosePopup()
                end)
            end
        end
        
        -- Dynamic canvas sizing
        task.spawn(function()
            task.wait()
            if optionsContainer and uiListLayout then
                optionsContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
            end
        end)
    end
    
    -- Filter change listener
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateOptions(searchBox.Text)
    end)
    
    -- Populate default list
    populateOptions()
    
    -- Open animation
    Utility.Tween(self.Arrow, { Rotation = 180 }, 0.15)
    Utility.Tween(self.SelectStroke, { Color = Theme.Accent }, 0.15)
    Utility.Tween(self.UIScale, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
end

function Dropdown:ClosePopup()
    if not self.PopupContainer then return end
    
    if self.Window and self.Window.OpenDropdown == self then
        self.Window.OpenDropdown = nil
    end
    
    -- Close animation
    Utility.Tween(self.Arrow, { Rotation = 0 }, 0.1)
    Utility.Tween(self.SelectStroke, { Color = Theme.Border }, 0.1)
    local tween = Utility.Tween(self.UIScale, { Scale = 0 }, 0.15)
    
    local currentBackdrop = self.Backdrop
    local currentContainer = self.PopupContainer
    
    self.Backdrop = nil
    self.PopupContainer = nil
    self.Popup = nil
    self.UIScale = nil
    
    tween.Completed:Connect(function()
        if currentBackdrop then currentBackdrop:Destroy() end
        if currentContainer then currentContainer:Destroy() end
    end)
end

function Dropdown:Set(val, force)
    if self.Value == val and not force then return end
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    self.ValueLabel.Text = tostring(val)
    
    -- If popup is open, we can update highlights
    if self.PopupContainer then
        local optionsContainer = self.Popup:FindFirstChild("OptionsContainer")
        if optionsContainer then
            for _, child in ipairs(optionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    local isSelected = (child.Name == "Option_" .. tostring(val))
                    local label = child:FindFirstChild("OptionLabel")
                    if label then
                        Utility.Tween(label, {
                            TextColor3 = isSelected and Theme.Accent or Theme.TextSecondary
                        }, 0.1)
                    end
                end
            end
        end
    end
    
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in dropdown callback: " .. tostring(err))
        end
    end)
end

function Dropdown:Refresh(newList, selectFirst)
    self.List = newList or {}
    
    if selectFirst and #self.List > 0 then
        self:Set(self.List[1])
    elseif not table.find(self.List, self.Value) and #self.List > 0 then
        self:Set(self.List[1])
    else
        self:Set(self.Value, true)
    end
    
    -- If open, close popup to force reload next time
    if self.PopupContainer then
        self:ClosePopup()
    end
end

return Dropdown
end

-- MODULE: components/Keybind
modules["components/Keybind"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

local BlacklistedKeys = {
    [Enum.KeyCode.Unknown] = true,
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Slash] = true, -- Avoid binding chat
    [Enum.KeyCode.Backspace] = true,
    [Enum.KeyCode.Escape] = true
}

function Keybind.new(text, parent, options, callback, window)
    local self = setmetatable({}, Keybind)
    
    options = options or {}
    self.Text = text or "Keybind"
    self.Default = options.default or options.Default or Enum.KeyCode.RightShift
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    
    self.Value = self.Default
    self.Binding = false
    self.GlobalConnection = nil
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Keybind_" .. self.Text,
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
        -- Label (Left)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -115, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Bind Button (Right)
        Utility.Create("TextButton", {
            Name = "BindButton",
            Size = UDim2.new(0, 140, 0, 26),
            Position = UDim2.new(1, -155, 0.5, -13),
            BackgroundColor3 = Theme.BorderMuted,
            Text = "",
            AutoButtonColor = false
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }),
            -- Text inside Bind Button
            Utility.Create("TextLabel", {
                Name = "BindLabel",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = self.Default.Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Center
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.BindButton = self.Frame:FindFirstChild("BindButton")
    self.BindStroke = self.BindButton:FindFirstChildOfClass("UIStroke")
    self.BindLabel = self.BindButton:FindFirstChild("BindLabel")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Binding Trigger Click
    self.BindButton.MouseButton1Click:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        self:StartBinding()
    end)
    
    Utility.AddClickEffect(self.BindButton)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        -- Store as name for JSON serialization compatibility
        self.Window.Flags[self.Flag] = self.Default.Name
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Setup initial key action binding
    self:BindKey(self.Default)
    
    return self
end

function Keybind:StartBinding()
    if self.Binding then return end
    self.Binding = true
    
    self.BindLabel.Text = "..."
    Utility.Tween(self.BindStroke, { Color = Theme.Accent }, 0.15)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        local key = input.KeyCode
        
        -- Capture key press (ignore mouse movements, focus textboxes, etc.)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if not BlacklistedKeys[key] then
                connection:Disconnect()
                self.Binding = false
                self:Set(key)
            elseif key == Enum.KeyCode.Escape then
                connection:Disconnect()
                self.Binding = false
                -- Revert to original
                self:Set(self.Value)
            end
        end
    end)
end

function Keybind:Set(keyCode, force)
    -- Handle string representations (e.g. from JSON config loads)
    if type(keyCode) == "string" then
        local success, resolved = pcall(function()
            return Enum.KeyCode[keyCode]
        end)
        if success then
            keyCode = resolved
        else
            warn("Could not resolve KeyCode string: " .. tostring(keyCode))
            keyCode = self.Default
        end
    end
    
    if self.Value == keyCode and not force then return end
    
    self.Value = keyCode
    self.BindLabel.Text = keyCode.Name
    
    -- Reset Visual states
    Utility.Tween(self.BindStroke, { Color = Theme.Border }, 0.15)
    
    -- Update Config value (serialize Enum to Name string)
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = keyCode.Name
    end
    
    -- Setup new Key listener
    self:BindKey(keyCode)
    
    -- Fire Callback
    task.spawn(function()
        local success, err = pcall(self.Callback, keyCode)
        if not success then
            warn("Error in keybind callback: " .. tostring(err))
        end
    end)
end

function Keybind:BindKey(keyCode)
    -- Disconnect old connection
    if self.GlobalConnection then
        self.GlobalConnection:Disconnect()
        self.GlobalConnection = nil
    end
    
    -- Bind global event for this key
    self.GlobalConnection = UserInputService.InputBegan:Connect(function(input, processed)
        -- Ignore inputs typed in chat, textboxes, etc.
        if not processed and input.KeyCode == keyCode then
            task.spawn(function()
                local success, err = pcall(self.Callback, keyCode)
                if not success then
                    warn("Error running keybind callback: " .. tostring(err))
                end
            end)
        end
    end)
end

function Keybind:Destroy()
    if self.GlobalConnection then
        self.GlobalConnection:Disconnect()
    end
end

return Keybind
end

-- MODULE: components/Label
modules["components/Label"] = function()local Theme = require("theme")
local Utility = require("utility")

local Label = {}
Label.__index = Label

function Label.new(text, parent)
    local self = setmetatable({}, Label)
    
    self.Text = text or "Label"
    
    self.Frame = Utility.Create("Frame", {
        Name = "Label_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1
    }, {
        Utility.Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            Font = Theme.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    })
    
    self.TextLabel = self.Frame:FindFirstChild("TextLabel")
    
    return self
end

function Label.newSection(text, parent)
    local self = setmetatable({}, Label)
    
    self.Text = text or "Section"
    
    self.Frame = Utility.Create("Frame", {
        Name = "Section_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1
    }, {
        -- Section Text (No accent bar, aligned to margin)
        Utility.Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = string.upper(self.Text),
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            Font = Theme.FontSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    })
    
    self.TextLabel = self.Frame:FindFirstChild("TextLabel")
    
    return self
end

function Label:Set(text)
    self.Text = text
    self.TextLabel.Text = text
end

return Label
end

-- MODULE: components/Slider
modules["components/Slider"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Slider = {}
Slider.__index = Slider

function Slider.new(text, parent, options, callback, window)
    local self = setmetatable({}, Slider)
    
    options = options or {}
    self.Text = text or "Slider"
    self.Min = options.min or options.Min or 0
    self.Max = options.max or options.Max or 100
    self.Default = options.default or options.Default or self.Min
    self.Step = options.step or options.Step or 1
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    self.Value = self.Default
    self.Dragging = false
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Slider_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label (Left-aligned, Top)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0.6, 0, 0, 25),
            Position = UDim2.new(0, 15, 0, 4),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Value Indicator (Right-aligned, Top)
        Utility.Create("TextLabel", {
            Name = "ValueLabel",
            Size = UDim2.new(0.4, -15, 0, 25),
            Position = UDim2.new(0.6, 0, 0, 4),
            BackgroundTransparency = 1,
            Text = tostring(self.Default),
            TextColor3 = Theme.TextPrimary,
            TextSize = 13,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
        -- Slider Track (Bottom area)
        Utility.Create("TextButton", {
            Name = "Track",
            Size = UDim2.new(1, -30, 0, 6),
            Position = UDim2.new(0, 15, 1, -14),
            BackgroundColor3 = Theme.BorderMuted,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            -- Slider Fill
            Utility.Create("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                -- Slider Knob
                Utility.Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -6, 0.5, -6),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel = 0
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.Track = self.Frame:FindFirstChild("Track")
    self.Fill = self.Track:FindFirstChild("Fill")
    self.Knob = self.Fill:FindFirstChild("Knob")
    self.ValueLabel = self.Frame:FindFirstChild("ValueLabel")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Dragging Logic
    local function updateValue(input)
        local absoluteWidth = self.Track.AbsoluteSize.X
        local relativeX = math.clamp(input.Position.X - self.Track.AbsolutePosition.X, 0, absoluteWidth)
        local percentage = relativeX / absoluteWidth
        
        local rawValue = self.Min + (self.Max - self.Min) * percentage
        -- Apply step snapping
        local steppedValue = math.round(rawValue / self.Step) * self.Step
        -- Clamping bounds in case of rounding floating issues
        steppedValue = math.clamp(steppedValue, self.Min, self.Max)
        
        self:Set(steppedValue)
    end
    
    self.Track.InputBegan:Connect(function(input)
        if self.Window and self.Window.ActiveDialogue then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            updateValue(input)
            TweenService:Create(self.Knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7) }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            self.Dragging = false
            TweenService:Create(self.Knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6) }):Play()
        end
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Set Initial Value
    self:Set(self.Default)
    
    return self
end

function Slider:Set(val)
    -- Clamp and align to step
    val = math.clamp(math.round(val / self.Step) * self.Step, self.Min, self.Max)
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    -- Update visuals
    self.ValueLabel.Text = tostring(val)
    local percentage = (val - self.Min) / (self.Max - self.Min)
    -- Handle divide by zero edge case
    if self.Max == self.Min then percentage = 0 end
    
    if self.Dragging then
        self.Fill.Size = UDim2.new(percentage, 0, 1, 0)
    else
        TweenService:Create(self.Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(percentage, 0, 1, 0) }):Play()
    end
    
    -- Callback trigger
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in slider callback: " .. tostring(err))
        end
    end)
end

return Slider
end

-- MODULE: components/Tab
modules["components/Tab"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")

local Tab = {}
Tab.__index = Tab

function Tab.new(name, window, icon)
    local self = setmetatable({}, Tab)
    
    self.Name = name
    self.Window = window
    self.Active = false
    
    -- 1. Tab Button in Sidebar
    local tabContainer = window.Sidebar:FindFirstChild("TabContainer")
    
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
    
    self.Button = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Parent = tabContainer,
        Size = UDim2.new(0.9, 0, 0, 36),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        
        -- Text Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = hasIcon and UDim2.new(1, -48, 1, 0) or UDim2.new(1, -20, 1, 0),
            Position = hasIcon and UDim2.new(0, 38, 0, 0) or UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    if hasIcon then
        self.Icon = Utility.Create("ImageLabel", {
            Name = "Icon",
            Parent = self.Button,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 14, 0.5, -8),
            BackgroundTransparency = 1,
            Image = iconAsset.Url,
            ImageRectSize = iconAsset.ImageRectSize,
            ImageRectOffset = iconAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 2
        })
    end
    
    -- 2. Content Page Frame
    self.Page = Utility.Create("ScrollingFrame", {
        Name = "Page_" .. name,
        Parent = window.ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    }, {
        Utility.Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })
    })
    
    -- Auto-adjust CanvasSize
    local uiListLayout = self.Page:FindFirstChildOfClass("UIListLayout")
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Page.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Button Logic
    self.Button.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        if not self.Active then
            Utility.Tween(self.Button:FindFirstChild("Label"), { TextColor3 = Theme.TextPrimary }, 0.15)
            if self.Icon then
                Utility.Tween(self.Icon, { ImageColor3 = Theme.TextPrimary }, 0.15)
            end
            Utility.Tween(self.Button, { BackgroundTransparency = 0.85 }, 0.15)
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        if not self.Active then
            Utility.Tween(self.Button:FindFirstChild("Label"), { TextColor3 = Theme.TextSecondary }, 0.15)
            if self.Icon then
                Utility.Tween(self.Icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
            end
            Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        self.Window:SelectTab(self.Name)
    end)
    
    Utility.AddClickEffect(self.Button)
    
    return self
end

function Tab:Show()
    self.Active = true
    self.Page.Visible = true
    
    local label = self.Button:FindFirstChild("Label")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Card }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextPrimary }, 0.15)
    if self.Icon then
        Utility.Tween(self.Icon, { ImageColor3 = Theme.TextPrimary }, 0.15)
    end
end

function Tab:Hide()
    self.Active = false
    self.Page.Visible = false
    
    local label = self.Button:FindFirstChild("Label")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextSecondary }, 0.15)
    if self.Icon then
        Utility.Tween(self.Icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
    end
end

-- Component wrappers
function Tab:AddButton(text, callback, icon)
    local Button = require("components/Button")
    return Button.new(text, self.Page, callback, icon, self.Window)
end

function Tab:AddToggle(text, options, callback)
    local Toggle = require("components/Toggle")
    return Toggle.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddSlider(text, options, callback)
    local Slider = require("components/Slider")
    return Slider.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddDropdown(text, options, callback)
    local Dropdown = require("components/Dropdown")
    return Dropdown.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddTextBox(text, placeholder, options, callback)
    local TextBox = require("components/TextBox")
    return TextBox.new(text, self.Page, placeholder, options, callback, self.Window)
end

function Tab:AddKeybind(text, options, callback)
    local Keybind = require("components/Keybind")
    return Keybind.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddColorpicker(text, options, callback)
    local Colorpicker = require("components/Colorpicker")
    return Colorpicker.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddLabel(text)
    local Label = require("components/Label")
    return Label.new(text, self.Page)
end

function Tab:AddSection(text)
    local Label = require("components/Label")
    return Label.newSection(text, self.Page)
end

return Tab
end

-- MODULE: components/TextBox
modules["components/TextBox"] = function()local Theme = require("theme")
local Utility = require("utility")

local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(text, parent, placeholder, options, callback, window)
    local self = setmetatable({}, TextBox)
    
    options = options or {}
    self.Text = text or "TextBox"
    self.Placeholder = placeholder or options.placeholder or options.Placeholder or "Type here..."
    self.Default = options.default or options.Default or ""
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    self.Value = self.Default
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "TextBox_" .. self.Text,
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
        -- Label (Left)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -170, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Input Holder Frame (Right)
        Utility.Create("Frame", {
            Name = "InputHolder",
            Size = UDim2.new(0, 140, 0, 26),
            Position = UDim2.new(1, -155, 0.5, -13),
            BackgroundColor3 = Theme.BorderMuted,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }),
            -- Actual TextBox
            Utility.Create("TextBox", {
                Name = "Input",
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = self.Default,
                PlaceholderText = self.Placeholder,
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.InputHolder = self.Frame:FindFirstChild("InputHolder")
    self.InputStroke = self.InputHolder:FindFirstChildOfClass("UIStroke")
    self.Input = self.InputHolder:FindFirstChild("Input")
    
    -- Focus effects
    self.Input.Focused:Connect(function()
        if self.Window and self.Window.ActiveDialogue then
            self.Input:ReleaseFocus()
            return
        end
        Utility.Tween(self.InputStroke, { Color = Theme.Accent }, 0.15)
    end)
    
    self.Input.FocusLost:Connect(function(enterPressed)
        Utility.Tween(self.InputStroke, { Color = Theme.Border }, 0.15)
        self:Set(self.Input.Text)
    end)
    
    -- Main frame hover effects
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Initialize
    self:Set(self.Default, true)
    
    return self
end

function TextBox:Set(val, force)
    if self.Value == val and not force then return end
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    if self.Input.Text ~= val then
        self.Input.Text = val
    end
    
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in textbox callback: " .. tostring(err))
        end
    end)
end

return TextBox
end

-- MODULE: components/Toggle
modules["components/Toggle"] = function()local Theme = require("theme")
local Utility = require("utility")

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(text, parent, options, callback, window)
    local self = setmetatable({}, Toggle)
    
    options = options or {}
    self.Text = text or "Toggle"
    self.Flag = options.flag or options.Flag
    self.Default = options.default or options.Default or false
    self.Callback = callback or function() end
    self.Window = window
    self.Value = false
    
    -- Main Frame
    self.Frame = Utility.Create("TextButton", {
        Name = "Toggle_" .. self.Text,
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
        }),
        -- Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Switch Track
        Utility.Create("Frame", {
            Name = "Track",
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -55, 0.5, -10),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            -- Switch Knob
            Utility.Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.Track = self.Frame:FindFirstChild("Track")
    self.Knob = self.Track:FindFirstChild("Knob")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Click toggle
    self.Frame.MouseButton1Click:Connect(function()
        if self.Window and self.Window.ActiveDialogue then return end
        self:Set(not self.Value)
    end)
    
    Utility.AddClickEffect(self.Frame)
    
    -- Register Flag in Window (if flag option was provided)
    if self.Flag and self.Window then
        -- Add registration functions to the window if not already initialized
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Set Initial Value
    self:Set(self.Default)
    
    return self
end

function Toggle:Set(state)
    self.Value = state
    
    -- Update Config Value in Library
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = state
    end
    
    -- Visual update (tween knob and background track color)
    local targetPos = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = state and Theme.Success or Theme.Border
    
    Utility.Tween(self.Knob, { Position = targetPos }, 0.15)
    Utility.Tween(self.Track, { BackgroundColor3 = targetColor }, 0.15)
    Utility.Tween(self.Frame:FindFirstChild("Label"), { TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary }, 0.15)
    
    -- Safe Callback execution
    task.spawn(function()
        local success, err = pcall(self.Callback, state)
        if not success then
            warn("Error in toggle callback: " .. tostring(err))
        end
    end)
end

return Toggle
end

-- MODULE: components/Window
modules["components/Window"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Window = {}
Window.__index = Window

function Window.new(title, configFolder)
    local self = setmetatable({}, Window)
    
    self.Title = title or "Useless Hub"
    self.ConfigFolder = configFolder or "uselesshub_configs"
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Closed = false
    self.Flags = {}
    self.FlagElements = {}
    
    -- Main ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = self.Title .. "_Gui",
        Parent = Utility.GetCoreGui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Centered pivot container for scaling & positioning (with UICorner so shadow is rounded)
    self.Container = Utility.Create("Frame", {
        Name = "WindowContainer",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 580, 0, 380),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius })
    })
    
    -- Main Window native drop shadow
    Utility.AddShadow(self.Container, {
        BlurRadius = UDim.new(0, 24),
        Transparency = 0.5
    })
    
    -- Main Frame (styled window)
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Parent = self.Container,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })

    -- Single UIScale Setup (on the Container for centered zoom)
    self.UIScale = Utility.Create("UIScale", {
        Name = "UIScale",
        Parent = self.Container,
        Scale = 0.94
    })
    
    -- Value holder for animating the appear scale cleanly
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



    -- Header
    self.Header = Utility.Create("Frame", {
        Name = "Header",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 2
    }, {
        Utility.Create("UICorner", {
            Name = "Corner",
            TopLeftRadius = Theme.CornerRadius,
            TopRightRadius = Theme.CornerRadius,
            BottomLeftRadius = UDim.new(0, 0),
            BottomRightRadius = UDim.new(0, 0)
        }),
        
        -- Header title
        Utility.Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Title,
            TextColor3 = Theme.TextPrimary,
            TextSize = 16,
            Font = Theme.FontSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        }),
        
        -- Window actions container
        Utility.Create("Frame", {
            Name = "Actions",
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(1, -80, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 2
        }),

        -- Bottom border divider line
        Utility.Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 3
        })
    })
    
    self.HeaderCorner = self.Header:FindFirstChild("Corner")
    self.HeaderDivider = self.Header:FindFirstChild("Divider")
    
    -- Close and Minimize Buttons
    local actionsContainer = self.Header:FindFirstChild("Actions")
    
    local minusAsset = Lucide.GetAsset("minus", 48)
    local xAsset = Lucide.GetAsset("x", 48)
    
    self.MinimizeButton = Utility.Create("TextButton", {
        Name = "Minimize",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3
    }, {
        Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = minusAsset.Url,
            ImageRectSize = minusAsset.ImageRectSize,
            ImageRectOffset = minusAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 4
        })
    })
    
    self.CloseButton = Utility.Create("TextButton", {
        Name = "Close",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3
    }, {
        Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = xAsset.Url,
            ImageRectSize = xAsset.ImageRectSize,
            ImageRectOffset = xAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 4
        })
    })
    
    -- Sidebar (Left)
    self.Sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 150, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        -- Rounded corners for Sidebar (Bottom-Left rounded, others square)
        Utility.Create("UICorner", {
            BottomLeftRadius = Theme.CornerRadius,
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomRightRadius = UDim.new(0, 0)
        }),

        -- Right border line
        Utility.Create("Frame", {
            Name = "Border",
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0
        }),
        -- Tab button container (aligned with page header content)
        Utility.Create("ScrollingFrame", {
            Name = "TabContainer",
            Size = UDim2.new(1, -5, 1, -15),
            Position = UDim2.new(0, 0, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            ScrollingDirection = Enum.ScrollingDirection.Y
        }, {
            Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        })
    })
    
    -- Content Pages Container (Right)
    self.ContentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -150, 1, -45),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundTransparency = 1
    })
    
    -- Make window draggable via Header (blocked if dialogue is active)
    Utility.MakeDraggable(self.Container, self.Header, function()
        return self.ActiveDialogue ~= nil
    end)
    
    -- Button Connections
    self.MinimizeButton.MouseEnter:Connect(function()
        if self.ActiveDialogue then return end
        local icon = self.MinimizeButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.Accent }, 0.15)
        end
    end)
    self.MinimizeButton.MouseLeave:Connect(function()
        if self.ActiveDialogue then return end
        local icon = self.MinimizeButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
        end
    end)
    self.MinimizeButton.MouseButton1Click:Connect(function()
        if self.ActiveDialogue then return end
        self:ToggleMinimize()
    end)
    
    self.CloseButton.MouseEnter:Connect(function()
        if self.ActiveDialogue then return end
        local icon = self.CloseButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.Failure }, 0.15)
        end
    end)
    self.CloseButton.MouseLeave:Connect(function()
        if self.ActiveDialogue then return end
        local icon = self.CloseButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
        end
    end)
    self.CloseButton.MouseButton1Click:Connect(function()
        if self.ActiveDialogue then return end
        self:Close()
    end)
    
    Utility.AddClickEffect(self.MinimizeButton)
    Utility.AddClickEffect(self.CloseButton)
    
    -- Auto-adjust CanvasSize of Sidebar TabContainer
    local tabContainer = self.Sidebar:FindFirstChild("TabContainer")
    local uiListLayout = tabContainer:FindFirstChildOfClass("UIListLayout")
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Bind key to toggle UI visibility (default RightShift)
    self.ToggleKey = Enum.KeyCode.RightShift
    self.InputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self:ToggleVisibility()
        end
    end)
    
    -- Animate Launch (Appear Scale)
    task.spawn(function()
        task.wait(0.02)
        TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = 1.0 }):Play()
    end)

    return self
end

function Window:ToggleMinimize()
    if self.Closed then return end
    
    self.Minimized = not self.Minimized
    
    local targetHeight = self.Minimized and 45 or 380
    
    -- Dynamically round bottom corners of header when minimized, and toggle header divider line
    if self.HeaderCorner then
        if self.Minimized then
            self.HeaderCorner.BottomLeftRadius = Theme.CornerRadius
            self.HeaderCorner.BottomRightRadius = Theme.CornerRadius
        else
            self.HeaderCorner.BottomLeftRadius = UDim.new(0, 0)
            self.HeaderCorner.BottomRightRadius = UDim.new(0, 0)
        end
    end
    if self.HeaderDivider then
        self.HeaderDivider.Visible = not self.Minimized
    end
    
    -- If minimizing, hide the body components immediately/smoothly
    if self.Minimized then
        self.Sidebar.Visible = false
        self.ContentContainer.Visible = false
    end
    
    -- Tween container size (updates drop shadow bounds!) and main frame size
    Utility.Tween(self.Container, { Size = UDim2.new(0, 580, 0, targetHeight) }, Theme.TweenSpeed, Theme.TweenEasing, Theme.TweenDirection)
    local tween = Utility.Tween(self.MainFrame, { Size = UDim2.new(1, 0, 0, targetHeight) }, Theme.TweenSpeed, Theme.TweenEasing, Theme.TweenDirection)
    
    if not self.Minimized then
        tween.Completed:Connect(function()
            if not self.Minimized then
                self.Sidebar.Visible = true
                self.ContentContainer.Visible = true
            end
        end)
    end
end

function Window:ToggleVisibility()
    if self.Closed then return end
    
    if self.MainFrame.Visible then
        local tween = TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 0.94 })
        tween:Play()
        self.ToggleConnection = tween.Completed:Connect(function()
            self.MainFrame.Visible = false
            if self.ToggleConnection then
                self.ToggleConnection:Disconnect()
                self.ToggleConnection = nil
            end
        end)
    else
        if self.ToggleConnection then
            self.ToggleConnection:Disconnect()
            self.ToggleConnection = nil
        end
        self.AppearScaleValue.Value = 0.94
        self.MainFrame.Visible = true
        TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = 1.0 }):Play()
    end
end

function Window:Close()
    if self.Closed then return end
    self.Closed = true
    
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    if self.ViewportConnection then
        self.ViewportConnection:Disconnect()
    end
    
    local tween = TweenService:Create(self.AppearScaleValue, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 0.94 })
    tween:Play()
    tween.Completed:Wait()
    
    self.ScreenGui:Destroy()
end

function Window:AddTab(name, icon)
    local Tab = require("components/Tab")
    local newTab = Tab.new(name, self, icon)
    
    table.insert(self.Tabs, newTab)
    
    -- If this is the first tab, select it
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    return newTab
end

function Window:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then
            self.CurrentTab = tab
            tab:Show()
        else
            tab:Hide()
        end
    end
end

-- Configuration System Methods
function Window:SaveConfig(name)
    return Utility.WriteConfig(self.ConfigFolder, name, self.Flags)
end

function Window:LoadConfig(name)
    local data = Utility.ReadConfig(self.ConfigFolder, name)
    if data then
        for flag, val in pairs(data) do
            if self.FlagElements[flag] then
                pcall(function()
                    self.FlagElements[flag]:Set(val)
                end)
            else
                self.Flags[flag] = val
            end
        end
        return true
    end
    return false
end

function Window:GetConfigs()
    return Utility.ListConfigs(self.ConfigFolder)
end

function Window:AddConfigTab()
    local configTab = self:AddTab("Settings", "settings")
    configTab:AddSection("Config Management")
    
    local configName = "default"
    
    local configInput = configTab:AddTextBox("Config Name", "default", {
        default = "default"
    }, function(val)
        configName = val
    end)
    
    local configDropdown
    local configList = {}
    
    local function refreshConfigs()
        configList = self:GetConfigs()
        if #configList == 0 then
            configList = {"Nothing here yet..."}
        end
        if configDropdown then
            configDropdown:Refresh(configList, false)
        end
    end
    
    configDropdown = configTab:AddDropdown("Saved Configs", {
        list = configList,
        default = ""
    }, function(selected)
        if selected and selected ~= "" and selected ~= "Nothing here yet..." then
            configName = selected
            configInput:Set(selected)
        end
    end)
    
    configTab:AddButton("Save Config", function()
        if configName == "" or configName == "Nothing here yet..." then return end
        self:SaveConfig(configName)
        refreshConfigs()
    end)
    
    configTab:AddButton("Load Config", function()
        if configName == "" or configName == "Nothing here yet..." then return end
        self:LoadConfig(configName)
    end)
    
    configTab:AddButton("Refresh Config List", function()
        refreshConfigs()
    end)
    
    -- Load initial files list
    refreshConfigs()
    
    return configTab
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
modules["packages/spr"] = function()--!strict
---------------------------------------------------------------------
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

local function magnitudeSq(vec: {number})
	local out = 0
	for _, v in vec do
		out += v^2
	end
	return out
end

local function distanceSq(vec0: {number}, vec1: {number})
	local out = 0
	for i0, v0 in vec0 do
		out += (vec1[i0] - v0)^2
	end
	return out
end

type TypeMetadata<T> = {
	springType: (dampingRatio: number, frequency: number, pos: number, typedat: TypeMetadata<T>, rawTarget: T) -> LinearSpring<T>,
	toIntermediate: (T) -> {number},
	fromIntermediate: ({number}) -> T,
}

-- Spring for an array of linear values
local LinearSpring = {}

type LinearSpring<T> = typeof(setmetatable({} :: {
	d: number,
	f: number,
	g: {number},
	p: {number},
	v: {number},
	typedat: TypeMetadata<T>,
	rawTarget: T,
}, LinearSpring))

do
	LinearSpring.__index = LinearSpring

	function LinearSpring.new<T>(dampingRatio: number, frequency: number, pos: T, rawGoal: T, typedat)
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

	function LinearSpring.setGoal<T>(self, goal: T)
		self.rawGoal = goal
		self.g = self.typedat.toIntermediate(goal)
	end

	function LinearSpring.setDampingRatio<T>(self: LinearSpring<T>, dampingRatio: number)
		self.d = dampingRatio
	end

	function LinearSpring.setFrequency<T>(self: LinearSpring<T>, frequency: number)
		self.f = frequency
	end

	function LinearSpring.canSleep<T>(self)
		if magnitudeSq(self.v) > SLEEP_VELOCITY_SQ_LIMIT then
			return false
		end

		if distanceSq(self.p, self.g) > SLEEP_OFFSET_SQ_LIMIT then
			return false
		end

		return true
	end

	function LinearSpring.step<T>(self: LinearSpring<T>, dt: number)
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
			--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
			-- Rewrite in Horner form:
			--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

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

type RotationSpring = typeof(setmetatable({} :: {
	d: number,
	f: number,
	g: CFrame,
	p: CFrame,
	v: Vector3,
}, RotationSpring))

do
	RotationSpring.__index = RotationSpring

	local function angleBetween(c0: CFrame, c1: CFrame)
		local _, angle = (c1:ToObjectSpace(c0)):ToAxisAngle()
		return math.abs(angle)
	end

	local function matrixToAxis(m: CFrame)
		local axis, angle = m:ToAxisAngle()
		return axis*angle
	end

	local function axisToMatrix(v: Vector3)
		local mag = v.Magnitude
		if mag > AXIS_MATRIX_EPS then
			return CFrame.fromAxisAngle(v.Unit, mag)
		end
		return CFrame.identity
	end

	function RotationSpring.new(d: number, f: number, p: CFrame, g: CFrame)
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

	function RotationSpring.setGoal(self: RotationSpring, value: CFrame)
		self.g = value
	end

	function RotationSpring.setDampingRatio(self: RotationSpring, dampingRatio: number)
		self.d = dampingRatio
	end

	function RotationSpring.setFrequency(self: RotationSpring, frequency: number)
		self.f = frequency
	end

	function RotationSpring.canSleep(self: RotationSpring)
		local sleepP = angleBetween(self.p, self.g) < SLEEP_ROTATION_OFFSET
		local sleepV = self.v.Magnitude < SLEEP_ROTATION_VELOCITY
		return sleepP and sleepV
	end

	function RotationSpring.step(self: RotationSpring, dt: number): CFrame
		local d = self.d
		local f = self.f*2*pi
		local g = self.g
		local p0 = self.p
		local v0 = self.v

		local offset = matrixToAxis(p0*g:Inverse())
		local decay = exp(-d*f*dt)

		local pt: CFrame
		local vt: Vector3

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

	fromIntermediate = function(value: {number})
		return Vector3.new(value[1], value[2], value[3])
	end,
}

-- Encapsulates a CFrame - Separates translation from rotation
local CFrameSpring = {}
do
	CFrameSpring.__index = CFrameSpring

	function CFrameSpring.new(
		dampingRatio: number,
		frequency: number,
		valueCurrent: CFrame,
		valueGoal: CFrame,
		_: any
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

	function CFrameSpring:setGoal(value: CFrame)
		self.rawGoal = value
		self._position:setGoal(value.Position)
		self._rotation:setGoal(value.Rotation)
	end

	function CFrameSpring:setDampingRatio(value: number)
		self._position:setDampingRatio(value)
		self._rotation:setDampingRatio(value)
	end

	function CFrameSpring:setFrequency(value: number)
		self._position:setFrequency(value)
		self._rotation:setFrequency(value)
	end

	function CFrameSpring:canSleep()
		return self._position:canSleep() and self._rotation:canSleep()
	end

	function CFrameSpring:step(dt): CFrame
		local p: Vector3 = self._position:step(dt)
		local r: CFrame = self._rotation:step(dt)
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

	function rgbToLuv(value: Color3): {number}
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

	function luvToRgb(value: {number}): Color3
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

		fromIntermediate = function(value: {number})
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

		fromIntermediate = function(value: {number})
			return UDim2.new(value[1], round(value[2]), value[3], round(value[4]))
		end,
	},

	Vector2 = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.X, value.Y}
		end,

		fromIntermediate = function(value: {number})
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

		fromIntermediate = function(value: {})
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

type PropertyOverride = {
	[string]: {
		class: string,
		get: (any)->(),
		set: (any, any)->(),
	}
}

local PSEUDO_PROPERTIES: PropertyOverride = {
	Pivot = {
		class = "PVInstance",
		get = function(inst: PVInstance)
			return inst:GetPivot()
		end,
		set = function(inst: PVInstance, value: CFrame)
			inst:PivotTo(value)
		end
	},
	Scale = {
		class = "Model",
		get = function(inst: Model)
			return inst:GetScale()
		end,
		set = function(inst: Model, value: number)
			inst:ScaleTo(value)
		end
	}
}

-- Frame loop
local springStates: {[Instance]: {[string]: any}} = {} -- {[instance] = {[property] = spring}
local completedCallbacks: {[Instance]: {()->()}} = {}

RunService.Heartbeat:Connect(function(dt)
	for instance, state in springStates do
		for propName, spring in state do
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
					(instance :: any)[propName] = spring.rawGoal
				else
					(instance :: any)[propName] = spring:step(dt)
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

				for _, callback in callbackList do
					task.spawn(callback)
				end
			end
		end
	end
end)

-- API
local spr = {}
do
	local function assertType(argNum: number, fnName: string, expectedType: string, value: unknown)
		if not expectedType:find(typeof(value)) then
			error(`bad argument #{argNum} to {fnName} ({expectedType} expected, got {typeof(value)})`, 3)
		end
	end

	function spr.target(instance: Instance, dampingRatio: number, frequency: number, properties: {[string]: any})
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

		for propName, propTarget in properties do
			local propValue
			local override = PSEUDO_PROPERTIES[propName]
			if override and instance:IsA(override.class) then
				propValue = override.get(instance)
			else
				propValue = (instance :: any)[propName]
			end

			if STRICT_RUNTIME_TYPES and typeof(propTarget) ~= typeof(propValue) then
				error(`bad property {propName} to spr.target ({typeof(propValue)} expected, got {typeof(propTarget)})`, 2)
			end

			-- Special case infinite frequency for an instantaneous change
			if frequency == math.huge then
				(instance :: any)[propName] = propTarget
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

	function spr.stop(instance: Instance, property: string?)
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

	function spr.completed(instance: Instance, callback: ()->())
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

local Library = {}

-- Create a new library window instance
function Library:CreateWindow(title, configFolder)
    return Window.new(title, configFolder)
end

-- Save flag states to configuration file
function Library:SaveConfig(window, name)
    if not window then return false end
    return window:SaveConfig(name)
end

-- Load flag states from configuration file
function Library:LoadConfig(window, name)
    if not window then return false end
    return window:LoadConfig(name)
end

-- List all saved configs in the folder
function Library:GetConfigs(window)
    if not window then return {} end
    return window:GetConfigs()
end

-- Allows runtime customization of the theme parameters
function Library:SetTheme(themeTable)
    if type(themeTable) ~= "table" then return end
    
    for key, val in pairs(themeTable) do
        if Theme[key] ~= nil then
            Theme[key] = val
        end
    end
end

return Library
end

return require("init")
