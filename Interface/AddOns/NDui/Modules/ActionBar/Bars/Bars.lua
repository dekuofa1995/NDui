local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:RegisterModule("Actionbar")
local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local tinsert, next = tinsert, next
local GetActionTexture = GetActionTexture
local margin, padding = C.Bars.margin, C.Bars.padding

function Bar:UpdateAllScale()
	if not C.db["Actionbar"]["Enable"] then return end
	Bar:UpdateActionSize("Bar1")
	Bar:UpdateActionSize("Bar2")
	Bar:UpdateActionSize("Bar3")
	Bar:UpdateActionSize("Bar4")
	Bar:UpdateActionSize("Bar5")
	Bar:UpdateActionSize("Bar6")
	Bar:UpdateActionSize("Bar7")
	Bar:UpdateActionSize("Bar8")
	Bar:UpdateActionSize("BarPet")
	Bar:UpdateStanceBar()
	Bar:UpdateVehicleButton()
end

function Bar:UpdateFontSize(button, fontSize)
	B.SetFontSize(button.Name, fontSize)
	B.SetFontSize(button.Count, fontSize)
	B.SetFontSize(button.HotKey, fontSize)
end

function Bar:UpdateActionSize(name)
	local frame = _G["NDui_Action"..name]
	if not frame then return end

	local size = C.db["Actionbar"][name.."Size"]
	local fontSize = C.db["Actionbar"][name.."Font"]
	local num = C.db["Actionbar"][name.."Num"]
	local perRow = C.db["Actionbar"][name.."PerRow"]

	if num == 0 then
		local column = 3
		local rows = 2
		frame:SetWidth(3*size + (column-1)*margin + 2*padding)
		frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
		frame.mover:SetSize(frame:GetSize())
		frame.child:SetSize(frame:GetSize())
		frame.child.mover:SetSize(frame:GetSize())
		frame.child.mover.isDisable = false
		for i = 1, 12 do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 7 then
				button:SetPoint("TOPLEFT", frame.child, padding, -padding)
			elseif mod(i-1, 3) ==  0 then
				button:SetPoint("TOP", frame.buttons[i-3], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
			end
			button:Show()
			Bar:UpdateFontSize(button, fontSize)
		end
	else
		for i = 1, num do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif mod(i-1, perRow) ==  0 then
				button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
			end
			button:Show()
			Bar:UpdateFontSize(button, fontSize)
		end

		for i = num+1, 12 do
			local button = frame.buttons[i]
			if not button then break end
			button:Hide()
		end

		local column = min(num, perRow)
		local rows = ceil(num/perRow)
		frame:SetWidth(column*size + (column-1)*margin + 2*padding)
		frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
		frame.mover:SetSize(frame:GetSize())
		if frame.child then frame.child.mover.isDisable = true end
	end
end

function Bar:UpdateButtonConfig(i)
	if not self.buttonConfig then
		self.buttonConfig = {
			hideElements = {},
			text = {
				hotkey = { font = {}, position = {} },
				count = { font = {}, position = {} },
				macro = { font = {}, position = {} },
			}
		}
	end
	self.buttonConfig.clickOnDown = true
	self.buttonConfig.showGrid = C.db["Actionbar"]["Grid"]
	self.buttonConfig.flyoutDirection = "UP"

	local hotkey = self.buttonConfig.text.hotkey
	hotkey.font.font = DB.Font[1]
	hotkey.font.size = C.db["Actionbar"]["Bar"..i.."Font"]
	hotkey.font.flags = DB.Font[3]
	hotkey.position.anchor = "TOPRIGHT"
	hotkey.position.relAnchor = false
	hotkey.position.offsetX = 0
	hotkey.position.offsetY = 0
	hotkey.justifyH = "RIGHT"

	local count = self.buttonConfig.text.count
	count.font.font = DB.Font[1]
	count.font.size = C.db["Actionbar"]["Bar"..i.."Font"]
	count.font.flags = DB.Font[3]
	count.position.anchor = "BOTTOMRIGHT"
	count.position.relAnchor = false
	count.position.offsetX = 2
	count.position.offsetY = 0
	count.justifyH = "RIGHT"

	local macro = self.buttonConfig.text.macro
	macro.font.font = DB.Font[1]
	macro.font.size = C.db["Actionbar"]["Bar"..i.."Font"]
	macro.font.flags = DB.Font[3]
	macro.position.anchor = "BOTTOM"
	macro.position.relAnchor = false
	macro.position.offsetX = 0
	macro.position.offsetY = 0
	macro.justifyH = "CENTER"

	local hideElements = self.buttonConfig.hideElements
	hideElements.hotkey = not C.db["Actionbar"]["Hotkeys"]
	hideElements.macro = not C.db["Actionbar"]["Macro"]
	hideElements.equipped = not C.db["Actionbar"]["EquipColor"]

	for _, button in next, self.buttons do
		self.buttonConfig.keyBoundTarget = button.bindName
		button.keyBoundTarget = self.buttonConfig.keyBoundTarget
		button.postKeybind = Bar.UpdateHotKey

		button:SetAttribute("buttonlock", GetCVarBool("lockActionBars"))
		button:SetAttribute("checkmouseovercast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("*unit2", "player")
		button:UpdateConfig(self.buttonConfig)

		if C.db["Actionbar"]["Classcolor"] then
			button.__bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
		else
			button.__bg:SetBackdropColor(.2, .2, .2, .25)
		end
	end
end

local fullPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"

function Bar:UpdateVisibility()
	for i = 1, 8 do
		local frame = _G["NDui_ActionBar"..i]
		if frame then
			if C.db["Actionbar"]["Bar"..i] then
				frame:Show()
				RegisterStateDriver(frame, "visibility", frame.visibility)
			else
				frame:Hide()
				UnregisterStateDriver(frame, "visibility")
			end
		end
	end
end

function Bar:UpdateBarConfig()
	for i = 1, 8 do
		local frame = _G["NDui_ActionBar"..i]
		if frame then
			Bar.UpdateButtonConfig(frame, i)
		end
	end
end

function Bar:OnButtonUpdate(button)
	if not button.__bg then return end

	if button.Border:IsShown() then
		button.__bg:SetBackdropBorderColor(0, .7, .1)
	else
		button.__bg:SetBackdropBorderColor(0, 0, 0)
	end
end

function Bar:CreateBars()
	Bar.headers = {}
	for index = 1, 8 do
		Bar.headers[index] = CreateFrame("Frame", "NDui_ActionBar"..index, UIParent, "SecureHandlerStateTemplate")
	end

	local BAR_DATA = {
		[1] = {page = 1, bindName = "ACTIONBUTTON", anchor = {"BOTTOM", UIParent, "BOTTOM", 0, 24}},
		[2] = {page = 6, bindName = "MULTIACTIONBAR1BUTTON", anchor = {"BOTTOM", _G.NDui_ActionBar1, "TOP", 0, -margin}},
		[3] = {page = 5, bindName = "MULTIACTIONBAR2BUTTON", anchor = {"RIGHT", _G.NDui_ActionBar1, "TOPLEFT", -margin, -padding/2}},
		[4] = {page = 3, bindName = "MULTIACTIONBAR3BUTTON", anchor = {"RIGHT", UIParent, "RIGHT", -1, 0}},
		[5] = {page = 4, bindName = "MULTIACTIONBAR4BUTTON", anchor = {"RIGHT", _G.NDui_ActionBar4, "LEFT", margin, 0}},
		[6] = {page = 13, bindName = "MULTIACTIONBAR5BUTTON", anchor = {"CENTER", UIParent, "CENTER", 0, 0}},
		[7] = {page = 14, bindName = "MULTIACTIONBAR6BUTTON", anchor = {"CENTER", UIParent, "CENTER", 0, 40}},
		[8] = {page = 15, bindName = "MULTIACTIONBAR7BUTTON", anchor = {"CENTER", UIParent, "CENTER", 0, 80}},
	}

	for index = 1, 8 do
		local data = BAR_DATA[index]
		local frame = Bar.headers[index]
		local mIndex = 1
		if index == 3 then
			frame.mover = B.Mover(frame, L["Actionbar"].."3L", "Bar3L", {"RIGHT", _G.NDui_ActionBar1, "TOPLEFT", -margin, -padding/2})
			local child = CreateFrame("Frame", nil, frame)
			child:SetSize(1, 1)
			child.mover = B.Mover(child, L["Actionbar"].."3R", "Bar3R", {"LEFT", _G.NDui_ActionBar1, "TOPRIGHT", margin, -padding/2})
			frame.child = child
		
			Bar.movers[mIndex] = frame.mover
			Bar.movers[mIndex+1] = child.mover
			mIndex = mIndex + 2
		else
			frame.mover = B.Mover(frame, L["Actionbar"]..index, "Bar"..index, data.anchor)
			Bar.movers[mIndex] = frame.mover
			mIndex = mIndex + 1
		end
		frame.buttons = {}

		for i = 1, 12 do
			local button = LAB:CreateButton(i, "$parentButton"..i, frame)
			button:SetState(0, "action", i)
			for k = 1, 18 do
				button:SetState(k, "action", (k - 1) * 12 + i)
			end
			button.MasqueSkinned = true
			button.bindName = data.bindName..i

			tinsert(frame.buttons, button)
			tinsert(Bar.buttons, button)
		end

		frame.visibility = i == 1 and"[petbattle] hide; show" or "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"

		frame:SetAttribute("_onstate-page", [[
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		]])
		RegisterStateDriver(frame, "page", index == 1 and fullPage or data.page)
	end

	LAB.RegisterCallback(Bar, "OnButtonUpdate", Bar.OnButtonUpdate)

	if LAB.flyoutHandler then
		LAB.flyoutHandler.Background:Hide()
		for _, button in next, LAB.FlyoutButtons do
			Bar:StyleActionButton(button)
		end
	end

	local function delayUpdate()
		Bar:UpdateBarConfig()
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
	end
	B:RegisterEvent("CVAR_UPDATE", function(_, var)
		if var == "lockActionBars" then
			if InCombatLockdown() then
				B:RegisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
				return
			end
			Bar:UpdateBarConfig()
		end
	end)
end

function Bar:OnLogin()
	Bar.buttons = {}
	Bar:MicroMenu()

	if C.db["Actionbar"]["Enable"] then
		Bar.movers = {}
		Bar:CreateBars()
		Bar:ReskinBars()
		Bar:UpdateBarConfig()
		Bar:UpdateVisibility()
		Bar:CreateExtrabar()
		Bar:CreateLeaveVehicle()
		Bar:CreatePetbar()
		Bar:CreateStancebar()
		Bar:HideBlizz()
		Bar:UpdateAllScale()
	end
end