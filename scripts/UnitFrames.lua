-- local PanelTarget = mainForm:GetChildChecked( "PanelTarget", false )
-- local ButtonTarget = PanelTarget:GetChildChecked( "ButtonTarget", false )

-- ButtonTarget:SetVal("button_label", userMods.ToWString('My target'))
-- ButtonTarget:SetTextColor(nil, "ffA330C9")

local myId
local targets = {}
local OKAY = "RENDERED"
local SYNCED = "SYNCED"
local TO_BE_SYNCED = "TO_BE_SYNCED"

function getColor(unitId)
    if unitId == unit.GetTarget(avatar.GetId()) then
        return COLOR_BUFF
    end

    return COLOR_NORMAL
end

function getTargetTarget(index)
    local targetTarget = unit.GetTarget(targets[index].unitId)

    return targetTarget and object.GetName(targetTarget)
end

function updateWidget(index)
    setTextColor(targets[index].widget, targets[index].color)
    local name = string.sub(str(object.GetName(targets[index].unitId)), 1, 15)
    local hp = str(targets[index].hp)
    local target = string.sub(str(targets[index].target), 1, 10)
    targets[index].widget:SetVal("value", name .. "-" .. hp .. "-" .. target)
    targets[index].status = OKAY
end

function removeTarget(index)
    local widgetName = str(targets[index].unitId)
    destroyWidget(getWidgetByName(widgetName))
    targetsShift(index)
end

function updateTargetTarget(index)
    local newTargetTarget = targets[index] and getTargetTarget(index) or nil

    if targets[index].target ~= newTargetTarget then
        targets[index].target = newTargetTarget
        targets[index].status = SYNCED
    end
end

function updateHp(index)
    local newHp = targets[index] and object.GetHealthInfo(targets[index].unitId).valuePercents or 100

    if targets[index].hp ~= newHp then
        targets[index].hp = newHp
        targets[index].status = SYNCED
    end
end

function updateColor(index)
    local newColor = targets[index] and getColor(targets[index].unitId) or COLOR_NORMAL

    if targets[index].color ~= newColor then
        targets[index].color = newColor
        targets[index].status = SYNCED
    end
end

function updateTarget(unitId)
    if not object.IsEnemy(unitId) or not object.IsInCombat(unitId) then
        return
    end

    local index = getIndex(targets, "unitId", unitId)

    if not index then
        addTarget(unitId)
    else
        targets[index].status = OKAY
        updateTargetTarget(index)
        updateColor(index)
        updateHp(index)
        if targets[index].status ~= OKAY then
            updateWidget(index)
        end
    end
end

function updateTargets()
    for index, target in pairs(targets) do
        target.status = TO_BE_SYNCED
    end

    for key, unitId in pairs(avatar.GetUnitList()) do
        updateTarget(unitId)
    end

    for index, target in pairs(targets) do
        if target.status == TO_BE_SYNCED then
            removeTarget(index)
        end
    end
end

function addTarget(unitId)
    local index = #targets + 1
    local widget = createTextView(str(unitId), 425, 250 + 25 * index, object.GetName(unitId))
    addWidgetToList(widget)
    targets[index] = {}
    targets[index].widget = widget
    targets[index].unitId = unitId
    updateTargetTarget(index)
    updateColor(index)
    updateHp(index)
    widget:SetTextScale(0.5)
end

function onEventSecondTimer(params)
    updateTargets(params)
end

function targetsShift(index)
    for i = index, #targets - 1 do
        targets[i] = targets[i+1]
        targets[i].status = SYNCED
        local widgetName = str(targets[i].unitId)
        move(getWidgetByName(widgetName), 425, 250 + 25 * i)
    end

    targets[#targets] = nil
end

function getIndex(array, key, value)
    for i = 1, #array do
        if array[i] and array[i][key] == value then
            return i
        end
    end

    return nil
end

--elseif unitId == unit.GetTarget(avatar.GetId()) then
--targets[unitId].color = COLOR_GOOD
--else
--targets[unitId].color = COLOR_NORMAL
--end

--function onUnitsChanged(params)
--    consoleLog("units changed")
--    removeTargets(params.despawned)
--    addTargets(params.spawned)
--end
--
--function onUnitSpawned(params)
--    consoleLog("unit spawned")
--end
--
--function onTextObjectClicked(params)
--    consoleLog(params)
--end
--
--function onUnitHealthChanged(params)
--    if params.unitId == myId then
--        return
--    end
--
--    for unitId, target in pairs(targetWidgets) do
--        consoleLog(unitId)
--        consoleLog(target)
--        if target.hp ~= object.GetHealthInfo(unitId).valuePercents then
--            updateWidget(unitId)
--        end
--    end
--end

function ButtonClick(params)
    consoleLog(params)
end

function init()
    myId = avatar.GetId()

    updateTargets()
    -- DnD.Init(PanelTarget,ButtonSettings,true)
    common.RegisterEventHandler(onEventSecondTimer, "EVENT_SECOND_TIMER")
    common.RegisterReactionHandler(ButtonClick, "LEFT_CLICK")
    common.RegisterReactionHandler(ButtonClick, "RIGHT_CLICK")
    --common.RegisterReactionHandler(onUnitsChanged, "EVENT_UNITS_CHANGED")
    --common.RegisterReactionHandler(onUnitSpawned, "EVENT_UNIT_SPAWNED")
    --common.RegisterReactionHandler(onTextObjectClicked, "mouse_left_click")
    --common.RegisterReactionHandler(onUnitHealthChanged, "EVENT_UNIT_HEALTH_CHANGED")
    --common.RegisterEventHandler(onUnitHealthChanged, "EVENT_UNIT_DAMAGE_RECEIVED")
    --common.RegisterEventHandler(onUnitHealthChanged, "EVENT_HEALING_RECEIVED")
end

if (avatar.IsExist()) then
    init()
else
    common.RegisterEventHandler(init, "EVENT_AVATAR_CREATED")
end