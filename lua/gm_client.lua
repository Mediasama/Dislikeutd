local GMItem = GM:createGMItem()

local nextObjectID = 0x70000100

-- НОВЫЙ БЛОК: Полный список всех GUI (включая систему покемонов)
local guiWindows = {
    -- Общие и старые окна
    "limitedTimeDrawNew", "likes", "illustration", "guideLibrary", "graphic",
    "gameMain", "g2042Transaction", "g2042StarProgress", "g2042SignIn",
    "g2042Shop", "g2042GoldExchange", "friend", "fragmentPool",
    "fragmentLottery", "editRegionTool", "decorationHouse", "decorationEdit",
    "dance", "dailyGoldCoinTurntable", "commonDialogS", "commonDialogC",
    "commonDialog", "centerTip", "cardPreviewPhoto", "cardDeletePhoto",
    "cardAutograph", "card", "buyConfirm", "turntableRewardDialog", 
    "transitions", "tradeDialogTip", "syntheticReward", "synthetic", 
    "signInRewardDialog", "shopDialog", "rideTips", "recommendShop", 
    "previewPalette", "pokemonWorldTips", "phone", "petStarTips", 
    "petSellBoard", "petSell", "petHeadInfo", "petHatchingDialog", 
    "petEvolveDialog", "petEggBuyConfirm", "petBag", "petAtlas2D", 
    "petAtlas", "palette", "openApplicationJumpAnimation", 
    "obtainRewardDialog", "npcDialog", "littleAtlas", "buyBuiltinGame", 
    "bulletScreen", "builtinGameReward", "builtinGameRemain", "builtinGame", 
    "bubbleTextBox", "bottomTip", "blackboardText", "blackboard", "actionControl",
    "toolbar", "takePhotos", "skillPokemonUsePreview", "skillEffectDetailTip",

    -- Система ПОКЕМОНОВ (из новых скриншотов)
    "pokemonWake", "pokemonTransitionMap", "pokemonTelegraph", "pokemonTaskDetail",
    "pokemonTask", "pokemonSwapResult", "pokemonSwapApply", "pokemonSwap",
    "pokemonSpecialDialog", "pokemonSelect", "pokemonRotaryTable", "pokemonRotaryResult",
    "pokemonRequestTeamDialog", "pokemonRequestPkDialog", "pokemonReplace",
    "pokemonRename", "pokemonRelease", "pokemonRegularGift", "pokemonRecovery",
    "pokemonPvP", "pokemonPopupUpgrade", "pokemonPlayerDialog", "pokemonPacket",
    "pokemonOthersPlayer", "pokemonOpenScreen", "pokemonMain", "pokemonLuckyWish",
    "pokemonLuckyTenTake", "pokemonLuckyProbability", "pokemonLuckyPool",
    "pokemonLuckyOnceTake", "pokemonLuckyExtra", "pokemonLuckyEgg", "pokemonLuckyDetails",
    "pokemonLearnSkill", "pokemonLeaderboardReward", "pokemonLeaderboardReceive",
    "pokemonLeaderboard", "pokemonItemDetail", "pokemonGuideComplete", "pokemonGuide",
    "pokemonGloryHall", "pokemonGloryDialog", "pokemonGiftBag", "pokemonEvolutionShow",
    "pokemonEvolution", "pokemonCommonTip", "pokemonCommonDialog", "pokemonCellMove",
    "pokemonCaptureRelease", "pokemonCapture", "pokemonBlockInputEvents",
    "pokemonBlessRemove", "pokemonBlessing", "pokemonBigMap", "pokemonBagStudySkill",
    "pokemonBag", "pokemon_three_select_one", "pokemon_starUp_popup", "pokemon_Shop",
    "pokemon_recharge_award", "pokemon_gold_exchange", "pokemon_base_interactionUI",

    -- Битвы, Питомцы и прочее
    "petsBook", "mutatePopup", "minimap", "guide_go_to_shop", "get_item_tip",
    "followPetPrivilegeTip", "dailyLottery", "cutscene", "cameraEdit",
    "buyGiftTip", "bookDetails", "battle_select_target", "battle_results",
    "battle_pre_animation", "battle_pokemon", "battle_main", "battle_effect_tip",
    "battle_dialog"
}

-- Автоматическое создание кнопок в папку "Все_GUI"
for _, guiName in ipairs(guiWindows) do
    GMItem["Все_GUI/" .. guiName] = function(self)
        UI:openWnd(guiName)
        print("Запрос на открытие GUI:", guiName)
    end
end

if GM.isOpen and World.openGM then
    WorldServer.BroadcastPacket({
      pid = "GMList",
      list = GM.GMList,
      btsList = GM.BTSGMList
    })
    self:sendPacket({
      pid = "ShowTip",
      tipType = 2,
      keepTime = 20,
      textKey = "\226\150\162FF^FF0000 \229\189\147\229\137\141\229\188\128\229\144\175\228\186\134\230\156\172\229\156\176\230\156\141\229\138\161\229\153\168GM\230\168\161\229\188\143\239\188\140\229\166\130\230\158\156\233\157\158\230\156\172\229\156\176\229\144\175\229\138\168\231\154\132\230\156\141\229\138\161\229\153\168\239\188\140\232\175\183\228\184\138\230\138\165"
    })
  end
  
  
