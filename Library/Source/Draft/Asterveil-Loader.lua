--[[
    ASTERVEIL HUB  -  Loader / API Showcase
    Loads the UI library and builds one window that demonstrates EVERY API:
      Tabs + SubTabs, every element component, containers, window APIs, locks, notifications,
      dialogs, config flags and the translation system (built-in languages, Auto Translate,
      Library:T / Translate / Prefetch / AddLanguage / SetText and tabs added at runtime).

    Usage:   loadstring(game:HttpGet("RAW_LINK_OF_THIS_FILE"))()
    Change LIBRARY_URL below if your library file lives somewhere else.
    You can also run the library from disk:  getgenv().AsterveilLibraryPath = "PickasHub/Asterveil.lua"
]]

---------------------------------------------------------------- load the library
local LIBRARY_URL = "https://raw.githubusercontent.com/pickapicksmm/Asterveil-Hub/refs/heads/main/Library/Asterveil.lua"

local function loadLibrary()
    local env = (getgenv and getgenv()) or _G
    if env.AsterveilLibraryPath and isfile and readfile and isfile(env.AsterveilLibraryPath) then
        local fn, err = loadstring(readfile(env.AsterveilLibraryPath))
        if fn then return fn() end
        warn("[Loader] local library failed to compile: " .. tostring(err))
    end
    local src = game:HttpGet(LIBRARY_URL)
    local fn, err = loadstring(src)
    if not fn then error("[Loader] library failed to compile: " .. tostring(err)) end
    return fn()
end

local okLib, Library = pcall(loadLibrary)
if not okLib or type(Library) ~= "table" then
    warn("[Loader] Could not load Asterveil library: " .. tostring(Library))
    return
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

---------------------------------------------------------------- translation: custom language (BEFORE CreateWindow)
-- New name -> new option in "Select Language". Keys are the English texts. Missing keys are filled by Auto Translate ("de" = Google code).
Library:AddLanguage("German", {
    ["Save"] = "Speichern", ["Load"] = "Laden", ["Delete"] = "Löschen", ["Settings"] = "Einstellungen",
    ["Language"] = "Sprache", ["Select Language"] = "Sprache wählen", ["Theme Color"] = "Designfarbe",
    ["Hello World"] = "Hallo Welt", ["Buttons"] = "Schaltflächen",
}, "de")

---------------------------------------------------------------- window
local Window = Library:CreateWindow({
    Title = "ASTERVEIL HUB",
    Icon = "sparkles",
    OpenSize = 48,                       -- floating open button size (30-90)
    ToggleKey = Enum.KeyCode.RightShift, -- show / hide the window
})
Window:SetTag("Desktop")                 -- chip next to the title (Android / iOS / Mac / Desktop / Neo get an icon)
Window:SetGame("API Showcase")
Window:AddTag({ Text = "v" .. tostring(Library.Version), Icon = "tag" })

local function note(title, content, kind)
    Library:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = 3 })
end

---------------------------------------------------------------- 1) BASIC  (tab with sub tabs)
local Basic = Window:AddTab({ Title = "Basic", Icon = "mouse-pointer-click" })

local tBtn = Basic:AddSubTab({ Title = "Buttons & Text", Icon = "type" })
tBtn:AddSection({ Title = "Buttons" })
tBtn:AddButton({ Title = "Click Me", ButtonText = "Click", Icon = "zap", Tooltip = "A normal button", Callback = function() note("Button", "You pressed the button.", "Success") end })
tBtn:AddButton({ Title = "Copy Hello", ButtonText = "Copy", Icon = "copy", Callback = function() if setclipboard then setclipboard("Hello World") end Library:Toast("Copied") end })
tBtn:AddSection({ Title = "Text" })
local lbl = tBtn:AddLabel({ Title = "This is a label" })
tBtn:AddButton({ Title = "Change Label", ButtonText = "Change", Callback = function()
    lbl:Set("Label changed at " .. os.date("%H:%M:%S"))   -- :Set keeps the text translated
end })
tBtn:AddParagraph({ Title = "Paragraph", Content = "Paragraphs have a title and a longer body text. Both are translated automatically when you change the language." })
tBtn:AddDivider()
tBtn:AddLabel({ Title = "Everything above the divider and below it is translated too." })

