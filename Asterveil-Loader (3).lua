--[[
	ASTERVEIL HUB  |  Loader + lahat ng API examples
	Library: Library/Source/Asterveil-UiLibrary.lua  (Space Universe: black & silver)
]]

local LIB_URL = "https://raw.githubusercontent.com/pickapicksmm/Asterveil-Hub/refs/heads/main/Library/Source/Asterveil-UiLibrary.lua"
local LOCAL_FILE = "Asterveil-UiLibrary.lua" -- kung nasa workspace folder ng executor, ito muna ang gagamitin

------------------------------------------------------------ load library
local function loadLibrary()
	if readfile and isfile and isfile(LOCAL_FILE) then
		local ok, lib = pcall(function() return loadstring(readfile(LOCAL_FILE))() end)
		if ok and lib then return lib end
	end
	local ok, lib = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
	if ok and lib then return lib end
	warn("[Asterveil Loader] Hindi na-load ang library: " .. tostring(lib))
end

local Library = loadLibrary()
if not Library then return end

------------------------------------------------------------ OPTIONAL: custom language (bago mag-CreateWindow)
-- Library:AddLanguage("Tagalog", {"Pangkalahatan", "Impormasyon", ...}, "tl")  -- dict ay ayon sa Library.LanguageKeys

------------------------------------------------------------ WINDOW
local Window = Library:CreateWindow({
	Title = "ASTERVEIL HUB",
	Icon = "sparkles",                    -- icon sa topbar
	-- Tag = "PC",                        -- custom device tag (kung wala, auto-detect: PC/Mac/Android/iOS/Tablet/Console)
	-- Game = "Pangalan ng Game",         -- custom game tag (default: auto)
	-- Size = Vector2.new(620, 400),
	-- OpenSize = 48,                     -- laki ng floating open button
	-- FloatImage = "rbxassetid://0",
	ToggleKey = Enum.KeyCode.RightShift,  -- show / hide
	-- General = false,                   -- itago ang built-in General tab (Info / Console / Configure / Settings)
	-- Version = "1.0.0",
})

-- Mga extra tag sa topbar
Window:AddTag({Text = "v1.0", Icon = "tag"})
-- Window:SetTag("Custom", Color3.fromRGB(30, 30, 36)); Window:SetGame("Game Name"); Window:SetTitle("Bagong Title")
-- Window:SetUserCard({Display = "Pangalan", Name = "username", Status = "Premium"})

------------------------------------------------------------ TAB 1: Basic controls
local Main = Window:AddTab({Title = "Main", Icon = "home"})

Main:AddSection("Basic Controls")

-- Button
Main:AddButton({
	Title = "Notify Me",
	ButtonText = "Click",
	Icon = "bell",
	Width = 88,
	Tooltip = "Magpapakita ng notification",
	Callback = function()
		Library:Notify({Title = "Hello", Content = "Gumagana ang button!", Type = "Success", Duration = 3})
	end,
})

-- Toggle
local tgl = Main:AddToggle({
	Title = "Auto Farm", Default = false, Flag = "AutoFarm", Tooltip = "Naka-save sa config",
	Callback = function(v) print("Auto Farm:", v) end,
})
-- tgl:Set(true); tgl:Get()

-- Checkbox
Main:AddCheckbox({Title = "Show ESP", Default = true, Flag = "ShowESP", Callback = function(v) print("ESP:", v) end})

-- Radio
Main:AddRadio({Title = "Mode", Options = {"Legit", "Rage", "Silent"}, Default = "Legit", Flag = "Mode", Callback = function(v) print("Mode:", v) end})

-- Slider
Main:AddSlider({
	Title = "Walk Speed", Min = 16, Max = 200, Step = 1, Default = 16, Suffix = " st/s", Flag = "WalkSpeed",
	Callback = function(v)
		local ch = game.Players.LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end,
})

-- Range slider (Default = {lo, hi})
Main:AddRangeSlider({Title = "Distance", Min = 0, Max = 500, Default = {50, 250}, Flag = "Distance", Callback = function(v) print("Range:", v[1] or v.Min, v[2] or v.Max) end})

-- Input / Textbox
Main:AddInput({Title = "Player Name", Placeholder = "Mag-type...", Default = "", Flag = "PlayerName", Callback = function(t) print("Name:", t) end})
Main:AddTextbox({Title = "Notes", Placeholder = "Multi-line text", Height = 70, Flag = "Notes", Callback = function(t) print("Notes:", t) end})

-- Keybind
Main:AddKeybind({Title = "Fly Key", Default = Enum.KeyCode.F, Flag = "FlyKey", OnPress = function() Library:Toast("Fly key pressed") end})

-- Dropdown / Multi dropdown
Main:AddDropdown({Title = "Target Part", Options = {"Head", "Torso", "HumanoidRootPart"}, Default = "Head", Search = true, Flag = "TargetPart", Callback = function(v) print("Target:", v) end})
Main:AddMultiDropdown({Title = "Teams", Options = {"Red", "Blue", "Green", "Yellow"}, Default = {"Red"}, Flag = "Teams", Callback = function(list) print("Teams:", table.concat(list, ", ")) end})

