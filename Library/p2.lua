------------------------------------------------------------------ element mixin
local Mixin = {}
Mixin.__index = Mixin

local function NewMixin(holder, tab, window)
	return setmetatable({Holder = holder, Tab = tab, Window = window, _n = 0}, Mixin)
end

local CbKeys = {"Callback", "OnClick", "OnToggle", "OnChange", "OnSelect", "OnInput", "OnKeybind", "OnColorChange", "OnValueChanged", "OnDropdownChanged", "OnSliderChanged"}
local function GetCb(opt)
	for _, k in ipairs(CbKeys) do
		if opt[k] then return opt[k] end
	end
end

local function SmallBtn(parent, icon, glyph, w, h)
	local b = New("TextButton", {Size = UDim2.fromOffset(w or 28, h or 28), BackgroundTransparency = 0.4, Text = "", AutoButtonColor = false, ClipsDescendants = true, Parent = parent})
	Themed(b, {BackgroundColor3 = "Element"})
	Corner(b, 6)
	local ic = Icon(b, icon, 14, "SubText", glyph)
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.fromScale(0.5, 0.5)
	Connect(b.MouseEnter, function() Tween(b, {BackgroundTransparency = 0.1}, 0.12); Tween(ic, {ImageColor3 = Library.Theme.Text}, 0.12) end)
	Connect(b.MouseLeave, function() Tween(b, {BackgroundTransparency = 0.4}, 0.12); Tween(ic, {ImageColor3 = Library.Theme.SubText}, 0.12) end)
	Connect(b.MouseButton1Click, function() Ripple(b) end)
	return b, ic
end

local function Pad(R, right)
	R.Title.Size = UDim2.new(1, -(12 + right), R.Title.Size.Y.Scale, R.Title.Size.Y.Offset)
	if R.Desc then R.Desc.Size = UDim2.new(1, -(12 + right), R.Desc.Size.Y.Scale, R.Desc.Size.Y.Offset) end
end

local function LockScroll(self, v)
	local sc = self.Tab and self.Tab.Scroll
	if sc then sc.ScrollingEnabled = not v end
end

function Mixin:_Frame(h, auto)
	self._n = self._n + 1
	local f = New("Frame", {Size = UDim2.new(1, 0, 0, h or 40), BackgroundTransparency = 0.3, BorderSizePixel = 0, LayoutOrder = self._n, Parent = self.Holder})
	if auto then f.AutomaticSize = Enum.AutomaticSize.Y end
	Themed(f, {BackgroundColor3 = "Element"})
	Corner(f, 8)
	Stroke(f, "Stroke", 1, 0.6)
	return f
end

function Mixin:_Row(opt, h, hh)
	self._n = self._n + 1
	local row = New("Frame", {Name = "Element", Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 0.3, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = self._n, Parent = self.Holder})
	Themed(row, {BackgroundColor3 = "Element"})
	Corner(row, 8)
	local stroke = Stroke(row, "Stroke", 1, 0.6)
	local scale = New("UIScale", {Parent = row})
	local hasDesc = opt.Description and opt.Description ~= ""
	local title, tb = L(row, opt.Title or opt.Name or "", 13, "Text", true, opt.Translate)
	New("UITextSizeConstraint", {MaxTextSize = 16, MinTextSize = 9, Parent = title})
	local desc, db
	if hasDesc then
		title.Position = UDim2.fromOffset(12, 8); title.Size = UDim2.new(1, -24, 0, 16)
		desc, db = L(row, opt.Description, 11, "SubText", false, opt.Translate)
		desc.Position = UDim2.fromOffset(12, 26); desc.Size = UDim2.new(1, -24, 0, 14)
	else
		title.Position = UDim2.fromOffset(12, 0); title.Size = UDim2.new(1, -24, 0, hh or h)
	end
	Connect(row.MouseEnter, function()
		Tween(row, {BackgroundColor3 = Library.Theme.ElementHover}, 0.15)
		Tween(stroke, {Color = Library.Theme.Accent, Transparency = 0.35}, 0.15)
		if opt.Tooltip then Library:ShowTooltip(opt.Tooltip) end
		Fire(opt.OnHover)
	end)
	Connect(row.MouseLeave, function()
		Tween(row, {BackgroundColor3 = Library.Theme.Element}, 0.2)
		Tween(stroke, {Color = Library.Theme.Stroke, Transparency = 0.6}, 0.2)
		if opt.Tooltip then Library:HideTooltip() end
	end)
	if opt.ContextMenu then
		Connect(row.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton2 then
				Library:ContextMenu(opt.ContextMenu)
			elseif i.UserInputType == Enum.UserInputType.Touch then
				local held = true
				local c
				c = i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then held = false; c:Disconnect() end
				end)
				task.delay(0.6, function() if held then Library:ContextMenu(opt.ContextMenu) end end)
			end
		end)
	end
	if self.Tab and self.Tab.Searchables then
		table.insert(self.Tab.Searchables, {Row = row, Title = title, Text = (opt.Title or "") .. " " .. (opt.Description or "")})
	end
	return {Row = row, Title = title, Desc = desc, TitleBind = tb, DescBind = db, Stroke = stroke, Scale = scale}
end

function Mixin:_Obj(R, opt, o)
	o = o or {}
	local row = R.Row
	o.Row = row
	o.Options = opt
	o.Enabled = true
	local blocker = New("Frame", {Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Active = true, ZIndex = 20, Parent = row})
	Corner(blocker, 8)
	function o:SetVisible(v) row:SetAttribute("Hidden", not v); row.Visible = v end
	function o:SetEnabled(v) blocker.Visible = not v; self.Enabled = v end
	function o:Enable() self:SetEnabled(true) end
	function o:Disable() self:SetEnabled(false) end
	function o:Destroy() row:Destroy() end
	function o:Remove() row:Destroy() end
	function o:Update() end
	function o:SetTitle(t) if R.TitleBind then R.TitleBind:Set(t) end end
	function o:SetDescription(t) if R.DescBind then R.DescBind:Set(t) end end
	if opt.Visible == false then o:SetVisible(false) end
	if opt.Enabled == false or opt.Disabled == true then o:SetEnabled(false) end
	return o
