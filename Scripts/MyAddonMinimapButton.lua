local MyAddonMinimapButton = CreateFrame("Button", "MyAddonMinimapButton", Minimap)
MyAddonMinimapButton:SetSize(32, 32)
MyAddonMinimapButton:SetFrameStrata("MEDIUM")
MyAddonMinimapButton:SetMovable(true)
MyAddonMinimapButton:RegisterForDrag("LeftButton")
MyAddonMinimapButton:SetPoint("CENTER", 0, 0)
MyAddonMinimapButton:SetNormalTexture("Interface\\AddOns\\MyLittleSharko\\Textures\\MinimapButtonNormal")
MyAddonMinimapButton:SetPushedTexture("Interface\\AddOns\\MyLittleSharko\\Textures\\MinimapButtonPushed")
MyAddonMinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
MyAddonMinimapButton:RegisterEvent("PLAYER_LOGIN")

function MyAddonMinimapButton_OnLoad(self)
  self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
end

function MyAddonMinimapButton_OnButtonLoad(self)
  self:SetAttribute("type", "togglemenu")
  self:SetAttribute("menu", "MyAddonOptionsMenu")
end

function MyAddonMinimapButton_OnClick(self, button)
  if button == "RightButton" then
    -- Handle right-click
  else
    -- Handle left-click
  end
end

MyAddonMinimapButton:SetScript("OnClick", MyAddonMinimapButton_OnClick)

-- Add more functions or event handlers as needed

-- Example: Create an options menu
local MyAddonOptionsMenu = CreateFrame("Frame", "MyAddonOptionsMenu", UIParent, "UIDropDownMenuTemplate")
local menuTable = {
  { text = "Option 1", func = function() print("Option 1 clicked!") end },
  { text = "Option 2", func = function() print("Option 2 clicked!") end },
}
UIDropDownMenu_Initialize(MyAddonOptionsMenu, function()
  for _, info in ipairs(menuTable) do
    UIDropDownMenu_AddButton(info)
  end
end)
