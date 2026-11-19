--[[
	ASTERVEIL UI LIBRARY  |  Space Edition  |  v1.0.0
	Executor UI library for Roblox (Luau)
	Discord: https://discord.gg/Xd6Xay6VsW
]]

local env = (getgenv and getgenv()) or _G
if env.AsterveilUI and type(env.AsterveilUI.Unload) == "function" then
	pcall(function() env.AsterveilUI:Unload() end)
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local LogService = game:GetService("LogService")
local LocalPlayer = Players.LocalPlayer

local ICONS_URL = "https://raw.githubusercontent.com/pickapicksmm/Asterveil-Hub/refs/heads/main/Library/Icons.lua"
local LOGO_URL = "https://raw.githubusercontent.com/pickapicksmm/Asterveil-Hub/refs/heads/main/Library/Image/logo.gif"
local DISCORD_URL = "https://discord.gg/Xd6Xay6VsW"
local DISCORD_CODE = "Xd6Xay6VsW"
local SHADOW = "rbxassetid://6014261993"

local httpRequest = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
local hasFS = (writefile and readfile and isfile and makefolder and isfolder) and true or false

local Library = {
	Version = "1.0.0",
	Flags = {}, Connections = {}, Logs = {}, Keybinds = {}, Commands = {},
	FrameCallbacks = {}, AnimGradients = {},
	Language = "English", IconSet = "lucide", Folder = "Asterveil", ConfigName = "Asterveil",
	ReduceEffects = false, Notifications = true, AutoSave = false, AutoLoad = false,
	CurrentScale = 1, Time = 0, FPS = 60,
	ToggleKey = Enum.KeyCode.RightShift,
	Font = Enum.Font.GothamMedium, FontBold = Enum.Font.GothamBold,
	NotifCount = 0,
}
env.AsterveilUI = Library

------------------------------------------------------------------ utils
local function Clamp(v, a, b) return math.max(a, math.min(b, v)) end

local function Round(v, inc)
	inc = inc or 1
	local d = tostring(inc):match("%.(%d+)")
	d = d and #d or 0
	v = math.floor(v / inc + 0.5) * inc
	return tonumber(string.format("%." .. d .. "f", v))
end

