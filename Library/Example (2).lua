-- Asterveil UI | Example
local Library = loadstring(readfile("AsterveilUI.lua"))() -- or loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:CreateWindow({
	Title = "Asterveil Hub",
	Tags = {{Text = "v1.0", Color = "Success"}}, -- extra tags beside the title (game + device tags are automatic)
	ToggleKey = Enum.KeyCode.RightShift,
})

-- TABS (Tag = small badge, Locked = locked tab)
local Main = Window:CreateTab({Title = "Main", Icon = "home", Tag = {Text = "NEW", Color = "Success"}})
local Premium = Window:CreateTab({Title = "Premium", Icon = "crown", Tag = "VIP", Locked = true, LockReason = "Premium members only"})

-- SECTION (with tag)
local Farm = Main:AddSection({Title = "Farming", Tag = {Text = "BETA", Color = "Warning"}})

Farm:AddToggle({Title = "Auto Farm", Description = "Farms automatically", Flag = "AutoFarm",
	Tag = {Text = "HOT", Color = "Error"},
	Callback = function(v) print("Auto Farm:", v) end})

Farm:AddSlider({Title = "Farm Speed", Min = 1, Max = 100, Default = 25, Suffix = "%", Flag = "FarmSpeed",
	Callback = function(v) print("Speed:", v) end})

Farm:AddDropdown({Title = "Target", Options = {"Nearest", "Boss", "Elite"}, Default = "Nearest", Flag = "Target"})
Farm:AddDropdown({Title = "Items", Options = {"Sword", "Bow", "Staff"}, Multi = true, Flag = "Items"})
Farm:AddColorPicker({Title = "ESP Color", Default = Color3.fromRGB(139, 92, 246), Flag = "ESP"})
Farm:AddKeybind({Title = "Toggle Farm", Default = Enum.KeyCode.F, Callback = function() print("F pressed") end})
Farm:AddTextbox({Title = "Webhook", Placeholder = "paste here...", Flag = "Webhook"})

-- LOCKED ELEMENT
Farm:AddButton({Title = "Teleport to Boss", Locked = true, LockReason = "Level 50 required",
	Callback = function() print("tp") end})

-- LOCK / UNLOCK AT RUNTIME
local vip = Farm:AddToggle({Title = "VIP Farm", Tag = {Text = "VIP", Color = "Accent3"}})
vip:Lock("Premium only")  -- vip:Unlock()

-- SUBTABS (lock a whole subtab)
local subs = Main:AddSubtabs({"General", "Visuals", "Misc"})
subs["General"]:AddLabel("General options live here.")
subs["Visuals"]:AddToggle({Title = "ESP"})
subs["Misc"]:AddParagraph({Title = "Misc", Content = "Coming soon."})
subs["Misc"]:Lock("Coming soon")

-- LOCK A WHOLE SECTION / TAB LATER
-- Farm:Lock("Under maintenance"); Farm:Unlock()
-- Premium:Unlock()

-- COLLAPSIBLE / ACCORDION
local acc = Main:AddCollapsible({Title = "Advanced", Group = "adv", Tag = "PRO"})
acc:AddToggle({Title = "Debug Mode"})

Premium:AddLabel("VIP content")

Library:Notify({Title = "Asterveil", Content = "Loaded successfully!", Type = "success"})
Window:LoadAutoConfig() -- call at the end so saved configs can apply
