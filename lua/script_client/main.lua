require("script_client.lib")
require("script_client.ui.ui_manager")
require("script_client.entity.entity")
require("script_client.entity.entity_event")
require("script_client.player.player")
require("script_client.player.player_dialog")
require("script_client.player.player_packet")
require("script_client.player.player_control")
require("script_client.player.player_pokemon_swap")
require("script_client.player.player_ui_manager")
require("script_client.world.map")
require("script_client.world.region")
require("script_client.skill.timeLine")
require("script_client.skill.skill")
require("script_client.skill.base")
require("script_client.missile.missile_client")
require("script_client.entity.interaction_event")
require("script_client.rank")
require("script_client.ui.main_ui_menu_manager")
require("script_client.event_cache")
local debugport = require("common.debugport")
Sound3DRollOffType = {
  INVERSE = 1048576,
  LINEAR = 2097152,
  LINEARSQUARE = 4194304,
  INVERSETAPERED = 8388608,
  CUSTOM = 67108864
}
local main = {}
local tickEngineHandler = L("tickEngineHandler", handle_tick)
local grassMoveTable = Lib.newWeakTable({})
local grassMoveEntityPool = {}
local grassMovePoolPtr = 1

function handle_tick(frameTime)
  tickEngineHandler(frameTime)
end

Lib.subscribeKeyDownEvent("key.f1", function()
  if Me.disableControl then
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end
end)
local flag = false
Lib.subscribeKeyDownEvent("key.f11", function()
  if Me.disableControl then
    if not flag then
      Game.RunTelnet(1, debugport.port)
    else
      Game.RunTelnet(2, debugport.serverPort)
    end
    flag = not flag
  end
end)

function main:init()
  Blockman.instance:setAutoSetMaxFps(false)
  CGame.Instance():SetMaxFps(World.cfg.maxFps)
  self:initLog()
  self:setGlobalProperty()
  self:loadConfig()
  local MovieManager = require("script_client.movie.movie_manager")
  MovieManager:init()
  local BattleActionManager = require("script_client.battle.battle_action_manager")
  BattleActionManager:init()
  local PokemonManager = require("script_client.pokemon.pokemon_manager")
  PokemonManager:init()
  local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
  UIRedDotMgr:init()
  UIMgr.MainUIMenuManage:init()
  self:initClientGrassAni()
end

function main:initClientGrassAni()
  World.Timer(1, function()
    for i = 1, 10 do
      grassMoveEntityPool[i] = EntityClient.CreateClientEntity({
        cfgName = "myplugin/tallgrass_move",
        pos = {
          x = 0,
          y = -3,
          z = 0
        },
        name = ""
      })
    end
    Lib.subscribeEvent(Event.EVENT_BLOCK_POS_CHANGE, function(oldPos, curPos)
      self:actionGrassAni(oldPos, curPos)
    end)
    World.LightTimer("grassCheck", 1, function()
      if Me.removed then
        return false
      end
      local curPos = Me:curBlockPos()
      if self.oldPos == curPos then
        return true
      end
      if not self.oldPos then
        self.oldPos = curPos
      end
      Lib.emitEvent(Event.EVENT_BLOCK_POS_CHANGE, self.oldPos, curPos)
      return true
    end)
  end)
end

function main:actionGrassAni(oldPos, curPos)
  self.oldPos = curPos
  if World.CurMap:getBlockConfigId(curPos) == 31 then
    local keyName = curPos.x .. "-" .. curPos.y .. "-" .. curPos.z
    if grassMoveTable[keyName] then
      grassMoveTable[keyName .. "Timer"]()
    else
      grassMoveTable[keyName] = grassMoveEntityPool[grassMovePoolPtr]
      if grassMovePoolPtr == 10 then
        grassMovePoolPtr = 1
      else
        grassMovePoolPtr = grassMovePoolPtr + 1
      end
    end
    if not grassMoveTable[keyName].map then
      grassMoveTable[keyName]:setMap(World.CurMap)
    end
    grassMoveTable[keyName]:setPosition({
      x = curPos.x + 0.5,
      y = curPos.y,
      z = curPos.z + 0.5
    })
    grassMoveTable[keyName]:updateUpperAction("move", -1)
    grassMoveTable[keyName .. "Timer"] = World.LightTimer("grassMoveTable", 15, function()
      World.LightTimer("grassMoveTable_n", 1, function()
        if not grassMoveTable[keyName] then
          return
        end
        grassMoveTable[keyName]:setPosition({
          x = 0,
          y = -3,
          z = 0
        })
        grassMoveTable[keyName] = nil
      end)
    end)
  end