local function New(class, props, children)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else o[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = o end
	if parent then o.Parent = parent end
	return o
end

local function Connect(sig, fn)
	local c = sig:Connect(fn)
	Library.Connections[#Library.Connections + 1] = c
	return c
end

local function Tween(o, props, t, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function Corner(p, r) return New("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end

local function Fire(cb, ...)
	if type(cb) ~= "function" then return end
	local ok, err = pcall(cb, ...)
	if not ok then Library:Log("Callback error: " .. tostring(err), "error") end
end

function Library:_OnFrame(fn) self.FrameCallbacks[#self.FrameCallbacks + 1] = fn end

function Library:Log(msg, kind)
	local e = {Time = os.date("%H:%M:%S"), Kind = kind or "info", Text = tostring(msg)}
	self.Logs[#self.Logs + 1] = e
	if #self.Logs > 300 then table.remove(self.Logs, 1) end
	if self.OnLog then pcall(self.OnLog, e) end
end

local function C(r, g, b) return Color3.fromRGB(r, g, b) end

------------------------------------------------------------------ themes
local Base = {
	Background = C(9, 7, 22), Surface = C(18, 14, 40), Element = C(28, 22, 60), ElementHover = C(40, 32, 84),
	Accent = C(139, 92, 246), Accent2 = C(34, 211, 238), Accent3 = C(236, 72, 153),
	Text = C(240, 238, 255), SubText = C(150, 146, 190), Stroke = C(78, 64, 150),
	Success = C(74, 222, 128), Warning = C(250, 204, 21), Error = C(248, 113, 113), Star = 1,
}
local function Theme(o)
	local t = {}
	for k, v in pairs(Base) do t[k] = v end
	for k, v in pairs(o) do t[k] = v end
	return t
end
Library.Themes = {
	["Nebula"] = Theme({}),
	["Cosmos"] = Theme({Background = C(4, 10, 26), Surface = C(8, 20, 48), Element = C(14, 32, 70), ElementHover = C(22, 46, 96), Accent = C(56, 189, 248), Accent2 = C(129, 140, 248), Accent3 = C(45, 212, 191), Stroke = C(40, 80, 140), SubText = C(140, 170, 210)}),
	["Aurora"] = Theme({Background = C(4, 18, 20), Surface = C(8, 32, 34), Element = C(12, 48, 50), ElementHover = C(18, 66, 68), Accent = C(52, 211, 153), Accent2 = C(96, 165, 250), Accent3 = C(167, 139, 250), Stroke = C(30, 110, 100), SubText = C(140, 190, 180)}),
	["Supernova"] = Theme({Background = C(24, 8, 10), Surface = C(44, 14, 16), Element = C(66, 22, 24), ElementHover = C(92, 32, 32), Accent = C(251, 113, 60), Accent2 = C(250, 204, 21), Accent3 = C(244, 63, 94), Stroke = C(140, 60, 50), SubText = C(210, 160, 150)}),
	["Dark Mode"] = Theme({Background = C(14, 14, 16), Surface = C(22, 22, 26), Element = C(32, 32, 38), ElementHover = C(44, 44, 52), Accent = C(99, 102, 241), Accent2 = C(168, 85, 247), Accent3 = C(236, 72, 153), Text = C(240, 240, 245), SubText = C(150, 150, 165), Stroke = C(60, 60, 72), Star = 0.3}),
	["Light Mode"] = Theme({Background = C(240, 242, 250), Surface = C(226, 230, 245), Element = C(255, 255, 255), ElementHover = C(236, 239, 252), Accent = C(99, 102, 241), Accent2 = C(14, 165, 233), Accent3 = C(236, 72, 153), Text = C(24, 24, 40), SubText = C(100, 104, 130), Stroke = C(190, 194, 220), Star = 0}),
}
Library.ThemeName = "Nebula"
Library.Theme = Theme({})

local ThemeList = {}
local function Themed(obj, map)
	ThemeList[#ThemeList + 1] = {obj = obj, map = map}
	for p, k in pairs(map) do
		if type(k) == "function" then obj[p] = k(Library.Theme) else obj[p] = Library.Theme[k] end
	end
	return obj
end

local function Grad2(t) return ColorSequence.new(t.Accent, t.Accent2) end
local function Grad3(t)
	return ColorSequence.new({ColorSequenceKeypoint.new(0, t.Accent), ColorSequenceKeypoint.new(0.5, t.Accent2), ColorSequenceKeypoint.new(1, t.Accent3)})
end

function Library:SetTheme(t)
	if type(t) == "string" then
		local th = self.Themes[t]
		if not th then return end
		self.ThemeName = t
		for k, v in pairs(th) do self.Theme[k] = v end
	elseif type(t) == "table" then
		for k, v in pairs(t) do self.Theme[k] = v end
		self.ThemeName = "Custom"
	end
	for i = #ThemeList, 1, -1 do
		local e = ThemeList[i]
		if not e.obj.Parent then
			table.remove(ThemeList, i)
		else
			for p, k in pairs(e.map) do
				local v
				if type(k) == "function" then v = k(self.Theme) else v = self.Theme[k] end
				if typeof(v) == "Color3" then Tween(e.obj, {[p] = v}, 0.4) else e.obj[p] = v end
			end
		end
	end
	if self.OnThemeChanged then pcall(self.OnThemeChanged) end
end

local function Stroke(p, key, th, tr)
	local s = New("UIStroke", {Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p})
	return Themed(s, {Color = key or "Stroke"})
end

------------------------------------------------------------------ translation
local LangCode = {
	["English"] = "en", ["Mandarin Chinese"] = "zh-CN", ["Japanese"] = "ja", ["Korean"] = "ko", ["Thai"] = "th",
	["Vietnamese"] = "vi", ["Khmer"] = "km", ["Lao"] = "lo", ["Burmese"] = "my", ["Tagalog"] = "tl",
	["Indonesian"] = "id", ["Bengali"] = "bn", ["Nepali"] = "ne", ["Arabic"] = "ar", ["Persian (Farsi)"] = "fa",
	["Turkish"] = "tr", ["Mongolian"] = "mn", ["Russian"] = "ru", ["Portuguese"] = "pt", ["Spanish"] = "es", ["Amharic"] = "am",
}
Library.Languages = {"English", "Mandarin Chinese", "Japanese", "Korean", "Thai", "Vietnamese", "Khmer", "Lao", "Burmese", "Tagalog", "Indonesian", "Bengali", "Nepali", "Arabic", "Persian (Farsi)", "Turkish", "Mongolian", "Russian", "Portuguese", "Spanish", "Amharic"}

local Order = {"zh-CN", "ja", "ko", "th", "vi", "km", "lo", "my", "tl", "id", "bn", "ne", "ar", "fa", "tr", "mn", "ru", "pt", "es", "am"}
local Dict = {}
local function D(key, ...)
	local t = {...}
	Dict[key] = {}
	for i, code in ipairs(Order) do Dict[key][code] = t[i] end
end
D("Search", "搜索", "検索", "검색", "ค้นหา", "Tìm kiếm", "ស្វែងរក", "ຄົ້ນຫາ", "ရှာဖွေရန်", "Hanapin", "Cari", "অনুসন্ধান", "खोज्नुहोस्", "بحث", "جستجو", "Ara", "Хайх", "Поиск", "Pesquisar", "Buscar", "ፈልግ")
D("Info", "信息", "情報", "정보", "ข้อมูล", "Thông tin", "ព័ត៌មាន", "ຂໍ້ມູນ", "အချက်အလက်", "Impormasyon", "Info", "তথ্য", "जानकारी", "معلومات", "اطلاعات", "Bilgi", "Мэдээлэл", "Информация", "Informações", "Información", "መረጃ")
D("Console", "控制台", "コンソール", "콘솔", "คอนโซล", "Bảng điều khiển", "កុងសូល", "ຄອນໂຊນ", "ကွန်ဆိုး", "Console", "Konsol", "কনসোল", "कन्सोल", "وحدة التحكم", "کنسول", "Konsol", "Консол", "Консоль", "Console", "Consola", "ኮንሶል")
D("Configure", "配置", "構成", "구성", "กำหนดค่า", "Cấu hình", "កំណត់រចនាសម្ព័ន្ធ", "ຕັ້ງຄ່າ", "ပြင်ဆင်ရန်", "I-configure", "Konfigurasi", "কনফিগার", "कन्फिगर", "تكوين", "پیکربندی", "Yapılandır", "Тохируулга", "Конфигурация", "Configurar", "Configurar", "አዋቅር")
D("Settings", "设置", "設定", "설정", "การตั้งค่า", "Cài đặt", "ការកំណត់", "ການຕັ້ງຄ່າ", "ဆက်တင်များ", "Mga Setting", "Pengaturan", "সেটিংস", "सेटिङहरू", "الإعدادات", "تنظیمات", "Ayarlar", "Тохиргоо", "Настройки", "Configurações", "Ajustes", "ቅንብሮች")
D("Language", "语言", "言語", "언어", "ภาษา", "Ngôn ngữ", "ភាសា", "ພາສາ", "ဘာသာစကား", "Wika", "Bahasa", "ভাষা", "भाषा", "اللغة", "زبان", "Dil", "Хэл", "Язык", "Idioma", "Idioma", "ቋንቋ")
D("Save", "保存", "保存", "저장", "บันทึก", "Lưu", "រក្សាទុក", "ບັນທຶກ", "သိမ်းဆည်းရန်", "I-save", "Simpan", "সংরক্ষণ", "सुरक्षित गर्नुहोस्", "حفظ", "ذخیره", "Kaydet", "Хадгалах", "Сохранить", "Salvar", "Guardar", "አስቀምጥ")
D("Delete", "删除", "削除", "삭제", "ลบ", "Xóa", "លុប", "ລຶບ", "ဖျက်ရန်", "Burahin", "Hapus", "মুছুন", "मेटाउनुहोस्", "حذف", "حذف", "Sil", "Устгах", "Удалить", "Excluir", "Eliminar", "ሰርዝ")
D("Load", "加载", "読み込み", "불러오기", "โหลด", "Tải", "ផ្ទុក", "ໂຫຼດ", "ဖွင့်ရန်", "I-load", "Muat", "লোড", "लोड गर्नुहोस्", "تحميل", "بارگذاری", "Yükle", "Ачаалах", "Загрузить", "Carregar", "Cargar", "ጫን")
D("Copy", "复制", "コピー", "복사", "คัดลอก", "Sao chép", "ចម្លង", "ສຳເນົາ", "ကူးယူရန်", "Kopyahin", "Salin", "কপি", "प्रतिलिपि", "نسخ", "کپی", "Kopyala", "Хуулах", "Копировать", "Copiar", "Copiar", "ቅዳ")
D("Session", "会话", "セッション", "세션", "เซสชัน", "Phiên", "វគ្គ", "ເຊດຊັນ", "စက်ရှင်", "Sesyon", "Sesi", "সেশন", "सत्र", "الجلسة", "نشست", "Oturum", "Сесс", "Сессия", "Sessão", "Sesión", "ክፍለ ጊዜ")
D("Executor", "执行器", "エグゼキューター", "실행기", "ตัวรัน", "Trình thực thi", "កម្មវិធីប្រតិបត្តិ", "ໂຕຣັນ", "အကောင်အထည်ဖော်", "Executor", "Executor", "এক্সিকিউটর", "एक्जिक्युटर", "المنفذ", "اجراکننده", "Çalıştırıcı", "Гүйцэтгэгч", "Исполнитель", "Executor", "Ejecutor", "አስፈጻሚ")

local Cache = {}
local TrList = {}
local Queue, Pending, Working = {}, {}, false

local function CachePath() return Library.Folder .. "/translations.json" end
local function LoadCache()
	if not hasFS then return end
	pcall(function()
		if isfile(CachePath()) then
			local d = HttpService:JSONDecode(readfile(CachePath()))
			if type(d) == "table" then Cache = d end
		end
	end)
end
local function SaveCache()
	if not hasFS then return end
	pcall(function()
		if not isfolder(Library.Folder) then makefolder(Library.Folder) end
		writefile(CachePath(), HttpService:JSONEncode(Cache))
	end)
end

function Library.Translate(text)
	local code = LangCode[Library.Language]
	if code == "en" or not text or text == "" then return text end
	local d = Dict[text]
	if d and d[code] then return d[code] end
	if Cache[code] and Cache[code][text] then return Cache[code][text] end
	return nil
end

local function TrApply(e)
	local shown = e.text
	if not e.notr then
		local tr = Library.Translate(e.text)
		if tr then
			shown = tr
		else
			Library._Queue(e.text)
		end
	end
	if e.fmt then
		local ok, r = pcall(e.fmt, shown)
		if ok then shown = r end
	end
	pcall(function() e.obj[e.prop] = shown end)
end

local function Fetch(text, code)
	if not httpRequest then return nil end
	local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. code .. "&dt=t&q=" .. HttpService:UrlEncode(text)
	local ok, res = pcall(httpRequest, {Url = url, Method = "GET"})
	if not ok or type(res) ~= "table" or res.StatusCode ~= 200 then return nil end
	local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
	if not ok2 or type(data) ~= "table" or type(data[1]) ~= "table" then return nil end
	local out = {}
	for _, seg in ipairs(data[1]) do
		if type(seg) == "table" and type(seg[1]) == "string" then out[#out + 1] = seg[1] end
	end
	if #out == 0 then return nil end
	return table.concat(out)
end

function Library._Queue(text)
	local code = LangCode[Library.Language]
	if code == "en" or not httpRequest or text == "" then return end
	local key = code .. "\0" .. text
	if Pending[key] then return end
	if Cache[code] and Cache[code][text] then return end
	Pending[key] = true
	Queue[#Queue + 1] = {text = text, code = code, key = key}
	if Working then return end
	Working = true
	task.spawn(function()
		while #Queue > 0 and not Library.Unloaded do
			local it = table.remove(Queue, 1)
			local res = Fetch(it.text, it.code)
			Pending[it.key] = nil
			if res then
				Cache[it.code] = Cache[it.code] or {}
				Cache[it.code][it.text] = res
				for i = #TrList, 1, -1 do
					local e = TrList[i]
					if e.text == it.text and e.obj.Parent then TrApply(e) end
				end
			end
			task.wait(0.08)
		end
		Working = false
		SaveCache()
	end)
end

function Library:Bind(obj, prop, text, fmt, notr)
	local e = {obj = obj, prop = prop, text = text or "", fmt = fmt, notr = notr}
	function e:Set(t) self.text = t; TrApply(self) end
	TrList[#TrList + 1] = e
	TrApply(e)
	return e
end

function Library:SetLanguage(name)
	if not LangCode[name] then return end
	self.Language = name
	for i = #TrList, 1, -1 do
		local e = TrList[i]
		if not e.obj.Parent then table.remove(TrList, i) else TrApply(e) end
	end
end

------------------------------------------------------------------ icons / logo
local IconsMod
local function LoadIcons()
	pcall(function()
		IconsMod = loadstring(game:HttpGet(ICONS_URL))()
		IconsMod.Load(Library.IconSet)
	end)
end

local function ResolveIcon(name)
	if not name then return nil end
	if type(name) == "number" then return {Image = "rbxassetid://" .. name} end
	if name:find("rbxasset") then return {Image = name} end
	if name:match("^%d+$") then return {Image = "rbxassetid://" .. name} end
	if not IconsMod then return nil end
	local lib
	pcall(function() lib = IconsMod.GetLibrary(Library.IconSet) end)
	local v
	if type(lib) == "table" then v = lib[name] or lib[name:lower()] end
	if v == nil then pcall(function() v = IconsMod.GetIcon(name, Library.IconSet) end) end
	if type(v) == "number" then v = "rbxassetid://" .. v end
	if type(v) == "string" then
		if v:match("^%d+$") then v = "rbxassetid://" .. v end
		return {Image = v}
	elseif type(v) == "table" then
		local img = v.Image or v.image or v.Icon or v.icon or v.Asset or v.asset or v.Id or v.id
		if type(img) == "number" then img = "rbxassetid://" .. img end
		local ro = v.ImageRectOffset or v.ImageRectPosition or v.Position or v.position
		local rs = v.ImageRectSize or v.Size or v.size
		if type(ro) == "table" and typeof(ro) ~= "Vector2" then ro = Vector2.new(ro[1] or ro.X or 0, ro[2] or ro.Y or 0) end
		if type(rs) == "table" and typeof(rs) ~= "Vector2" then rs = Vector2.new(rs[1] or rs.X or 0, rs[2] or rs.Y or 0) end
		if img then return {Image = img, Offset = typeof(ro) == "Vector2" and ro or nil, Size = typeof(rs) == "Vector2" and rs or nil} end
	end
	return nil
end

local function Icon(parent, name, size, key, glyph)
	local img = New("ImageLabel", {Name = "Icon", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), ScaleType = Enum.ScaleType.Fit, Parent = parent})
	Themed(img, {ImageColor3 = key or "Text"})
	local r = ResolveIcon(name)
	if r and r.Image then
		img.Image = r.Image
		if r.Offset then img.ImageRectOffset = r.Offset end
		if r.Size then img.ImageRectSize = r.Size end
	elseif glyph then
		local t = New("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = glyph, Font = Enum.Font.GothamBold, TextSize = size, Parent = img})
		Themed(t, {TextColor3 = key or "Text"})
	end
	return img
end

local function GetLogo()
	if not (hasFS and getcustomasset and httpRequest) then return nil end
	local ok, res = pcall(function()
		if not isfolder(Library.Folder) then makefolder(Library.Folder) end
		local path = Library.Folder .. "/logo.gif"
		if not isfile(path) then
			local r = httpRequest({Url = LOGO_URL, Method = "GET"})
			if r and r.Body and #r.Body > 10 then writefile(path, r.Body) end
		end
		if isfile(path) then return getcustomasset(path) end
	end)
	if ok then return res end
	return nil
end

------------------------------------------------------------------ primitives
local function L(parent, text, size, key, bold, tr)
	local l = New("TextLabel", {BackgroundTransparency = 1, Font = bold and Library.FontBold or Library.Font, TextSize = size or 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", Parent = parent})
	Themed(l, {TextColor3 = key or "Text"})
	local e
	if tr == false then l.Text = text or "" else e = Library:Bind(l, "Text", text or "") end
	return l, e
end

local function Hit(parent)
	return New("TextButton", {Name = "Hit", BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 3, AutoButtonColor = false, Parent = parent})
end

local function Press(hit, scale)
	Connect(hit.MouseButton1Down, function() Tween(scale, {Scale = 0.97}, 0.08) end)
	local function up() Tween(scale, {Scale = 1}, 0.18, Enum.EasingStyle.Back) end
	Connect(hit.MouseButton1Up, up)
	Connect(hit.MouseLeave, up)
end

local function Ripple(host)
	if Library.ReduceEffects then return end
	local m = UIS:GetMouseLocation()
	local sc = Library.CurrentScale or 1
	local rel = (m - host.AbsolutePosition) / sc
	local size = math.max(host.AbsoluteSize.X, host.AbsoluteSize.Y) / sc * 2.2
	local r = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(rel.X, rel.Y), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 6, Parent = host})
	Themed(r, {BackgroundColor3 = "Accent2"})
	Corner(r, 1000)
	Tween(r, {Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1}, 0.6)
	task.delay(0.65, function() r:Destroy() end)
end

local function DragArea(frame, fn, onState)
	local active = false
	local function upd()
		local m = UIS:GetMouseLocation()
		local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
		fn(Clamp((m.X - ap.X) / math.max(as.X, 1), 0, 1), Clamp((m.Y - ap.Y) / math.max(as.Y, 1), 0, 1))
	end
	local function state(v) active = v; if onState then onState(v) end end
	Connect(frame.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then state(true); upd() end
	end)
	Connect(UIS.InputChanged, function(i)
		if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd() end
	end)
	Connect(UIS.InputEnded, function(i)
		if active and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then state(false) end
	end)
end

local function MakeDraggable(handle, target, opts)
	opts = opts or {}
	local st
	Connect(handle.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			st = {start = i.Position, pos = target.Position, moved = false}
		end
	end)
	Connect(UIS.InputChanged, function(i)
		if st and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - st.start
			if not st.moved and d.Magnitude > (opts.threshold or 0) then st.moved = true end
			if st.moved then
				target.Position = UDim2.new(st.pos.X.Scale, st.pos.X.Offset + d.X, st.pos.Y.Scale, st.pos.Y.Offset + d.Y)
			end
		end
	end)
	Connect(UIS.InputEnded, function(i)
		if st and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			local was = st
			st = nil
			if not was.moved and opts.onClick then opts.onClick() end
		end
	end)
end

local function MakeCircular(parent, size, thick)
	thick = thick or 6
	local root = New("Frame", {Name = "Circular", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent})
	local track = New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -2 * thick, 1, -2 * thick), Position = UDim2.fromOffset(thick, thick), Parent = root})
	Corner(track, size)
	Themed(New("UIStroke", {Thickness = thick, Transparency = 0.8, Parent = track}), {Color = "Stroke"})
	local function half(right)
		local clip = New("Frame", {BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(right and 0.5 or 0, 0, 0, 0), Parent = root})
		local rg = New("Frame", {BackgroundTransparency = 1, Size = UDim2.new(2, -2 * thick, 1, -2 * thick), Position = UDim2.new(right and -1 or 0, thick, 0, thick), Parent = clip})
		Corner(rg, size)
		local st = New("UIStroke", {Thickness = thick, Parent = rg})
		return Themed(New("UIGradient", {Parent = st}), {Color = Grad2})
	end
	local gR, gL = half(true), half(false)
	local halfSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.501, 1), NumberSequenceKeypoint.new(1, 1)})
	local full, none = NumberSequence.new(0), NumberSequence.new(1)
	local function set(p)
		local a = Clamp(p, 0, 1) * 360
		if a <= 180 then
			gR.Transparency = halfSeq; gR.Rotation = a; gL.Transparency = none
		else
			gR.Transparency = full; gL.Transparency = halfSeq; gL.Rotation = a
		end
	end
	set(0)
	local nv = Instance.new("NumberValue")
	nv.Changed:Connect(set)
	root.Destroying:Connect(function() nv:Destroy() end)
	local obj = {Frame = root, Value = 0}
	function obj:Set(p, instant)
		self.Value = p
		if instant then nv.Value = p else Tween(nv, {Value = p}, 0.45) end
	end
	return obj
end

local function MakeBar(parent, h)
	local bg = New("Frame", {Size = UDim2.new(1, 0, 0, h or 8), BorderSizePixel = 0, Parent = parent})
	Themed(bg, {BackgroundColor3 = "Stroke"})
	Corner(bg, 8)
	local fill = New("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = bg})
	Corner(fill, 8)
	local g = Themed(New("UIGradient", {Parent = fill}), {Color = Grad3})
	Library.AnimGradients[#Library.AnimGradients + 1] = g
	local obj = {Frame = bg, Fill = fill}
	function obj:Set(p) Tween(fill, {Size = UDim2.fromScale(Clamp(p, 0, 1), 1)}, 0.35) end
	return obj
end

------------------------------------------------------------------ gui root & overlays
function Library:_EnsureGui()
	if self.Gui and self.Gui.Parent then return self.Gui end
	local g = Instance.new("ScreenGui")
	g.Name = HttpService:GenerateGUID(false):sub(1, 12)
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = 999999
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	if syn and syn.protect_gui then pcall(syn.protect_gui, g) end
	local parent = (gethui and gethui()) or ((pcall(function() return CoreGui.Name end)) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
	g.Parent = parent
	self.Gui = g
	self.NotifHolder = New("Frame", {Name = "Notifs", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 300, 1, -32), BackgroundTransparency = 1, ZIndex = 60, Parent = g})
	New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = self.NotifHolder})
	return g
end

function Library:Notify(opt)
	if type(opt) == "string" then opt = {Content = opt} end
	opt = opt or {}
	if not self.Notifications and not opt.Force then return end
	self:_EnsureGui()
	local kind = opt.Type or "info"
	local key = ({info = "Accent2", success = "Success", warning = "Warning", error = "Error"})[kind] or "Accent2"
	local iconName = opt.Icon or ({info = "info", success = "check-circle", warning = "alert-triangle", error = "x-circle"})[kind] or "info"
	local dur = opt.Duration or 4
	self.NotifCount = self.NotifCount + 1
	local wrap = New("Frame", {Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, LayoutOrder = self.NotifCount, Parent = self.NotifHolder})
	local card = New("Frame", {Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 330, 0, 0), BorderSizePixel = 0, ClipsDescendants = true, Parent = wrap})
	Themed(card, {BackgroundColor3 = "Surface"})
	Corner(card, 10)
	Stroke(card, key, 1.2, 0.35)
	local bar = New("Frame", {Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, Parent = card})
	Themed(bar, {BackgroundColor3 = key})
	local ic = Icon(card, iconName, 20, key, "!")
	ic.Position = UDim2.fromOffset(14, 12)
	local t = L(card, opt.Title or "Notification", 13, "Text", true, opt.Translate)
	t.Position = UDim2.fromOffset(42, 8); t.Size = UDim2.new(1, -52, 0, 16)
	local c = L(card, opt.Content or "", 11, "SubText", false, opt.Translate)
	c.Position = UDim2.fromOffset(42, 26); c.Size = UDim2.new(1, -52, 0, 30); c.TextWrapped = true; c.TextYAlignment = Enum.TextYAlignment.Top; c.TextTruncate = Enum.TextTruncate.AtEnd
	local prog = New("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, Parent = card})
	Themed(prog, {BackgroundColor3 = key})
	local hit = Hit(card)
	local closed = false
	local function close()
		if closed then return end
		closed = true
		Tween(card, {Position = UDim2.new(1, 330, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.32, function() wrap:Destroy() end)
	end
	Connect(hit.MouseButton1Click, close)
	Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.45, Enum.EasingStyle.Back)
	Tween(prog, {Size = UDim2.new(0, 0, 0, 2)}, dur, Enum.EasingStyle.Linear)
	task.delay(dur, close)
	local n = 0
	for _, ch in ipairs(self.NotifHolder:GetChildren()) do if ch:IsA("Frame") then n = n + 1 end end
	if n > 5 then
		local oldest, lo
		for _, ch in ipairs(self.NotifHolder:GetChildren()) do
			if ch:IsA("Frame") and (not lo or ch.LayoutOrder < lo) then oldest, lo = ch, ch.LayoutOrder end
		end
		if oldest then oldest:Destroy() end
	end
	return {Close = close}
end

function Library:ShowTooltip(text)
	if not text or text == "" then return end
	self:_EnsureGui()
	if not self.Tip then
		local f = New("Frame", {AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Visible = false, ZIndex = 120, Parent = self.Gui})
		Themed(f, {BackgroundColor3 = "Surface"})
		f.BackgroundTransparency = 0.05
		Corner(f, 6)
		Stroke(f, "Accent", 1, 0.3)
		New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), Parent = f})
		local l = New("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Font = self.Font, TextSize = 12, Text = "", Parent = f})
		Themed(l, {TextColor3 = "Text"})
		self.Tip = {Frame = f, Label = l}
		self:_OnFrame(function()
			if f.Visible then
				local m = UIS:GetMouseLocation()
				f.Position = UDim2.fromOffset(m.X + 14, m.Y + 16)
			end
		end)
	end
	self.TipToken = (self.TipToken or 0) + 1
	local tk = self.TipToken
	task.delay(0.35, function()
		if self.TipToken == tk and self.Tip and not self.Unloaded then
			local tr = self.Translate(text)
			self.Tip.Label.Text = tr or text
			self.Tip.Frame.Visible = true
		end
	end)
end

function Library:HideTooltip()
	self.TipToken = (self.TipToken or 0) + 1
	if self.Tip then self.Tip.Frame.Visible = false end
end

function Library:ClosePopover()
	if self.PopCleanup then self.PopCleanup() end
end

function Library:Popover(pos, width)
	self:ClosePopover()
	self:_EnsureGui()
	local f = New("Frame", {Position = UDim2.fromOffset(pos.X, pos.Y), Size = UDim2.fromOffset(width or 170, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 90, Parent = self.Gui})
	Themed(f, {BackgroundColor3 = "Surface"})
	Corner(f, 8)
	Stroke(f, "Accent", 1, 0.4)
	New("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = f})
	New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
	local conn
	local function cleanup()
		if conn then conn:Disconnect(); conn = nil end
		if f then f:Destroy(); f = nil end
		self.PopCleanup = nil
	end
	self.PopCleanup = cleanup
	task.delay(0.1, function()
		if not f then return end
		conn = UIS.InputBegan:Connect(function(i)
			if not f then return end
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.Touch then
				local m = UIS:GetMouseLocation()
				local ap, as = f.AbsolutePosition, f.AbsoluteSize
				if m.X < ap.X or m.X > ap.X + as.X or m.Y < ap.Y or m.Y > ap.Y + as.Y then cleanup() end
			end
		end)
	end)
	task.defer(function()
		if not f then return end
		local vp = self.Gui.AbsoluteSize
		local as = f.AbsoluteSize
		f.Position = UDim2.fromOffset(Clamp(pos.X, 8, vp.X - as.X - 8), Clamp(pos.Y, 8, vp.Y - as.Y - 8))
	end)
	return f, cleanup
end

function Library:ContextMenu(items, pos)
	pos = pos or UIS:GetMouseLocation()
	local f, close = self:Popover(pos, 180)
	for i, it in ipairs(items or {}) do
		local b = New("TextButton", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = f})
		Themed(b, {BackgroundColor3 = "Accent"})
		Corner(b, 6)
		local x = 8
		if it.Icon then
			local ic = Icon(b, it.Icon, 14, "SubText")
			ic.Position = UDim2.fromOffset(8, 7)
			x = 30
		end
		local lb = L(b, it.Title or "Item", 12, "Text", false, it.Translate)
		lb.Position = UDim2.fromOffset(x, 0); lb.Size = UDim2.new(1, -x - 8, 1, 0)
		Connect(b.MouseEnter, function() Tween(b, {BackgroundTransparency = 0.7}, 0.12) end)
		Connect(b.MouseLeave, function() Tween(b, {BackgroundTransparency = 1}, 0.12) end)
		Connect(b.MouseButton1Click, function() close(); Fire(it.Callback) end)
	end
	return f
end

function Library:Dialog(opt)
	opt = opt or {}
	self:_EnsureGui()
	local dim = New("TextButton", {Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 100, Parent = self.Gui})
	Tween(dim, {BackgroundTransparency = 0.5}, 0.2)
	local card = New("CanvasGroup", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(340, 0), AutomaticSize = Enum.AutomaticSize.Y, GroupTransparency = 1, BorderSizePixel = 0, Parent = dim})
	Themed(card, {BackgroundColor3 = "Surface"})
	Corner(card, 12)
	Stroke(card, "Accent", 1.5, 0.3)
	local sc = New("UIScale", {Scale = 0.88, Parent = card})
	Tween(sc, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
	Tween(card, {GroupTransparency = 0}, 0.2)
	New("UIPadding", {PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = card})
	New("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card})
	local t = L(card, opt.Title or "Confirm", 15, "Text", true, opt.Translate)
	t.Size = UDim2.new(1, 0, 0, 20); t.LayoutOrder = 1
	local c = L(card, opt.Content or "", 12, "SubText", false, opt.Translate)
	c.Size = UDim2.new(1, 0, 0, 0); c.AutomaticSize = Enum.AutomaticSize.Y; c.TextWrapped = true; c.TextTruncate = Enum.TextTruncate.None; c.LayoutOrder = 2
	local row = New("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 3, Parent = card})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
	local function close()
		Tween(dim, {BackgroundTransparency = 1}, 0.2)
		Tween(card, {GroupTransparency = 1}, 0.2)
		Tween(sc, {Scale = 0.9}, 0.2)
		task.delay(0.25, function() dim:Destroy() end)
	end
	for i, b in ipairs(opt.Buttons or {{Title = "OK", Primary = true}}) do
		local btn = New("TextButton", {Size = UDim2.fromOffset(96, 34), BackgroundTransparency = b.Primary and 0 or 0.3, Text = "", AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = i, Parent = row})
		Themed(btn, {BackgroundColor3 = b.Primary and "Accent" or "Element"})
		Corner(btn, 8)
		local lb = L(btn, b.Title or "OK", 12, b.Primary and "Text" or "Text", true, b.Translate)
		lb.Size = UDim2.fromScale(1, 1); lb.TextXAlignment = Enum.TextXAlignment.Center
		Connect(btn.MouseButton1Click, function() Ripple(btn); close(); Fire(b.Callback) end)
	end
	return {Close = close}
end

function Library:Confirm(title, content, onYes, onNo)
	return self:Dialog({Title = title, Content = content, Buttons = {
		{Title = "Cancel", Callback = onNo},
		{Title = "Confirm", Primary = true, Callback = onYes},
	}})
end

function Library:AddCommand(title, run, category, row)
	self.Commands[#self.Commands + 1] = {Title = title, Run = run, Category = category or "Action", Row = row}
end

function Library:ClosePalette()
	if self.PaletteClose then self.PaletteClose() end
end

function Library:OpenPalette()
	if self.Palette then self:ClosePalette(); return end
	self:_EnsureGui()
	local dim = New("TextButton", {Name = "Palette", Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 95, Parent = self.Gui})
	Tween(dim, {BackgroundTransparency = 0.55}, 0.2)
	local card = New("CanvasGroup", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.fromOffset(380, 310), GroupTransparency = 1, BorderSizePixel = 0, Parent = dim})
	Themed(card, {BackgroundColor3 = "Surface"})
	Corner(card, 12)
	Stroke(card, "Accent", 1.5, 0.3)
	local sc = New("UIScale", {Scale = 0.92, Parent = card})
	Tween(sc, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
	Tween(card, {GroupTransparency = 0}, 0.2)
	local ic = Icon(card, "search", 18, "Accent2", "?")
	ic.Position = UDim2.fromOffset(14, 13)
	local box = New("TextBox", {Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -56, 0, 44), BackgroundTransparency = 1, Text = "", ClearTextOnFocus = false, PlaceholderText = "Type a command...", Font = self.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = card})
	Themed(box, {TextColor3 = "Text", PlaceholderColor3 = "SubText"})
	local line = New("Frame", {Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, Parent = card})
	Themed(line, {BackgroundColor3 = "Stroke"})
	local list = New("ScrollingFrame", {Position = UDim2.fromOffset(6, 50), Size = UDim2.new(1, -12, 1, -56), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = card})
	New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})
	local items, rows, sel = {}, {}, 1
	local function paint()
		for i, r in ipairs(rows) do
			Tween(r, {BackgroundTransparency = i == sel and 0.6 or 1}, 0.1)
		end
		if rows[sel] then
			local y = rows[sel].AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y
			if y < list.CanvasPosition.Y then list.CanvasPosition = Vector2.new(0, y)
			elseif y + 30 > list.CanvasPosition.Y + list.AbsoluteSize.Y then list.CanvasPosition = Vector2.new(0, y + 30 - list.AbsoluteSize.Y) end
		end
	end
	local function close()
		if not self.Palette then return end
		self.Palette = nil
		self.PaletteClose = nil
		if self.PaletteConn then self.PaletteConn:Disconnect(); self.PaletteConn = nil end
		Tween(dim, {BackgroundTransparency = 1}, 0.15)
		Tween(card, {GroupTransparency = 1}, 0.15)
		task.delay(0.2, function() dim:Destroy() end)
	end
	local function run(it)
		close()
		if it then Fire(it.Run) end
	end
	local function render()
		for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		rows = {}
		for i = #self.Commands, 1, -1 do
			local c = self.Commands[i]
			if c.Row and not c.Row.Parent then table.remove(self.Commands, i) end
		end
		local q = box.Text:lower()
		items = {}
		for _, c in ipairs(self.Commands) do
			local shown = (self.Translate(c.Title) or c.Title):lower()
			if q == "" or shown:find(q, 1, true) or c.Title:lower():find(q, 1, true) then items[#items + 1] = c end
		end
		sel = Clamp(sel, 1, math.max(#items, 1))
		for i = 1, math.min(#items, 50) do
			local it = items[i]
			local b = New("TextButton", {Size = UDim2.new(1, -4, 0, 30), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = list})
			Themed(b, {BackgroundColor3 = "Accent"})
			Corner(b, 6)
			local lb = L(b, it.Title, 12, "Text", false)
			lb.Position = UDim2.fromOffset(10, 0); lb.Size = UDim2.new(1, -90, 1, 0)
			local cat = L(b, it.Category, 10, "SubText", false)
			cat.AnchorPoint = Vector2.new(1, 0); cat.Position = UDim2.new(1, -10, 0, 0); cat.Size = UDim2.new(0, 70, 1, 0); cat.TextXAlignment = Enum.TextXAlignment.Right
			Connect(b.MouseEnter, function() sel = i; paint() end)
			Connect(b.MouseButton1Click, function() run(it) end)
			rows[i] = b
		end
		paint()
	end
	self.Palette = card
	self.PaletteClose = close
	Connect(dim.MouseButton1Click, function()
		local m = UIS:GetMouseLocation()
		local ap, as = card.AbsolutePosition, card.AbsoluteSize
		if m.X < ap.X or m.X > ap.X + as.X or m.Y < ap.Y or m.Y > ap.Y + as.Y then close() end
	end)
	Connect(box:GetPropertyChangedSignal("Text"), function() sel = 1; render() end)
	Connect(box.FocusLost, function(enter) if enter then run(items[sel]) end end)
	self.PaletteConn = UIS.InputBegan:Connect(function(i)
		if i.KeyCode == Enum.KeyCode.Escape then close()
		elseif i.KeyCode == Enum.KeyCode.Down then sel = math.min(sel + 1, #rows); paint()
		elseif i.KeyCode == Enum.KeyCode.Up then sel = math.max(sel - 1, 1); paint() end
	end)
	render()
	task.defer(function() box:CaptureFocus() end)
end

------------------------------------------------------------------ config system
function Library:_EnsureFolders()
	if not hasFS then return false end
	pcall(function()
		if not isfolder(self.Folder) then makefolder(self.Folder) end
		if not isfolder(self.Folder .. "/Configs") then makefolder(self.Folder .. "/Configs") end
	end)
	return true
end

local function Ser(v)
	local t = typeof(v)
	if t == "Color3" then return {__t = "c", r = v.R, g = v.G, b = v.B} end
	if t == "EnumItem" then return {__t = "k", n = v.Name} end
	return v
end

local function Des(v)
	if type(v) == "table" and v.__t == "c" then return Color3.new(v.r, v.g, v.b) end
	if type(v) == "table" and v.__t == "k" then
		if not v.n then return nil end
		local ok, k = pcall(function() return Enum.KeyCode[v.n] end)
		return ok and k or nil
	end
	return v
end

local function CleanName(n)
	n = tostring(n or "")
	n = n:gsub("[^%w%-%_ ]", "")
	return n
end

function Library:ListConfigs()
	local out = {}
	if not (hasFS and listfiles) then return out end
	self:_EnsureFolders()
	pcall(function()
		for _, p in ipairs(listfiles(self.Folder .. "/Configs")) do
			local n = p:match("([^/\\]+)%.json$")
			if n then out[#out + 1] = n end
		end
	end)
	table.sort(out)
	return out
end

function Library:SaveConfig(name, silent)
	name = CleanName(name)
	if name == "" then self:Notify({Title = "Configure", Content = "Enter a configure name first.", Type = "warning"}); return false end
	if not self:_EnsureFolders() then self:Notify({Title = "Configure", Content = "Your executor does not support file saving.", Type = "error"}); return false end
	local data = {}
	for flag, o in pairs(self.Flags) do
		if not o.NoSave and o.Get then
			local ok, v = pcall(o.Get, o)
			if ok and v ~= nil then data[flag] = Ser(v) end
		end
	end
	local ok, err = pcall(function() writefile(self.Folder .. "/Configs/" .. name .. ".json", HttpService:JSONEncode(data)) end)
	if not ok then self:Log("Save failed: " .. tostring(err), "error"); return false end
	self.ConfigName = name
	self:Log("Configure saved: " .. name, "success")
	if not silent then self:Notify({Title = "Configure", Content = "Saved \"" .. name .. "\"", Type = "success"}) end
	if self.OnConfigsChanged then pcall(self.OnConfigsChanged) end
	return true
end

function Library:LoadConfig(name, silent)
	name = CleanName(name)
	local path = self.Folder .. "/Configs/" .. name .. ".json"
	if not (hasFS and isfile(path)) then
		if not silent then self:Notify({Title = "Configure", Content = "Config not found.", Type = "error"}) end
		return false
	end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(data) ~= "table" then self:Notify({Title = "Configure", Content = "Config file is corrupted.", Type = "error"}); return false end
	self._loading = true
	local th = self.Flags["UI.Theme"]
	if th and data["UI.Theme"] ~= nil then pcall(th.Set, th, Des(data["UI.Theme"])) end
	for flag, v in pairs(data) do
		local o = self.Flags[flag]
		if o and o.Set and flag ~= "UI.Theme" then pcall(o.Set, o, Des(v)) end
	end
	self._loading = false
	self.ConfigName = name
	self:Log("Configure loaded: " .. name, "success")
	if not silent then self:Notify({Title = "Configure", Content = "Loaded \"" .. name .. "\"", Type = "success"}) end
	return true
end

function Library:DeleteConfig(name)
	name = CleanName(name)
	local path = self.Folder .. "/Configs/" .. name .. ".json"
	if hasFS and delfile and isfile(path) then
		pcall(delfile, path)
		self:Notify({Title = "Configure", Content = "Deleted \"" .. name .. "\"", Type = "warning"})
		self:Log("Configure deleted: " .. name, "warn")
		if self.OnConfigsChanged then pcall(self.OnConfigsChanged) end
		return true
	end
	self:Notify({Title = "Configure", Content = "Config not found.", Type = "error"})
	return false
end

function Library:ResetConfig()
	self._loading = true
	for _, o in pairs(self.Flags) do
		if not o.NoSave and o.Set and o.Default ~= nil then pcall(o.Set, o, o.Default) end
	end
	self._loading = false
	self:Notify({Title = "Configure", Content = "Reset to defaults.", Type = "info"})
end

function Library:_Changed()
	if not self.AutoSave or self._loading then return end
	self._saveToken = (self._saveToken or 0) + 1
	local tk = self._saveToken
	task.delay(1.2, function()
		if tk == self._saveToken and self.AutoSave and not self.Unloaded then self:SaveConfig(self.ConfigName, true) end
	end)
end

function Library:SetAutoLoad(v)
	self.AutoLoad = v
	if not hasFS then return end
	pcall(function()
		self:_EnsureFolders()
		if v then writefile(self.Folder .. "/autoload.txt", self.ConfigName) elseif isfile(self.Folder .. "/autoload.txt") then delfile(self.Folder .. "/autoload.txt") end
	end)
end

function Library:GetKeybinds()
	local out = {}
	for _, kb in ipairs(self.Keybinds) do
		if kb.Key then out[#out + 1] = {Name = kb.Name, Key = kb.Key.Name} end
	end
	return out
end

function Library:Unload()
	if self.Unloaded then return end
	self.Unloaded = true
	for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
	self.Connections = {}
	if self.PaletteConn then pcall(function() self.PaletteConn:Disconnect() end) end
	if self.Blur then pcall(function() self.Blur:Destroy() end) end
	if self.Gui then pcall(function() self.Gui:Destroy() end) end
	if env.AsterveilUI == self then env.AsterveilUI = nil end
end

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

local TextService = game:GetService("TextService")

-- Tag / badge: text is always centered, width follows the text (or Width / MaxWidth)
local function MakeTag(parent, spec, ts)
	if type(spec) == "string" then spec = {Text = spec} end
	ts = ts or 10
	local key = spec.Color or "Accent"
	local frame = New("Frame", {Name = "Tag", AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, ts + 6), BackgroundTransparency = 0.82, BorderSizePixel = 0, ClipsDescendants = true, Parent = parent})
	local st = New("UIStroke", {Thickness = 1, Transparency = 0.55, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame})
	if typeof(key) == "Color3" then
		frame.BackgroundColor3 = key; st.Color = key
	else
		Themed(frame, {BackgroundColor3 = key}); Themed(st, {Color = key})
	end
	Corner(frame, 100)
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame})
	New("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = frame})
	if spec.Width then frame.AutomaticSize = Enum.AutomaticSize.None; frame.Size = UDim2.fromOffset(spec.Width, ts + 6) end
	if spec.Icon then
		local ic = Icon(frame, spec.Icon, ts + 1, typeof(key) == "string" and key or "Accent", "•")
		ic.LayoutOrder = 1
		if typeof(key) == "Color3" then ic.ImageColor3 = key end
	end
	local label = New("TextLabel", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), Font = Library.FontBold, TextSize = ts, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", LayoutOrder = 2, Parent = frame})
	if typeof(key) == "Color3" then label.TextColor3 = key else Themed(label, {TextColor3 = key}) end
	local function fit(text)
		if spec.MaxWidth then
			local w = TextService:GetTextSize(text, ts, Library.FontBold, Vector2.new(1e4, 100)).X
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Size = UDim2.new(0, math.min(w + 1, spec.MaxWidth), 1, 0)
		end
	end
	local bind
	if spec.Translate == false then label.Text = spec.Text or ""; fit(label.Text) else bind = Library:Bind(label, "Text", spec.Text or "") end
	local tag = {Frame = frame, Label = label}
	function tag:Set(t) if bind then bind:Set(t) else label.Text = t; fit(t) end end
	function tag:SetVisible(v) frame.Visible = v end
	return tag
end

local function TagList(opt)
	local list = {}
	if opt.Tag then list[#list + 1] = opt.Tag end
	for _, t in ipairs(opt.Tags or {}) do list[#list + 1] = t end
	return list
end

local function LockedNotice(o)
	Library:Notify({Title = "Locked", Content = o.LockReason or "This feature is locked.", Type = "warning", Duration = 2.5})
end

local function Pad(R, right)
	R.Bar.Size = UDim2.new(1, -(12 + right), R.Bar.Size.Y.Scale, R.Bar.Size.Y.Offset)
	if R.Desc then R.Desc.Size = UDim2.new(1, -(12 + right), R.Desc.Size.Y.Scale, R.Desc.Size.Y.Offset) end
end

local function LockScroll(self, v)
	local sc = self.Tab and self.Tab.Scroll
	if sc then sc.ScrollingEnabled = not v end
end

function Mixin:_Kid(m)
	self._kids = self._kids or {}
	table.insert(self._kids, m)
	if self.Locked then task.defer(function() m:SetLocked(true, self.LockReason) end) end
	return m
end

function Mixin:SetLocked(v, reason)
	self.Locked = v and true or false
	self.LockReason = reason
	for _, o in ipairs(self._objs or {}) do
		if o.Row and o.Row.Parent then o:SetLocked(v, reason) end
	end
	for _, k in ipairs(self._kids or {}) do k:SetLocked(v, reason) end
	if self.OnLockChanged then pcall(self.OnLockChanged, v, reason) end
end
function Mixin:Lock(reason) self:SetLocked(true, reason) end
function Mixin:Unlock() self:SetLocked(false) end

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
	local bar = New("Frame", {Name = "TitleBar", BackgroundTransparency = 1, ClipsDescendants = true, Parent = row})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = bar})
	local title, tb = L(bar, opt.Title or opt.Name or "", 13, "Text", true, opt.Translate)
	title.AutomaticSize = Enum.AutomaticSize.X; title.Size = UDim2.new(0, 0, 1, 0); title.TextTruncate = Enum.TextTruncate.None; title.LayoutOrder = 1
	New("UITextSizeConstraint", {MaxTextSize = 16, MinTextSize = 9, Parent = title})
	local tags = {}
	for i, t in ipairs(TagList(opt)) do
		local tg = MakeTag(bar, t, 10)
		tg.Frame.LayoutOrder = 1 + i
		tags[#tags + 1] = tg
	end
	local desc, db
	if hasDesc then
		bar.Position = UDim2.fromOffset(12, 8); bar.Size = UDim2.new(1, -24, 0, 16)
		desc, db = L(row, opt.Description, 11, "SubText", false, opt.Translate)
		desc.Position = UDim2.fromOffset(12, 26); desc.Size = UDim2.new(1, -24, 0, 14)
	else
		bar.Position = UDim2.fromOffset(12, 0); bar.Size = UDim2.new(1, -24, 0, hh or h)
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
	return {Row = row, Bar = bar, Tags = tags, Title = title, Desc = desc, TitleBind = tb, DescBind = db, Stroke = stroke, Scale = scale}
end

function Mixin:_Obj(R, opt, o)
	o = o or {}
	local row = R.Row
	o.Row = row
	o.Options = opt
	o.Enabled = true
	self._objs = self._objs or {}
	table.insert(self._objs, o)
	local blocker = New("Frame", {Visible = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Active = true, ZIndex = 20, Parent = row})
	Corner(blocker, 8)
	local lockOv, lockBind
	function o:SetLocked(v, reason)
		o.Locked = v and true or false
		o.LockReason = reason
		if v then
			if not lockOv then
				lockOv = New("TextButton", {Name = "Lock", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = "", AutoButtonColor = false, ZIndex = 22, Parent = row})
				Corner(lockOv, 8)
				local c = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, ZIndex = 23, Parent = lockOv})
				New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c})
				local ic = Icon(c, "lock", 15, "Warning", "L")
				ic.LayoutOrder = 1
				local lb, lbd = L(c, reason or "Locked", 12, "Text", true)
				lb.AutomaticSize = Enum.AutomaticSize.X; lb.Size = UDim2.fromOffset(0, 16); lb.TextXAlignment = Enum.TextXAlignment.Center; lb.TextTruncate = Enum.TextTruncate.None; lb.LayoutOrder = 2
				lockBind = lbd
				Connect(lockOv.MouseButton1Click, function() LockedNotice(o) end)
			end
			lockBind:Set(reason or "Locked")
			lockOv.Visible = true
		elseif lockOv then
			lockOv.Visible = false
		end
	end
	function o:Lock(reason) o:SetLocked(true, reason or opt.LockReason) end
	function o:Unlock() o:SetLocked(false) end
	if self.Locked then task.defer(function() o:SetLocked(true, self.LockReason) end) end
	if opt.Locked then task.defer(function() o:SetLocked(true, opt.LockReason) end) end
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
	Library:AddCommand(opt.Title or "Button", function() if o.Locked then LockedNotice(o) else Fire(cb) end end, "Button", row)
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
	Library:AddCommand("Toggle: " .. (opt.Title or "Toggle"), function() if o.Locked then LockedNotice(o) else o:Set(not value) end end, "Toggle", row)
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
	R.Bar.Size = UDim2.new(0, 90, 0, 40)
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
	local hb = New("Frame", {Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -4, 0, 20), BackgroundTransparency = 1, Parent = head})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = hb})
	local lbl = L(hb, opt.Title or "Section", 12, "Accent2", true, opt.Translate)
	lbl.AutomaticSize = Enum.AutomaticSize.X; lbl.Size = UDim2.new(0, 0, 1, 0); lbl.TextTruncate = Enum.TextTruncate.None; lbl.LayoutOrder = 1
	for i, t in ipairs(TagList(opt)) do
		local tg = MakeTag(hb, t, 9)
		tg.Frame.LayoutOrder = 1 + i
	end
	local lk = Icon(hb, "lock", 12, "Warning", "L")
	lk.LayoutOrder = 99; lk.Visible = false
	local line = New("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = head})
	Themed(New("UIGradient", {Transparency = NumberSequence.new(0, 1), Parent = line}), {Color = Grad2})
	local m = NewMixin(sec, self.Tab, self.Window)
	m.OnLockChanged = function(v) lk.Visible = v end
	function m:SetVisible(v) sec.Visible = v end
	function m:Destroy() sec:Destroy() end
	self:_Kid(m)
	if opt.Locked then m:SetLocked(true, opt.LockReason) end
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
	self:_Kid(m)
	return m
end

function Mixin:AddGrid(opt)
	opt = opt or {}
	self._n = self._n + 1
	local g = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = self._n, Parent = self.Holder})
	local cols = opt.Columns or 2
	New("UIGridLayout", {CellSize = UDim2.new(1 / cols, -6, 0, opt.CellHeight or 40), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g})
	return self:_Kid(NewMixin(g, self.Tab, self.Window))
end

function Mixin:AddCollapsible(opt)
	if type(opt) == "string" then opt = {Title = opt} end
	opt = opt or {}
	self._n = self._n + 1
	local wrap = New("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 0.3, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = self._n, Parent = self.Holder})
	Themed(wrap, {BackgroundColor3 = "Element"})
	Corner(wrap, 8)
	Stroke(wrap, "Stroke", 1, 0.6)
	local hbar = New("Frame", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -44, 0, 38), BackgroundTransparency = 1, ClipsDescendants = true, Parent = wrap})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = hbar})
	local title = L(hbar, opt.Title or "Collapsible", 13, "Text", true, opt.Translate)
	title.AutomaticSize = Enum.AutomaticSize.X; title.Size = UDim2.new(0, 0, 1, 0); title.TextTruncate = Enum.TextTruncate.None; title.LayoutOrder = 1
	for i, t in ipairs(TagList(opt)) do
		local tg = MakeTag(hbar, t, 10)
		tg.Frame.LayoutOrder = 1 + i
	end
	local clk = Icon(hbar, "lock", 13, "Warning", "L")
	clk.LayoutOrder = 99; clk.Visible = false
	local chev = Icon(wrap, "chevron-down", 16, "SubText", "v")
	chev.AnchorPoint = Vector2.new(1, 0); chev.Position = UDim2.new(1, -12, 0, 11)
	local hit = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), ZIndex = 3, AutoButtonColor = false, Parent = wrap})
	local body = New("Frame", {Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = wrap})
	local lay = New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body})
	New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = body})
	local open = false
	local m = NewMixin(body, self.Tab, self.Window)
	m.OnLockChanged = function(v) clk.Visible = v end
	self:_Kid(m)
	if opt.Locked then task.defer(function() m:SetLocked(true, opt.LockReason) end) end
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
		local target = ((i - 1) % #names) + 1
		if subs[target] and subs[target].Locked then
			Library:Notify({Title = "Locked", Content = subs[target].LockReason or "This subtab is locked.", Type = "warning", Duration = 2.5})
			return
		end
		idx = target
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
		local ppad = New("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = p})
		Corner(p, 13)
		local plk = Icon(p, "lock", 12, "Warning", "L")
		plk.Position = UDim2.new(0, -20, 0.5, -6); plk.Visible = false
		Connect(p.MouseButton1Click, function() Ripple(p); select(i) end)
		pb[i] = p
		local f = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, LayoutOrder = order + 1, Parent = self.Holder})
		New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
		frames[i] = f
		local m = NewMixin(f, self.Tab, self.Window)
		m.OnLockChanged = function(v)
			plk.Visible = v
			Tween(ppad, {PaddingLeft = UDim.new(0, v and 28 or 14)}, 0.2)
			Tween(p, {TextTransparency = v and 0.5 or 0}, 0.2)
		end
		self:_Kid(m)
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