end

function Mixin:_Flag(opt, o, default)
	o.Default = default
	if opt.NoSave then o.NoSave = true end
	if opt.Flag then
		Library.Flags[opt.Flag] = o
		o.Flag = opt.Flag
	end
	return o
end

------------------------------------------------ button / toggle / checkbox
function Mixin:AddButton(opt)
	if type(opt) == "string" then opt = {Title = opt} end
	local R = self:_Row(opt, opt.Description and 52 or 40)
	local row = R.Row
	Pad(R, 44)
	local ic = Icon(row, opt.Icon or "mouse-pointer-click", 16, "Accent2", "›")
	ic.AnchorPoint = Vector2.new(1, 0.5)
	ic.Position = UDim2.new(1, -14, 0.5, 0)
	local hit = Hit(row)
	Press(hit, R.Scale)
	local cb = GetCb(opt)
	local o = self:_Obj(R, opt, {})
	function o:Click() Fire(cb) end
	function o:SetCallback(f) cb = f end
	Connect(hit.MouseButton1Click, function() Ripple(row); Fire(cb) end)
	Library:AddCommand(opt.Title or "Button", function() Fire(cb) end, "Button", row)
	return o
end

function Mixin:AddToggle(opt)
	opt = opt or {}
	local R = self:_Row(opt, opt.Description and 52 or 40)
	local row = R.Row
	Pad(R, 64)
	local cb = GetCb(opt)
	local track = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 22), BorderSizePixel = 0, Parent = row})
	Themed(track, {BackgroundColor3 = "Stroke"})
	Corner(track, 11)
	local fill = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = track})
	Corner(fill, 11)
	local g = Themed(New("UIGradient", {Parent = fill}), {Color = Grad2})
	Library.AnimGradients[#Library.AnimGradients + 1] = g
	local knob = New("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2, Parent = track})
	Corner(knob, 8)
	local hit = Hit(row)
	Press(hit, R.Scale)
	local value = false
	local o = self:_Obj(R, opt, {Value = false})
	function o:Set(v, silent)
		v = not not v
		local changed = v ~= value
		value = v
		o.Value = v
		Tween(knob, {Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)}, 0.28, Enum.EasingStyle.Back)
		Tween(fill, {BackgroundTransparency = v and 0 or 1}, 0.25)
		if changed and not silent then Fire(cb, v); Library:_Changed() end
	end
	function o:Get() return value end
	function o:Toggle() o:Set(not value) end
	function o:SetValue(v) o:Set(v) end
	function o:GetValue() return value end
	self:_Flag(opt, o, opt.Default and true or false)
	o:Set(opt.Default, true)
	if opt.Default and opt.FireInit ~= false then task.defer(Fire, cb, true) end
	Connect(hit.MouseButton1Click, function() Ripple(row); o:Set(not value) end)
	Library:AddCommand("Toggle: " .. (opt.Title or "Toggle"), function() o:Set(not value) end, "Toggle", row)
	return o
end

function Mixin:AddCheckbox(opt)
	opt = opt or {}
	local R = self:_Row(opt, opt.Description and 52 or 40)
	local row = R.Row
	Pad(R, 44)
	local cb = GetCb(opt)
	local box = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Parent = row})
	Themed(box, {BackgroundColor3 = "Accent"})
	Corner(box, 5)
	local st = Stroke(box, "Stroke", 1.5, 0)
	local ck = Icon(box, "check", 14, "Text", "✓")
	ck.AnchorPoint = Vector2.new(0.5, 0.5); ck.Position = UDim2.fromScale(0.5, 0.5); ck.ImageTransparency = 1
	local hit = Hit(row)
	Press(hit, R.Scale)
	local value = false
	local o = self:_Obj(R, opt, {Value = false})
	function o:Set(v, silent)
		v = not not v
		local changed = v ~= value
		value = v
		o.Value = v
		Tween(box, {BackgroundTransparency = v and 0 or 1}, 0.2)
		Tween(ck, {ImageTransparency = v and 0 or 1}, 0.2)
		Tween(st, {Color = v and Library.Theme.Accent or Library.Theme.Stroke}, 0.2)
		if changed and not silent then Fire(cb, v); Library:_Changed() end
	end
	function o:Get() return value end
	function o:Toggle() o:Set(not value) end
	self:_Flag(opt, o, opt.Default and true or false)
	o:Set(opt.Default, true)
	if opt.Default and opt.FireInit ~= false then task.defer(Fire, cb, true) end
	Connect(hit.MouseButton1Click, function() Ripple(row); o:Set(not value) end)
	return o
end

