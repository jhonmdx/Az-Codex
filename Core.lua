local addonName = ...
local data = RaidIntelData
local mainFrame
local bodyText
local specText
local urlBox
local contentButtons = {}
local languageButtons = {}
local sourceLabel
local selectedContent = "raid"
local language = "ptBR"

local text = {
    ptBR = {
        package = "Pacote local v%s - atualizado em %s.",
        localData = "Os dados sao locais; o addon nao consulta o Wowhead pela internet.",
        noGuide = "Ainda nao ha guia cadastrado para esta especializacao.",
        addGuide = "Adicione em Data.lua um registro para a chave classe:specID.",
        sourceHelp = "As fontes abaixo podem ser usadas para consultar os guias.",
        patch = "Patch: ",
        noProfile = "Ainda nao ha dados verificados para este modo de jogo.",
        addProfile = "Preencha raid ou mythicPlus neste registro em Data.lua.",
        bis = "EQUIPAMENTO BIS",
        unnamedItem = "Item sem nome",
        stats = "PRIORIDADE DE ATRIBUTOS",
        enchants = "ENCANTAMENTOS",
        unnamedEnchant = "Encantamento sem nome",
        other = "OUTRAS RECOMENDACOES",
        source = "Fonte do guia: ",
        unknownSource = "Fonte nao informada",
        updated = "Dados atualizados em: ",
        unavailable = "Especializacao indisponivel",
        raid = "Raide",
        mythicPlus = "Mitico+",
        selected = " (selecionado)",
        sourceLabel = "Fontes (clique para copiar o endereco):",
        loaded = "carregado. Use /raidintel para abrir.",
    },
    enUS = {
        package = "Local pack v%s - updated %s.",
        localData = "Data is stored locally; the addon does not fetch Wowhead online.",
        noGuide = "No guide is available for this specialization yet.",
        addGuide = "Add a record in Data.lua using the class:specID key.",
        sourceHelp = "Use the sources below to look up guides.",
        patch = "Patch: ",
        noProfile = "No verified data is available for this content type yet.",
        addProfile = "Fill in raid or mythicPlus in this Data.lua record.",
        bis = "BEST-IN-SLOT GEAR",
        unnamedItem = "Unnamed item",
        stats = "STAT PRIORITY",
        enchants = "ENCHANTMENTS",
        unnamedEnchant = "Unnamed enchantment",
        other = "OTHER RECOMMENDATIONS",
        source = "Guide source: ",
        unknownSource = "Source not specified",
        updated = "Data updated: ",
        unavailable = "Specialization unavailable",
        raid = "Raid",
        mythicPlus = "Mythic+",
        selected = " (selected)",
        sourceLabel = "Sources (click to copy the address):",
        loaded = "loaded. Type /raidintel to open.",
    },
}

local function t(key)
    return text[language][key]
end

local function getPlayerSpecialization()
    local _, classFile = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID, specName

    if specIndex then
        specID, specName = GetSpecializationInfo(specIndex)
    end

    return classFile, specID, specName
end

local function getSpecRecord(classFile, specID)
    if not classFile or not specID then
        return nil
    end

    return data.specs[classFile .. ":" .. specID]
end

local function makeBodyText(record, profile)
    local lines = {
        string.format(t("package"), data.version, data.updatedAt),
        t("localData"),
        "",
    }

    if not record then
        table.insert(lines, t("noGuide"))
        table.insert(lines, t("addGuide"))
        table.insert(lines, "")
        table.insert(lines, t("sourceHelp"))
        return table.concat(lines, "\n")
    end

    if record.patch then
        table.insert(lines, t("patch") .. record.patch)
        table.insert(lines, "")
    end

    if not profile then
        table.insert(lines, t("noProfile"))
        table.insert(lines, t("addProfile"))
        return table.concat(lines, "\n")
    end

    if profile.summary then
        table.insert(lines, profile.summary)
        table.insert(lines, "")
    end

    if profile.bisItems and #profile.bisItems > 0 then
        table.insert(lines, t("bis"))
        for _, item in ipairs(profile.bisItems) do
            local itemText = item.slot and (item.slot .. ": ") or ""
            itemText = itemText .. (item.name or t("unnamedItem"))
            if item.note then
                itemText = itemText .. " (" .. item.note .. ")"
            end
            table.insert(lines, "- " .. itemText)
        end
        table.insert(lines, "")
    end

    if profile.stats and #profile.stats > 0 then
        table.insert(lines, t("stats"))
        for _, stat in ipairs(profile.stats) do
            table.insert(lines, "- " .. stat)
        end
        table.insert(lines, "")
    end

    if profile.enchants and #profile.enchants > 0 then
        table.insert(lines, t("enchants"))
        for _, enchant in ipairs(profile.enchants) do
            local enchantText = enchant.slot and (enchant.slot .. ": ") or ""
            enchantText = enchantText .. (enchant.name or t("unnamedEnchant"))
            table.insert(lines, "- " .. enchantText)
        end
        table.insert(lines, "")
    end

    if profile.recommendations and #profile.recommendations > 0 then
        table.insert(lines, t("other"))
        for _, recommendation in ipairs(profile.recommendations) do
            table.insert(lines, "- " .. recommendation)
        end
        table.insert(lines, "")
    end

    if profile.sourceName or profile.sourceUrl then
        table.insert(lines, t("source") .. (profile.sourceName or t("unknownSource")))
        if profile.sourceUrl then
            table.insert(lines, profile.sourceUrl)
        end
        table.insert(lines, "")
    end

    if profile.updatedAt then
        table.insert(lines, t("updated") .. profile.updatedAt)
    end

    return table.concat(lines, "\n")