------------------------------------------------------------------ window
local function GetExecutor()
	local ok, n = pcall(function() return identifyexecutor() end)
	return (ok and n) and tostring(n) or "Unknown"
end

local function GetHwid()
	local ok, v = pcall(function() return gethwid() end)
	if ok and v then return tostring(v) end
	ok, v = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
	return (ok and v) and tostring(v) or "Unknown"
end

local function GetDevice()
	local ok, plat = pcall(function() return UIS:GetPlatform().Name end)
	local map = {OSX = "macOS", IOS = "iOS", XBoxOne = "Xbox", PS4 = "PlayStation", PS5 = "PlayStation"}
	local name = ok and (map[plat] or plat) or "Unknown"
	local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	return name, mobile and "smartphone" or "monitor"
end

local function FormatTime(s)
	s = math.floor(s)
	local h, m = math.floor(s / 3600), math.floor(s % 3600 / 60)
	if h > 0 then return string.format("%d:%02d:%02d", h, m, s % 60) end
	return string.format("%d:%02d", m, s % 60)
end

local function Esc(s) return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end

local function PillBtn(parent, icon, glyph, text, key)
	local b = New("TextButton", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundTransparency = 0.7, Text = "", AutoButtonColor = false, ClipsDescendants = true, Parent = parent})
	Themed(b, {BackgroundColor3 = key or "Accent"})
	Corner(b, 13)
	New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12), Parent = b})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = b})
	local ic = Icon(b, icon, 13, "Text", glyph)
	ic.LayoutOrder = 1
	local lb = L(b, text, 11, "Text", true)
	lb.AutomaticSize = Enum.AutomaticSize.X; lb.Size = UDim2.fromOffset(0, 26); lb.TextTruncate = Enum.TextTruncate.None; lb.LayoutOrder = 2
	Connect(b.MouseEnter, function() Tween(b, {BackgroundTransparency = 0.45}, 0.12) end)
	Connect(b.MouseLeave, function() Tween(b, {BackgroundTransparency = 0.7}, 0.12) end)
	Connect(b.MouseButton1Click, function() Ripple(b) end)
	return b