GMItem["^FF0000Spam/Spam"] = GM:inputStr(function(self, BaseD)

    -- Если введена 1 — останавливаем спам
    if BaseD == "1" then
        self.stopSpamUltra = true
        print("UltraSpam остановлен.")
        return true
    end

    -- Включаем спам
    self.stopSpamUltra = false

    -- Функция спама
    local function spamLoop()
        if self.stopSpamUltra then
            return false -- прекращаем таймер
        end

        local packet = {
            pid = "ChatMessage",
            fromname = "Iikj",
            msg = "&$[9900DD]$" .. BaseD ..
                  "$& [S=vip_nameplate_10_plus.json] [S=vip_nameplate_10_plus.json] " ..
                  "[S=vip_nameplate_10_plus.json] [S=vip_nameplate_10plus.json] " ..
                  "[S=vip_nameplate_10_plus.json] [S=vip_nameplate_10plus.json]",
            type = self.selectChannel
        }

        Me:sendPacket(packet)
        return true -- продолжить таймер
    end

    -- Запуск таймера с интервалом 1 тик
    World.Timer(1, spamLoop)

    return true
end)

GMItem["^FF0000КРАШ/^FFAA00Сервер Краш"] = function()
    Client.ShowTip(3, " ЗАПУСК...", 3)
    
    local total = 0
    local timer = World.Timer(1, function()
        for i = 1, 50000 do
            pcall(function()
                Me:sendPacket({
                    pid = "testPacket",
                    counter = total + i,
                    data = {}
                })
            end)
        end
        total = total + 50000
        
        if total >= 1000000 then
            Client.ShowTip(3, " 1M", 5)
            return false
        end
        
        return true
    end)
end
  

GMItem["^FF0000RealHacks/^FF0000GcubeAddl"] = function(self)
    PlayerWallet:setMoneyCount("gDiamonds", 1000000)
end


GMItem["^FF0000RealHacks/^FF0000UnlockAlll"] = function(self)
    self:deltaLotteryTimes(1000)
end


GMItem["^FF0000RealHacks/^FF0000ChakraTck"] = function(self)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000StrengthTck"] = function(self)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000JumpTck"] = function(self)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000SpeedTck"] = function(self)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
end




GMItem["^00FF00NormalHacks/00FF00Fly"] = function(self)
    isOpenFly = not isOpenFly
    self:setFlyMode(isOpenFly and 1 or 0)
end

GMItem["^00FF00NormalHacks/00FF00NoClip"] = function(self)
    isOpenFly = not isOpenFly
    self:setFlyMode(isOpenFly and 1 or 0)
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getCurScene()
    scene:setEditorCanCollide(not scene:getEditorCanCollide())
end

GMItem["^00FF00NormalHacks/00FF00Camera"] = function(self)
    cameraMode = not cameraMode
    self:setCameraMode(cameraMode and true or false)
end

GMItem["^00FF00NormalHacks/00FF00SwimHack"] = function(self)
    cameraMode = not cameraMode
    self:setForceSwimMode(cameraMode and true or false)
end

GMItem["^00FF00NormalHacks/00FF00ClimbHack"] = function(self)
    cameraMode = not cameraMode
    self:setForceClimbMode(cameraMode and true or false, 1, 0)
end

GMItem["^00FF00NormalHacks/00FF00SetClimbDegress"] = GM:inputStr(function(self, Degress)
    self:setForceClimbMode(true, 1, Degress)
end)

GMItem["^00FF00NormalHacks/00FF00ChangeActor"] = GM:inputStr(function(self, value)
    self:changeActor(value)
end)

GMItem["^00FF00NormalHacks/00FF00ChangeNickName"] = GM:inputStr(function(self, value)
    self:setShowName(value)
end)

--[[GMItem["089/ChangePos"] = GM:inputStr(function(self, Num, self, Num2, self, Num3)
local playerPos = VectorUtil.newVector3(Num, Num2, Num3)
    self:setPosition(playerPos)
end)]]

GMItem["^00FF00NormalHacks/00FF00Reach"] = GM:inputStr(function(self, Value)
    local bm = Blockman.Instance()
    bm:setReachDistance(Value)
end)

GMItem["^00FF00NormalHacks/InfinityJump"] = function(self)
World.Timer(1, function()
local bm = Blockman.Instance()
bm:control():jump()
    return true
end)
end

GMItem["^00FF00NormalHacks/00FF00Emoji"] = GM:inputStr(function(self, ID)
    Me:sendPacket({
        pid = "PlayAnimoji",
        actionId = ID
   })
end)

--[[GMItem["089/SendMsg"] = function(self)
   local packet = {
   pid = "ChatMessage",
   fromname = "Iikj",
   msg = "Iikj", 
   type = self.selectChannel
   }
   Me:sendPacket(packet)
end]]

GMItem["^00FF00NormalHacks/00FF00UltraSpam"] = GM:inputStr(function(self, BaseD)
   World.Timer(1, function()
   local packet = {
   pid = "ChatMessage",
   fromname = "Iikj",
   msg = BaseD, 
   type = self.selectChannel
   }
   Me:sendPacket(packet)
   return true
end)
end)