-- Color picker
Main:AddColorpicker({Title = "ESP Color", Default = Color3.fromRGB(220, 224, 232), Flag = "ESPColor", Callback = function(c) print("Color:", c) end})

-- Date / time picker
Main:AddDatePicker({Title = "Date", Callback = function(d) print("Date:", d) end})
Main:AddTimePicker({Title = "Time", Callback = function(t) print("Time:", t) end})

-- Search bar
Main:AddSearchbar({Placeholder = "Hanapin...", Callback = function(text) print("Search:", text) end})

------------------------------------------------------------ TAB 2: Display
local Display = Window:AddTab({Title = "Display", Icon = "layout-grid"})

Display:AddSection("Text")
Display:AddLabel({Title = "Simpleng label"})
Display:AddParagraph({Title = "Paragraph", Content = "Mahabang paliwanag na awtomatikong nagwa-wrap sa maraming linya."})
Display:AddDivider()
Display:AddCodeBlock({Code = "print('Hello, Asterveil!')", Language = "lua"})
Display:AddLink({Text = "Discord Community", Url = "https://discord.gg/Xd6Xay6VsW"})

Display:AddSection("Status / Feedback")
Display:AddProgressBar({Title = "Progress", Value = 40}) -- 0 hanggang 100
Display:AddLoadingBar({Title = "Loading..."})
Display:AddSpinner({Title = "Please wait", Size = 24})
Display:AddStatus({Title = "Server", State = "Online", Text = "Connected"}) -- Online / Idle / Busy / Offline
Display:AddBadge({Text = "NEW", Color = Color3.fromRGB(230, 232, 238)})
Display:AddTag({Tags = {{Text = "Beta", Icon = "flask-conical"}, {Text = "VIP", Icon = "crown"}}})
Display:AddAlert({Title = "Heads up", Content = "Ito ay alert box.", Type = "Info"}) -- Info / Success / Warning / Error

Display:AddSection("Media")
Display:AddIcon({Icon = "star", Size = 28})
Display:AddImage({Image = "rbxassetid://0", Height = 100})
Display:AddAvatar({UserId = game.Players.LocalPlayer.UserId, Size = 56, Square = false})
Display:AddProfile({Display = game.Players.LocalPlayer.DisplayName, Name = game.Players.LocalPlayer.Name, Status = "Online", UserId = game.Players.LocalPlayer.UserId})

Display:AddSection("Data")
local tbl = Display:AddTable({Columns = {"Name", "Level", "Role"}, Rows = {{"Pika", "99", "Owner"}, {"Aster", "50", "Admin"}}})
-- tbl:AddRow({"Veil", "10", "User"}); tbl:Clear()
Display:AddList({Title = "Servers", Height = 110, Items = {"Server 1", "Server 2", "Server 3"}, Callback = function(it) print("Picked:", it) end})
Display:AddInfo({Title = "Executor", Value = (identifyexecutor and identifyexecutor()) or "Unknown", Copy = true})
Display:AddDual({Left = {Title = "Kills", Value = "12"}, Right = {Title = "Deaths", Value = "3"}})
Display:AddGameCard({})
Display:AddCommunityCard({Title = "Discord Community", Link = "discord.gg/Xd6Xay6VsW", Icon = "discord", Color = Color3.fromRGB(88, 101, 242)})

------------------------------------------------------------ TAB 3: Navigation + Layout
local Layout = Window:AddTab({Title = "Layout", Icon = "layers"})

Layout:AddSection("Navigation")
Layout:AddBreadcrumb({Items = {"Home", "Settings", "Theme"}, Callback = function(item) print("Crumb:", item) end})
Layout:AddPagination({Total = 5, Current = 1, Callback = function(p) print("Page:", p) end})
local stepper = Layout:AddStepper({Steps = {"Start", "Config", "Run", "Done"}, Current = 1, Callback = function(s) print("Step:", s) end})
-- stepper:Next(); stepper:Prev(); stepper:Set(3)

Layout:AddSection("Containers")
local group = Layout:AddGroupbox({Title = "Groupbox", Icon = "box"})
group:AddToggle({Title = "Nasa loob ng groupbox", Flag = "GroupToggle"})

local card = Layout:AddCard({Title = "Card", Content = "Simpleng card na may text."})
local col = Layout:AddCollapsible({Title = "Advanced", Icon = "settings", Open = false})
col:AddSlider({Title = "Tick Rate", Min = 1, Max = 60, Default = 30, Flag = "Tick"})
col:AddToggle({Title = "Debug Mode", Flag = "Debug"})
-- col:Toggle(true); col:IsOpen()

local left, right = Layout:AddColumns(2) -- magkatabi (nagsta-stack sa maliit na screen)
left:AddGroupbox({Title = "Left"}):AddButton({Title = "Left Btn"})
right:AddGroupbox({Title = "Right"}):AddButton({Title = "Right Btn"})