end

function Library:_RefreshKeybinds()
	for i = #self.Keybinds, 1, -1 do
		local k = self.Keybinds[i]
		if k.Row and not k.Row.Parent then table.remove(self.Keybinds, i) end
	end
	if self.KeybindList then
		local lines = {"Command Palette  -  Ctrl + K"}
		for _, k in ipairs(self.Keybinds) do
			if k.Key then lines[#lines + 1] = k.Name .. "  -  " .. k.Key.Name end
		end
		self.KeybindList:Set(table.concat(lines, "\n"))
	end
end

function Library:_Loader(title)
	local gui = self.Gui
	local ov = New("CanvasGroup", {Name = "Loader", Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 70, Parent = gui})
	local ring = MakeCircular(ov, 112, 7)
	ring.Frame.AnchorPoint = Vector2.new(0.5, 0.5); ring.Frame.Position = UDim2.new(0.5, 0, 0.5, -34)
	local star = New("TextLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -34), Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, Text = "✦", Font = Enum.Font.GothamBold, TextSize = 40, Parent = ov})
	Themed(star, {TextColor3 = "Accent2"})
	local t = L(ov, title or "Asterveil", 20, "Text", true, false)
	t.AnchorPoint = Vector2.new(0.5, 0); t.Position = UDim2.new(0.5, 0, 0.5, 34); t.Size = UDim2.fromOffset(300, 26); t.TextXAlignment = Enum.TextXAlignment.Center
	local s, sb = L(ov, "Starting...", 12, "SubText", false)
	s.AnchorPoint = Vector2.new(0.5, 0); s.Position = UDim2.new(0.5, 0, 0.5, 62); s.Size = UDim2.fromOffset(300, 18); s.TextXAlignment = Enum.TextXAlignment.Center
	local holder = New("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 90), Size = UDim2.fromOffset(220, 6), BackgroundTransparency = 1, Parent = ov})
	local bar = MakeBar(holder, 6)
	local obj = {}
	function obj:Set(p, text)
		ring:Set(p); bar:Set(p)
		if text then sb:Set(text) end
	end
	function obj:Close()
		Tween(ov, {GroupTransparency = 1}, 0.45)
		task.delay(0.5, function() ov:Destroy() end)
	end
	return obj
end

function Library:CreateWindow(opt)
	opt = opt or {}
	if opt.Font then self.Font = opt.Font end
	if opt.FontBold then self.FontBold = opt.FontBold end
	if opt.Folder then self.Folder = opt.Folder end
	if opt.IconSet then self.IconSet = opt.IconSet end
	if opt.ToggleKey then self.ToggleKey = opt.ToggleKey end
	if opt.ConfigName then self.ConfigName = opt.ConfigName end
	if opt.Theme then self.Theme = Theme(self.Themes[opt.Theme] or {}); self.ThemeName = opt.Theme end
	self.ShowFPS, self.ShowClock = true, true
	self.ReduceEffects = UIS.TouchEnabled and not UIS.KeyboardEnabled
	self.UseBlur = true
	self:_EnsureGui()
	self:_EnsureFolders()
	LoadCache()
	local Gui = self.Gui

	local loader = self:_Loader(opt.Title or "Asterveil")
	loader:Set(0.08, "Loading icons...")
	LoadIcons()
	loader:Set(0.35, "Downloading logo...")
	local logoAsset = opt.Logo or GetLogo()
	loader:Set(0.6, "Building interface...")

	local W, H = 660, 430
	if opt.Size then W, H = opt.Size.X.Offset, opt.Size.Y.Offset end
	local SB_W = 176
	local Window = {Library = self, Tabs = {}, SettingsTabs = {}, AllTabs = {}, History = {}, HIdx = 0, Visible = false, SizeMul = 1, InSettings = false, Title = opt.Title or "Asterveil"}
	self.Window = Window

	local Anchor = New("Frame", {Name = "Anchor", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Visible = false, Parent = Gui})
	local Container = New("Frame", {Name = "Container", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1, Parent = Anchor})
	local ScaleObj = New("UIScale", {Parent = Container})
	local Shadow = New("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 6), Size = UDim2.new(1, 80, 1, 80), BackgroundTransparency = 1, Image = SHADOW, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ImageTransparency = 0.6, ZIndex = 0, Parent = Container})
	Themed(Shadow, {ImageColor3 = "Accent"})
	local Main = New("CanvasGroup", {Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Parent = Container})
	local MainCorner = Corner(Main, 14)
	local Bg = New("Frame", {Name = "Bg", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.06, BorderSizePixel = 0, ZIndex = 1, Parent = Main})
	local BgCorner = Corner(Bg, 14)
	Themed(New("UIGradient", {Rotation = 35, Parent = Bg}), {Color = function(t)
		return ColorSequence.new({ColorSequenceKeypoint.new(0, t.Background), ColorSequenceKeypoint.new(0.55, t.Surface), ColorSequenceKeypoint.new(1, t.Background)})
	end})
	local Border = New("Frame", {Name = "Border", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 9, Parent = Container})
	local BorderCorner = Corner(Border, 14)
	local bstroke = New("UIStroke", {Thickness = 1.6, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Border})
	local bgrad = Themed(New("UIGradient", {Parent = bstroke}), {Color = Grad3})

	-- space: nebula + stars
	local blobs = {}
	for i, c in ipairs({{"Accent", 0.15, 0.2, 320}, {"Accent2", 0.85, 0.8, 280}, {"Accent3", 0.75, 0.12, 230}}) do
		local f = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(c[2], c[3]), Size = UDim2.fromOffset(c[4], c[4]), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 2, Parent = Main})
		Themed(f, {BackgroundColor3 = c[1]})
		Corner(f, 1000)
		New("UIGradient", {Rotation = 30 * i, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)}), Parent = f})
		blobs[i] = {f = f, bx = c[2], by = c[3]}
	end
	local StarLayer = New("Frame", {Name = "Stars", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, ClipsDescendants = true, Parent = Main})
	local stars = {}
	for i = 1, 56 do
		local sz = math.random(1, 3)
		local s = New("Frame", {Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = (i % 7 == 0) and C(160, 230, 255) or C(255, 255, 255), BorderSizePixel = 0, Parent = StarLayer})
		Corner(s, 3)
		stars[i] = {f = s, x = math.random(), y = math.random(), sp = math.random(3, 14) / 1000, ph = math.random() * 6.28, tw = math.random(10, 30) / 10, base = math.random(25, 80) / 100}
	end
	local nextShoot = 3
	local function ShootingStar()
		local x, y = math.random(5, 60) / 100, math.random(0, 30) / 100
		local s = New("Frame", {Size = UDim2.fromOffset(70, 2), Position = UDim2.fromScale(x, y), Rotation = 28, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.1, ZIndex = 3, Parent = StarLayer})
		New("UIGradient", {Transparency = NumberSequence.new(1, 0), Parent = s})
		Tween(s, {Position = UDim2.fromScale(x + 0.4, y + 0.45), BackgroundTransparency = 1}, 0.9, Enum.EasingStyle.Quad)
		task.delay(1, function() s:Destroy() end)
	end

	function Window:_BaseScale()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local c = Container.Size
		return Clamp(math.min((vp.X - 20) / c.X.Offset, (vp.Y - 20) / c.Y.Offset), 0.4, 1)
	end
	function Window:_ApplyScale(anim)
		local s = self:_BaseScale() * self.SizeMul
		Library.CurrentScale = s
		if anim then Tween(ScaleObj, {Scale = s}, 0.3) else ScaleObj.Scale = s end
	end
	Window:_ApplyScale()
	if workspace.CurrentCamera then
		Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() Window:_ApplyScale(true) end)
	end

	-- blur
	self.Blur = New("BlurEffect", {Size = 0, Name = HttpService:GenerateGUID(false):sub(1, 8), Parent = Lighting})
	function Window:_UpdateBlur()
		Tween(Library.Blur, {Size = (Window.Visible and Library.UseBlur) and 14 or 0}, 0.35)
	end

	------------------------------------------------ topbar
	local Topbar = New("Frame", {Name = "Topbar", Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 5, Parent = Main})
	Themed(Topbar, {BackgroundColor3 = "Surface"})
	local tline = New("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = Topbar})
	Themed(tline, {BackgroundColor3 = "Stroke"})

	local LogoWraps = {}
	local function MakeLogo(parent, size)
		local wrap = New("Frame", {Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, Parent = parent})
		local fb = New("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✦", Font = Enum.Font.GothamBold, TextSize = math.floor(size * 0.8), Parent = wrap})
		Themed(fb, {TextColor3 = "Accent2"})
		local img = New("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = logoAsset or "", ScaleType = Enum.ScaleType.Fit, ZIndex = 2, Parent = wrap})
		task.delay(3, function()
			if img.Parent and logoAsset and img.IsLoaded then fb.Visible = false end
		end)
		LogoWraps[#LogoWraps + 1] = wrap
		return wrap
	end

	local tlogo = MakeLogo(Topbar, 26)
	tlogo.Position = UDim2.fromOffset(12, 9)
	local ttitle = L(Topbar, Window.Title, 14, "Text", true, false)
	ttitle.Position = UDim2.fromOffset(46, 4); ttitle.Size = UDim2.fromOffset(170, 18)

	local tagRow = New("Frame", {Position = UDim2.fromOffset(46, 23), Size = UDim2.fromOffset(176, 16), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Topbar})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tagRow})
	local gameTag = MakeTag(tagRow, {Text = "Loading...", Icon = "gamepad-2", Color = "Accent", MaxWidth = 88, Translate = false}, 9)
	gameTag.Frame.LayoutOrder = 1
	local devName, devIcon = GetDevice()
	local devTag = MakeTag(tagRow, {Text = devName, Icon = devIcon, Color = "Accent2", Translate = false}, 9)
	devTag.Frame.LayoutOrder = 2
	for i, t in ipairs(opt.Tags or {}) do
		local tg = MakeTag(tagRow, t, 9)
		tg.Frame.LayoutOrder = 2 + i
	end
	task.spawn(function()
		local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
		local n = (ok and info and info.Name) or (game.Name ~= "" and game.Name) or "Unknown Game"
		gameTag:Set(n)
	end)
	Window.GameTag, Window.DeviceTag = gameTag, devTag

	MakeDraggable(Topbar, Anchor, {threshold = 2})

	local backBtn = SmallBtn(Topbar, "arrow-left", "←", 26, 26)
	backBtn.Position = UDim2.fromOffset(232, 9)
	local fwdBtn = SmallBtn(Topbar, "arrow-right", "→", 26, 26)
	fwdBtn.Position = UDim2.fromOffset(262, 9)
	local crumb = New("TextLabel", {Position = UDim2.fromOffset(296, 0), Size = UDim2.new(1, -296 - 106, 1, 0), BackgroundTransparency = 1, RichText = true, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", Parent = Topbar})
	Themed(crumb, {TextColor3 = "SubText"})

	local palBtn = SmallBtn(Topbar, "command", "⌘", 28, 28)
	palBtn.AnchorPoint = Vector2.new(1, 0); palBtn.Position = UDim2.new(1, -78, 0, 8)
	local minBtn = SmallBtn(Topbar, "minus", "-", 28, 28)
	minBtn.AnchorPoint = Vector2.new(1, 0); minBtn.Position = UDim2.new(1, -44, 0, 8)
	local closeBtn, closeIc = SmallBtn(Topbar, "x", "x", 28, 28)
	closeBtn.AnchorPoint = Vector2.new(1, 0); closeBtn.Position = UDim2.new(1, -10, 0, 8)
	Connect(closeBtn.MouseEnter, function() Tween(closeBtn, {BackgroundColor3 = Library.Theme.Error, BackgroundTransparency = 0.2}, 0.12) end)
	Connect(closeBtn.MouseLeave, function() Tween(closeBtn, {BackgroundColor3 = Library.Theme.Element}, 0.12) end)

	------------------------------------------------ sidebar
	local Sidebar = New("Frame", {Name = "Sidebar", Position = UDim2.fromOffset(0, 44), Size = UDim2.new(0, SB_W, 1, -68), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 4, Parent = Main})
	Themed(Sidebar, {BackgroundColor3 = "Surface"})
	local sedge = New("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = Sidebar})
	Themed(sedge, {BackgroundColor3 = "Stroke"})

	local sf = New("Frame", {Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -56, 0, 32), BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = Sidebar})
	Themed(sf, {BackgroundColor3 = "Element"})
	Corner(sf, 8)
	local sfs = Stroke(sf, "Stroke", 1, 0.6)
	local sic = Icon(sf, "search", 14, "SubText", "?")
	sic.Position = UDim2.fromOffset(9, 9)
	local sbox = New("TextBox", {Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -36, 1, 0), BackgroundTransparency = 1, Text = "", ClearTextOnFocus = false, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = sf})
	Themed(sbox, {TextColor3 = "Text", PlaceholderColor3 = "SubText"})
	Library:Bind(sbox, "PlaceholderText", "Search")
	Connect(sbox.Focused, function() Tween(sfs, {Color = Library.Theme.Accent, Transparency = 0.1}, 0.15) end)
	Connect(sbox.FocusLost, function() Tween(sfs, {Color = Library.Theme.Stroke, Transparency = 0.6}, 0.15) end)
	local setBtn, setIc = SmallBtn(Sidebar, "settings", "⚙", 32, 32)
	setBtn.AnchorPoint = Vector2.new(1, 0); setBtn.Position = UDim2.new(1, -10, 0, 10)

	local function MakeList()
		local s = New("ScrollingFrame", {Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -116), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Sidebar})
		New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = s})
		New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 2), Parent = s})
		return s
	end
	Window.TabList = MakeList()
	Window.SetList = MakeList()
	Window.SetList.Visible = false

	local backRow = New("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 0.8, Text = "", AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = 0, Parent = Window.SetList})
	Themed(backRow, {BackgroundColor3 = "Element"})
	Corner(backRow, 8)
	local bic = Icon(backRow, "chevron-left", 16, "Accent2", "‹")
	bic.Position = UDim2.fromOffset(10, 9)
	local blb = L(backRow, "Back", 13, "Text", true)
	blb.Position = UDim2.fromOffset(34, 0); blb.Size = UDim2.new(1, -40, 1, 0)

	-- user card
	local uc = New("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8), Size = UDim2.new(1, -16, 0, 50), BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = Sidebar})
	Themed(uc, {BackgroundColor3 = "Element"})
	Corner(uc, 10)
	Stroke(uc, "Stroke", 1, 0.5)
	local av = New("ImageLabel", {Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 0.4, Image = "", Parent = uc})
	Themed(av, {BackgroundColor3 = "Surface"})
	Corner(av, 17)
	New("UIAspectRatioConstraint", {AspectRatio = 1, Parent = av})
	Stroke(av, "Accent", 1.5, 0.2)
	local dot = New("Frame", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromOffset(44, 44), Size = UDim2.fromOffset(9, 9), BorderSizePixel = 0, Parent = uc})
	Themed(dot, {BackgroundColor3 = "Success"})
	Corner(dot, 5)
	local un = L(uc, LocalPlayer.DisplayName, 12, "Text", true, false)
	un.Position = UDim2.fromOffset(52, 8); un.Size = UDim2.new(1, -60, 0, 16)
	local ut = L(uc, "@" .. LocalPlayer.Name, 10, "SubText", false, false)
	ut.Position = UDim2.fromOffset(52, 25); ut.Size = UDim2.new(1, -60, 0, 14)
	task.spawn(function()
		local ok, img = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
		if ok and img then av.Image = img end
	end)

	------------------------------------------------ pages / footer
	local PageHost = New("Frame", {Name = "Pages", Position = UDim2.fromOffset(SB_W, 44), Size = UDim2.new(1, -SB_W, 1, -68), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 4, Parent = Main})
	local Footer = New("Frame", {Name = "Footer", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 5, Parent = Main})
	Themed(Footer, {BackgroundColor3 = "Surface"})
	local fline = New("Frame", {Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = Footer})
	Themed(fline, {BackgroundColor3 = "Stroke"})
	local fl = L(Footer, "", 10, "SubText", false, false)
	fl.Position = UDim2.fromOffset(12, 0); fl.Size = UDim2.new(0.5, 0, 1, 0)
	local fr = L(Footer, "Asterveil v" .. Library.Version, 10, "SubText", false, false)
	fr.AnchorPoint = Vector2.new(1, 0); fr.Position = UDim2.new(1, -30, 0, 0); fr.Size = UDim2.new(0.4, 0, 1, 0); fr.TextXAlignment = Enum.TextXAlignment.Right
	local rh = New("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "◢", Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = Footer})
	Themed(rh, {TextColor3 = "SubText"})

	local function statusText()
		local parts = {}
		if Library.ShowFPS then parts[#parts + 1] = math.floor(Library.FPS + 0.5) .. " FPS" end
		if Library.ShowClock then parts[#parts + 1] = os.date("%H:%M:%S") end
		return table.concat(parts, "  •  ")
	end

	-- resize
	local rs
	Connect(rh.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			rs = {m = UIS:GetMouseLocation(), size = Container.Size, anchor = Anchor.Position, scale = Library.CurrentScale}
		end
	end)
	Connect(UIS.InputChanged, function(i)
		if rs and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = (UIS:GetMouseLocation() - rs.m) / rs.scale
			local nw, nh = Clamp(rs.size.X.Offset + d.X, 520, 1100), Clamp(rs.size.Y.Offset + d.Y, 340, 720)
			Container.Size = UDim2.fromOffset(nw, nh)
			Anchor.Position = UDim2.new(rs.anchor.X.Scale, rs.anchor.X.Offset + (nw - rs.size.X.Offset) * rs.scale / 2, rs.anchor.Y.Scale, rs.anchor.Y.Offset + (nh - rs.size.Y.Offset) * rs.scale / 2)
		end
	end)
	Connect(UIS.InputEnded, function(i)
		if rs and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			rs = nil
			Window:_ApplyScale(true)
		end
	end)

	------------------------------------------------ tabs
	local function PaintTab(tab, anim)
		local a = tab.Active
		local t = anim and 0.2 or 0
		Tween(tab.Button, {BackgroundTransparency = a and 0.78 or 1}, t)
		Tween(tab.Bar, {Size = UDim2.fromOffset(3, a and 18 or 0)}, t)
		Tween(tab.Lbl, {TextColor3 = Library.Theme[a and "Text" or "SubText"]}, t)
		Tween(tab.Ico, {ImageColor3 = Library.Theme[a and "Accent2" or "SubText"]}, t)
	end

	function Window:_Crumb()
		local t = self.Current
		local function hex(k) return "#" .. Library.Theme[k]:ToHex() end
		local s = "<font color=\"" .. hex("Text") .. "\">" .. Esc(self.Title) .. "</font>"
		if self.InSettings then s = s .. "  <font color=\"" .. hex("Accent2") .. "\">›</font>  " .. Esc(Library.Translate("Settings") or "Settings") end
		if t then s = s .. "  <font color=\"" .. hex("Accent2") .. "\">›</font>  <font color=\"" .. hex("Accent2") .. "\">" .. Esc(t.Lbl.Text) .. "</font>" end
		crumb.Text = s
	end

	function Window:_NewTab(o, group)
		if type(o) == "string" then o = {Title = o} end
		local isSet = group == "settings"
		local list = isSet and self.SetList or self.TabList
		local tab = NewMixin(nil, nil, self)
		tab.Tab = tab; tab.Title = o.Title or "Tab"; tab.Searchables = {}; tab.Group = group or "main"; tab.Active = false
		local btn = New("TextButton", {Name = tab.Title, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = (isSet and #self.SettingsTabs or #self.Tabs) + 1, Parent = list})
		Themed(btn, {BackgroundColor3 = "Accent"})
		Corner(btn, 8)
		local bar = New("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 0), BorderSizePixel = 0, Parent = btn})
		Themed(bar, {BackgroundColor3 = "Accent2"})
		Corner(bar, 2)
		local ico = Icon(btn, o.Icon or "circle", 16, "SubText", "•")
		ico.Position = UDim2.fromOffset(12, 10)
		Themed(ico, {ImageColor3 = function(t) return tab.Active and t.Accent2 or t.SubText end})
		local tagList = TagList(o)
		local lbl = L(btn, tab.Title, 13, "SubText", true, o.Translate)
		lbl.Position = UDim2.fromOffset(38, 0); lbl.Size = UDim2.new(1, -(44 + (#tagList > 0 and 56 or 22)), 1, 0)
		Themed(lbl, {TextColor3 = function(t) return tab.Active and t.Text or t.SubText end})
		local rc = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), BackgroundTransparency = 1, Parent = btn})
		New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rc})
		for i, t in ipairs(tagList) do
			local tg = MakeTag(rc, t, 9)
			tg.Frame.LayoutOrder = i
		end
		local lk = Icon(rc, "lock", 13, "Warning", "L")
		lk.LayoutOrder = 99; lk.Visible = false
		local page = New("CanvasGroup", {Name = tab.Title, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false, Parent = PageHost})
		local scroll = New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = page})
		Themed(scroll, {ScrollBarImageColor3 = "Accent"})
		New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll})
		New("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 14), Parent = scroll})
		tab.Holder = scroll; tab.Scroll = scroll; tab.Page = page; tab.Button = btn; tab.Bar = bar; tab.Lbl = lbl; tab.Ico = ico
		tab.OnLockChanged = function(v)
			lk.Visible = v
			Tween(lbl, {TextTransparency = v and 0.5 or 0}, 0.2)
		end
		Connect(btn.MouseEnter, function() if not tab.Active then Tween(btn, {BackgroundTransparency = 0.9}, 0.12) end end)
		Connect(btn.MouseLeave, function() if not tab.Active then Tween(btn, {BackgroundTransparency = 1}, 0.12) end end)
		Connect(btn.MouseButton1Click, function() Ripple(btn); self:SelectTab(tab) end)
		table.insert(isSet and self.SettingsTabs or self.Tabs, tab)
		table.insert(self.AllTabs, tab)
		Library:AddCommand("Go to " .. tab.Title, function() self:ShowSettings(isSet); self:SelectTab(tab) end, "Tab")
		if o.Locked then task.defer(function() tab:SetLocked(true, o.LockReason) end) end
		if not isSet and not self.Current and not self.InSettings then self:SelectTab(tab) end
		return tab
	end

	function Window:CreateTab(o) return self:_NewTab(o, "main") end
	Window.AddTab = Window.CreateTab

	function Window:SelectTab(tab, fromHistory)
		if not tab or tab == self.Current then return end
		if tab.Locked then
			Library:Notify({Title = "Locked", Content = tab.LockReason or "This tab is locked.", Type = "warning", Duration = 2.5})
			return
		end
		local prev = self.Current
		self.Current = tab
		if prev then
			prev.Active = false
			PaintTab(prev, true)
			Tween(prev.Page, {GroupTransparency = 1}, 0.15)
			task.delay(0.17, function() if prev ~= self.Current then prev.Page.Visible = false end end)
		end
		tab.Active = true
		PaintTab(tab, true)
		tab.Page.Visible = true
		tab.Page.GroupTransparency = 1
		tab.Page.Position = UDim2.fromOffset(0, 16)
		Tween(tab.Page, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, 0.35)
		if not fromHistory then
			for i = #self.History, self.HIdx + 1, -1 do table.remove(self.History, i) end
			table.insert(self.History, tab)
			self.HIdx = #self.History
		end
		self:_Crumb()
	end
	function Window:Back() if self.HIdx > 1 then self.HIdx = self.HIdx - 1; local t = self.History[self.HIdx]; self:ShowSettings(t.Group == "settings", true); self:SelectTab(t, true) end end
	function Window:Next() if self.HIdx < #self.History then self.HIdx = self.HIdx + 1; local t = self.History[self.HIdx]; self:ShowSettings(t.Group == "settings", true); self:SelectTab(t, true) end end
	Connect(backBtn.MouseButton1Click, function() Window:Back() end)
	Connect(fwdBtn.MouseButton1Click, function() Window:Next() end)

	function Window:ShowSettings(v, keep)
		if v == self.InSettings then return end
		self.InSettings = v
		local from, to = self.TabList, self.SetList
		if not v then from, to = to, from end
		from.Visible = false
		to.Visible = true
		to.Position = UDim2.fromOffset(v and 30 or -30, 52)
		Tween(to, {Position = UDim2.fromOffset(0, 52)}, 0.3)
		Tween(setIc, {Rotation = v and 90 or 0}, 0.35, Enum.EasingStyle.Back)
		Tween(setBtn, {BackgroundTransparency = v and 0.05 or 0.4}, 0.2)
		if keep then self:_Crumb(); return end
		if v then
			self.LastTab = self.Current
			self:SelectTab(self.SettingsTabs[1])
		else
			local t = self.LastTab
			if not t or t.Group == "settings" then t = self.Tabs[1] end
			self:SelectTab(t)
		end
	end
	Connect(setBtn.MouseButton1Click, function() Window:ShowSettings(not Window.InSettings) end)
	Connect(backRow.MouseButton1Click, function() Ripple(backRow); Window:ShowSettings(false) end)

	function Window:_Search(q)
		q = q:lower()
		local first
		for _, tab in ipairs(self.AllTabs) do
			local tm = q == "" or tab.Lbl.Text:lower():find(q, 1, true) ~= nil or tab.Title:lower():find(q, 1, true) ~= nil
			local any = tm
			for _, s in ipairs(tab.Searchables) do
				if s.Row.Parent then
					local hay = ((s.Title and s.Title.Text or "") .. " " .. s.Text):lower()
					local m = q == "" or hay:find(q, 1, true) ~= nil
					if m then any = true end
					s.Row.Visible = (q == "" or m or tm) and not s.Row:GetAttribute("Hidden")
				end
			end
			tab.Button.Visible = any
			if any and not first and (tab.Group == "settings") == self.InSettings then first = tab end
		end
		if q ~= "" and first and (not self.Current or not self.Current.Button.Visible) then self:SelectTab(first) end
	end
	Connect(sbox:GetPropertyChangedSignal("Text"), function() Window:_Search(sbox.Text) end)

	------------------------------------------------ window api
	function Window:SetVisible(v)
		if v == self.Visible then return end
		self.Visible = v
		self._vt = (self._vt or 0) + 1
		local tk = self._vt
		if v then
			Anchor.Visible = true
			Shadow.ImageTransparency = 0.6
			ScaleObj.Scale = Library.CurrentScale * 0.85
			Main.GroupTransparency = 1
			Tween(ScaleObj, {Scale = Library.CurrentScale}, 0.5, Enum.EasingStyle.Back)
			Tween(Main, {GroupTransparency = 0}, 0.3)
		else
			Tween(ScaleObj, {Scale = Library.CurrentScale * 0.9}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween(Main, {GroupTransparency = 1}, 0.22)
			Tween(Shadow, {ImageTransparency = 1}, 0.2)
			task.delay(0.27, function() if self._vt == tk then Anchor.Visible = false end end)
		end
		self:_UpdateBlur()
	end
	function Window:Toggle() self:SetVisible(not self.Visible) end
	Window.Show = function(s) s:SetVisible(true) end
	Window.Hide = function(s) s:SetVisible(false) end

	function Window:Close()
		if self.Closing then return end
		self.Closing = true
		Tween(ScaleObj, {Scale = Library.CurrentScale * 0.8}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		Tween(Main, {GroupTransparency = 1}, 0.28)
		Tween(Shadow, {ImageTransparency = 1}, 0.2)
		if Library.Blur then Tween(Library.Blur, {Size = 0}, 0.3) end
		task.delay(0.35, function() Library:Unload() end)
	end
	Window.Destroy = Window.Close
	function Window:Notify(o) return Library:Notify(o) end
	function Window:SetTransparency(a) Bg.BackgroundTransparency = Clamp(a, 0, 0.95) end
	function Window:SetCorner(r)
		MainCorner.CornerRadius = UDim.new(0, r); BgCorner.CornerRadius = UDim.new(0, r); BorderCorner.CornerRadius = UDim.new(0, r)
	end
	function Window:SetTitle(t) self.Title = t; ttitle.Text = t; self:_Crumb() end
	function Window:SetTheme(t) Library:SetTheme(t) end
	function Window:Dialog(o) return Library:Dialog(o) end
	function Window:Confirm(...) return Library:Confirm(...) end

	Connect(minBtn.MouseButton1Click, function()
		Window:SetVisible(false)
		if not Window.MinHinted then
			Window.MinHinted = true
			Library:Notify({Title = "Minimized", Content = "Tap the floating logo or press " .. Library.ToggleKey.Name .. " to open again.", Type = "info", Duration = 3.5})
		end
	end)
	Connect(closeBtn.MouseButton1Click, function() Window:Close() end)
	Connect(palBtn.MouseButton1Click, function() Library:OpenPalette() end)
	Library.OnThemeChanged = function()
		for _, t in ipairs(Window.AllTabs) do PaintTab(t, false) end
		Window:_Crumb()
	end

	------------------------------------------------ floating logo + watermark
	local Float = New("Frame", {Name = "FloatingLogo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 46, 0.5, 0), Size = UDim2.fromOffset(58, 58), BackgroundTransparency = 1, ZIndex = 40, Parent = Gui})
	local fglow = New("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 40, 1, 40), BackgroundTransparency = 1, Image = SHADOW, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ImageTransparency = 0.45, Parent = Float})
	Themed(fglow, {ImageColor3 = "Accent2"})
	local Orb = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Float})
	Themed(Orb, {BackgroundColor3 = "Background"})
	Corner(Orb, 100)
	local ostroke = New("UIStroke", {Thickness = 2, Color = Color3.new(1, 1, 1), Parent = Orb})
	local ograd = Themed(New("UIGradient", {Parent = ostroke}), {Color = Grad3})
	local olg = MakeLogo(Orb, 38)
	olg.AnchorPoint = Vector2.new(0.5, 0.5); olg.Position = UDim2.fromScale(0.5, 0.5)
	local dotp = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, Parent = Float})
	Themed(dotp, {BackgroundColor3 = "Accent3"})
	Corner(dotp, 3)
	local fhit = New("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5, Parent = Float})
	MakeDraggable(fhit, Float, {threshold = 6, onClick = function() Window:Toggle() end})
	function Window:SetLogoVisible(v) Float.Visible = v end

	local WM = New("Frame", {Name = "Watermark", Position = UDim2.fromOffset(12, 12), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28), BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 30, Parent = Gui})
	Themed(WM, {BackgroundColor3 = "Surface"})
	Corner(WM, 14)
	Stroke(WM, "Accent", 1.2, 0.35)
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = WM})
	New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12), Parent = WM})
	local wmI = New("TextLabel", {Size = UDim2.fromOffset(14, 28), BackgroundTransparency = 1, Text = "✦", Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = 1, Parent = WM})
	Themed(wmI, {TextColor3 = "Accent2"})
	local wmT = New("TextLabel", {AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28), BackgroundTransparency = 1, Text = "", Font = Library.FontBold, TextSize = 12, LayoutOrder = 2, Parent = WM})
	Themed(wmT, {TextColor3 = "Text"})
	local wmHit = New("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 31, Parent = WM})
	MakeDraggable(wmHit, WM, {threshold = 3})
	function Window:SetWatermark(v) WM.Visible = v end

	------------------------------------------------ frame loop
	Connect(RunService.Heartbeat, function(dt)
		Library.Time = Library.Time + dt
		Library.FPS = Library.FPS * 0.92 + (1 / math.max(dt, 1e-4)) * 0.08
		for i = 1, #Library.FrameCallbacks do
			local fn = Library.FrameCallbacks[i]
			if fn then fn(dt, Library.Time) end
		end
		local ag = Library.AnimGradients
		if Window.Visible and not Library.ReduceEffects then
			for i = #ag, 1, -1 do
				local g = ag[i]
				if g.Parent then g.Offset = Vector2.new(math.sin(Library.Time * 0.9 + i * 0.7) * 0.3, 0) else table.remove(ag, i) end
			end
		end
	end)

	local acc = 0
	Library:_OnFrame(function(dt, t)
		-- floating logo (always)
		if Float.Visible then
			Orb.Position = UDim2.new(0.5, 0, 0.5, math.sin(t * 2) * 4)
			Orb.Rotation = math.sin(t * 1.3) * 5
			dotp.Position = UDim2.new(0.5 + math.cos(t * 2.2) * 0.62, 0, 0.5 + math.sin(t * 2.2) * 0.62 + math.sin(t * 2) * 0.07, 0)
			fglow.ImageTransparency = 0.5 + math.sin(t * 2.4) * 0.12
			ograd.Rotation = (t * 90) % 360
		end
		acc = acc + dt
		if acc >= 0.5 then
			acc = 0
			local st = statusText()
			fl.Text = st
			wmT.Text = Window.Title .. (st ~= "" and ("  |  " .. st) or "")
		end
		if not Window.Visible then return end
		local rd = Library.ReduceEffects
		local mul = Library.Theme.Star or 1
		local show = rd and 14 or #stars
		for i = 1, #stars do
			local s = stars[i]
			if i > show or mul <= 0 then
				s.f.Visible = false
			else
				s.f.Visible = true
				s.x = (s.x - s.sp * dt * 0.6) % 1
				s.f.Position = UDim2.fromScale(s.x, s.y)
				s.f.BackgroundTransparency = 1 - Clamp(s.base + math.sin(t * s.tw + s.ph) * 0.25, 0, 1) * mul
			end
		end
		if not rd then
			for i, b in ipairs(blobs) do
				b.f.Position = UDim2.fromScale(b.bx + math.sin(t * 0.1 + i) * 0.05, b.by + math.cos(t * 0.08 + i * 2) * 0.05)
			end
			bgrad.Rotation = (t * 40) % 360
			Shadow.ImageTransparency = 0.6 + math.sin(t * 1.5) * 0.08
			nextShoot = nextShoot - dt
			if nextShoot <= 0 and mul > 0.5 then nextShoot = math.random(40, 90) / 10; ShootingStar() end
		end
	end)

	------------------------------------------------ global input
	Connect(UIS.InputBegan, function(i, gp)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if UIS:GetFocusedTextBox() then return end
		if Library._listening then return end
		if i.KeyCode == Library.ToggleKey then Window:Toggle(); return end
		if i.KeyCode == Enum.KeyCode.K and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then Library:OpenPalette(); return end
		for _, kb in ipairs(Library.Keybinds) do
			if kb.Key and kb.Key == i.KeyCode and kb.Callback then
				if kb.Mode == "Hold" then Fire(kb.Callback, true) else Fire(kb.Callback) end
			end
		end
	end)
	Connect(UIS.InputEnded, function(i)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		for _, kb in ipairs(Library.Keybinds) do
			if kb.Key and kb.Key == i.KeyCode and kb.Callback and kb.Mode == "Hold" then Fire(kb.Callback, false) end
		end
	end)

	loader:Set(0.8, "Building settings...")

	------------------------------------------------ settings tabs
	local startClock = os.clock()

	-- INFO
	local info = Window:_NewTab({Title = "Info", Icon = "info"}, "settings")
	info:AddGameCard()
	local sc = info:_Frame(48)
	local sl = L(sc, "", 12, "Text", true, false)
	sl.Position = UDim2.fromOffset(12, 0); sl.Size = UDim2.new(0.5, -12, 1, 0)
	local sbind = Library:Bind(sl, "Text", "Session", function(s) return s .. " : " .. FormatTime(os.clock() - startClock) end)
	local el = L(sc, "", 12, "Text", true, false)
	el.Position = UDim2.new(0.5, 0, 0, 0); el.Size = UDim2.new(0.5, -12, 1, 0)
	local executor = GetExecutor()
	Library:Bind(el, "Text", "Executor", function(s) return s .. " : " .. executor end)
	local sacc = 0
	Library:_OnFrame(function(dt)
		sacc = sacc + dt
		if sacc >= 1 then sacc = 0; if info.Active then sbind:Set("Session") end end
	end)
	info:AddCopyField({Title = "Hwid", Text = GetHwid()})

	-- CONSOLE
	local con = Window:_NewTab({Title = "Console", Icon = "terminal"}, "settings")
	local capConn
	con:AddToggle({Title = "Capture Game Output", Description = "Show game output inside this console", NoSave = true, Callback = function(v)
		if capConn then capConn:Disconnect(); capConn = nil end
		if v then
			capConn = LogService.MessageOut:Connect(function(msg, mt)
				local k = "info"
				if mt == Enum.MessageType.MessageError then k = "error" elseif mt == Enum.MessageType.MessageWarning then k = "warn" end
				Library:Log(msg, k)
			end)
		end
	end})
	local panel = con:_Frame(250)
	local hdr = New("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = panel})
	local cic = Icon(hdr, "terminal", 16, "Accent2", ">")
	cic.Position = UDim2.fromOffset(12, 10)
	local ctitle = L(hdr, "Console", 13, "Text", true)
	ctitle.Position = UDim2.fromOffset(36, 0); ctitle.Size = UDim2.new(0, 90, 1, 0)
	local btnRow = New("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundTransparency = 1, Parent = hdr})
	New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = btnRow})
	local copyB = PillBtn(btnRow, "copy", "⧉", "Copy", "Accent")
	copyB.LayoutOrder = 1
	local delB = PillBtn(btnRow, "trash-2", "x", "Delete Log", "Error")
	delB.LayoutOrder = 2
	local logs = New("ScrollingFrame", {Position = UDim2.fromOffset(8, 40), Size = UDim2.new(1, -16, 1, -48), BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = panel})
	Themed(logs, {BackgroundColor3 = "Background", ScrollBarImageColor3 = "Accent"})
	Corner(logs, 8)
	New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = logs})
	New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = logs})
	local kindKey = {info = "SubText", success = "Success", warn = "Warning", error = "Error"}
	local lineN = 0
	local function addLine(e)
		lineN = lineN + 1
		local k = kindKey[e.Kind] or "SubText"
		local l = New("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, RichText = true, TextWrapped = true, Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = lineN, Text = "", Parent = logs})
		Themed(l, {TextColor3 = "Text"})
		l.Text = "<font color=\"#" .. Library.Theme[k]:ToHex() .. "\">[" .. e.Time .. "]</font> " .. Esc(e.Text)
		local kids = {}
		for _, c in ipairs(logs:GetChildren()) do if c:IsA("TextLabel") then kids[#kids + 1] = c end end
		if #kids > 300 then kids[1]:Destroy() end
		task.defer(function() logs.CanvasPosition = Vector2.new(0, 1e6) end)
	end
	for _, e in ipairs(Library.Logs) do addLine(e) end
	Library.OnLog = addLine
	Connect(copyB.MouseButton1Click, function()
		local out = {}
		for _, e in ipairs(Library.Logs) do out[#out + 1] = "[" .. e.Time .. "] " .. e.Text end
		if setclipboard then setclipboard(table.concat(out, "\n")) end
		Library:Notify({Title = "Console", Content = "Logs copied to clipboard.", Type = "success", Duration = 2})
	end)
	Connect(delB.MouseButton1Click, function()
		Library.Logs = {}
		for _, c in ipairs(logs:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
		Library:Notify({Title = "Console", Content = "Logs deleted.", Type = "warning", Duration = 2})
	end)
	local dc = con:_Frame(64)
	local dic = Icon(dc, "message-circle", 22, "Accent2", "#")
	dic.Position = UDim2.fromOffset(14, 21)
	local dt1 = L(dc, "Join our Discord", 13, "Text", true)
	dt1.Position = UDim2.fromOffset(46, 12); dt1.Size = UDim2.new(1, -170, 0, 18)
	local dt2 = L(dc, "discord.gg/" .. DISCORD_CODE, 11, "Accent2", false, false)
	dt2.Position = UDim2.fromOffset(46, 32); dt2.Size = UDim2.new(1, -170, 0, 16)
	local join = PillBtn(dc, "link", "↗", "Invite", "Accent")
	join.AnchorPoint = Vector2.new(1, 0.5); join.Position = UDim2.new(1, -12, 0.5, 0)
	Connect(join.MouseButton1Click, function()
		if setclipboard then setclipboard(DISCORD_URL) end
		if httpRequest then
			pcall(httpRequest, {Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"}, Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", args = {code = DISCORD_CODE}, nonce = HttpService:GenerateGUID(false)})})
		end
		Library:Notify({Title = "Discord", Content = "Invite link copied: " .. DISCORD_URL, Type = "success"})
	end)

	-- CONFIGURE
	local cfg = Window:_NewTab({Title = "Configure", Icon = "sliders-horizontal"}, "settings")
	local nameBox = cfg:AddTextbox({Title = "Configure Name", Placeholder = "put name here....", Default = Library.ConfigName, NoSave = true})
	local cfgDrop
	cfgDrop = cfg:AddDropdown({Title = "Configure's", Options = Library:ListConfigs(), NoSave = true, Translate = false, Callback = function(v) if v then nameBox:Set(v, true) end end})
	local function refreshCfg() cfgDrop:SetOptions(Library:ListConfigs(), true) end
	Library.OnConfigsChanged = refreshCfg
	cfg:AddButton({Title = "Save Configure", Icon = "save", Callback = function()
		if Library:SaveConfig(nameBox:Get()) then refreshCfg(); cfgDrop:Set(Library.ConfigName, true) end
	end})
	cfg:AddButton({Title = "Delete Configure", Icon = "trash-2", Callback = function()
		local n = cfgDrop:Get() or nameBox:Get()
		Library:Confirm("Delete Configure", "Delete \"" .. tostring(n) .. "\" permanently?", function() Library:DeleteConfig(n); cfgDrop:Set(nil, true) end)
	end})
	cfg:AddButton({Title = "Load Configure", Icon = "download", Callback = function()
		local n = cfgDrop:Get() or nameBox:Get()
		if Library:LoadConfig(n) then nameBox:Set(n, true) end
	end})
	cfg:AddButton({Title = "Reset Configure", Icon = "rotate-ccw", Callback = function() Library:ResetConfig() end})
	local autoName = hasFS and pcall(function() return isfile(Library.Folder .. "/autoload.txt") end) and isfile(Library.Folder .. "/autoload.txt") and readfile(Library.Folder .. "/autoload.txt") or nil
	cfg:AddToggle({Title = "Auto Save", Description = "Save the current configure after every change", NoSave = true, Callback = function(v) Library.AutoSave = v end})
	cfg:AddToggle({Title = "Auto Load", Description = "Load this configure when the script starts", NoSave = true, Default = autoName ~= nil, FireInit = false, Callback = function(v) Library:SetAutoLoad(v) end})
	if autoName and autoName ~= "" then Library.ConfigName = autoName; nameBox:Set(autoName, true) end
	function Window:LoadAutoConfig()
		if autoName and autoName ~= "" then Library:LoadConfig(autoName, true) end
	end

	-- SETTINGS
	local st = Window:_NewTab({Title = "Settings", Icon = "settings"}, "settings")
	local pal = st:AddSection("Color Palette")
	local pickers = {}
	local themeNames = {"Nebula", "Cosmos", "Aurora", "Supernova", "Dark Mode", "Light Mode"}
	pal:AddDropdown({Title = "Theme", Options = themeNames, Default = Library.ThemeName, Flag = "UI.Theme", Callback = function(v)
		Library:SetTheme(v)
		for key, p in pairs(pickers) do p:Set(Library.Theme[key], true) end
	end})
	for _, c in ipairs({{"Accent", "Accent"}, {"Secondary", "Accent2"}, {"Tertiary", "Accent3"}, {"Background", "Background"}, {"Text", "Text"}}) do
		pickers[c[2]] = pal:AddColorPicker({Title = c[1] .. " Color", Default = Library.Theme[c[2]], Flag = "UI.Color." .. c[2], Callback = function(col) Library:SetTheme({[c[2]] = col}) end})
	end
	local win = st:AddSection("Window")
	win:AddSlider({Title = "Window Transparency", Min = 0, Max = 90, Default = 6, Suffix = "%", Flag = "UI.Transparency", Callback = function(v) Window:SetTransparency(v / 100) end})
	win:AddSlider({Title = "Window Corner", Min = 0, Max = 24, Default = 14, Flag = "UI.Corner", Callback = function(v) Window:SetCorner(v) end})
	win:AddSlider({Title = "Open Window Size", Min = 60, Max = 140, Default = 100, Suffix = "%", Flag = "UI.Size", Callback = function(v) Window.SizeMul = v / 100; Window:_ApplyScale(true) end})
	local lang = st:AddSection("Language")
	lang:AddDropdown({Title = "Language", Options = Library.Languages, Default = "English", Translate = false, Flag = "UI.Language", Callback = function(v) Library:SetLanguage(v); Window:_Crumb() end})
	local fx = st:AddSection("Effects")
	fx:AddToggle({Title = "Reduce Effects", Description = "Fewer stars and animations for low-end devices", Default = Library.ReduceEffects, Flag = "UI.Reduce", Callback = function(v) Library.ReduceEffects = v end})
	fx:AddToggle({Title = "Background Blur", Default = true, Flag = "UI.Blur", Callback = function(v) Library.UseBlur = v; Window:_UpdateBlur() end})
	fx:AddToggle({Title = "Floating Logo", Default = true, Flag = "UI.Float", Callback = function(v) Window:SetLogoVisible(v) end})
	fx:AddToggle({Title = "Watermark", Default = true, Flag = "UI.Watermark", Callback = function(v) Window:SetWatermark(v) end})
	fx:AddToggle({Title = "FPS Counter", Default = true, Flag = "UI.FPS", Callback = function(v) Library.ShowFPS = v end})
	fx:AddToggle({Title = "Clock", Default = true, Flag = "UI.Clock", Callback = function(v) Library.ShowClock = v end})
	fx:AddToggle({Title = "Notifications", Default = true, Flag = "UI.Notifs", Callback = function(v) Library.Notifications = v end})
	local kbs = st:AddSection("Keybinds")
	kbs:AddKeybind({Title = "UI Toggle Key", Default = Library.ToggleKey, Flag = "UI.ToggleKey", OnChanged = function(k) if k then Library.ToggleKey = k end end})
	Library.KeybindList = kbs:AddParagraph({Title = "Keybind Manager", Content = "", Translate = false})
	Library:_RefreshKeybinds()

	Library:AddCommand("Toggle UI", function() Window:Toggle() end, "Window")
	Library:AddCommand("Close UI", function() Window:Close() end, "Window")
	Library:AddCommand("Save Configure", function() Library:SaveConfig(nameBox:Get()) end, "Config")
	for _, n in ipairs(themeNames) do Library:AddCommand("Theme: " .. n, function() Library:SetTheme(n); for key, p in pairs(pickers) do p:Set(Library.Theme[key], true) end end, "Theme") end

	Window:SetTransparency(0.06)
	Library:Log("Asterveil UI v" .. Library.Version .. " loaded.", "success")
	loader:Set(1, "Ready")
	task.wait(0.35)
	loader:Close()
	Window:SetVisible(true)
	task.delay(1.2, function() if autoName and autoName ~= "" and not Library._autoDone then Library._autoDone = true; Window:LoadAutoConfig() end end)
	return Window
end

return Library