--[[GMItem["089/2XScale"] = function(self)
local Data = Lib.v3(2, 2, 2)
local allEntity = World.CurWorld:getAllEntity()
		for _, _entity in pairs(allEntity) do
	    _entity:setActorScale(Data)
	    _entity:setData("actorScale", Data)  
	    end
end]]

GMItem["^00FF00NormalHacks/00FF00Suicide"] = function(self)
    self:onDead({
        from = self,
        cause = "GM_SUICIDE",
    })
end

--[[GMItem["089/kreeeest"] = function(self)
    player:sendPacket({
            pid = "PushClientSendPrivateChatEmoji",
            senderId = 48,
        })
end]]

--[[GMItem["089/获得方块名字"] = GM:inputStr(function(self, value)
    local arr = Lib.splitString(value, ",")
    if #arr ~= 3 then
        return
    end
    local pos = {x = arr[1], y = arr[2], z = arr[3]}
    player:setPosition(pos)
end)]] 

--[[GMItem["089/testttttt"] = GM:inputStr(function(self, tee)
    Interface.onAppActionTrigger(tee)
end)]]



GMItem["^00FF00NormalHacks/00FF00SetSpeed"] = GM:inputStr(function(self, Grav)
Player.CurPlayer:setProp("moveSpeed", Grav)
end)

GMItem["^00FF00NormalHacks/00FF00SetJumpHeight"] = GM:inputStr(function(self, Grav1)
Player.CurPlayer:setProp("jumpSpeed", Grav1)
end)

GMItem["^00FF00NormalHacks/00FF00SetBreakSpeed"] = GM:inputStr(function(self, Grav2)
Player.CurPlayer:setProp("breakTimeFactor", Grav2)
end)

GMItem["00FF00NormalHacks/00FF00SetClickDistance"] = GM:inputStr(function(self, Grav3)
Player.CurPlayer:setProp("clickDistance", Grav3)
end)







--[[GMItem["089/SetStepHeight"] = GM:inputStr(function(self, Grav7)
   Player.CurPlayer:setProp("stepHeight", Grav7)
end)]]

--[[GMItem["089/TREST"] = function(self)
   Lib.emitEvent(Event.EVENT_STOP_DEAD_COUNTDOWN)
    Lib.emitEvent(Event.EVENT_CLOSE_ALL_WND)
    Lib.emitEvent(Event.EVENT_EDIT_MAP_MAKING)
    if self.deathEffectTimer then
        self.deathEffectTimer()
    end
    if self.deleteDeathEffect then
        self.deleteDeathEffect()
    end
    World.Timer(5, function()
            local gameRootPath = CGame.Instance():getGameRootDir()
            CGame.instance:restartGame(gameRootPath, World.GameName, 0, true)
            Blockman.instance.singleGame = false
            return false
    end)
end

GMItem["089/TREST22"] = function(self)
Me:doHurt(Lib.v3(10, 10, 10))
end

GMItem["089/TREST23"] = function(self)
for userIDD = 16, 900000000, 16 do
CGame.instance:getShellInterface():onSendMessage(Define.privateMessageType.inviteMsg, userIDD)
end
end]]



--[[GMItem["089/TestS"] = function(self)
	--Blockman.instance.gameSettings:useVoxelTerrain(false)
--Blockman.instance:onSetClipboard("Www")
    local mapCfg = self.map.cfg
    mapCfg.canBreak = true
end]]



GMItem["g2030过场动画/客户端创建玩家npc"] = function(self)
    Game.EntitySpawn(Me, {
        objID = nextObjectID,
        cfgName = "myplugin/player1",
        actorName = "boy.actor",
        pos = Me:getPosition(),
        name = Me.name,
        curHp = 1,
        rideOnId = 0,
    }, function(entity)
        entity.isMovieEntity = true
        entity:updateHeadInfo()
    end)
    nextObjectID = nextObjectID + 1
end

local index = 0
local isShow = false
GMItem["g2033/关闭测试"] = function(self)
    Me:skipGuide()
end

GMItem["g2030/控制台显示日志"] = function(self)
    print("***********************************************************************************")
    Lib.logDebug("Hello World!")
    Lib.logInfo("Hello World!")
    Lib.logWarning("Hello World!")
    Lib.logError("Hello World!")
    Lib.logFatal("Hello World!")
    print("***********************************************************************************")
end

GMItem["g2030/显示隐藏UI"] = function(self)
    if not self.showFunc then
        self.showFunc = UI:hideOpenedWnd("skills")
    else
        self.showFunc()
        self.showFunc = nil
    end
end

GMItem["g2030Pet/测抽卡"] = function(self)
    local packet = {
        pid = "petDraw",
        poolID = 201
    }
    self:sendPacket(packet)
end

GMItem["g2030测试/闪白"] = function(self)
    UI:openWnd("simulatorEffect")
    local wnd = UI:getWnd("simulatorEffect")
    wnd:playScreenWhiteFlicker(function()
        --TODO
    end)
end

GMItem["g2030/传送"] = function(self)
    local pos = Me:getPosition()
    Me:setPosition(Lib.v3(pos.x, 5000, pos.z))
end

--GMItem["g2030测试/设置朝向"] = GM:inputNumber(function(self, yaw)
--    Me:setBodyYaw(yaw)
--    Me:setRotationYaw(yaw)
--end, 0)

