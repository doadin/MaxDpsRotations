local _, addonTable = ...

--- @type MaxDps
if not MaxDps then return end

local Warrior = addonTable.Warrior
local MaxDps = MaxDps
local UnitPower = UnitPower
local UnitHealth = UnitHealth
local UnitAura = UnitAura
local GetSpellDescription = GetSpellDescription
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local PowerTypeRage = Enum.PowerType.Rage

local fd
local cooldown
local buff
local talents
local targets
local rage
local rageMax
local rageDeficit
local targetHP
local targetmaxHP
local targethealthPerc
local curentHP
local maxHP
local healthPerc

local className, classFilename, classId = UnitClass("player")
local currentSpec = GetSpecialization()
local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
local classtable

--setmetatable(classtable, Warrior.spellMeta)

function Warrior:Fury()
	fd = MaxDps.FrameData
	cooldown = fd.cooldown
	buff = fd.buff
	talents = fd.talents
	targets = 1
	rage = UnitPower('player', PowerTypeRage)
	rageMax = UnitPowerMax('player', PowerTypeRage)
	rageDeficit = rageMax - rage
	targetHP = UnitHealth('target')
	targetmaxHP = UnitHealthMax('target')
	targethealthPerc = (targetHP / targetmaxHP) * 100
	curentHP = UnitHealth('player')
	maxHP = UnitHealthMax('player')
	healthPerc = (curentHP / maxHP) * 100
	classtable = MaxDps.SpellTable

    if targets > 1  then
        return Warrior:FurySingleTarget()
    end

    return Warrior:FurySingleTarget()
end

function Warrior:FurySingleTarget()
    --Cast Ravager Icon Ravager on the pull, or as soon as the target is well positioned and not expected to move.
    if cooldown[classtable.Ravager].ready then
        return classtable.Ravager
    end
    --Cast Recklessness Icon Recklessness on cooldown or whenever burst damage is needed.
    if cooldown[classtable.Recklessness].ready then
        return classtable.Recklessness
    end

    -- OdynsFury before avatar
    if MaxDps.tier[31] and MaxDps.tier[31].count >= 4 and cooldown[classtable.Avatar].ready and cooldown[classtable.OdynsFury].ready then
        return classtable.OdynsFury
    end

    --Cast Avatar Icon Avatar alongside Recklessness.
    if buff[classtable.Recklessness].up and cooldown[classtable.Avatar].ready then
        return classtable.Avatar
    end
    --Cast Spear of Bastion Icon Spear of Bastion during Recklessness and while Enraged.
    if buff[classtable.Recklessness].up and buff[classtable.Enrage].up and cooldown[classtable.SpearofBastion].ready then
        return classtable.SpearofBastion
    end
    --Cast Odyn's Fury Icon Odyn's Fury while Enraged. With the T31 set bonus, it should always be used before Avatar.
    if buff[classtable.Enrage].up and cooldown[classtable.OdynsFury].ready then
        return classtable.OdynsFury
    end
    -- TODO
    --Cast Avatar Icon Avatar as the initial 4-second Avatar buff triggered by Odyn's Fury is falling off in order to maximize DoT and Dancing Blades Icon Dancing Blades uptime.
    --if buff[classtable.Avatarbuff].duration < 4 and cooldown[classtable.Avatar].ready then
    --    return classtable.Avatar
    --end
    --Cast Bloodthirst Icon Bloodthirst when it has a 100% chance to crit through the Merciless Assault buff (generally 6 stacks with Recklessness).
    if buff[classtable.MercilessAssault].up and cooldown[classtable.Bloodthirst].ready then
        return classtable.Bloodthirst
    end
    --Cast Bloodbath Icon Bloodbath to consume the Reckless Abandon buff.
    if buff[classtable.RecklessAbandon].up and cooldown[classtable.Bloodbath].ready then
        return classtable.Bloodbath
    end
    --Cast Thunderous Roar Icon Thunderous Roar while Enraged.
    if buff[classtable.Enrage].up and cooldown[classtable.ThunderousRoar].ready then
        return classtable.ThunderousRoar
    end
    --Cast Onslaught Icon Onslaught while Enraged or with Tenderize Icon Tenderize talented.
    if buff[classtable.Enrage].up or talents[classtable.Tenderize] and cooldown[classtable.Onslaught].ready then
        return classtable.Onslaught
    end
    --Cast Execute Icon Execute only while the Furious Bloodthirst Icon Furious Bloodthirst buff is not active.
    if (not buff[classtable.FuriousBloodthirst].up) and targethealthPerc < 20 and rage >= 30 and cooldown[classtable.Execute].ready then
        return classtable.Execute
    end
    --Cast Rampage Icon Rampage to spend Rage and maintain Enrage.
    if rage >= 80 and cooldown[classtable.Rampage].ready then
        return classtable.Rampage
    end
    --Cast Execute Icon Execute as able.
    if rage >= 30 and targethealthPerc < 20 and cooldown[classtable.Execute].ready then
        return classtable.Execute
    end
    --Cast Bloodthirst Icon Bloodthirst on cooldown to reduce gaps in the rotation.
    if cooldown[classtable.Bloodthirst].ready then
        return classtable.Bloodthirst
    end
    --Cast Slam Icon Slam as a filler between Bloodthirst casts.
    if cooldown[classtable.Slam].ready then
        return classtable.Slam
    end
    --Cast Whirlwind Icon Whirlwind as a filler between Bloodthirst casts.
    if cooldown[classtable.Whirlwind].ready then
        return classtable.Whirlwind
    end