------------------------------------------------ slider
function Mixin:AddSlider(opt)
	opt = opt or {}
	local min, max, inc = opt.Min or 0, opt.Max or 100, opt.Increment or opt.Step or 1
	local hasDesc = opt.Description and opt.Description ~= ""
	local h = hasDesc and 68 or 54
	local R = self:_Row(opt, h, 30)
	local row = R.Row
	Pad(R, 84)
	local cb = GetCb(opt)
	local suffix = opt.Suffix or ""
	local vb = New("TextBox", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6), Size = UDim2.fromOffset(70, 20), Font = Library.FontBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = true, Text = "", Parent = row})
	Themed(vb, {BackgroundColor3 = "Surface", TextColor3 = "Accent2"})
	Corner(vb, 5)
	local bar = New("Frame", {Position = UDim2.new(0, 12, 0, h - 18), Size = UDim2.new(1, -24, 0, 6), BorderSizePixel = 0, Parent = row})
	Themed(bar, {BackgroundColor3 = "Stroke"})
	Corner(bar, 3)
	local fill = New("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = bar})
	Corner(fill, 3)
	local g = Themed(New("UIGradient", {Parent = fill}), {Color = Grad2})
	Library.AnimGradients[#Library.AnimGradients + 1] = g
	local knob = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3, Parent = fill})
	Corner(knob, 7)
	Stroke(knob, "Accent", 2, 0)
	local area = New("TextButton", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "", ZIndex = 4, AutoButtonColor = false, Parent = bar})
	local value = min
	local o = self:_Obj(R, opt, {Value = min})
	local function show(v)
		local a = (v - min) / math.max(max - min, 1e-9)
		Tween(fill, {Size = UDim2.fromScale(Clamp(a, 0, 1), 1)}, 0.08, Enum.EasingStyle.Linear)
		vb.Text = tostring(v) .. suffix
	end
	function o:Set(v, silent)
		v = Round(Clamp(tonumber(v) or min, min, max), inc)
		local changed = v ~= value
		value = v
		o.Value = v
		show(v)
		if changed and not silent then Fire(cb, v); Library:_Changed() end
	end
	function o:Get() return value end
	function o:SetValue(v) o:Set(v) end
	function o:GetValue() return value end
	function o:SetRange(a, b) min, max = a, b; o:Set(value, true) end
	self:_Flag(opt, o, opt.Default or min)
	o:Set(opt.Default or min, true)
	DragArea(area, function(x) o:Set(min + (max - min) * x) end, function(a)
		LockScroll(self, a)
		Tween(knob, {Size = a and UDim2.fromOffset(18, 18) or UDim2.fromOffset(14, 14)}, 0.12)
	end)
	Connect(vb.FocusLost, function()
		local n = tonumber((vb.Text:gsub("[^%d%.%-]", "")))
		if n then o:Set(n) else show(value) end
	end)
	if opt.Default and opt.FireInit ~= false and opt.Default ~= min then task.defer(Fire, cb, value) end
	return o
end

------------------------------------------------ dropdown
function Mixin:AddDropdown(opt)
	opt = opt or {}
	local multi = opt.Multi or opt.Multiple or false
	local options = opt.Options or opt.Values or {}
	local notr = opt.Translate == false
	local R = self:_Row(opt, 40, 40)
	local row = R.Row
	Pad(R, 190)
	local cb = GetCb(opt)
	local val = L(row, "", 12, "SubText", false, false)
	val.AnchorPoint = Vector2.new(1, 0); val.Position = UDim2.new(1, -34, 0, 0); val.Size = UDim2.fromOffset(150, 40); val.TextXAlignment = Enum.TextXAlignment.Right
	local vb = Library:Bind(val, "Text", "", nil, notr)
	local chev = Icon(row, "chevron-down", 16, "SubText", "v")
	chev.AnchorPoint = Vector2.new(1, 0); chev.Position = UDim2.new(1, -10, 0, 12)
	local hit = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 40), ZIndex = 3, AutoButtonColor = false, Parent = row})
	Press(hit, R.Scale)
	local searchOn = #options > 8
	local top = searchOn and 78 or 46
	local sbox
	if searchOn then
		sbox = New("TextBox", {Position = UDim2.fromOffset(8, 44), Size = UDim2.new(1, -16, 0, 26), Text = "", ClearTextOnFocus = false, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
		Themed(sbox, {BackgroundColor3 = "Surface", TextColor3 = "Text", PlaceholderColor3 = "SubText"})
		Corner(sbox, 6)
		New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = sbox})
		Library:Bind(sbox, "PlaceholderText", "Search")
	end
	local list = New("ScrollingFrame", {Position = UDim2.fromOffset(8, top), Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = row})
	New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})
	local selected, current, buttons, open = {}, nil, {}, false
	local resize, build

	local function getMulti()
		local arr = {}
		for _, n in ipairs(options) do if selected[n] then arr[#arr + 1] = n end end
		return arr
	end
	local function display()
		if multi then
			local a = getMulti()
			vb:Set(#a > 0 and table.concat(a, ", ") or "None")
		else
			vb:Set(current ~= nil and tostring(current) or "None")
		end
	end
	local function paint()
		for name, b in pairs(buttons) do
			local on
			if multi then on = selected[name] and true or false else on = current == name end
			Tween(b.Frame, {BackgroundTransparency = on and 0.6 or 1}, 0.15)
			b.Check.Visible = on
		end
	end
	function resize(instant)
		local n = 0
		for _, b in pairs(buttons) do if b.Frame.Visible then n = n + 1 end end
		local hh = math.min(n * 31, 170)
		list.Size = UDim2.new(1, -16, 0, hh)
		Tween(row, {Size = UDim2.new(1, 0, 0, open and (top + hh + 8) or 40)}, instant and 0 or 0.28)
	end
	local function setOpen(v)
		open = v
		Tween(chev, {Rotation = v and 180 or 0}, 0.25)
		resize()
	end
	local function pick(name)
		if multi then selected[name] = (not selected[name]) or nil else current = name end
		display(); paint()
		if not multi then setOpen(false) end
		Fire(cb, multi and getMulti() or current)
		Library:_Changed()
	end
	function build()
		for _, b in pairs(buttons) do b.Frame:Destroy() end
		buttons = {}
		for i, name in ipairs(options) do
			local f = New("TextButton", {Size = UDim2.new(1, -4, 0, 28), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = list})
			Themed(f, {BackgroundColor3 = "Accent"})
			Corner(f, 6)
			local lb = L(f, tostring(name), 12, "Text", false, not notr)
			lb.Position = UDim2.fromOffset(10, 0); lb.Size = UDim2.new(1, -36, 1, 0)
			local ck = Icon(f, "check", 14, "Accent2", "✓")
			ck.AnchorPoint = Vector2.new(1, 0.5); ck.Position = UDim2.new(1, -8, 0.5, 0); ck.Visible = false
			Connect(f.MouseEnter, function() if not (current == name or selected[name]) then Tween(f, {BackgroundTransparency = 0.88}, 0.1) end end)
			Connect(f.MouseLeave, function() if not (current == name or selected[name]) then Tween(f, {BackgroundTransparency = 1}, 0.1) end end)
			Connect(f.MouseButton1Click, function() pick(name) end)
			buttons[name] = {Frame = f, Label = lb, Check = ck}
		end
		paint()
		resize(true)
	end
	if sbox then
		Connect(sbox:GetPropertyChangedSignal("Text"), function()
			local q = sbox.Text:lower()
			for name, b in pairs(buttons) do b.Frame.Visible = q == "" or tostring(name):lower():find(q, 1, true) ~= nil end
			resize(true)
		end)
	end
	local o = self:_Obj(R, opt, {Value = nil})
	function o:Set(v, silent)
		if multi then
			selected = {}
			if type(v) == "table" then
				for k, x in pairs(v) do
					if type(k) == "number" then selected[x] = true elseif x then selected[k] = true end
				end
			elseif v ~= nil then selected[v] = true end
			o.Value = getMulti()
		else
			current = v
			o.Value = v
		end
		display(); paint()
		if not silent then Fire(cb, multi and getMulti() or current); Library:_Changed() end
	end
	function o:Get() if multi then return getMulti() end return current end
	function o:SetValue(v) o:Set(v) end
	function o:GetValue() return o:Get() end
	function o:SetOptions(newOpts, keep)
		options = newOpts or {}
		if not keep then current = nil; selected = {} end
		build(); display()
	end
	o.Refresh = o.SetOptions
	function o:Clear() o:Set(multi and {} or nil, true) end
	function o:Close() setOpen(false) end
	self:_Flag(opt, o, opt.Default)
	build()
	if opt.Default ~= nil then o:Set(opt.Default, true) else display() end
	Connect(hit.MouseButton1Click, function() Ripple(row); setOpen(not open) end)
	if opt.Default ~= nil and opt.FireInit ~= false then task.defer(Fire, cb, multi and getMulti() or current) end
	return o
end

------------------------------------------------ textbox / keybind
function Mixin:AddTextbox(opt)
	opt = opt or {}
	local R = self:_Row(opt, opt.Description and 52 or 40)
	local row = R.Row
	Pad(R, 164)
	local cb = GetCb(opt)
	local box = New("TextBox", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(146, 26), Text = "", ClearTextOnFocus = opt.ClearOnFocus or false, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = row})
	Themed(box, {BackgroundColor3 = "Surface", TextColor3 = "Text", PlaceholderColor3 = "SubText"})
	Corner(box, 6)
	New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box})
	local st = Stroke(box, "Stroke", 1, 0.3)
	Library:Bind(box, "PlaceholderText", opt.Placeholder or "Enter text...")
	local o = self:_Obj(R, opt, {Value = ""})
	function o:Set(v, silent)
		v = tostring(v or "")
		box.Text = v
		o.Value = v
		if not silent then Fire(cb, v, false) end
	end
	function o:Get() return box.Text end
	function o:SetValue(v) o:Set(v) end
	function o:GetValue() return box.Text end
	self:_Flag(opt, o, opt.Default or "")
	box.Text = tostring(opt.Default or "")
	Connect(box.Focused, function() Tween(st, {Color = Library.Theme.Accent, Transparency = 0}, 0.15); Fire(opt.OnFocus) end)
	Connect(box.FocusLost, function(enter)
		Tween(st, {Color = Library.Theme.Stroke, Transparency = 0.3}, 0.15)
		o.Value = box.Text
		Fire(cb, box.Text, enter)
		Fire(opt.OnBlur, box.Text)
		Library:_Changed()
	end)
	Connect(box:GetPropertyChangedSignal("Text"), function()
		if opt.Numeric then
			local c = box.Text:gsub("[^%d%.%-]", "")
			if c ~= box.Text then box.Text = c end
		end
		o.Value = box.Text
		Fire(opt.OnInput, box.Text)
	end)
	return o
