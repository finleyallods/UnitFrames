local wtChat

function consoleLog(message)
    if common.IsWString(message) then
        sendMessage(userMods.FromWString(message))
    elseif (type(message) == "table") then
        for key, value in pairs(message) do
            sendMessage(key .. ": {")
            consoleLog(value)
            sendMessage("}")
        end
    else
        sendMessage(tostring(message))
    end
end

function debugMessage(message)
    if debugMode then
        sendMessage(message)
    end
end

function sendMessage(message)
    local fontSize = 14
    local format = "<body alignx='left' fontname='AllodsWest' fontsize='" .. (fontSize)
    format = format .. "' shadow='1' ><rs class='color'><r name='text'/></rs></body>"

    local valuedText = common.CreateValuedText()
    valuedText:SetFormat(userMods.ToWString(format))
    valuedText:SetClassVal("color", "LogColorWhite")
    valuedText:SetVal("text", userMods.ToWString(message))

    local chatLog = stateMainForm:GetChildUnchecked("ChatLog", false);
    wtChat = chatLog and chatLog:GetChildUnchecked("Container", true) or stateMainForm:GetChildUnchecked("Chat", true)
    wtChat:PushFrontValuedText(valuedText)
end

