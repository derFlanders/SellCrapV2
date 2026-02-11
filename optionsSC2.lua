if (SELLCRAP2 == nil) then 
    SELLCRAP2 = {};

    local frame = CreateFrame("Frame");
    frame:RegisterEvent("ADDON_LOADED");
    frame:SetScript("OnEvent", 
        function(self, event, addonName)
            if (event == "ADDON_LOADED" and addonName == "SellCrap2") then
                handleSavedVars();
            end
        end
    )
end

local optionspanel = CreateFrame("Frame", "SellCrap2OptionsPanel", UIParent);
optionspanel.name = "SellCrap2";

-- Rahmen erstellen
local headerFrame = CreateFrame("Frame", nil, optionspanel, "BackdropTemplate")
headerFrame:SetPoint("TOPLEFT", 10, 5)
headerFrame:SetSize(400, 40)
headerFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
headerFrame:SetBackdropColor(0, 0, 0, 0.5)
headerFrame:SetBackdropBorderColor(1, 0.82, 0, 1)

-- Überschrift
optionspanel.headline = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optionspanel.headline:SetText("SellCrap|cFFFF80002|r Settings")
optionspanel.headline:SetPoint("TOP", 0, -10)


-- Auto Sell Checkbox
optionspanel.autoSellCheckbox = CreateFrame("CheckButton", "SellCrap2OptionsPanelCheckBox1", optionspanel, "ChatConfigCheckButtonTemplate");
optionspanel.autoSellCheckbox:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 10, -20);
optionspanel.autoSellCheckbox.text = optionspanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
optionspanel.autoSellCheckbox.text:SetPoint("LEFT", optionspanel.autoSellCheckbox, "RIGHT", 5, 0);
optionspanel.autoSellCheckbox.text:SetText("Auto-sell on Merchant visit");
optionspanel.autoSellCheckbox:SetScript("OnClick", function(self)
    SELLCRAP2VARS.autoSellCheckboxState = self:GetChecked();
end);

-- Auto Repair Checkbox
optionspanel.autoRepairCheckbox = CreateFrame("CheckButton", "SellCrap2OptionsPanelCheckBox2", optionspanel, "ChatConfigCheckButtonTemplate");
optionspanel.autoRepairCheckbox:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 10, -50);
optionspanel.autoRepairCheckbox.text = optionspanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
optionspanel.autoRepairCheckbox.text:SetPoint("LEFT", optionspanel.autoRepairCheckbox, "RIGHT", 5, 0);
optionspanel.autoRepairCheckbox.text:SetText("Auto-repair on Merchant visit");
optionspanel.autoRepairCheckbox:SetScript("OnClick", function(self)
    SELLCRAP2VARS.autoRepairCheckboxState = self:GetChecked();
end);


-- Show Bag Crap Value Checkbox
optionspanel.showBagCrapValueCheckbox = CreateFrame("CheckButton", "SellCrap2OptionsPanelCheckBox3", optionspanel, "ChatConfigCheckButtonTemplate");
optionspanel.showBagCrapValueCheckbox:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 10, -80);
optionspanel.showBagCrapValueCheckbox.text = optionspanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
optionspanel.showBagCrapValueCheckbox.text:SetPoint("LEFT", optionspanel.showBagCrapValueCheckbox, "RIGHT", 5, 0);
optionspanel.showBagCrapValueCheckbox.text:SetText("Show Crap value window");
optionspanel.showBagCrapValueCheckbox:SetScript("OnClick", function(self)
    SELLCRAP2VARS.showBagCrapValueCheckboxState = self:GetChecked();
    if SELLCRAP2.showBagCrapValue then
        SELLCRAP2:showBagCrapValue(SELLCRAP2VARS.showBagCrapValueCheckboxState);
    end
end);


-- Color Crap Items Checkbox
optionspanel.colorCrapItemsCheckbox = CreateFrame("CheckButton", "SellCrap2OptionsPanelCheckBox4", optionspanel, "ChatConfigCheckButtonTemplate");
optionspanel.colorCrapItemsCheckbox:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 10, -110);
optionspanel.colorCrapItemsCheckbox.text = optionspanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
optionspanel.colorCrapItemsCheckbox.text:SetPoint("LEFT", optionspanel.colorCrapItemsCheckbox, "RIGHT", 5, 0);
optionspanel.colorCrapItemsCheckbox.text:SetText("Color/Dim Crap items in bags - |cFFFFFFFFStandard Bags only|r");
optionspanel.colorCrapItemsCheckbox:SetScript("OnClick", function(self)
    SELLCRAP2VARS.colorCrapItemsState = self:GetChecked();
    if SELLCRAP2.showBagCrapValue then
        SELLCRAP2:showBagCrapValue(SELLCRAP2VARS.showBagCrapValueCheckboxState);
    end
end);

-- Untere Linie
local bottomLine = optionspanel:CreateTexture(nil, "ARTWORK")
bottomLine:SetColorTexture(1, 0.82, 0, 1)
bottomLine:SetSize(400, 0.5)
bottomLine:SetPoint("TOPLEFT", optionspanel.colorCrapItemsCheckbox, "BOTTOMLEFT", -10, -20);

-- Text unter der Linie
optionspanel.infoText = optionspanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionspanel.infoText:SetText("Addon rewrite for TBC by |cFFFF8000derFlanders|r original by |cFFFF8000fitzsimmons9|r")
optionspanel.infoText:SetPoint("TOPLEFT", bottomLine, "LEFT", 10, -10)
optionspanel.infoText:SetTextColor(0.8, 0.9, 0.7, 1)



-- REGISTRIERUNG
local category = Settings.RegisterCanvasLayoutCategory(optionspanel, "SellCrap2");
Settings.RegisterAddOnCategory(category);

-- SLASH COMMAND
SLASH_SELLCRAP21 = "/sellcrap2"
SlashCmdList["SELLCRAP2"] = function()
    Settings.OpenToCategory(category:GetID());
end

function handleSavedVars()
    if (SELLCRAP2VARS == nil) then SELLCRAP2VARS = {}; end
    
    -- Defaults (Hier wurden die Änderungen für den automatischen Start vorgenommen)
    if (SELLCRAP2VARS.autoSellCheckboxState == nil) then SELLCRAP2VARS.autoSellCheckboxState = false end
    if (SELLCRAP2VARS.autoRepairCheckboxState == nil) then SELLCRAP2VARS.autoRepairCheckboxState = false end
    if (SELLCRAP2VARS.showBagCrapValueCheckboxState == nil) then SELLCRAP2VARS.showBagCrapValueCheckboxState = true end -- Standardmäßig AN
    if (SELLCRAP2VARS.colorCrapItemsState == nil) then SELLCRAP2VARS.colorCrapItemsState = true end -- Standardmäßig AN

    -- Fensterposition wiederherstellen
    if SELLCRAP2.RestorePosition then
        SELLCRAP2:RestorePosition();
    end

    -- Sync UI
    optionspanel.autoSellCheckbox:SetChecked(SELLCRAP2VARS.autoSellCheckboxState);
    optionspanel.autoRepairCheckbox:SetChecked(SELLCRAP2VARS.autoRepairCheckboxState);
    optionspanel.showBagCrapValueCheckbox:SetChecked(SELLCRAP2VARS.showBagCrapValueCheckboxState);
    optionspanel.colorCrapItemsCheckbox:SetChecked(SELLCRAP2VARS.colorCrapItemsState);
    
    if SELLCRAP2.showBagCrapValue then
        SELLCRAP2:showBagCrapValue(SELLCRAP2VARS.showBagCrapValueCheckboxState);
    end
end