local tTog = Basic:AddSubTab({ Title = "Toggles", Icon = "toggle-left" })
tTog:AddSection({ Title = "Switches" })
tTog:AddToggle({ Title = "Auto Farm", Flag = "AutoFarm", Default = false, Tooltip = "Saved in configs through its Flag", Callback = function(v) Library:Log("Auto Farm = " .. tostring(v), "Info") end })
tTog:AddCheckbox({ Title = "Enable ESP", Flag = "ESP", Default = true, Callback = function(v) Library:Log("ESP = " .. tostring(v), "Info") end })
tTog:AddRadio({ Title = "Farm Mode", Flag = "FarmMode", Options = { "Nearest", "Strongest", "Weakest" }, Default = "Nearest", Callback = function(v) Library:Log("Mode: " .. tostring(v)) end })
tTog:AddSection({ Title = "Controlling from code" })
local masterToggle = tTog:AddToggle({ Title = "Master Switch", Default = false })
tTog:AddButton({ Title = "Turn Master Switch On", ButtonText = "Set On", Callback = function() masterToggle:Set(true) end })
tTog:AddButton({ Title = "Read Master Switch", ButtonText = "Get", Callback = function() note("Master Switch", tostring(masterToggle:Get())) end })

local tInp = Basic:AddSubTab({ Title = "Inputs", Icon = "keyboard" })
tInp:AddSection({ Title = "Text input" })
tInp:AddInput({ Title = "Player Name", Placeholder = "Type a name...", Flag = "PlayerName", Callback = function(v) Library:Log("Name: " .. v) end })
tInp:AddTextbox({ Title = "Notes", Placeholder = "Write something long...", Height = 100, Flag = "Notes" })
tInp:AddSection({ Title = "Keybind" })
tInp:AddKeybind({ Title = "Toggle Fly", Default = Enum.KeyCode.F, Flag = "FlyKey", OnPress = function() note("Keybind", "Fly key pressed") end })
tInp:AddSection({ Title = "Search" })
tInp:AddSearchbar({ Title = "Filter rows", Placeholder = "Search these rows...", Callback = function(q) end })
tInp:AddLabel({ Title = "Apple" }) tInp:AddLabel({ Title = "Banana" }) tInp:AddLabel({ Title = "Cherry" }) tInp:AddLabel({ Title = "Dragonfruit" })

---------------------------------------------------------------- 2) VALUES
local Values = Window:AddTab({ Title = "Values", Icon = "sliders-horizontal" })

local vNum = Values:AddSubTab({ Title = "Numbers", Icon = "gauge" })
vNum:AddSlider({ Title = "Walk Speed", Min = 16, Max = 200, Step = 1, Default = 16, Suffix = " sps", Flag = "WalkSpeed", Callback = function(v)
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end
end })
vNum:AddSlider({ Title = "Opacity", Min = 0, Max = 1, Step = .05, Default = .5, Flag = "Opacity" })
vNum:AddRangeSlider({ Title = "Level Range", Min = 1, Max = 100, Default = { 20, 60 }, Flag = "LevelRange", Callback = function(r) Library:Log("Range " .. r[1] .. " - " .. r[2]) end })