GMItem["g2030测试/开始拍照"] = function(self)
    --Me:sendTrigger(Me, "START_CAMERA_MODE", Me)
    Me:startCameraMode()
end

GMItem["g2030测试/释放技能"] = function(self)
    local controlView = UI:getWnd("skills")
    Skill.Cast(controlView.skillList[2].name)
end

GMItem["g2030过场动画/跳过过场动画"] = function(self)
    Lib.emitEvent(Event.EVENT_SKIP_CUTSCENE)
end

GMItem["g2030/弹跳台"] = function(self)
    self:changeJumpState("JumpLaunchState")
end

GMItem["g2030过场动画/开始动作录制"] = function(self)
    if not self.recordAction then
        --self.recordActionFile = io.open("recordAction.txt", "a")
        self.recordAction = true
    end
end
GMItem["g2030过场动画/停止动作录制"] = function(self)
    if self.recordAction then
        --io.close(self.recordActionFile)
        --self.recordActionFile = nil
        self.recordAction = false
    end
end

GMItem["g2030/上腰带"] = function(self)
    self:exchangeEquip("myplugin/sash_simple")
end
GMItem["g2030/上腰带2"] = function(self)
    self:exchangeEquip("myplugin/sash_simple1")
end
GMItem["g2030/上武器"] = function(self)
    self:exchangeEquip("myplugin/weapon_simple")
end
GMItem["g2030/头顶文字改变"] = function(self)
    Lib.emitEvent("EVENT_TEST_1")
end

GMItem["g2033/购买麦克风和月卡"] = function(self)
    UI:openWnd("chatShop")
end

-----------------------------------Pet Model Test----------------------------------
GMItem["g2030Pet/检查是否存在宠物实体"] = function(self)
    print("==============================================")
    for k, v in pairs(Player.CurPlayer.equipPetList) do
        print("ridePos:", k, "entity Info:", Player.CurPlayer:getPet(v.objID))
    end
end
-----------------------------------Pet Model Test End-------------------------------

GMItem["g2030技能/击退技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_beatback")
end
GMItem["g2030技能/击飞技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_hitfly")
end
GMItem["g2030技能/3号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_03")
end
GMItem["g2030技能/4号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_04")
end
GMItem["g2030技能/5号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_05")
end
GMItem["g2030技能/6号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_06")
end
GMItem["g2030技能/7号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_07")
end
GMItem["g2030技能/8号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_08")
end
GMItem["g2030技能/9号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_09")
end
GMItem["g2030技能/10号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_10")
end
GMItem["g2030技能/11号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_11")
end
GMItem["g2030技能/12号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_12")
end
GMItem["g2030技能/13号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_13")
end
GMItem["g2030技能/14号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_14")
end
GMItem["g2030技能/15号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_15")
end
GMItem["g2030技能/16号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_16")
end
GMItem["g2030技能/17号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_17")
end
GMItem["g2030技能/18号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_18")
end
GMItem["g2030技能/19号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_19")
end
GMItem["g2030技能/20号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_20")
end
GMItem["g2030技能/眩晕技能"] = function(self)
    Skill.Cast("myplugin/player_dizziness_skill")
end
GMItem["g2030/隐藏自己"] = function(self)
    self:setActorHide(true)
end
GMItem["g2030/显示自己"] = function(self)
    self:setActorHide(false)
end

GMItem["雷电技能/ray1"] = function(self)
    Skill.Cast("myplugin/skill_lightning_ray_line_missile")
end

GMItem["雷电技能/ray2"] = function(self)
    Skill.Cast("myplugin/skill_lightning_ray_line")

end
GMItem["g2030-island-effect/显示加速度"] = function(self)
    print("---------------------self:moveAcc:"..self:prop("moveAcc").."--------------------------------")
    print("---------------------self:jumpSpeed:"..self:prop("jumpSpeed").."--------------------------------")
    print("---------------------self:moveSpeed:"..self:prop("moveSpeed").."--------------------------------")
end

GMItem["g2030Bgm/C"] = function(self)
    local path = self:prop("bgmSound")
    if path then
        print("-----------have bgmSound-------------")
    else
        print("-----------no bgmSound-------------")
    end
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        print("-----------is bgmSound Playing:-------------", tostring(TdAudioEngine.Instance():isPlaying(bgmsoundId)))
    end
end

GMItem["g2030Bgm/开"] = function(self)
    self:playGameBgm()
end

GMItem["g2030Bgm/关"] = function(self)
    self:stopGameBgm()
end



GMItem["g2030Bgm/暂停"] = function(self)
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        TdAudioEngine.Instance():pauseSound(bgmsoundId)
    end
end

GMItem["g2030Bgm/恢复"] = function(self)
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        TdAudioEngine.Instance():resumeSound(bgmsoundId)
    end
end

GMItem["开发/client内存单层分析"] = GM:inputStr(function(self, name)
    require("common.mem").List(tonumber(name), 1)
end, "1")

GMItem["g2033jump/Cbuff"] = function(self)
    local buffName = "myplugin/add_agility_buff"
    local buff = self:getTypeBuff("fullName", buffName)
    if buff then
        print("-----------have agility buff-------------")
    else
        print("-----------no agility buff-------------")
    end