end

function main:hideEngineUI()
  World.Timer(1, function()
    UI:closeWnd(UI:getWnd("skills", false))
    UI:closeWnd(UI:getWnd("topteamInfo", false))
    UI:closeWnd(UI:getWnd("playerList", false))
    UI:closeWnd(UI:getWnd("reload", false))
    UI:getWnd("battle_results"):onHide()
  end)
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)
end

function main:initLog()
  Lib.setDebugLog(CGame.Instance():isDebuging())
end

function main:loadConfig()
  local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")
  PokemonRotaryTableConfig:init()
  local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")
  PokemonGloryHallConfig:init()
  local MainUiMenuBtnConfig = T(Config, "MainUiMenuBtnConfig")
  MainUiMenuBtnConfig:init()
  local PokemonLuckyRareConfig = T(Config, "PokemonLuckyRareConfig")
  PokemonLuckyRareConfig:init()
  local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
  PokemonLuckyPriceConfig:init()
  local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
  PokemonLuckyPkmConfig:init()
  local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
  PokemonLuckyExtraConfig:init()
  local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
  TriggerGiftConfig:init()
  local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
  RegularGiftItemConfig:init()
  local RegularGiftConfig = T(Config, "RegularGiftConfig")
  RegularGiftConfig:init()
  local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
  RechargeAwardConfig:init()
  local WorldCommonTipsConfig = T(Config, "WorldCommonTipsConfig")
  WorldCommonTipsConfig:init()
  local PayShopConfig = T(Config, "PayShopConfig")
  PayShopConfig:init()
  local SoundConfig = T(Config, "SoundConfig")
  SoundConfig:init()
  local GloryConfig = T(Config, "GloryConfig")
  GloryConfig:init()
  local PlayerExpConfig = T(Config, "PlayerExpConfig")
  PlayerExpConfig:init()
  local NormalBattleRewardConfig = T(Config, "NormalBattleRewardConfig")
  NormalBattleRewardConfig:init()
  local MainBattleRewardConfig = T(Config, "MainBattleRewardConfig")
  MainBattleRewardConfig:init()
  local SpriteBallConfig = T(Config, "SpriteBallConfig")
  SpriteBallConfig:init()
  local SkillConfig = T(Config, "SkillConfig")
  SkillConfig:init()
  local SkillEffectConfig = T(Config, "SkillEffectConfig")
  SkillEffectConfig:init()
  local DailyLotteryConfig = T(Config, "DailyLotteryConfig")
  DailyLotteryConfig:init()
  local NPCConfig = T(Config, "NPCConfig")
  NPCConfig:init()
  local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
  NPCPokemonConfig:init()
  local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
  PokemonLeaderboardRewardConfig:init()
  local MapConfig = T(Config, "MapConfig")
  MapConfig:init()
  local RegionConfig = T(Config, "RegionConfig")
  RegionConfig:init()
  local GymConfig = T(Config, "GymConfig")
  GymConfig:init()
  local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
  GymDefaultRankConfig:init()
  local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
  PokemonGuideConfig:init()
  local SkillPerformConfig = T(Config, "SkillPerformConfig")
  SkillPerformConfig:init()
  local ActiveRewardConfig = T(Config, "ActiveRewardConfig")
  ActiveRewardConfig:init()
  local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
  PokemonTaskConfig:init()
end

function main:getGrassMoveTable()
  return grassMoveTable
end

-- =========================================================================
-- DEBUG ENVIRONMENT, PACKET LOGGER & LATENCY INJECTION (Vector 2 & 3)
-- =========================================================================
DebugEnv = DebugEnv or {}
DebugEnv.packetLogEnabled = false
DebugEnv.latencyMs = 0 -- Configurable latency in milliseconds (0 = disabled)
DebugEnv.packetHistory = {}
DebugEnv.maxHistory = 100