local vPick = Values:AddSubTab({ Title = "Pickers", Icon = "palette" })
vPick:AddSection({ Title = "Dropdowns" })
vPick:AddDropdown({ Title = "Weapon", Options = { "Sword", "Bow", "Staff" }, Default = "Sword", Flag = "Weapon", Callback = function(v) Library:Log("Weapon: " .. tostring(v)) end })
vPick:AddDropdown({ Title = "Big List (searchable)", Options = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel" }, Search = true })
vPick:AddMultiDropdown({ Title = "Targets", Options = { "Players", "NPCs", "Bosses", "Chests" }, Default = { "NPCs" }, Flag = "Targets", Callback = function(t) Library:Log("Targets: " .. table.concat(t, ", ")) end })
local dynDD = vPick:AddDropdown({ Title = "Dynamic Options", Options = { "One", "Two" }, Default = "One" })
vPick:AddButton({ Title = "Replace dynamic options", ButtonText = "Update", Callback = function() dynDD:SetOptions({ "Gold", "Silver", "Bronze" }) dynDD:Set("Gold") end })
vPick:AddSection({ Title = "Colors" })
vPick:AddColorpicker({ Title = "ESP Color", Default = Color3.fromRGB(255, 80, 120), Flag = "ESPColor", Callback = function(c) end })

local vTime = Values:AddSubTab({ Title = "Date & Time", Icon = "calendar" })
vTime:AddDatePicker({ Title = "Event Date", Flag = "EventDate", Callback = function(d) Library:Log("Date " .. d) end })
vTime:AddTimePicker({ Title = "Event Time", Callback = function(t) Library:Log("Time " .. t) end })

---------------------------------------------------------------- 3) DISPLAY
local Display = Window:AddTab({ Title = "Display", Icon = "layout-dashboard" })

local dProg = Display:AddSubTab({ Title = "Progress", Icon = "loader" })
local pb = dProg:AddProgressBar({ Title = "Download", Value = 30 })
dProg:AddButton({ Title = "Advance progress", ButtonText = "+10%", Callback = function() pb._v = math.min(100, (pb._v or 30) + 10) pb:Set(pb._v) end })
dProg:AddLoadingBar({ Title = "Loading" })
dProg:AddSpinner({ Size = 32 })
local st = dProg:AddStatus({ Title = "Server", Text = "Online", State = "Online" })
dProg:AddButton({ Title = "Cycle status", ButtonText = "Next", Callback = function()
    local order = { { "Online", "Online" }, { "Idle", "Idle" }, { "Busy", "Busy" }, { "Offline", "Offline" } }
    local c = ((st._i or 0) % #order) + 1 st._i = c
    st:SetState(order[c][1]) st:Set(order[c][2])
end })

local dBadge = Display:AddSubTab({ Title = "Badges & Alerts", Icon = "badge-check" })
dBadge:AddBadge({ Text = "NEW" })
dBadge:AddBadge({ Text = "Premium", Color = Color3.fromRGB(255, 190, 60) })
dBadge:AddTag({ Tags = { { Text = "Fast", Icon = "zap" }, { Text = "Safe", Icon = "shield" }, { Text = "Free", Icon = "gift", Color = Color3.fromRGB(90, 220, 140) } } })
dBadge:AddAlert({ Type = "Info", Title = "Information", Content = "Alerts can be Info, Success, Warning or Error." })
dBadge:AddAlert({ Type = "Success", Title = "Success", Content = "Everything worked as expected." })
dBadge:AddAlert({ Type = "Warning", Title = "Warning", Content = "Be careful with this feature." })
dBadge:AddAlert({ Type = "Error", Title = "Error", Content = "Something went wrong." })

local dMedia = Display:AddSubTab({ Title = "Media", Icon = "image" })
dMedia:AddImage({ Image = "rbxthumb://type=AvatarBust&id=" .. LP.UserId .. "&w=150&h=150", Height = 120 })
dMedia:AddIcon({ Icon = "sparkles", Size = 28 })
dMedia:AddAvatar({ Size = 56 })
dMedia:AddProfile({ Status = "Using Asterveil Hub" })
dMedia:AddLink({ Text = "Open documentation (copies link)", Url = "https://github.com/pickapicksmm/Asterveil-Hub" })

local dData = Display:AddSubTab({ Title = "Data", Icon = "table" })
dData:AddCodeBlock({ Language = "lua", Code = 'local Library = loadstring(game:HttpGet("RAW_LINK"))()\nlocal Window = Library:CreateWindow({ Title = "My Hub" })' })
local tbl = dData:AddTable({ Columns = { "Item", "Price", "Stock" }, Rows = { { "Sword", "$10", "5" }, { "Bow", "$25", "2" } } })
dData:AddButton({ Title = "Add a table row", ButtonText = "Add", Callback = function() tbl:AddRow({ "Item " .. math.random(100), "$" .. math.random(5, 90), tostring(math.random(1, 9)) }) end })
dData:AddList({ Title = "Servers", Items = { "Server 1", "Server 2", "Server 3", "Server 4" }, Height = 110, Callback = function(v) Library:Log("Picked " .. tostring(v)) end })
dData:AddInfo({ Title = "User Id", Value = LP.UserId, Copy = true })
dData:AddDual({ Left = { Title = "Kills", Value = "12" }, Right = { Title = "Deaths", Value = "3" } })
dData:AddGameCard({})
dData:AddCommunityCard({ Title = "Discord Community", Link = "discord.gg/R3rDNwrV7y", Icon = "discord", Color = Color3.fromRGB(88, 101, 242) })

local dCon = Display:AddSubTab({ Title = "Console", Icon = "terminal" })
local con = dCon:AddConsole({ Height = 200, Toolbar = true, MaxLines = 200 })
for _, k in ipairs({ "Info", "Success", "Warning", "Error" }) do
    dCon:AddButton({ Title = "Log " .. k, ButtonText = "Log", Callback = function() con:Log("This is a " .. k .. " message", k) end })
end

---------------------------------------------------------------- 4) NAVIGATION + LAYOUT
local Layout = Window:AddTab({ Title = "Layout", Icon = "layout-grid" })

local lNav = Layout:AddSubTab({ Title = "Navigation", Icon = "compass" })
lNav:AddBreadcrumb({ Items = { "Home", "Farm", "Settings" }, Callback = function(i, n) Library:Log("Crumb " .. i .. ": " .. n) end })
lNav:AddPagination({ Total = 5, Current = 1, Callback = function(p) Library:Log("Page " .. p) end })
local stepper = lNav:AddStepper({ Steps = { "Account", "Options", "Finish" }, Current = 1 })
lNav:AddButton({ Title = "Previous step", ButtonText = "Prev", Callback = function() stepper:Prev() end })
lNav:AddButton({ Title = "Next step", ButtonText = "Next", Callback = function() stepper:Next() end })

local lBox = Layout:AddSubTab({ Title = "Containers", Icon = "box" })
local left, right = lBox:AddColumns(2)
local g1 = left:AddGroupbox({ Title = "Farm", Icon = "sprout" })
g1:AddToggle({ Title = "Auto Farm" }) g1:AddSlider({ Title = "Range", Min = 1, Max = 50, Default = 10 })
local g2 = right:AddGroupbox({ Title = "Combat", Icon = "swords" })
g2:AddToggle({ Title = "Kill Aura" }) g2:AddDropdown({ Title = "Target", Options = { "Nearest", "Lowest HP" }, Default = "Nearest" })
lBox:AddCard({ Title = "Card", Icon = "info", Content = "Cards show a title with a short text." })
local coll = lBox:AddCollapsible({ Title = "Collapsible", Icon = "chevrons-down-up", Open = false })
coll:AddLabel({ Title = "Hidden until you open it" }) coll:AddButton({ Title = "Inside the collapsible", ButtonText = "OK", Callback = function() note("Collapsible", "Clicked inside") end })
local scroll = lBox:AddScrollArea({ Title = "Scroll Area", Height = 120 })
for i = 1, 8 do scroll:AddLabel({ Title = "Scrollable row " .. i }) end
lBox:AddButton({ Title = "Toggle collapsible from code", ButtonText = "Toggle", Callback = function() coll:Toggle() end })

---------------------------------------------------------------- 5) WINDOW & NOTIFICATIONS
local Win = Window:AddTab({ Title = "Window", Icon = "app-window" })

