local frame = CreateFrame("Frame")
local alertFrame

local function createMacro(playerName)
    local commandText = string.format("/gremove %s", playerName)

    local macroID = GetMacroIndexByName("MyGuildKickMacro")
    if macroID and macroID > 0 then
        EditMacro(macroID, "MyGuildKickMacro", nil, commandText)
    else
        CreateMacro("MyGuildKickMacro", "INV_MISC_QUESTIONMARK", commandText, 1)
    end
end

local function showAlert(playerName)
    if not alertFrame then
        alertFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
        alertFrame:SetSize(200, 100)
        alertFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -10)
        alertFrame.text = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        alertFrame.text:SetPoint("CENTER", alertFrame, "CENTER")
        alertFrame:Hide()

        alertFrame.closeButton = CreateFrame("Button", nil, alertFrame, "UIPanelCloseButton")
        alertFrame.closeButton:SetPoint("TOPRIGHT", alertFrame, "TOPRIGHT")
        alertFrame.closeButton:SetScript("OnClick", function() alertFrame:Hide() end)
    end

    alertFrame.text:SetText(string.format("%s has died!\nClick macro to remove.", playerName))
    alertFrame:Show()

    C_Timer.After(10, function() 
        if alertFrame:IsShown() then
            alertFrame:Hide()
        end
    end)
end

frame:SetScript("OnEvent", function(self, event, msg)
    if event == "CHAT_MSG_GUILD_DEATHS" then
        print("Received death announcement:", msg)

        local bracketContent = string.match(msg, "%[(.-)%]")
        local level = string.match(msg, "has died at level (%d+)")
        local location = string.match(msg, "while in ([%w%s]+),")
        local mob = string.match(msg, "slain by: ([%w%s]+)%.$")
        
        if bracketContent and level and location and mob then
            createMacro(bracketContent)
            showAlert(bracketContent)
        else
            print("Failed to capture content within brackets.")
        end
    end
end)

frame:RegisterEvent("CHAT_MSG_GUILD_DEATHS")

-- Create the macro on addon load
local initialCommandText = "/gremove <Name Here>"
local initialMacroID = GetMacroIndexByName("MyGuildKickMacro")
if not initialMacroID or initialMacroID == 0 then
    CreateMacro("MyGuildKickMacro", "INV_MISC_QUESTIONMARK", initialCommandText, 1)
end