end
Mixin.AddInput = Mixin.AddTextbox
Mixin.AddInputField = Mixin.AddTextbox

function Mixin:AddKeybind(opt)
	opt = opt or {}
	local R = self:_Row(opt, opt.Description and 52 or 40)
	local row = R.Row
	Pad(R, 116)
	local btn = New("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(96, 26), Text = "", AutoButtonColor = false, ZIndex = 4, Parent = row})
	Themed(btn, {BackgroundColor3 = "Surface"})
	Corner(btn, 6)
	Stroke(btn, "Stroke", 1, 0.3)
	local lbl = L(btn, "None", 12, "Text", true, false)
	lbl.Size = UDim2.fromScale(1, 1); lbl.TextXAlignment = Enum.TextXAlignment.Center
	local kb = {Name = opt.Title or "Keybind", Key = nil, Mode = opt.Mode or "Press", Callback = GetCb(opt), Row = row}
	table.insert(Library.Keybinds, kb)
	local o = self:_Obj(R, opt, {Value = nil})
	local listening = false
	function o:Set(v, silent)
		if type(v) == "string" then
			local ok, k = pcall(function() return Enum.KeyCode[v] end)
			v = ok and k or nil
		end
		kb.Key = v
		o.Value = v
		lbl.Text = v and v.Name or "None"
		if Library._RefreshKeybinds then Library:_RefreshKeybinds() end
		if not silent then Fire(opt.OnChanged, v); Library:_Changed() end
	end
	function o:Get() return kb.Key end
	function o:SetValue(v) o:Set(v) end
	self:_Flag(opt, o, opt.Default)
	o:Set(opt.Default, true)
	Connect(btn.MouseButton1Click, function()
		if listening then return end
		listening = true
		Library._listening = true
		lbl.Text = "..."
		local c
		c = UIS.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				c:Disconnect()
				if i.KeyCode == Enum.KeyCode.Escape then o:Set(nil) else o:Set(i.KeyCode) end
				task.delay(0.15, function() listening = false; Library._listening = false end)
			end
		end)
	end)
	return o
end

