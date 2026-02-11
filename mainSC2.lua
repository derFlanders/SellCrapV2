function SELLCRAP2:printSellValue(rawMoneyValue)
    if (rawMoneyValue > 0) then
        -- Icons auf die Standard-Pfad-Struktur aktualisiert
        local goldCoinIcon = "|TInterface\\Icons\\INV_Misc_Coin_01:12:12:0:0:64:64:4:60:4:60|t";
        local silverCoinIcon = "|TInterface\\Icons\\INV_Misc_Coin_03:12:12:0:0:64:64:4:60:4:60|t";
        local copperCoinIcon = "|TInterface\\Icons\\INV_Misc_Coin_05:12:12:0:0:64:64:4:60:4:60|t";

        local goldValue = math.floor(rawMoneyValue/10000);
        local silverValue = math.floor((rawMoneyValue-(goldValue*10000))/100);
        local copperValue = rawMoneyValue-(silverValue*100)-(goldValue*10000);

        local goldString = (goldValue > 0) and (goldValue..goldCoinIcon) or "";
        local silverString = (silverValue > 0) and (silverValue..silverCoinIcon) or "";
        local copperString = (copperValue > 0) and (copperValue..copperCoinIcon) or "";

        print("Selling crap for a total of "..goldString..silverString..copperString);
    end
end

function SELLCRAP2:sellCrap()
    local totalGreysValue = 0;
    -- Loop für Hauptrucksack (0) und die 4 Taschen-Slots (1-4)
    for bagNumber = 0, 4 do
        local slotsCount = C_Container.GetContainerNumSlots(bagNumber);
        for slotNumber = 1, slotsCount do
            local containerInfo = C_Container.GetContainerItemInfo(bagNumber, slotNumber);
            
            if (containerInfo and containerInfo.itemID) then
                -- GetItemInfo wird für den Verkaufspreis benötigt
                local _, _, quality, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(containerInfo.itemID);
                
                -- Qualität 0 = Grau (Poor)
                if (quality == 0 and itemSellPrice and itemSellPrice > 0) then
                    -- In der neuen API wird UseContainerItem zu C_Container.UseContainerItem
                    C_Container.UseContainerItem(bagNumber, slotNumber);
                    totalGreysValue = totalGreysValue + (containerInfo.stackCount * itemSellPrice);
                end
            end
        end
    end
    SELLCRAP2:printSellValue(totalGreysValue);
end

function SELLCRAP2:repair()
    local repairCost, canRepair = GetRepairAllCost();
    if (canRepair and repairCost > 0) then
        RepairAllItems();
    end
end    

-- Button Erstellung (MerchantFrame)
local sellCrapButton = CreateFrame("Button", nil, MerchantFrame);
sellCrapButton:SetPoint("TOP", MerchantFrame, "CENTER", 0, 195);
sellCrapButton:SetWidth(100);
sellCrapButton:SetHeight(30);
sellCrapButton:SetText("Sell Crap");
sellCrapButton:SetNormalFontObject("GameFontNormal");

-- Texturen zuweisen
local normalTexture = sellCrapButton:CreateTexture();
normalTexture:SetTexture("Interface/Buttons/UI-Panel-Button-Up");
normalTexture:SetTexCoord(0, 0.625, 0, 0.6875);
normalTexture:SetAllPoints();
sellCrapButton:SetNormalTexture(normalTexture);

local highlightTexture = sellCrapButton:CreateTexture();
highlightTexture:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight");
highlightTexture:SetTexCoord(0, 0.625, 0, 0.6875);
highlightTexture:SetAllPoints();
sellCrapButton:SetHighlightTexture(highlightTexture);

local pushedTexture = sellCrapButton:CreateTexture();
pushedTexture:SetTexture("Interface/Buttons/UI-Panel-Button-Down");
pushedTexture:SetTexCoord(0, 0.625, 0, 0.6875);
pushedTexture:SetAllPoints();
sellCrapButton:SetPushedTexture(pushedTexture);

sellCrapButton:SetScript("OnClick", function()
    SELLCRAP2:sellCrap();
end)

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("MERCHANT_SHOW");
eventFrame:SetScript("OnEvent", function()
    -- Prüfung ob SELLCRAP2VARS initialisiert wurde
    if (SELLCRAP2VARS) then
        if (SELLCRAP2VARS.autoSellCheckboxState) then
            SELLCRAP2:sellCrap();
        end
        if (SELLCRAP2VARS.autoRepairCheckboxState) then
            SELLCRAP2:repair();
        end
    end
end);