local wNote = Win:AddSubTab({ Title = "Notifications", Icon = "bell" })
for _, k in ipairs({ "Info", "Success", "Warning", "Error" }) do
    wNote:AddButton({ Title = k .. " notification", ButtonText = "Show", Callback = function() Library:Notify({ Title = k, Content = "This is a " .. k .. " notification.", Type = k, Duration = 4 }) end })
end
wNote:AddButton({ Title = "Toast", ButtonText = "Show", Callback = function() Library:Toast("This is a toast message", 2.5) end })
wNote:AddButton({ Title = "Dialog (2 buttons)", ButtonText = "Open", Callback = function()
    Window:Dialog({ Title = "Are you sure?", Content = "Dialogs have a title, a message and buttons.", Buttons = {
        { Text = "Yes", Icon = "check", Callback = function() note("Dialog", "You pressed Yes", "Success") end },
        { Text = "No", Callback = function() note("Dialog", "You pressed No", "Warning") end } } })
end })
wNote:AddButton({ Title = "Modal with elements", ButtonText = "Open", Callback = function()
    local m = Window:Modal({ Title = "Modal", Content = "A modal can hold any element." })
    m:AddToggle({ Title = "Remember me" }) m:AddButton({ Title = "Close the modal", ButtonText = "Close", Callback = function() m:Close() end })
end })