------------------------------------------------ color picker
function Mixin:AddColorPicker(opt)
	opt = opt or {}
	local R = self:_Row(opt, 40, 40)
	local row = R.Row
	Pad(R, 64)
	local cb = GetCb(opt)
	local sw = New("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.fromOffset(40, 24), BorderSizePixel = 0, Parent = row})
	Corner(sw, 6)
	Stroke(sw, "Stroke", 1, 0.2)
	local hit = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 40), ZIndex = 3, AutoButtonColor = false, Parent = row})
	Press(hit, R.Scale)
	local sv = New("Frame", {Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -52, 0, 100), BorderSizePixel = 0, Parent = row})
	Corner(sv, 6)
	local white = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sv})
	Corner(white, 6)
	New("UIGradient", {Transparency = NumberSequence.new(0, 1), Parent = white})
	local black = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = sv})
	Corner(black, 6)
	New("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black})
	local cur = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ZIndex = 3, Parent = sv})
	Corner(cur, 6)
	New("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Parent = cur})
	local hue = New("Frame", {Position = UDim2.new(1, -30, 0, 48), Size = UDim2.fromOffset(18, 100), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = row})
	Corner(hue, 6)
	local kps = {}
	for i = 0, 6 do kps[#kps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(math.min(i / 6, 0.999), 1, 1)) end
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(kps), Parent = hue})
	local hcur = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 4, 0, 4), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3, Parent = hue})
	Corner(hcur, 2)
	New("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1, Parent = hcur})
	local hex = New("TextBox", {Position = UDim2.fromOffset(12, 156), Size = UDim2.new(1, -24, 0, 26), Text = "", ClearTextOnFocus = false, Font = Library.Font, TextSize = 12, Parent = row})
	Themed(hex, {BackgroundColor3 = "Surface", TextColor3 = "Text"})
	Corner(hex, 6)
	local h, s, v = 0, 1, 1
	local open = false
	local o = self:_Obj(R, opt, {Value = Color3.new(1, 1, 1)})
	local function apply(fire)
		local col = Color3.fromHSV(h, s, v)
		sw.BackgroundColor3 = col
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		cur.Position = UDim2.fromScale(s, 1 - v)
		hcur.Position = UDim2.fromScale(0.5, h)
		hex.Text = "#" .. col:ToHex():upper()
		o.Value = col
		if fire then Fire(cb, col); Library:_Changed() end
	end
	function o:Set(c, silent)
		if typeof(c) ~= "Color3" then return end
		h, s, v = c:ToHSV()
		apply(not silent)
	end
	function o:Get() return Color3.fromHSV(h, s, v) end
	function o:SetValue(c) o:Set(c) end
	self:_Flag(opt, o, opt.Default or Color3.new(1, 1, 1))
	o:Set(opt.Default or Color3.new(1, 1, 1), true)
	DragArea(sv, function(x, y) s = x; v = 1 - y; apply(true) end, function(a) LockScroll(self, a) end)
	DragArea(hue, function(_, y) h = Clamp(y, 0, 0.999); apply(true) end, function(a) LockScroll(self, a) end)
	Connect(hex.FocusLost, function()
		local t = hex.Text:gsub("#", "")
		if #t == 6 and t:match("^%x+$") then
			o:Set(Color3.fromRGB(tonumber(t:sub(1, 2), 16), tonumber(t:sub(3, 4), 16), tonumber(t:sub(5, 6), 16)))
		else apply(false) end
	end)
	Connect(hit.MouseButton1Click, function()
		Ripple(row)
		open = not open
		Tween(row, {Size = UDim2.new(1, 0, 0, open and 192 or 40)}, 0.28)
	end)
	return o
end

------------------------------------------------ text elements
function Mixin:AddLabel(text, opt)
	if type(text) == "table" then opt = text; text = opt.Text or opt.Title end
	opt = opt or {}
	self._n = self._n + 1
	local l = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, Font = Library.Font, TextSize = opt.Size or 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._n, Text = "", Parent = self.Holder})
	New("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = l})
	Themed(l, {TextColor3 = opt.Color or "SubText"})
	local e = Library:Bind(l, "Text", text or "", nil, opt.Translate == false)
	local o = {Row = l}
	function o:Set(t) e:Set(t) end
	function o:SetText(t) e:Set(t) end
	function o:SetVisible(v) l.Visible = v end
	function o:Destroy() l:Destroy() end
	return o
end
Mixin.AddTextLabel = Mixin.AddLabel

function Mixin:AddRichText(opt)
	if type(opt) == "string" then opt = {Text = opt} end
	opt = opt or {}
	self._n = self._n + 1
	local l = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, RichText = true, Font = Library.Font, TextSize = opt.Size or 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = self._n, Text = opt.Text or "", Parent = self.Holder})
	New("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = l})
	Themed(l, {TextColor3 = "Text"})
	local o = {Row = l}
	function o:Set(t) l.Text = t end
	function o:SetVisible(v) l.Visible = v end
	function o:Destroy() l:Destroy() end
	return o
end

function Mixin:AddParagraph(opt)
	if type(opt) == "string" then opt = {Content = opt} end
	opt = opt or {}
	local f = self:_Frame(0, true)
	New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = f})
	New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
	local t, tb = L(f, opt.Title or "", 13, "Text", true, opt.Translate)
	t.Size = UDim2.new(1, 0, 0, 18); t.LayoutOrder = 1
	local c, cbind = L(f, opt.Content or "", 12, "SubText", false, opt.Translate)
	c.Size = UDim2.new(1, 0, 0, 0); c.AutomaticSize = Enum.AutomaticSize.Y; c.TextWrapped = true; c.TextTruncate = Enum.TextTruncate.None; c.LayoutOrder = 2
	if (opt.Title or "") == "" then t.Visible = false end
	if self.Tab and self.Tab.Searchables then
		table.insert(self.Tab.Searchables, {Row = f, Title = t, Text = (opt.Title or "") .. " " .. (opt.Content or "")})
	end
	local o = {Row = f}
	function o:Set(content) cbind:Set(content) end
	function o:SetTitle(x) tb:Set(x); t.Visible = true end
	function o:SetVisible(v) f.Visible = v end
	function o:Destroy() f:Destroy() end
	return o
