local currentWidgets = {}

function addWidgetToList(widget)
    currentWidgets[widget:GetName()] = widget
end

function getWidgetByName(widgetName)
    return currentWidgets[widgetName]
end

function destroyAllWidgets()
    for key, value in pairs(currentWidgets) do
        destroyWidget(value)
    end
end