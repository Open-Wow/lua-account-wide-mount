--[[
                                                                 __      __       __                                  __
                                                                /  |    /  \     /  |                                /  |
    ______    _______   _______   ______   __    __  _______   _$$ |_   $$  \   /$$ |  ______   __    __  _______   _$$ |_
    /      \  /       | /       | /      \ /  |  /  |/       \ / $$   |  $$$  \ /$$$ | /      \ /  |  /  |/       \ / $$   |
    $$$$$$  |/$$$$$$$/ /$$$$$$$/ /$$$$$$  |$$ |  $$ |$$$$$$$  |$$$$$$/   $$$$  /$$$$ |/$$$$$$  |$$ |  $$ |$$$$$$$  |$$$$$$/
    /    $$ |$$ |      $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |  $$ | __ $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |  $$ | __
    /$$$$$$$ |$$ \_____ $$ \_____ $$ \__$$ |$$ \__$$ |$$ |  $$ |  $$ |/  |$$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ |  $$ |  $$ |/  |
    $$    $$ |$$       |$$       |$$    $$/ $$    $$/ $$ |  $$ |  $$  $$/ $$ | $/  $$ |$$    $$/ $$    $$/ $$ |  $$ |  $$  $$/
    $$$$$$$/  $$$$$$$/  $$$$$$$/  $$$$$$/   $$$$$$/  $$/   $$/    $$$$/  $$/      $$/  $$$$$$/   $$$$$$/  $$/   $$/    $$$$/
                                                                                                               Without AIO
  @Original_Author : iThorgrim
  This script allow player to learn mount on connect, levelup.

  @Open-Wow Github : https://github.com/Open-Wow
  @AzerothCore Community : https://discord.gg/PaqQRkd
  Thanks for your patience <3.

]] --

-- Require list of all mount
local mount_listing = require('mount_list')

local accMount = {}

accMount.Config = {

  -- Option for developers
  dbname = 'R1_Eluna'
}

CharDBExecute("CREATE TABLE IF NOT EXISTS `" ..accMount.Config.dbname.."`.`account_mount` ( `accountid` INT(10) NOT NULL, `spell` INT(10), PRIMARY KEY (`accountid`, `spell`));")

function accMount.getMount(event, player, spellid)
  if mount_listing[spellid] then
    if not player:GetData('account_mount_'..spellid) then
      player:SetData('account_mount_'..spellid, spellid)
    end
  end

  if ((spellId == 33388) or (spellId == 33391) or (spellId == 34090) or (spellId == 34091)) then
    accMount.setMount(player)
  end
end
RegisterPlayerEvent(40, accMount.getMount)

function accMount.setMount(player)
  local pLevel = player:GetLevel()
  local spell

  if pLevel >= 20 or pLevel >= 30 then
    spell = 33388
  elseif pLevel >= 40 then
    spell = 33391
  elseif pLevel >= 40 then
    spell = 34090
  elseif pLevel >= 40 then
    spell = 34091
  end

  for spellid, mountInfo in pairs(mount_listing) do
    if player:GetData('account_mount_'..spellid) then
      if pLevel >= mountInfo[1] and player:HasSpell(spell) and not player:HasSpell(spellid) then
        if mountInfo[2] == 1 and player:IsAlliance() then
          player:LearnSpell(spellid)
        elseif mountInfo[2] == 2 and player:IsHorde() then
          player:LearnSpell(spellid)
        elseif mountInfo[2] == 0 then
          player:LearnSpell(spellid)
        end
      end
    end
  end
end

function accMount.onLogin(event, player)
  local pAcc = player:GetAccountId()

  local getMount = CharDBQuery('SELECT spell FROM '..accMount.Config.dbname..'.account_mount WHERE accountid = '..pAcc..';')
  if getMount then
    repeat
      player:SetData('account_mount_'..getMount:GetUInt32(0), getMount:GetUInt32(0))
    until not getMount:NextRow()
  end

  accMount.setMount(player)
end
RegisterPlayerEvent(3, accMount.onLogin)

function accMount.getAllMounts(event)
  for _, player in pairs(GetPlayersInWorld()) do
    accMount.onLogin(event, player)
  end
end
RegisterServerEvent(33, accMount.getAllMounts)

function accMount.onLogout(event, player)
  local pAcc = player:GetAccountId()

  for spellid, mountInfo in pairs(mount_listing) do
    if player:GetData('account_mount_'..spellid) then
      CharDBExecute('INSERT IGNORE INTO '..accMount.Config.dbname..'.account_mount VALUES ('..pAcc..', '..spellid..')')
    end
  end
end
RegisterPlayerEvent(4, accMount.onLogout)

function accMount.setAllMounts(event)
  for _, player in pairs(GetPlayersInWorld()) do
    accMount.onLogout(event, player)
  end
end
RegisterServerEvent(16, accMount.setAllMounts)

function accMount.onLevelUp(event, player, oldlevel)
  if (oldlevel == 19 or oldlevel == 39 or oldlevel == 59 or oldlevel == 69) then
    accMount.setMount(player)
  end
end
RegisterPlayerEvent(13, accMount.onLevelUp)