end

function Mixin:AddDivider()
	self._n = self._n + 1
	local d = New("Frame", {Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5, LayoutOrder = self._n, Parent = self.Holder})
	Themed(d, {BackgroundColor3 = "Stroke"})
	return d
end

function Mixin:AddSeparator(text)
	self._n = self._n + 1
	local f = New("Frame", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Holder})
	local lb = L(f, text or "", 11, "SubText", true)
	lb.AnchorPoint = Vector2.new(0.5, 0.5); lb.Position = UDim2.fromScale(0.5, 0.5); lb.Size = UDim2.fromOffset(0, 14); lb.AutomaticSize = Enum.AutomaticSize.X; lb.TextXAlignment = Enum.TextXAlignment.Center; lb.TextTruncate = Enum.TextTruncate.None; lb.ZIndex = 2
	for i = 0, 1 do
		local ln = New("Frame", {AnchorPoint = Vector2.new(i, 0.5), Position = UDim2.new(i, 0, 0.5, 0), Size = UDim2.new(0.5, -((text and text ~= "") and 50 or 0), 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = f})
		Themed(ln, {BackgroundColor3 = "Stroke"})
	end
	return f
end

function Mixin:AddCopyField(opt)
	opt = opt or {}
	local R = self:_Row(opt, 40)
	local row = R.Row
	Pad(R, 12)
	R.Title.Size = UDim2.new(0, 90, 0, 40)
	local val = L(row, tostring(opt.Text or ""), 12, "SubText", false, false)
	val.Position = UDim2.fromOffset(100, 0); val.Size = UDim2.new(1, -150, 1, 0)
	local b = SmallBtn(row, "copy", "⧉", 28, 28)
	b.AnchorPoint = Vector2.new(1, 0.5); b.Position = UDim2.new(1, -8, 0.5, 0)
	local o = self:_Obj(R, opt, {})
	function o:Set(t) val.Text = tostring(t) end
	function o:Get() return val.Text end
	Connect(b.MouseButton1Click, function()
		if setclipboard then setclipboard(val.Text) end
		Library:Notify({Title = "Copied", Content = val.Text, Type = "success", Duration = 2})
	end)
	return o
end
Mixin.AddCopyText = Mixin.AddCopyField

function Mixin:AddSearchBar(opt)
	opt = opt or {}
	local f = self:_Frame(36)
	local ic = Icon(f, "search", 16, "SubText", "?")
	ic.Position = UDim2.fromOffset(12, 10)
	local box = New("TextBox", {Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -48, 1, 0), BackgroundTransparency = 1, Text = "", ClearTextOnFocus = false, Font = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
	Themed(box, {TextColor3 = "Text", PlaceholderColor3 = "SubText"})
	Library:Bind(box, "PlaceholderText", opt.Placeholder or "Search")
	local holder = self.Holder
	Connect(box:GetPropertyChangedSignal("Text"), function()
		local q = box.Text:lower()
		local tab = self.Tab
		if tab and tab.Searchables then
			for _, s in ipairs(tab.Searchables) do
				if s.Row.Parent == holder then
					local hay = ((s.Title and s.Title.Text or "") .. " " .. s.Text):lower()
					s.Row.Visible = (q == "" or hay:find(q, 1, true) ~= nil) and not s.Row:GetAttribute("Hidden")
				end
			end
		end
		Fire(GetCb(opt), box.Text)
	end)
	return {Row = f, Box = box}
end

------------------------------------------------ progress
function Mixin:AddProgressBar(opt)
	opt = opt or {}
	local max = opt.Max or 100
	local R = self:_Row(opt, opt.Description and 66 or 54, 30)
	Pad(R, 64)
	local pct = L(R.Row, "0%", 12, "Accent2", true, false)
	pct.AnchorPoint = Vector2.new(1, 0); pct.Position = UDim2.new(1, -12, 0, 0); pct.Size = UDim2.fromOffset(54, 30); pct.TextXAlignment = Enum.TextXAlignment.Right
	local bar = MakeBar(R.Row, 8)
	bar.Frame.Position = UDim2.new(0, 12, 1, -20); bar.Frame.Size = UDim2.new(1, -24, 0, 8)
	local o = self:_Obj(R, opt, {Value = 0})
	function o:Set(v)
		o.Value = v
		local a = Clamp(v / max, 0, 1)
		bar:Set(a)
		pct.Text = math.floor(a * 100 + 0.5) .. "%"
	end
	function o:Get() return o.Value end
	o:Set(opt.Value or opt.Default or 0)
	return o
end

function Mixin:AddCircularProgress(opt)
	opt = opt or {}
	local max = opt.Max or 100
	local R = self:_Row(opt, 80, 80)
	Pad(R, 80)
	local ring = MakeCircular(R.Row, 56, 6)
	ring.Frame.AnchorPoint = Vector2.new(1, 0.5); ring.Frame.Position = UDim2.new(1, -14, 0.5, 0)
	local pct = L(ring.Frame, "0%", 11, "Text", true, false)
	pct.Size = UDim2.fromScale(1, 1); pct.TextXAlignment = Enum.TextXAlignment.Center
	local o = self:_Obj(R, opt, {Value = 0})
	function o:Set(v)
		o.Value = v
		local a = Clamp(v / max, 0, 1)
		ring:Set(a)
		pct.Text = math.floor(a * 100 + 0.5) .. "%"
	end
	function o:Get() return o.Value end
	o:Set(opt.Value or opt.Default or 0)
	return o
end

------------------------------------------------ containers
function Mixin:AddSection(arg)
	local opt = type(arg) == "string" and {Title = arg} or arg or {}
	self._n = self._n + 1
	local sec = New("Frame", {Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Holder})
	New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec})
	local head = New("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 0, Parent = sec})
	local lbl = L(head, opt.Title or "Section", 12, "Accent2", true, opt.Translate)
	lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.fromOffset(2, 0)
	local line = New("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = head})
	Themed(New("UIGradient", {Transparency = NumberSequence.new(0, 1), Parent = line}), {Color = Grad2})
	local m = NewMixin(sec, self.Tab, self.Window)
	m._n = 0
	function m:SetVisible(v) sec.Visible = v end
	function m:Destroy() sec:Destroy() end
	return m
end
Mixin.CreateSection = Mixin.AddSection

function Mixin:AddSubsection(arg)
	local opt = type(arg) == "string" and {Title = arg} or arg or {}
	self._n = self._n + 1
	local sec = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Holder})
	New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec})
	New("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = sec})
	local lbl = L(sec, opt.Title or "Subsection", 11, "SubText", true, opt.Translate)
	lbl.Size = UDim2.new(1, 0, 0, 16); lbl.LayoutOrder = 0
	local m = NewMixin(sec, self.Tab, self.Window)
	function m:SetVisible(v) sec.Visible = v end
	return m
end

function Mixin:AddGrid(opt)
	opt = opt or {}
	self._n = self._n + 1
	local g = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Holder})
	local cols = opt.Columns or 2
	New("UIGridLayout", {CellSize = UDim2.new(1 / cols, -6, 0, opt.CellHeight or 40), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g})
	return NewMixin(g, self.Tab, self.Window)