local wWin = Win:AddSubTab({ Title = "Window Control", Icon = "sliders" })
wWin:AddButton({ Title = "Collapse / expand sidebar", ButtonText = "Toggle", Callback = function() Window:ToggleSidebar() end })
wWin:AddButton({ Title = "Open the Info panel", ButtonText = "Info", Callback = function() Window:ShowInfo() end })
wWin:AddButton({ Title = "Hide window (RightShift shows it)", ButtonText = "Hide", Callback = function() Window:SetVisible(false) end })
wWin:AddButton({ Title = "Change tag", ButtonText = "Set", Callback = function() Window:SetTag("Neo", Color3.fromRGB(124, 108, 255)) end })
wWin:AddButton({ Title = "Change game text", ButtonText = "Set", Callback = function() Window:SetGame("Game " .. math.random(100)) end })
wWin:AddButton({ Title = "Update user card status", ButtonText = "Set", Callback = function() Window:SetUserCard({ Status = "Status " .. os.date("%H:%M") }) end })
wWin:AddSlider({ Title = "Floating button size", Min = 30, Max = 90, Default = 48, Callback = function(v) Window:SetOpenSize(v) end })
wWin:AddSlider({ Title = "Window glass", Min = 0, Max = .8, Step = .05, Default = .2, Callback = function(v) Library:SetGlass(v) end })
wWin:AddSlider({ Title = "Corner radius", Min = 4, Max = 24, Default = 16, Callback = function(v) Library:SetRadius(v) end })
wWin:AddColorpicker({ Title = "Accent color", Default = Library.Theme.Accent, Callback = function(c) Library:SetAccent(c) end })

local wCfg = Win:AddSubTab({ Title = "Flags & Config", Icon = "save" })
wCfg:AddParagraph({ Title = "Flags", Content = "Every element with a Flag is stored in Library.Flags and saved by the Configure panel (Info > Configure)." })
wCfg:AddButton({ Title = "Print all flags to the console", ButtonText = "Print", Callback = function()
    for k, v in pairs(Library.Flags) do Library:Log(tostring(k) .. " = " .. tostring(v)) end
end })
wCfg:AddButton({ Title = "Save config 'showcase'", ButtonText = "Save", Callback = function() note("Config", Library:SaveConfig("showcase") and "Saved" or "Save failed", "Info") end })
wCfg:AddButton({ Title = "Load config 'showcase'", ButtonText = "Load", Callback = function() note("Config", Library:LoadConfig("showcase") and "Loaded" or "Load failed", "Info") end })

local wLock = Win:AddSubTab({ Title = "Locks & Tooltips", Icon = "lock" })
wLock:AddToggle({ Title = "VIP Feature", Locked = true, LockText = "VIP", LockMessage = "Buy VIP to unlock this feature", LockTitle = "VIP only" })
local unlockMe = wLock:AddToggle({ Title = "Locked from code", Locked = true, LockText = "Locked", LockMessage = "Press the button below to unlock" })
wLock:AddButton({ Title = "Unlock the toggle above", ButtonText = "Unlock", Callback = function() unlockMe:SetLocked(false) end })
wLock:AddButton({ Title = "Hover me for a tooltip", ButtonText = "Hover", Tooltip = "Tooltips are translated as well" })

---------------------------------------------------------------- 6) LOCKED TAB
local vip = Window:AddTab({ Title = "VIP", Icon = "crown", Locked = true, LockText = "VIP", LockMessage = "Buy VIP to unlock this tab" })
local vs = vip:AddSubTab({ Title = "Perks", Icon = "gem" })
vs:AddLabel({ Title = "Only VIP users can see this." })

---------------------------------------------------------------- 7) TRANSLATION
local Tr = Window:AddTab({ Title = "Translation", Icon = "languages" })

