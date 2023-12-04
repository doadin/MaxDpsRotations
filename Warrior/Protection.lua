local _, addonTable = ...

--- @type MaxDps
if not MaxDps then
	return
end

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

function Warrior:Protection()
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
	classtable = MaxDps["SpellTable"]

	if targets > 1 then
		return Warrior:ProtectionMultiTarget()
	end

	return Warrior:ProtectionSingleTarget()
end



function Warrior:ProtectionSingleTarget()
	--Cast Avatar Icon Avatar on cooldown
	if talents[classtable.Avatar] and cooldown[classtable.Avatar].ready then
        return classtable.Avatar
    end
	--Cast Demoralizing Shout Icon Demoralizing Shout on cooldown (only with Booming Voice Icon Booming Voice).
	if cooldown[classtable.DemoralizingShout].ready then
        return classtable.DemoralizingShout
    end
	--Cast Ravager Icon Ravager
	if cooldown[classtable.Ravager].ready then
        return classtable.Ravager
    end
	--Cast Thunderous Roar Icon Thunderous Roar
	if talents[classtable.ThunderousRoar] and cooldown[classtable.ThunderousRoar].ready then
        return classtable.ThunderousRoar
    end
	--Cast Shield Charge Icon Shield Charge
	if talents[classtable.ShieldCharge] and cooldown[classtable.ShieldCharge].ready then
        return classtable.ShieldCharge
    end
	--Cast Spear of Bastion Icon Spear of Bastion
	if talents[classtable.SpearofBastion] and cooldown[classtable.SpearofBastion].ready then
        return classtable.SpearofBastion
    end
	--Cast Shield Slam Icon Shield Slam on cooldown
	if cooldown[classtable.ShieldSlam].ready then
        return classtable.ShieldSlam
    end
	--Cast Thunder Clap Icon Thunder Clap on cooldown
	if cooldown[classtable.ThunderClap].ready then
        return classtable.ThunderClap
    end
	--Cast Execute Icon Execute, if you do not need Rage for survivability
	if targethealthPerc < 20 and cooldown[classtable.Execute].ready then
		return classtable.Execute
	end
	--Cast Revenge Icon Revenge, if you do not need Rage for survivability
	if cooldown[classtable.Revenge].ready then
		return classtable.Revenge
	end
end

function Warrior:ProtectionMultiTarget()
	--Cast Ravager Icon Ravager.
	if cooldown[classtable.Ravager].ready then
        return classtable.Ravager
    end
	--Cast Thunderous Roar Icon Thunderous Roar
	if cooldown[classtable.ThunderousRoar].ready then
        return classtable.ThunderousRoar
    end
	--Cast Shield Charge Icon Shield Charge.
	if cooldown[classtable.ShieldCharge].ready then
        return classtable.ShieldCharge
    end
	--Cast Spear of Bastion Icon Spear of Bastion.
	if cooldown[classtable.SpearofBastion].ready then
        return classtable.SpearofBastion
    end
	--Cast Thunder Clap Icon Thunder Clap on cooldown.
	if cooldown[classtable.ThunderClap].ready then
        return classtable.ThunderClap
    end
	--Cast Shield Slam Icon Shield Slam on cooldown.
	if cooldown[classtable.ShieldSlam].ready then
        return classtable.ShieldSlam
    end
	--Cast Revenge Icon Revenge.
	if cooldown[classtable.Ravager].ready then
        return classtable.Ravager
    end
end