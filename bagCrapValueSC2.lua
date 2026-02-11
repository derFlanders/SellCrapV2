local goldCoinIcon = "|TInterface\\MONEYFRAME\\UI-GoldIcon:14:14:0:0:64:64:4:60:4:60|t";
local silverCoinIcon = "|TInterface\\MONEYFRAME\\UI-SilverIcon:14:14:0:0:64:64:4:60:4:60|t";
local copperCoinIcon = "|TInterface\\MONEYFRAME\\UI-CopperIcon:14:14:0:0:64:64:4:60:4:60|t";

-- Hauptfenster Erstellung
local displayFrame = CreateFrame("Frame", "SellCrap2_StandaloneValueFrame", UIParent, "BackdropTemplate");
displayFrame:SetFrameStrata("MEDIUM");
displayFrame:SetMovable(true);
displayFrame:SetResizable(true);
displayFrame:SetClampedToScreen(true);

-- API Check für Größenbegrenzung
if displayFrame.SetResizeBounds then
    displayFrame:SetResizeBounds(110, 45, 400, 100);
else
    displayFrame:SetMinResize(110, 45);
    displayFrame:SetMaxResize(400, 100);
end

displayFrame:EnableMouse(true);
displayFrame:RegisterForDrag("LeftButton");

-- Optik
displayFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});
displayFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9);
displayFrame:SetBackdropBorderColor(1, 0.82, 0, 0.6);

local titleBg = displayFrame:CreateTexture(nil, "BACKGROUND")
titleBg:SetPoint("TOPLEFT", 4, -4)
titleBg:SetPoint("TOPRIGHT", -4, -4)
titleBg:SetHeight(16)
titleBg:SetColorTexture(1, 0.82, 0, 0.15)

displayFrame.title = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
displayFrame.title:SetPoint("TOP", displayFrame, "TOP", 0, -6);
displayFrame.title:SetText("CRAP VALUE");

displayFrame.text = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
displayFrame.text:SetPoint("CENTER", displayFrame, "CENTER", 0, -6);

-- Resize-Handle
local resizeButton = CreateFrame("Button", nil, displayFrame);
resizeButton:SetSize(16, 16);
resizeButton:SetPoint("BOTTOMRIGHT", displayFrame, "BOTTOMRIGHT", 0, 0);
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");

resizeButton:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        displayFrame:StartSizing("BOTTOMRIGHT");
    end
end);

resizeButton:SetScript("OnMouseUp", function(self, button)
    displayFrame:StopMovingOrSizing();
    if SELLCRAP2VARS then
        SELLCRAP2VARS.frameSize = { width = displayFrame:GetWidth(), height = displayFrame:GetHeight() };
    end
end);

-- KLICK-LOGIK
displayFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not IsModifierKeyDown() then
        self:StartMoving();
    elseif button == "RightButton" then
        -- DER DIREKTE WEG: Ruft die hinter dem Slash-Befehl liegende Funktion auf
        -- Falls SlashCmdList nicht greift, nutzen wir MacroEdit_Execute
        local chatCmd = SlashCmdList["SELLCRAP2"]
        if chatCmd then
            chatCmd("") -- Ruft die Funktion direkt auf
        else
            -- Sicherster Fallback für WoW
            ExecuteChatLine("/sellcrap2")
        end
    end
end);

displayFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing();
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint();
        if SELLCRAP2VARS then
            SELLCRAP2VARS.framePos = { point = point, rel = relativePoint, x = xOfs, y = yOfs };
        end
    end
end);

-- FUNKTIONEN
function SELLCRAP2:RestorePosition()
    if SELLCRAP2VARS then
        if SELLCRAP2VARS.frameSize then
            displayFrame:SetSize(SELLCRAP2VARS.frameSize.width, SELLCRAP2VARS.frameSize.height);
        else
            displayFrame:SetSize(130, 48);
        end
        if SELLCRAP2VARS.framePos then
            local p = SELLCRAP2VARS.framePos;
            displayFrame:ClearAllPoints();
            displayFrame:SetPoint(p.point, UIParent, p.rel, p.x, p.y);
        else
            displayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        end
    end
end

local function calculateCrapValue()
    local totalGreysValue = 0;
    for bagNumber = 0, 4 do
        local slotsCount = C_Container.GetContainerNumSlots(bagNumber);
        for slotNumber = 1, slotsCount do
            local containerInfo = C_Container.GetContainerItemInfo(bagNumber, slotNumber);
            if (containerInfo and containerInfo.itemID and containerInfo.quality == 0) then
                local _, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(containerInfo.itemID);
                if (itemSellPrice) then
                    totalGreysValue = totalGreysValue + (containerInfo.stackCount * itemSellPrice);
                end
            end
        end
    end
    
    local gold = math.floor(totalGreysValue/10000);
    local silver = math.floor((totalGreysValue % 10000) / 100);
    local copper = totalGreysValue % 100;
    
    if gold > 0 then 
        return string.format("%d%s %d%s %d%s", gold, goldCoinIcon, silver, silverCoinIcon, copper, copperCoinIcon)
    elseif silver > 0 then
        return string.format("%d%s %d%s", silver, silverCoinIcon, copper, copperCoinIcon)
    else
        return string.format("%d%s", copper, copperCoinIcon)
    end
end

local function HighlightCrap()
    local shouldColor = (SELLCRAP2VARS and SELLCRAP2VARS.colorCrapItemsState);
    for bag = 0, 4 do
        local slots = C_Container.GetContainerNumSlots(bag);
        for slot = 1, slots do
            local info = C_Container.GetContainerItemInfo(bag, slot);
            local itemButton = _G["ContainerFrame"..(bag+1).."Item"..(slots-slot+1)] or _G["ContainerFrameCombinedBagsItem"..(slot)]
            if itemButton and itemButton.icon then
                if info and info.quality == 0 and shouldColor then
                    itemButton.icon:SetVertexColor(0.2, 0.2, 0.2, 1);
                else
                    itemButton.icon:SetVertexColor(1, 1, 1, 1);
                end
            end
        end
    end
end

local function RefreshUI()
    if not SELLCRAP2VARS or not SELLCRAP2VARS.showBagCrapValueCheckboxState then
        displayFrame:Hide() 
        HighlightCrap()
        return 
    end
    displayFrame:Show()
    displayFrame.text:SetText(calculateCrapValue())
    HighlightCrap()
end

C_Timer.NewTicker(0.5, function()
    RefreshUI()
end)

function SELLCRAP2:showBagCrapValue(show) 
    RefreshUI()
end