local area = Layout:AddScrollArea({Title = "Scroll Area", Height = 100})
for i = 1, 8 do area:AddLabel({Title = "Item " .. i}) end

------------------------------------------------------------ TAB 4: Subtabs + Lock
local Sub = Window:AddTab({Title = "Subtabs", Icon = "folder"})
local general = Sub:AddSubTab({Title = "General", Icon = "home"})
local combat = Sub:AddSubTab({Title = "Combat", Icon = "swords"})
local premium = Sub:AddSubTab({Title = "Premium", Icon = "crown", Locked = true, LockText = "VIP", LockMessage = "Premium lang ito."})
general:AddSection("General Options")
general:AddToggle({Title = "Option sa General", Flag = "GenOpt"})
combat:AddSection("Combat Options")
combat:AddSlider({Title = "Aim FOV", Min = 10, Max = 360, Default = 90, Flag = "AimFOV"})
premium:AddLabel({Title = "Naka-lock"})
-- general:Select()

-- Lock kahit anong element / tab
local lockedBtn = Sub:AddButton({Title = "Locked Feature", ButtonText = "Run"})
lockedBtn:SetLocked(true, {Text = "Locked", Message = "Kailangan ng premium"})
-- lockedBtn:SetLocked(false); lockedBtn:IsLocked()
-- Main:SetLocked(true, {...}) ; Main:IsLocked()   (para sa buong tab)

------------------------------------------------------------ TAB 5: Popups & Library API
local Util = Window:AddTab({Title = "Popups", Icon = "message-square"})
Util:AddSection("Notifications")
for _, kind in ipairs({"Info", "Success", "Warning", "Error"}) do
	Util:AddButton({Title = "Notify: " .. kind, ButtonText = "Show", Callback = function()
		Library:Notify({Title = kind, Content = "Halimbawa ng " .. kind .. " notification", Type = kind, Duration = 4})
	end})
end
Util:AddButton({Title = "Toast", ButtonText = "Show", Callback = function() Library:Toast("Maliit na toast message", 2) end})

Util:AddSection("Dialog / Modal")
Util:AddButton({Title = "Dialog", ButtonText = "Open", Callback = function()
	Window:Dialog({
		Title = "Sigurado ka?", Content = "Ito ay halimbawa ng dialog.",
		Buttons = {
			{Text = "Cancel"},
			{Text = "Okay", Icon = "check", Callback = function() Library:Notify({Content = "Confirmed", Type = "Success"}) end},
		},
	})
end})
Util:AddButton({Title = "Custom Modal", ButtonText = "Open", Callback = function()
	local m = Window:Modal({Title = "Modal", Content = "Pwede kang maglagay ng elements dito.", Width = 280})
	m:AddToggle({Title = "Option sa modal"})
	m:AddButton({Title = "Isara", ButtonText = "Close", Callback = function() m:Close() end})
end})

Util:AddSection("Library API")
Util:AddButton({Title = "Accent: Silver", ButtonText = "Apply", Callback = function() Library:SetAccent(Color3.fromRGB(160, 166, 180)) end})
Util:AddButton({Title = "Accent: Ice Blue", ButtonText = "Apply", Callback = function() Library:SetAccent(Color3.fromRGB(150, 190, 255)) end})
Util:AddButton({Title = "Glass 40%", ButtonText = "Apply", Callback = function() Library:SetGlass(0.4) end})
Util:AddButton({Title = "Radius 8", ButtonText = "Apply", Callback = function() Library:SetRadius(8) end})
Util:AddButton({Title = "Language: Spanish", ButtonText = "Apply", Callback = function() Library:SetLanguage("Spanish") end})
Util:AddButton({Title = "Language: English", ButtonText = "Apply", Callback = function() Library:SetLanguage("English") end})
Util:AddButton({Title = "Save Config 'Default'", ButtonText = "Save", Callback = function() Library:SaveConfig("Default") end})
Util:AddButton({Title = "Load Config 'Default'", ButtonText = "Load", Callback = function() Library:LoadConfig("Default") end})
Util:AddButton({Title = "Hide UI", ButtonText = "Hide", Callback = function() Window:SetVisible(false) end})
Util:AddButton({Title = "Destroy UI", ButtonText = "Destroy", Callback = function() Window:Destroy() end})

------------------------------------------------------------ Console logging (General > Console)
Library:Log("Asterveil loaded sa " .. tostring(Window._tag and Window._tag.Text or "?"), "Info")  -- Info / Warning / Error

------------------------------------------------------------ Flags
-- Library.Flags.AutoFarm  --> kasalukuyang value (boolean / number / string...)
task.spawn(function()
	while task.wait(1) do
		if not Window._gui or not Window._gui.Parent then break end
		if Library.Flags.AutoFarm then
			-- gawin dito ang auto farm
		end
	end
end)

Library:Notify({Title = "Asterveil", Content = "Loaded! Pindutin ang RightShift para i-toggle.", Type = "Success", Duration = 5})