end

local function updateContentButtons()
    for content, button in pairs(contentButtons) do
        local label = content == "raid" and t("raid") or t("mythicPlus")
        if content == selectedContent then
            label = label .. t("selected")
        end
        button:SetText(label)
    end
end

local function refreshView()
    local classFile, specID, specName = getPlayerSpecialization()
    local _, className = UnitClass("player")
    local record = getSpecRecord(classFile, specID)
    local profile = record and record[selectedContent]

    if specName and className then
        specText:SetText(className .. " - " .. specName)
    else
        specText:SetText(t("unavailable"))
    end

    bodyText:SetText(makeBodyText(record, profile))
    local contentHeight = math.max(bodyText:GetStringHeight() + 12, 1)
    bodyText:GetParent():SetHeight(contentHeight)
end

local function createContentButtons()
    local options = {
        { key = "raid", label = "raid" },
        { key = "mythicPlus", label = "mythicPlus" },
    }

    for index, option in ipairs(options) do
        local contentKey = option.key
        local button = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        button:SetSize(130, 24)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20 + ((index - 1) * 138), -70)
        button:SetText(t(option.label))
        button:SetScript("OnClick", function()
            selectedContent = contentKey
            updateContentButtons()
            refreshView()
        end)
        contentButtons[contentKey] = button
    end

    updateContentButtons()
end

local function updateLanguageButtons()
    for locale, button in pairs(languageButtons) do
        local label = locale == "ptBR" and "PT-BR" or "EN"
        button:SetText(locale == language and label .. " *" or label)
    end
end

local function setLanguage(locale)
    language = locale
    RaidIntelDB.language = locale
    sourceLabel:SetText(t("sourceLabel"))
    updateContentButtons()
    updateLanguageButtons()
    refreshView()
end

local function createLanguageButtons()
    for index, locale in ipairs({ "ptBR", "enUS" }) do
        local selectedLocale = locale
        local button = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        button:SetSize(54, 20)
        button:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -42 - ((index - 1) * 58), -17)
        button:SetText(selectedLocale == "ptBR" and "PT-BR" or "EN")
        button:SetScript("OnClick", function()
            setLanguage(selectedLocale)
        end)
        languageButtons[selectedLocale] = button
    end
    updateLanguageButtons()
end

local function createSourceButtons()
    for index, source in ipairs(data.sources) do
        local sourceInfo = source
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local button = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        button:SetSize(220, 24)
        button:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 18 + (column * 236), 80 - (row * 30))
        button:SetText(sourceInfo.name)
        button:SetScript("OnClick", function()
            urlBox:SetText(sourceInfo.url)
            urlBox:SetFocus()
            urlBox:HighlightText()
        end)
    end
end

local function createMainFrame()
    mainFrame = CreateFrame("Frame", "RaidIntelMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(520, 500)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:Hide()

    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -18)
    title:SetText("Raid Intel")

    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)
    createLanguageButtons()

    specText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    specText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    specText:SetPoint("RIGHT", mainFrame, "RIGHT", -20, 0)
    specText:SetJustifyH("LEFT")

    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -104)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -36, 144)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(420, 1)
    scrollFrame:SetScrollChild(content)

    bodyText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bodyText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    bodyText:SetWidth(420)
    bodyText:SetJustifyH("LEFT")
    bodyText:SetJustifyV("TOP")
    bodyText:SetSpacing(3)

    sourceLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sourceLabel:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 112)
    sourceLabel:SetText(t("sourceLabel"))

    urlBox = CreateFrame("EditBox", nil, mainFrame, "InputBoxTemplate")
    urlBox:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 24, 20)
    urlBox:SetSize(466, 24)
    urlBox:SetAutoFocus(false)
    urlBox:SetTextInsets(4, 4, 0, 0)
    urlBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    createContentButtons()
    createSourceButtons()
    table.insert(UISpecialFrames, "RaidIntelMainFrame")
end

local function toggleMainFrame()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        refreshView()
        mainFrame:Show()
    end
end

SLASH_RAIDINTEL1 = "/raidintel"
SlashCmdList.RAIDINTEL = function()
    toggleMainFrame()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        if type(RaidIntelDB) ~= "table" then
            RaidIntelDB = {}
        end
        if RaidIntelDB.language == "ptBR" or RaidIntelDB.language == "enUS" then
            language = RaidIntelDB.language
        else
            RaidIntelDB.language = language
        end
        createMainFrame()
        print(addonName .. " " .. t("loaded"))
    elseif unit == "player" and mainFrame and mainFrame:IsShown() then
        refreshView()
    end
end)
