print('start frame')

local f = CreateFrame("Frame", "DragFrame2", UIParent)
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetPoint("BOTTOMLEFT", UIParent, 30, 350)
btn:SetSize(100, 40)
btn:SetText("Click me")
btn:SetScript("OnClick", function(self, button, down)
	print("Pressed", button, down and "down" or "up")
	if not down then
		return ReloadUI()
	end
end)
btn:RegisterForClicks("AnyDown", "AnyUp")