end

function Warrior:FuryMultiTarget()
    --Cast Ravager Icon Ravager on the pull, or as soon as the target is well positioned and not expected to move.
    if cooldown[classtable.Ravager].ready then
        return classtable.Ravager
    end
    --Cast Recklessness Icon Recklessness.
    if cooldown[classtable.Recklessness].ready then
        return classtable.Recklessness
    end
    --Cast Avatar Icon Avatar with Recklessness.
    if buff[classtable.Recklessness].up and cooldown[classtable.Avatar].ready then
        return classtable.Avatar
    end
    --Cast Charge Icon Charge whenever out of range.

    --Cast Whirlwind Icon Whirlwind when the buff is not active.
    if not buff[classtable.MeatCleaver].up and cooldown[classtable.Whirlwind].ready then
        return classtable.Whirlwind
    end
    --Cast Odyn's Fury Icon Odyn's Fury while Enraged or with Titanic Rage Icon Titanic Rage.
    if buff[classtable.Enrage].up or talents[classtable.TitanicRage] and cooldown[classtable.OdynsFury].ready then
        return classtable.OdynsFury
    end
    --Cast Spear of Bastion Icon Spear of Bastion while Enraged.
    if buff[classtable.Enrage].up and cooldown[classtable.SpearofBastion].ready then
        return classtable.SpearofBastion
    end
    --Cast Thunderous Roar Icon Thunderous Roar while Enraged.
    if buff[classtable.Enrage].up and cooldown[classtable.ThunderousRoar].ready then
        return classtable.ThunderousRoar
    end
    -- TODO
    --Cast Avatar Icon Avatar to trigger Odyn's Fury via Titan's Torment. When Titanic Rage Icon Titanic Rage is talented, delay until the initial Whirlwind buff stacks have fallen.
    --if buff[classtable.SuddenDeathAura].up and cooldown[classtable.Avatar].ready then
    --    return classtable.Avatar
    --end
    --Cast Bloodthirst Icon Bloodthirst when it has a 100% chance to crit through the Merciless Assault buff (generally 6 stacks with Recklessness).
    if buff[classtable.MercilessAssault].up and cooldown[classtable.Bloodthirst].ready then
        return classtable.Bloodthirst
    end
    --Cast Bloodbath Icon Bloodbath to consume the Reckless Abandon buff.
    if buff[classtable.RecklessAbandon].up and cooldown[classtable.Bloodbath].ready then
        return classtable.Bloodbath
    end
    --Cast Onslaught Icon Onslaught while Enraged or with Tenderize Icon Tenderize talented.
    if buff[classtable.Enrage].up or talents[classtable.Tenderize] and cooldown[classtable.Onslaught].ready then
        return classtable.Onslaught
    end
    --Cast Execute Icon Execute only while the Furious Bloodthirst Icon Furious Bloodthirst buff is not active.
    if not buff[classtable.FuriousBloodthirst].up and rage >= 30 and cooldown[classtable.Execute].ready then
        return classtable.Execute
    end
    --Cast Rampage Icon Rampage to spend Rage and maintain Enrage.
    if rage >= 80 and cooldown[classtable.Rampage].ready then
        return classtable.Rampage
    end
    --Cast Execute Icon Execute as able.
    if rage >= 20 and cooldown[classtable.Execute].ready then
        return classtable.Execute
    end
    --Cast Bloodthirst Icon Bloodthirst on cooldown to reduce gaps in the rotation.
    if cooldown[classtable.Bloodthirst].ready then
        return classtable.Bloodthirst
    end
    --Cast Slam Icon Slam as a filler between Bloodthirst casts.
    if cooldown[classtable.Slam].ready then
        return classtable.Slam
    end
    --Cast Whirlwind Icon Whirlwind as a filler between Bloodthirst casts.
    if cooldown[classtable.Whirlwind].ready then
        return classtable.Whirlwind
    end
end