end

function Mixin:AddCollapsible(opt)
	if type(opt) == "string" then opt = {Title = opt} end
	opt = opt or {}
	self._n = self._n + 1
	local wrap = New("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 0.3, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = self._n, Parent = self.Holder})
	Themed(wrap, {BackgroundColor3 = "Element"})
	Corner(wrap, 8)
	Stroke(wrap, "Stroke", 1, 0.6)
	local title = L(wrap, opt.Title or "Collapsible", 13, "Text", true, opt.Translate)
	title.Position = UDim2.fromOffset(12, 0); title.Size = UDim2.new(1, -44, 0, 38)
	local chev = Icon(wrap, "chevron-down", 16, "SubText", "v")
	chev.AnchorPoint = Vector2.new(1, 0); chev.Position = UDim2.new(1, -12, 0, 11)
	local hit = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), ZIndex = 3, AutoButtonColor = false, Parent = wrap})
	local body = New("Frame", {Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = wrap})
	local lay = New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body})
	New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = body})
	local open = false
	local m = NewMixin(body, self.Tab, self.Window)
	local function resize(anim)
		local hgt = open and (40 + lay.AbsoluteContentSize.Y + 8) or 38
		Tween(wrap, {Size = UDim2.new(1, 0, 0, hgt)}, anim and 0.28 or 0)
	end
	function m:SetOpen(v)
		if v == open then return end
		open = v
		Tween(chev, {Rotation = v and 180 or 0}, 0.25)
		if v and opt.Group and self.Tab then
			self.Tab.Groups = self.Tab.Groups or {}
			for _, other in ipairs(self.Tab.Groups[opt.Group] or {}) do
				if other ~= self then other:SetOpen(false) end
			end
		end
		resize(true)
	end
	function m:Toggle() m:SetOpen(not open) end
	function m:SetVisible(v) wrap.Visible = v end
	function m:Destroy() wrap:Destroy() end
	if opt.Group and self.Tab then
		self.Tab.Groups = self.Tab.Groups or {}
		self.Tab.Groups[opt.Group] = self.Tab.Groups[opt.Group] or {}
		table.insert(self.Tab.Groups[opt.Group], m)
	end
	Connect(lay:GetPropertyChangedSignal("AbsoluteContentSize"), function() if open then resize(false) end end)
	Connect(hit.MouseButton1Click, function() Ripple(wrap); m:Toggle() end)
	if opt.Open then task.defer(function() m:SetOpen(true) end) end
	return m
end
Mixin.AddAccordion = Mixin.AddCollapsible

function Mixin:AddSubtabs(names, opt)
	opt = opt or {}
	self._n = self._n + 2
	local order = self._n - 1
	local bar = New("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = order, Parent = self.Holder})
	local back = SmallBtn(bar, "chevron-left", "‹", 28, 28)
	back.Position = UDim2.fromOffset(0, 3)
	local nxt = SmallBtn(bar, "chevron-right", "›", 28, 28)
	nxt.AnchorPoint = Vector2.new(1, 0); nxt.Position = UDim2.new(1, 0, 0, 3)
	local pills = New("ScrollingFrame", {Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -68, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, Parent = bar})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = pills})
	local subs, frames, pb, idx = {}, {}, {}, 1
	local function select(i)
		idx = ((i - 1) % #names) + 1
		for k, f in ipairs(frames) do
			f.Visible = k == idx
			Tween(pb[k], {BackgroundTransparency = k == idx and 0.25 or 0.88}, 0.2)
			Tween(pb[k], {TextColor3 = Library.Theme[k == idx and "Text" or "SubText"]}, 0.2)
		end
		Fire(opt.Callback, names[idx], idx)
	end
	for i, name in ipairs(names) do
		local p = New("TextButton", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 0.88, Text = "", Font = Library.FontBold, TextSize = 12, AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = i, Parent = pills})
		Themed(p, {BackgroundColor3 = "Accent", TextColor3 = "SubText"})
		Library:Bind(p, "Text", name)
		New("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = p})
		Corner(p, 13)
		Connect(p.MouseButton1Click, function() Ripple(p); select(i) end)
		pb[i] = p
		local f = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, LayoutOrder = order + 1, Parent = self.Holder})
		New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
		frames[i] = f
		local m = NewMixin(f, self.Tab, self.Window)
		subs[i] = m
		subs[name] = m
	end
	Connect(back.MouseButton1Click, function() select(idx - 1) end)
	Connect(nxt.MouseButton1Click, function() select(idx + 1) end)
	subs.Select = function(_, i) if type(i) == "string" then for k, n in ipairs(names) do if n == i then i = k end end end select(i) end
	select(1)
	return subs