end

local editRegionMode = false
GMItem["template/创建区域"] = function(self)
    local debugDraw = DebugDraw.instance
    if editRegionMode  and debugDraw:isEditRegionBoxEnabled() then
        debugDraw:setEnabled(false)
        debugDraw:setDrawRegionEnabled(false)
        debugDraw:setEditRegionBoxEnabled(false)
        UI:closeWnd("editRegionTool", 0)
    else
        editRegionMode = true
        if UI:isOpen("editRegionTool") then
            UI:getWnd("editRegionTool", true):onReload(0)
        else
            UI:openWnd("editRegionTool", 0)
        end
        debugDraw:setEnabled(true)
        debugDraw:setDrawRegionEnabled(true)
        debugDraw:setEditRegionBoxEnabled(true)

    end
    Me:cfg().collision = not debugDraw:isEditRegionBoxEnabled()
    Me:sendPacket({
        pid = "SetFly",
        isOpen = debugDraw:isEditRegionBoxEnabled()
    })
end

GMItem["Hacks/Global_Mining_Enable"] = function(self)
    World.KeepMiningMode = true
    local allRegions = World.CurWorld.regions
    for _, region in pairs(allRegions) do
        C_MineAreaMgr:initMineArea(region.map, region.cfg.id, region.min, region.max)
    end
    print("Mining mode enabled globally")
end

-- Отключает эффекты SafeZone, препятствий и скрытия интерфейса
GMItem["Hacks/Ignore_Region_Rules"] = function(self)
    World.IgnoreRegionEffects = not World.IgnoreRegionEffects
    print("Ignore Region Rules:", World.IgnoreRegionEffects)
end

-- Мгновенная активация копания в текущей точке
GMItem["Hacks/Force_Mine_Action"] = function(self)
    if C_MineAreaMgr then
        C_MineAreaMgr:onPlayerEnterRegion(Me)
        print("Forcing MineAreaMgr action...")
    end
end

-- Телепортация к ближайшей богатой рудой зоне (тип break)
GMItem["Hacks/Teleport_to_Resources"] = function(self)
    local allRegions = World.CurWorld.regions
    for _, region in pairs(allRegions) do
        if region.cfg.type == "break" then
            local targetPos = (region.min + region.max) / 2
            Me:setPosition(targetPos)
            print("Teleported to mining region:", region.cfg.id)
            break
        end
    end
end

-- =========================================================================
-- GM ОТЛАДКА И ТЕСТИРОВАНИЕ: ИНСТРУМЕНТЫ, КАТАЛОГИ И ОПЦИИ РАЗРАБОТЧИКА
-- =========================================================================

-- Вспомогательная функция спавна/просмотра тестовой сущности
local function spawnDebugEntity(cfgId, customName)
    local PokemonConfig = T(Config, "PokemonConfig")
    local pkmCfg = PokemonConfig:getConfigById(cfgId)
    local fullName = pkmCfg and pkmCfg.fullName or ("myplugin/pet_" .. cfgId)
    local entityCfg = Entity.GetCfg(fullName)
    local pos = Me:getPosition()
    local spawnPos = Lib.v3(pos.x + 2, pos.y, pos.z + 2)

    Game.EntitySpawn(Me, {
        objID = nextObjectID,
        cfgName = fullName,
        actorName = (entityCfg and entityCfg.actorName) or (pkmCfg and pkmCfg.model) or "boy.actor",
        pos = spawnPos,
        name = customName or (pkmCfg and Lang:toText(pkmCfg.nameKey or "")) or tostring(cfgId),
        curHp = 100,
        rideOnId = 0,
    }, function(entity)
        if entity then
            entity.isMovieEntity = true
            if entity.updateHeadInfo then
                entity:updateHeadInfo()
            end
            print(string.format("[DebugSpawn] Entity spawned: ID %s (%s) at objID: %s", tostring(cfgId), tostring(customName), tostring(nextObjectID)))
        end
    end)
    nextObjectID = nextObjectID + 1
end

-- -------------------------------------------------------------------------
-- 1. КАТАЛОГИЗАЦИЯ СКРЫТЫХ ТЕСТОВЫХ ЭНТИТИ И ПРОТОТИПОВ
-- -------------------------------------------------------------------------

-- Категория А: Лимитированные энтити тестовых пулов (Pool 1 / Flash-сессии)
GMItem["Тест_Сущности/Категория_А/10500501 - Апофис (Pool 1 - 250 круток)"] = function(self)
    spawnDebugEntity(10500501, "Apophis [Апофис]")
end

GMItem["Тест_Сущности/Категория_А/10301301 - Валькирия (Pool 1 - 500 круток)"] = function(self)
    spawnDebugEntity(10301301, "Valkyrja [Валькирия]")
end

GMItem["Тест_Сущности/Категория_А/10500401 - Варус (Pool 1 Доп. слот)"] = function(self)
    spawnDebugEntity(10500401, "Varus [Варус]")
end

GMItem["Тест_Сущности/Категория_А/10301401 - Карнал (Pool 1 Доп. слот)"] = function(self)
    spawnDebugEntity(10301401, "Karnal [Карнал]")
end