-- 7.1 language + auto translate
local trLang = Tr:AddSubTab({ Title = "Language", Icon = "globe" })
trLang:AddSection({ Title = "Select language" })
trLang:AddDropdown({ Title = "Select Language", Options = Library.Languages, Default = Library.Lang, Search = true, Callback = function(v)
    if v ~= Library.Lang then Library:SetLanguage(v) end
end })
trLang:AddToggle({ Title = "Auto Translate", Default = Library.AutoTranslate, Callback = function(v)
    Library.AutoTranslate = v
    if v then Library:SetLanguage(Library.Lang, true) end
end })
trLang:AddSlider({ Title = "Seconds between requests", Min = .1, Max = 2, Step = .05, Default = Library.TranslateDelay or .25, Callback = function(v) Library.TranslateDelay = v end })
trLang:AddParagraph({ Title = "How it works", Content = "Built-in words are translated instantly. Every other text (tabs, buttons, labels, tooltips, notifications) is translated online once, cached in a file and kept translated, including tabs and elements added after you changed the language." })
local qInfo = trLang:AddInfo({ Title = "Queue", Value = "0" })
local cInfo = trLang:AddInfo({ Title = "Cached texts", Value = "0" })
task.spawn(function()
    while qInfo.Frame.Parent do
        local n = 0
        for _, m in pairs(Library._cache or {}) do for _ in pairs(m) do n = n + 1 end end
        qInfo:Set(#(Library._q or {})) cInfo:Set(n)
        task.wait(1)
    end
end)

-- 7.2 live translator
local trTool = Tr:AddSubTab({ Title = "Translator", Icon = "message-square" })
local srcText = trTool:AddInput({ Title = "Text", Placeholder = "Type English text...", Default = "Hello, welcome to Asterveil Hub!" })
local targetLang = "Japanese"
trTool:AddDropdown({ Title = "Translate to", Options = Library.Languages, Default = targetLang, Search = true, Callback = function(v) targetLang = v end })
local outBox = trTool:AddCodeBlock({ Language = "result", Code = "(result appears here)" })
trTool:AddButton({ Title = "Library:Translate(text, language, callback)", ButtonText = "Translate", Icon = "languages", Callback = function()
    outBox:Set("Translating...")
    local direct = Library:Translate(srcText:Get(), targetLang, function(res) outBox:Set(res) end)
    if direct then outBox:Set(direct) end   -- built-in / cached words return instantly
end })
trTool:AddButton({ Title = "Library:T('Save') in current language", ButtonText = "Run", Callback = function() note("Library:T", "Save -> " .. Library:T("Save")) end })
trTool:AddButton({ Title = "Library:Prefetch(words, languages)", ButtonText = "Prefetch", Callback = function()
    Library:Prefetch({ "Auto Farm", "Kill Aura", "Speed" }, { "Japanese", "Spanish", "German" })
    Library:Toast("Prefetching in the background...", 2.5, true)
end })

-- 7.3 SetText + add things at runtime
local trDyn = Tr:AddSubTab({ Title = "Dynamic Content", Icon = "plus-circle" })
trDyn:AddParagraph({ Title = "Added later = translated too", Content = "Use these buttons after choosing a language. New tabs, sub tabs and elements are put in the translation queue the moment they are created." })
local counter = 0
local dynLabel = trDyn:AddLabel({ Title = "Dynamic label 0" })
trDyn:AddButton({ Title = "Library:SetText / label:Set", ButtonText = "Update", Callback = function()
    counter = counter + 1
    dynLabel:Set("Dynamic label " .. counter)
end })
local added = 0
trDyn:AddButton({ Title = "Add a new element", ButtonText = "Add", Icon = "plus", Callback = function()
    added = added + 1
    trDyn:AddToggle({ Title = "New toggle number " .. added, Tooltip = "Created at runtime" })
end })
local tabCount = 0
trDyn:AddButton({ Title = "Add a new tab", ButtonText = "Add Tab", Icon = "plus", Callback = function()
    tabCount = tabCount + 1
    local t = Window:AddTab({ Title = "New Tab " .. tabCount, Icon = "sparkles" })
    local s1 = t:AddSubTab({ Title = "First Sub Tab", Icon = "star" })
    s1:AddSection({ Title = "Fresh section" })
    s1:AddButton({ Title = "Fresh button", ButtonText = "Press", Callback = function() note("New tab", "Hello from the new tab", "Success") end })
    s1:AddParagraph({ Title = "Fresh paragraph", Content = "This tab did not exist when the language was chosen." })
    local s2 = t:AddSubTab({ Title = "Second Sub Tab", Icon = "heart" })
    s2:AddToggle({ Title = "Fresh toggle" })
    s2:AddDropdown({ Title = "Fresh dropdown", Options = { "First option", "Second option" }, Default = "First option" })
    Library:Notify({ Title = "Tab added", Content = "A new tab was created and is being translated.", Type = "Success" })
end })

-- 7.4 custom languages
local trCustom = Tr:AddSubTab({ Title = "Custom Language", Icon = "book-open" })
trCustom:AddCodeBlock({ Language = "lua", Code = 'Library:AddLanguage("German", {\n    ["Save"] = "Speichern",\n}, "de") -- call BEFORE CreateWindow\n-- 3rd argument = Google language code, so Auto Translate fills the rest' })
trCustom:AddButton({ Title = "Switch to German (added with AddLanguage)", ButtonText = "German", Callback = function() Library:SetLanguage("German") end })
trCustom:AddButton({ Title = "Switch back to English", ButtonText = "English", Callback = function() Library:SetLanguage("English") end })
trCustom:AddLabel({ Title = "Hello World" })

---------------------------------------------------------------- done
Library:Log("Asterveil API showcase loaded.", "Success")
Library:Notify({ Title = "Showcase loaded", Content = "Every API is demonstrated in the tabs. Try Translation > Language.", Type = "Success", Duration = 5 })
pcall(function() ((getgenv and getgenv()) or _G).AsterveilWindow = Window end)
return Window