function DebugEnv:logPacket(direction, packet)
  if not self.packetLogEnabled then
    return
  end
  local record = {
    time = os.time(),
    direction = direction, -- "OUT" or "IN"
    pid = packet and packet.pid or "unknown",
    data = packet
  }
  table.insert(self.packetHistory, record)
  if #self.packetHistory > self.maxHistory then
    table.remove(self.packetHistory, 1)
  end
  print(string.format("[DebugEnv Network][%s] PID: %s | Payload: %s", direction, tostring(record.pid), Lib.v2s and Lib.v2s(packet, 2) or tostring(packet)))
end

function DebugEnv:setPacketLogEnabled(enable)
  self.packetLogEnabled = enable
  print(string.format("[DebugEnv] Packet logging set to: %s", tostring(enable)))
end

function DebugEnv:setLatency(ms)
  self.latencyMs = tonumber(ms) or 0
  print(string.format("[DebugEnv] Latency injection set to: %d ms", self.latencyMs))
end

-- Hook Me:sendPacket / Player:sendPacket for outgoing packets and latency injection
local raw_sendPacket = Player.sendPacket
function Player:sendPacket(packet, callBack)
  if DebugEnv.packetLogEnabled then
    DebugEnv:logPacket("OUT", packet)
  end

  if DebugEnv.latencyMs and DebugEnv.latencyMs > 0 then
    local ticks = math.max(1, math.floor(DebugEnv.latencyMs / 50))
    World.Timer(ticks, function()
      raw_sendPacket(self, packet, callBack)
    end)
  else
    raw_sendPacket(self, packet, callBack)
  end
end

-- Hook handles for incoming packet inspection
local raw_pushLuckyEggResult = Player.PackageHandlers.pushLuckyEggResult
if raw_pushLuckyEggResult then
  Player.PackageHandlers.pushLuckyEggResult = function(player, packet)
    if DebugEnv.packetLogEnabled then
      DebugEnv:logPacket("IN", packet)
    end
    raw_pushLuckyEggResult(player, packet)
  end
end

local raw_receiveLuckyExtraSuccess = Player.PackageHandlers.receiveLuckyExtraSuccess
if raw_receiveLuckyExtraSuccess then
  Player.PackageHandlers.receiveLuckyExtraSuccess = function(player, packet)
    if DebugEnv.packetLogEnabled then
      DebugEnv:logPacket("IN", packet)
    end
    raw_receiveLuckyExtraSuccess(player, packet)
  end
end

-- Helper for Vector 2: Fast counter initialization and batch milestone emulation
function DebugEnv:simulateTakeCount(poolId, count)
  local luckyEggInfo = Me:getLuckyEggInfo()
  luckyEggInfo[poolId] = luckyEggInfo[poolId] or {}
  luckyEggInfo[poolId].totalTakeCounts = count
  Me:setLuckyEggInfo(luckyEggInfo)
  Lib.emitEvent(Event.EVENT_UPDATE_LUCKY_EGG_INFO)
  print(string.format("[DebugEnv] Initialized totalTakeCounts for pool %s to %d", tostring(poolId), count))
end

function DebugEnv:batchClaimMilestones(poolId)
  local luckyEggInfo = Me:getLuckyEggInfo()
  local curCount = (luckyEggInfo[poolId] and luckyEggInfo[poolId].totalTakeCounts) or 0
  local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
  local extraData = PokemonLuckyExtraConfig:getDataByPoolId(poolId)
  local claimed = 0
  for _, item in pairs(extraData or {}) do
    if curCount >= item.take_count then
      Me:sendPacket({
        pid = "receiveLuckyEggExtraAward",
        extraId = item.id
      })
      claimed = claimed + 1
      print(string.format("[DebugEnv] Dispatched claim for milestone extraId: %s (take_count: %d, pkm_id: %s)", tostring(item.id), item.take_count, tostring(item.pkm_id)))
    end
  end
  print(string.format("[DebugEnv] Total milestones claimed in batch for pool %s: %d", tostring(poolId), claimed))
end

main:init()
return main