-- Категория Б: Элитные отладочные сущности (Pool 2 / Картографические модули)
GMItem["Тест_Сущности/Категория_Б/10501501 - Little Edas (Элитный пул)"] = function(self)
    spawnDebugEntity(10501501, "Little Edas [Маленькая Эдас]")
end

GMItem["Тест_Сущности/Категория_Б/10501502 - Edas (Элитный пул)"] = function(self)
    spawnDebugEntity(10501502, "Edas [Эдас]")
end

GMItem["Тест_Сущности/Категория_Б/10200901 - Kulos (Элитный пул)"] = function(self)
    spawnDebugEntity(10200901, "Kulos [Кулос]")
end

GMItem["Тест_Сущности/Категория_Б/10100801 - Dark Fang (Карты 5-6)"] = function(self)
    spawnDebugEntity(10100801, "Dark Fang [Темный клык]")
end

GMItem["Тест_Сущности/Категория_Б/10100802 - Black Claw (Карты 5-6)"] = function(self)
    spawnDebugEntity(10100802, "Black Claw [Черный коготь]")
end

GMItem["Тест_Сущности/Категория_Б/10100901 - Little Ali (Карты 5-6)"] = function(self)
    spawnDebugEntity(10100901, "Little Ali [Маленький Али]")
end

GMItem["Тест_Сущности/Категория_Б/10100902 - Ali (Карты 5-6)"] = function(self)
    spawnDebugEntity(10100902, "Ali [Али]")
end

-- Категория В: Резервные / невыпущенные прототипы из исходных файлов
GMItem["Тест_Сущности/Категория_В/1 - Чармандер"] = function(self)
    spawnDebugEntity(1, "Charmander [Чармандер]")
end

GMItem["Тест_Сущности/Категория_В/2 - Чармелеон"] = function(self)
    spawnDebugEntity(2, "Charmeleon [Чармелеон]")
end

GMItem["Тест_Сущности/Категория_В/3 - Чаризард"] = function(self)
    spawnDebugEntity(3, "Charizard [Чаризард]")
end

GMItem["Тест_Сущности/Категория_В/10400901 - Дин-а-линг"] = function(self)
    spawnDebugEntity(10400901, "Ding-a-ling [Дин-а-линг]")
end

GMItem["Тест_Сущности/Категория_В/10400902 - Эл"] = function(self)
    spawnDebugEntity(10400902, "El [Эл]")
end

GMItem["Тест_Сущности/Категория_В/10401301 - Эмир"] = function(self)
    spawnDebugEntity(10401301, "Emir [Эмир]")
end

GMItem["Тест_Сущности/Категория_В/10201101 - Лофи"] = function(self)
    spawnDebugEntity(10201101, "Lofi [Лофи]")
end

GMItem["Тест_Сущности/Категория_В/10201102 - Лорд"] = function(self)
    spawnDebugEntity(10201102, "Lord [Лорд]")
end

GMItem["Тест_Сущности/Категория_В/10300901 - Рафаэль (1)"] = function(self)
    spawnDebugEntity(10300901, "Raphael [Рафаэль 1]")
end

GMItem["Тест_Сущности/Категория_В/10300902 - Рафаэль (2)"] = function(self)
    spawnDebugEntity(10300902, "Raphael [Рафаэль 2]")
end

GMItem["Тест_Сущности/Категория_В/10100401 - Птица в небе"] = function(self)
    spawnDebugEntity(10100401, "Sky Bird [Птица в небе]")
end

GMItem["Тест_Сущности/Категория_В/10401201 - Куру"] = function(self)
    spawnDebugEntity(10401201, "Kuru [Куру]")
end

GMItem["Тест_Сущности/Категория_В/10100702 - Бебелла"] = function(self)
    spawnDebugEntity(10100702, "Bebella [Бебелла]")
end

-- -------------------------------------------------------------------------
-- 2. ВЕКТОР 1: УПРАВЛЕНИЕ ТАЙМЕРАМИ И СЕССИЯМИ FLASH POOL TAB (win_pokemonLuckyEgg)
-- -------------------------------------------------------------------------
local flashPoolHooked = false
local mockFlashActive = true

GMItem["Вектор_1_FlashPool/Переключить_видимость_FlashTab"] = function(self)
    mockFlashActive = not mockFlashActive
    local wnd = UI:getWnd("pokemonLuckyEgg")
    if not flashPoolHooked and wnd then
        local raw_getFlashTabRemainTime = wnd.getFlashTabRemainTime
        wnd.getFlashTabRemainTime = function(instance)
            if mockFlashActive then
                return 86400 -- Возвращаем 24 часа активности для теста
            else
                return 0
            end
        end
        flashPoolHooked = true
    end

    if wnd and UI:isOpen("pokemonLuckyEgg") then
        wnd:updateTabBtnShow()
        wnd:startFlashTabDownTime()
    end
    print(string.format("[FlashPool] Mock FlashTab state set to: %s", tostring(mockFlashActive)))
end