end
Mixin.CreateSubtabs = Mixin.AddSubtabs

function Mixin:AddPageSelector(opt)
	opt = opt or {}
	local pages = opt.Pages or 5
	local f = self:_Frame(40)
	local cb = GetCb(opt)
	local cur = opt.Default or 1
	local back = SmallBtn(f, "chevron-left", "‹", 28, 28)
	back.AnchorPoint = Vector2.new(0, 0.5); back.Position = UDim2.new(0, 8, 0.5, 0)
	local nxt = SmallBtn(f, "chevron-right", "›", 28, 28)
	nxt.AnchorPoint = Vector2.new(1, 0.5); nxt.Position = UDim2.new(1, -8, 0.5, 0)
	local mid = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -90, 0, 28), BackgroundTransparency = 1, Parent = f})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = mid})
	local btns = {}
	local function set(p, silent)
		cur = Clamp(p, 1, pages)
		for i, b in ipairs(btns) do
			Tween(b, {BackgroundTransparency = i == cur and 0.2 or 0.9}, 0.15)
		end
		if not silent then Fire(cb, cur) end
	end
	for i = 1, pages do
		local b = New("TextButton", {Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 0.9, Text = tostring(i), Font = Library.FontBold, TextSize = 12, AutoButtonColor = false, LayoutOrder = i, Parent = mid})
		Themed(b, {BackgroundColor3 = "Accent", TextColor3 = "Text"})
		Corner(b, 13)
		Connect(b.MouseButton1Click, function() set(i) end)
		btns[i] = b
	end
	Connect(back.MouseButton1Click, function() set(cur - 1) end)
	Connect(nxt.MouseButton1Click, function() set(cur + 1) end)
	set(cur, true)
	return {Row = f, Set = function(_, p) set(p) end, Get = function() return cur end}
end

------------------------------------------------ viewport / video
function Mixin:AddViewport(opt)
	opt = opt or {}
	local f = self:_Frame(opt.Height or 140)
	f.ClipsDescendants = true
	local vp = New("ViewportFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Ambient = Color3.fromRGB(120, 120, 150), LightColor = Color3.new(1, 1, 1), Parent = f})
	local cam = New("Camera", {Parent = vp})
	vp.CurrentCamera = cam
	local model = New("Model", {Parent = vp})
	if opt.Object then
		local c = opt.Object:Clone()
		c.Parent = model
	else
		local planet = New("Part", {Shape = Enum.PartType.Ball, Size = Vector3.new(2.2, 2.2, 2.2), Material = Enum.Material.SmoothPlastic, Color = Library.Theme.Accent, Anchored = true, CFrame = CFrame.new(0, 0, 0), Parent = model})
		New("Part", {Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.08, 4, 4), Material = Enum.Material.Neon, Color = Library.Theme.Accent2, Transparency = 0.35, Anchored = true, CFrame = CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(math.rad(20), 0, 0), Parent = model})
	end
	cam.CFrame = CFrame.new(Vector3.new(0, 1.2, 6), Vector3.new(0, 0, 0))
	Library:_OnFrame(function(dt, t)
		if f.Parent and Library.Window and Library.Window.Visible then model:PivotTo(CFrame.Angles(0, t * 0.6, 0)) end
	end)
	return {Row = f, Viewport = vp, Model = model}
end

function Mixin:AddVideo(opt)
	opt = opt or {}
	local f = self:_Frame(opt.Height or 140)
	f.ClipsDescendants = true
	local v = New("VideoFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Video = opt.Video or "", Looped = opt.Looped ~= false, Volume = opt.Volume or 0, Parent = f})
	if opt.Playing ~= false then pcall(function() v:Play() end) end
	return {Row = f, Video = v}
end

------------------------------------------------ misc cards
function Mixin:AddGameCard()
	local f = self:_Frame(96)
	local pid = game.PlaceId
	local thumb = New("ImageLabel", {Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(72, 72), BackgroundTransparency = 0.5, Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150", ScaleType = Enum.ScaleType.Crop, Parent = f})
	Themed(thumb, {BackgroundColor3 = "Surface"})
	Corner(thumb, 10)
	New("UIAspectRatioConstraint", {AspectRatio = 1, Parent = thumb})
	Stroke(thumb, "Accent", 1.5, 0.3)
	local name = L(f, "Loading...", 14, "Text", true, false)
	name.Position = UDim2.fromOffset(96, 12); name.Size = UDim2.new(1, -108, 0, 20)
	task.spawn(function()
		local ok, info = pcall(function() return MarketplaceService:GetProductInfo(pid) end)
		if ok and info and info.Name then name.Text = info.Name else name.Text = game.Name ~= "" and game.Name or "Unknown Game" end
	end)
	local cap = L(f, "Place ID", 11, "SubText", false, false)
	cap.Position = UDim2.fromOffset(96, 34); cap.Size = UDim2.new(1, -150, 0, 14)
	local idl = L(f, tostring(pid), 13, "Accent2", true, false)
	idl.Position = UDim2.fromOffset(96, 48); idl.Size = UDim2.new(1, -150, 0, 18)
	local b = SmallBtn(f, "copy", "⧉", 28, 28)
	b.AnchorPoint = Vector2.new(1, 0); b.Position = UDim2.new(1, -10, 0, 38)
	Connect(b.MouseButton1Click, function()
		if setclipboard then setclipboard(tostring(pid)) end
		Library:Notify({Title = "Copied", Content = "Place ID " .. tostring(pid), Type = "success", Duration = 2})
	end)
	local jl = L(f, "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers, 11, "SubText", false, false)
	jl.Position = UDim2.fromOffset(96, 72); jl.Size = UDim2.new(1, -108, 0, 16)
	return {Row = f}
end

