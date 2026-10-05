local addonName = ...
local data = RaidIntelData
local mainFrame
local bodyText
local specText
local urlBox
local buildButton
local contentButtons = {}
local languageButtons = {}
local sourceLabel
local selectedContent = "raid"
local selectedBuildID
local selectedBuildContext
local language = "ptBR"

local text = {
    ptBR = {
        package = "Pacote local v%s - atualizado em %s.",
        localData = "Os dados sao locais; o addon nao consulta o Wowhead pela internet.",
        noGuide = "Ainda nao ha guia cadastrado para esta especializacao.",
        sourceHelp = "As fontes abaixo podem ser usadas para consultar os guias.",
        patch = "Patch: ",
        noProfile = "Ainda nao ha dados verificados para este modo de jogo.",
        bis = "EQUIPAMENTO BIS",
        stats = "PRIORIDADE DE ATRIBUTOS",
        enchants = "ENCANTAMENTOS",
        other = "OUTRAS RECOMENDACOES",
        source = "Fonte do guia: ",
        unknownSource = "Fonte nao informada",
        updated = "Dados atualizados em: ",
        overview = "VISAO GERAL",
        popularity = "POPULARIDADE",
        sampleSize = "Tamanho da amostra: ",
        talents = "TALENTOS",
        gems = "GEMAS",
        gear = "EQUIPAMENTO",
        rotation = "ROTACAO",
        build = "Build: ",
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
        sourceHelp = "Use the sources below to look up guides.",
        patch = "Patch: ",
        noProfile = "No verified data is available for this content type yet.",
        bis = "BEST-IN-SLOT GEAR",
        stats = "STAT PRIORITY",
        enchants = "ENCHANTMENTS",
        other = "OTHER RECOMMENDATIONS",
        source = "Guide source: ",
        unknownSource = "Source not specified",
        updated = "Data updated: ",
        overview = "OVERVIEW",
        popularity = "POPULARITY",
        sampleSize = "Sample size: ",
        talents = "TALENTS",
        gems = "GEMS",
        gear = "GEAR",
        rotation = "ROTATION",
        build = "Build: ",
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

    local classData = data.classes and data.classes[classFile]
    if not classData or not classData.specializations then
        return nil
    end

    return classData.specializations[tostring(specID)]
end

local function localized(value)
    if type(value) ~= "table" then
        return value
    end

    return value[language] or value.enUS or value.ptBR
end

local function appendList(lines, title, values)
    if type(values) ~= "table" or #values == 0 then
        return
    end

    table.insert(lines, title)
    for _, value in ipairs(values) do
        local line = value
        if type(value) == "table" then
            local slot = localized(value.slot)
            local name = localized(value.name or value.value)
            line = (slot and (slot .. ": ") or "") .. (name or "")
            local note = localized(value.note)
            if note then
                line = line .. " (" .. note .. ")"
            end
        else
            line = localized(value)
        end
        if line and line ~= "" then
            table.insert(lines, "- " .. line)
        end
    end
    table.insert(lines, "")
end

local function makeBodyText(record, profile)
    local lines = {
        string.format(t("package"), data.version, data.updatedAt),
        t("localData"),
        "",
    }

    if not record then
        table.insert(lines, t("noGuide"))
        table.insert(lines, "")
        table.insert(lines, t("sourceHelp"))
        return table.concat(lines, "\n")
    end

    local patch = data.gameVersion and data.gameVersion.patch
    if patch and patch ~= "" then
        table.insert(lines, t("patch") .. patch)
        table.insert(lines, "")
    end

    if not profile then
        table.insert(lines, t("noProfile"))
        return table.concat(lines, "\n")
    end

    if profile.name then
        table.insert(lines, t("build") .. (localized(profile.name) or ""))
        table.insert(lines, "")
    end

    if profile.overview then
        table.insert(lines, t("overview"))
        table.insert(lines, localized(profile.overview))
        table.insert(lines, "")
    end

    if profile.popularity then
        table.insert(lines, t("popularity"))
        local description = localized(profile.popularity.summary or profile.popularity.description)
        if description then
            table.insert(lines, description)
        end
        if profile.popularity.sampleSize then
            table.insert(lines, t("sampleSize") .. profile.popularity.sampleSize)
        end
        table.insert(lines, "")
    end

    if profile.talents then
        table.insert(lines, t("talents"))
        local importString = localized(profile.talents.importString)
        local description = localized(profile.talents.description)
        if importString then
            table.insert(lines, importString)
        end
        if description then
            table.insert(lines, description)
        end
        table.insert(lines, "")
    end

    appendList(lines, t("stats"), profile.stats)
    appendList(lines, t("gems"), profile.gems)
    appendList(lines, t("enchants"), profile.enchants)
    appendList(lines, t("bis"), profile.bisItems)
    appendList(lines, t("gear"), profile.gear)
    appendList(lines, t("rotation"), profile.rotation)
    appendList(lines, t("other"), profile.recommendations)

    if profile.sources and #profile.sources > 0 then
        local firstSource = profile.sources[1]
        table.insert(lines, t("source") .. (firstSource.name or t("unknownSource")))
        for _, source in ipairs(profile.sources) do
            if source.url then
                table.insert(lines, source.url)
            end
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

local function getBuildIDs(content)
    local buildIDs = {}
    if content and type(content.builds) == "table" then
        for buildID in pairs(content.builds) do
            table.insert(buildIDs, buildID)
        end
        table.sort(buildIDs)
    end
    return buildIDs
end

local function refreshView()
    local classFile, specID, specName = getPlayerSpecialization()
    local _, className = UnitClass("player")
    local record = getSpecRecord(classFile, specID)
    local content = record and record.contents and record.contents[selectedContent]
    local profile
    local buildIDs = getBuildIDs(content)
    local context = classFile and specID
        and (classFile .. ":" .. specID .. ":" .. selectedContent)

    if selectedBuildContext ~= context then
        selectedBuildContext = context
        selectedBuildID = nil
    end

    if content and content.builds and #buildIDs > 0 then
        local defaultBuildID = content.defaultBuildId
        if not selectedBuildID or not content.builds[selectedBuildID] then
            selectedBuildID = content.builds[defaultBuildID] and defaultBuildID or buildIDs[1]
        end
        profile = content.builds[selectedBuildID]
    end

    if specName and className then
        specText:SetText(className .. " - " .. specName)
    else
        specText:SetText(t("unavailable"))
    end

    bodyText:SetText(makeBodyText(record, profile))
    local contentHeight = math.max(bodyText:GetStringHeight() + 12, 1)
    bodyText:GetParent():SetHeight(contentHeight)

    if buildButton then
        if profile then
            local buildName = localized(profile.name) or selectedBuildID
            buildButton:SetText(t("build") .. buildName)
            buildButton:Show()
            buildButton:SetEnabled(#buildIDs > 1)
        else
            buildButton:Hide()
        end
    end
end

local function cycleBuild()
    local classFile, specID = getPlayerSpecialization()
    local record = getSpecRecord(classFile, specID)
    local content = record and record.contents and record.contents[selectedContent]
    local buildIDs = getBuildIDs(content)
    if #buildIDs < 2 then
        return
    end

    for index, buildID in ipairs(buildIDs) do
        if buildID == selectedBuildID then
            selectedBuildID = buildIDs[(index % #buildIDs) + 1]
            refreshView()
            return
        end
    end

    selectedBuildID = buildIDs[1]
    refreshView()
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
    title:SetText("Az Codex")

    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)
    createLanguageButtons()

    buildButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    buildButton:SetSize(180, 24)
    buildButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 296, -70)
    buildButton:SetScript("OnClick", cycleBuild)
    buildButton:Hide()

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