GMItem["Вектор_1_FlashPool/Принудительно_открыть_Flash_Пул"] = function(self)
    mockFlashActive = true
    UI:openWnd("pokemonLuckyEgg")
    local wnd = UI:getWnd("pokemonLuckyEgg")
    if wnd then
        if not flashPoolHooked then
            wnd.getFlashTabRemainTime = function(instance)
                return 86400
            end
            flashPoolHooked = true
        end
        wnd.curSelectTab = Define.LuckyEggTabType.flashTab
        wnd:updateTabBtnShow()
        wnd:updateTabViewShow()
    end
    print("[FlashPool] Force opened PokemonLuckyEgg on Flash Pool Tab.")
end

GMItem["Вектор_1_FlashPool/Симуляция_Крутки_Резерв_Валюты_x1"] = function(self)
    -- Вектор 1: Если у тестера отсутствуют item_ticket_01, задействуем механизм pokemon_lucky_price.csv (n_currencyType=0, payCurrency/gDiamonds)
    local priceData = T(Config, "PokemonLuckyPriceConfig"):getDataByPoolIdAndTakeType(Define.LuckyEggTabType.flashTab, 0)
    local bagTicketNum = Me:getTrayItemCountByFullName(priceData.fullName)
    print(string.format("[LuckyDraw Test] Ticket count: %d, required: %d, currencyType: %d, price: %d",
        bagTicketNum, priceData.ticket_count, priceData.currencyType, priceData.currency_count))
    if bagTicketNum < priceData.ticket_count then
        print("[LuckyDraw Test] No tickets available. Using fallback direct currency simulation (n_currencyType=0 / payCurrency / gDiamonds).")
    end
    Me:sendPacket({
        pid = "takeLuckyEggAward",
        tabType = Define.LuckyEggTabType.flashTab,
        takeType = 0
    })
end

GMItem["Вектор_1_FlashPool/Симуляция_Крутки_Резерв_Валюты_x10"] = function(self)
    local priceData = T(Config, "PokemonLuckyPriceConfig"):getDataByPoolIdAndTakeType(Define.LuckyEggTabType.flashTab, 1)
    local bagTicketNum = Me:getTrayItemCountByFullName(priceData.fullName)
    print(string.format("[LuckyDraw Test x10] Ticket count: %d, required: %d, currencyType: %d, price: %d",
        bagTicketNum, priceData.ticket_count, priceData.currencyType, priceData.currency_count))
    if bagTicketNum < priceData.ticket_count then
        print("[LuckyDraw Test x10] No tickets available. Fallback: direct simulation.")
    end
    Me:sendPacket({
        pid = "takeLuckyEggAward",
        tabType = Define.LuckyEggTabType.flashTab,
        takeType = 1
    })
end

-- -------------------------------------------------------------------------
-- 3. ВЕКТОР 2: ТЕСТИРОВАНИЕ ТРИГГЕРОВ КОНТРОЛЬНЫХ ТОЧЕК (Milestone Extra Awards)
-- -------------------------------------------------------------------------
GMItem["Вектор_2_Milestones/Установить_Счетчик_Flash_250_(Апофис)"] = function(self)
    if DebugEnv and DebugEnv.simulateTakeCount then
        DebugEnv:simulateTakeCount(Define.LuckyEggTabType.flashTab, 250)
    else
        local luckyEggInfo = Me:getLuckyEggInfo()
        luckyEggInfo[Define.LuckyEggTabType.flashTab] = luckyEggInfo[Define.LuckyEggTabType.flashTab] or {}
        luckyEggInfo[Define.LuckyEggTabType.flashTab].totalTakeCounts = 250
        Me:setLuckyEggInfo(luckyEggInfo)
        Lib.emitEvent(Event.EVENT_UPDATE_LUCKY_EGG_INFO)
    end
    print("[Milestone] Set Flash totalTakeCounts = 250 (Apophis trigger).")
end

GMItem["Вектор_2_Milestones/Установить_Счетчик_Flash_500_(Валькирия)"] = function(self)
    if DebugEnv and DebugEnv.simulateTakeCount then
        DebugEnv:simulateTakeCount(Define.LuckyEggTabType.flashTab, 500)
    else
        local luckyEggInfo = Me:getLuckyEggInfo()
        luckyEggInfo[Define.LuckyEggTabType.flashTab] = luckyEggInfo[Define.LuckyEggTabType.flashTab] or {}
        luckyEggInfo[Define.LuckyEggTabType.flashTab].totalTakeCounts = 500
        Me:setLuckyEggInfo(luckyEggInfo)
        Lib.emitEvent(Event.EVENT_UPDATE_LUCKY_EGG_INFO)
    end
    print("[Milestone] Set Flash totalTakeCounts = 500 (Valkyrja trigger).")
end

GMItem["Вектор_2_Milestones/Забрать_Чекпоинт_10009_(Апофис)"] = function(self)
    Me:sendPacket({
        pid = "receiveLuckyEggExtraAward",
        extraId = 10009
    })
    print("[Milestone] Dispatched receiveLuckyEggExtraAward for 10009 (Apophis).")
end

GMItem["Вектор_2_Milestones/Забрать_Чекпоинт_10014_(Валькирия)"] = function(self)
    Me:sendPacket({
        pid = "receiveLuckyEggExtraAward",
        extraId = 10014
    })
    print("[Milestone] Dispatched receiveLuckyEggExtraAward for 10014 (Valkyrja).")
end

GMItem["Вектор_2_Milestones/Пакетная_выдача_всех_доступных_наград_Flash"] = function(self)
    if DebugEnv and DebugEnv.batchClaimMilestones then
        DebugEnv:batchClaimMilestones(Define.LuckyEggTabType.flashTab)
    else
        local luckyEggInfo = Me:getLuckyEggInfo()
        local curCount = (luckyEggInfo[Define.LuckyEggTabType.flashTab] and luckyEggInfo[Define.LuckyEggTabType.flashTab].totalTakeCounts) or 0
        local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
        local extraData = PokemonLuckyExtraConfig:getDataByPoolId(Define.LuckyEggTabType.flashTab)
        for _, item in pairs(extraData or {}) do
            if curCount >= item.take_count then
                Me:sendPacket({
                    pid = "receiveLuckyEggExtraAward",
                    extraId = item.id
                })
            end
        end
    end
end

-- -------------------------------------------------------------------------
-- 4. ВЕКТОР 3: СТРЕСС-ТЕСТИРОВАНИЕ СИНХРОНИЗАЦИИ ИНВЕНТАРЯ И ЛОГИРОВАНИЕ
-- -------------------------------------------------------------------------
GMItem["Вектор_3_Network/Переключить_Логирование_Пакетов"] = function(self)
    if DebugEnv then
        DebugEnv:setPacketLogEnabled(not DebugEnv.packetLogEnabled)
    else
        print("[DebugEnv] DebugEnv module not ready.")
    end
end

GMItem["Вектор_3_Network/Эмуляция_Задержки_0ms_(Откл)"] = function(self)
    if DebugEnv then
        DebugEnv:setLatency(0)
    end
end

GMItem["Вектор_3_Network/Эмуляция_Задержки_200ms"] = function(self)
    if DebugEnv then
        DebugEnv:setLatency(200)
    end
end

GMItem["Вектор_3_Network/Эмуляция_Задержки_500ms"] = function(self)
    if DebugEnv then
        DebugEnv:setLatency(500)
    end
end

GMItem["Вектор_3_Network/Стресс_тест_Синхронизации_Box_Pets_x20"] = function(self)
    print("[StressTest] Executing 20 rapid inventory & extra check calls to verify Box Pets sync...")
    for i = 1, 20 do
        World.Timer(i, function()
            Me:sendPacket({
                pid = "requestCurServerTime"
            })
            local boxPets = Me:getValue("packetPetList") or {}
            print(string.format("[StressTest Iteration %d] Client Box Pets count: %d", i, #boxPets))
            return false
        end)
    end
end

-- -------------------------------------------------------------------------
-- 5. ULTRA_pup / ВЫДАЧА ТИКЕТОВ ГАЧИ (ETicket, UTicket, SpecialTicket)
-- -------------------------------------------------------------------------

-- Элитные билеты (item_ticket_02) из ежедневного задания taskid = 24
GMItem["^FFFF00ULTRA_pup/ETicket"] = function()
    for i = 1, 100 do
        Me:sendPacket({
            pid = "GetTaskReward",
            taskid = 24
        })
    end
    print("[Ticket GM] Sent 100x GetTaskReward for taskid 24 (item_ticket_02 Elite Ticket).")
end

-- Стандартные / универсальные билеты (item_ticket_03) из ежедневного задания taskid = 16
GMItem["^FFFF00ULTRA_pup/UTicket"] = function()
    for i = 1, 100 do
        Me:sendPacket({
            pid = "GetTaskReward",
            taskid = 16
        })
    end
    print("[Ticket GM] Sent 100x GetTaskReward for taskid 16 (item_ticket_03 Universal Ticket).")
end

-- Специальные лимитированные билеты (item_ticket_01) для пула 1 (Апофис, Валькирия и др.)
-- В заданиях task 1-24 нет item_ticket_01. Поэтому предоставляем прямой способ и альтернативные варианты:
GMItem["^FFFF00ULTRA_pup/SpecialTicket"] = function()
    -- Метод 1: Прямое добавление в трей/инвентарь игрока
    if Me.obtainItemsByFullName then
        pcall(function()
            Me:obtainItemsByFullName("myplugin/item_ticket_01", 100, "gm_ticket")
        end)
    end
    -- Метод 2: Покупка/получение через пакет регулярных наборов (good 105 из regular_gift_item = 30x item_ticket_01)
    for i = 1, 4 do
        Me:sendPacket({
            pid = "requestBugRegularGift",
            itemId = 10020,
            buyCount = 1
        })
    end
    -- Метод 3: Начисление gDiamonds для прямой крутки без тикетов (pokemon_lucky_price.csv fallback: 50 / 500 gDiamonds)
    if PlayerWallet and PlayerWallet.setMoneyCount then
        pcall(function()
            PlayerWallet:setMoneyCount("gDiamonds", 1000000)
        end)
    end
    print("[Ticket GM] Dispatched Special Limited Tickets (myplugin/item_ticket_01) & fallback currency balance.")
end

-- Дубликат в меню Вектор 1 для удобства
GMItem["Вектор_1_FlashPool/Выдать_Спец_Тикеты_Flash_(item_ticket_01)"] = function(self)
    GMItem["^FFFF00ULTRA_pup/SpecialTicket"]()
end

return GMItem
