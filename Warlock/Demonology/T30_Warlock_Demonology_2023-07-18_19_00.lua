local _, addonTable = ...;

-- @type MaxDps;
if not MaxDps then return end;
local Warlock = addonTable.Warlock;
local MaxDps = MaxDps;

local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;

local itemID = GetInventoryItemID('player', INVSLOT_MAINHAND);

local mainHandSubClassID = itemID and  select(13, GetItemInfo(itemID));

local TwoHanderWepCheck = mainHandSubClassID and (mainHandSubClassID == 1 or mainHandSubClassID == 5 or mainHandSubClassID == 8 or mainHandSubClassID == 10);

local DE = {
	GrimoireFelguard = 111898,
	SummonVilefiend = 264119,
	PowerSiphon = 264130,
	Demonbolt = 264178,
	ShadowBolt = 686,
	NetherPortal = 267217,
	Implosion = 196277,
	DemonicPower = 265273,
	HandOfGuldan = 105174,
	Guillotine = 386833,
	DemonicStrength = 267171,
	BilescourgeBombers = 267211,
	Tyrant = 265187,
	SacrificedSouls = 267214,
	TheExpendables = 387600,
	SoulStrike = 264057,
	SummonSoulkeeper = 386256,
	TormentedSoul = 386309,
	DemonicCore = 267102,
	Dreadstalkers = 104316,
	DemonicCalling = 205145,
	Doom = 603,
	Soulburn = 385899,
	SoulboundTyrant = 334585,
	GrandWarlocksDesign = 387084,
};
local A = {
};
function Warlock:Demonology()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local timeShift = fd.timeShift;
	local targets = fd.targets and fd.targets or 1;
	local gcd = fd.gcd;
	local timeToDie = fd.timeToDie;
	local mana = UnitPower('player', Enum.PowerType.Mana);
	local manaMax = UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local manaRegen = select(2,GetPowerRegen());
	local manaRegenCombined = manaRegen + mana;
	local manaDeficit = UnitPowerMax('player', Enum.PowerType.Mana) - mana;
	local manaTimeToMax = manaMax - mana / manaRegen;
	local soulShards = UnitPower('player', Enum.PowerType.SoulShards);
	local soulShardsMax = UnitPowerMax('player', Enum.PowerType.SoulShards);
	local soulShardsPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local soulShardsRegen = select(2,GetPowerRegen());
	local soulShardsRegenCombined = soulShardsRegen + soulShards;
	local soulShardsDeficit = UnitPowerMax('player', Enum.PowerType.SoulShards) - soulShards;
	local soulShardsTimeToMax = soulShardsMax - soulShards / soulShardsRegen;

	-- call_action_list,name=variables;
	local result = Warlock:DemonologyVariables();
	if result then
		return result;
	end

	-- call_action_list,name=tyrant,if=talent.summon_demonic_tyrant&(time-variable.next_tyrant)<=(variable.tyrant_prep_start+2)&cooldown.summon_demonic_tyrant.up&variable.np_condition;
	if talents[DE.SummonDemonicTyrant] and ( GetTime() - nextTyrant ) <= ( tyrantPrepStart + 2 ) and cooldown[DE.SummonDemonicTyrant].up and npCondition then
		local result = Warlock:DemonologyTyrant();
		if result then
			return result;
		end
	end

	-- call_action_list,name=tyrant,if=talent.summon_demonic_tyrant&(variable.tyrant_cd<=variable.tyrant_prep_start|cooldown.summon_demonic_tyrant.up&(buff.power_infusion.up|buff.nether_portal.up))&variable.np_condition;
	if talents[DE.SummonDemonicTyrant] and ( tyrantCd <= tyrantPrepStart or cooldown[DE.SummonDemonicTyrant].up and ( buff[DE.PowerInfusion].up or buff[DE.NetherPortal].up ) ) and npCondition then
		local result = Warlock:DemonologyTyrant();
		if result then
			return result;
		end
	end

	-- implosion,if=fight_remains<2*gcd;
	if talents[DE.Implosion] and mana >= 1000 and (timeToDie < 2 * gcd) then
		return DE.Implosion;
	end

	-- nether_portal,if=!talent.summon_demonic_tyrant&soul_shard>2|fight_remains<30;
	if talents[DE.NetherPortal] and cooldown[DE.NetherPortal].ready and soulShards >= 1 and currentSpell ~= DE.NetherPortal and (not talents[DE.SummonDemonicTyrant] and soulShards > 2 or timeToDie < 30) then
		return DE.NetherPortal;
	end

	-- call_action_list,name=items;
	local result = Warlock:DemonologyItems();
	if result then
		return result;
	end

	-- call_action_list,name=ogcd,if=buff.demonic_power.up|!talent.summon_demonic_tyrant&(buff.nether_portal.up|!talent.nether_portal);
	if buff[DE.DemonicPower].up or not talents[DE.SummonDemonicTyrant] and ( buff[DE.NetherPortal].up or not talents[DE.NetherPortal] ) then
		local result = Warlock:DemonologyOgcd();
		if result then
			return result;
		end
	end

	-- hand_of_guldan,if=buff.nether_portal.remains>cast_time;
	if soulShards >= 3 and currentSpell ~= DE.HandOfGuldan and (buff[DE.NetherPortal].remains > timeShift) then
		return DE.HandOfGuldan;
	end

	-- call_dreadstalkers,if=variable.tyrant_cd>cooldown+8*variable.shadow_timings;
	if tyrantCd > cooldown[DE.].remains + 8 * shadowTimings then
		return DE.CallDreadstalkers;
	end

	-- call_dreadstalkers,if=!talent.summon_demonic_tyrant|fight_remains<14;
	if not talents[DE.SummonDemonicTyrant] or timeToDie < 14 then
		return DE.CallDreadstalkers;
	end

	-- grimoire_felguard,if=!talent.summon_demonic_tyrant|fight_remains<cooldown.summon_demonic_tyrant.remains_expected;
	if talents[DE.GrimoireFelguard] and cooldown[DE.GrimoireFelguard].ready and soulShards >= 1 and (not talents[DE.SummonDemonicTyrant] or timeToDie < cooldown[DE.SummonDemonicTyrant].remains) then
		return DE.GrimoireFelguard;
	end

	-- summon_vilefiend,if=!talent.summon_demonic_tyrant|variable.tyrant_cd>cooldown+variable.tyrant_prep_start|fight_remains<cooldown.summon_demonic_tyrant.remains_expected;
	if talents[DE.SummonVilefiend] and cooldown[DE.SummonVilefiend].ready and soulShards >= 1 and currentSpell ~= DE.SummonVilefiend and (not talents[DE.SummonDemonicTyrant] or tyrantCd > cooldown[DE.].remains + tyrantPrepStart or timeToDie < cooldown[DE.SummonDemonicTyrant].remains) then
		return DE.SummonVilefiend;
	end

	-- guillotine,if=cooldown.demonic_strength.remains|!talent.demonic_strength;
	if talents[DE.Guillotine] and cooldown[DE.Guillotine].ready and (cooldown[DE.DemonicStrength].remains or not talents[DE.DemonicStrength]) then
		return DE.Guillotine;
	end

	-- demonic_strength;
	if talents[DE.DemonicStrength] and cooldown[DE.DemonicStrength].ready then
		return DE.DemonicStrength;
	end

	-- bilescourge_bombers,if=!pet.demonic_tyrant.active;
	if talents[DE.BilescourgeBombers] and cooldown[DE.BilescourgeBombers].ready and (not) then
		return DE.BilescourgeBombers;
	end

	-- shadow_bolt,if=soul_shard<5&talent.fel_covenant&buff.fel_covenant.remains<5;
	if mana >= 750 and currentSpell ~= DE.ShadowBolt and (soulShards < 5 and talents[DE.FelCovenant] and buff[DE.FelCovenant].remains < 5) then
		return DE.ShadowBolt;
	end

	-- implosion,if=two_cast_imps>0&buff.tyrant.down&active_enemies>1+(talent.sacrificed_souls.enabled);
	if talents[DE.Implosion] and mana >= 1000 and (0 and not buff[DE.Tyrant].up and targets > 1 + ( talents[DE.SacrificedSouls] )) then
		return DE.Implosion;
	end

	-- implosion,if=buff.wild_imps.stack>9&buff.tyrant.up&active_enemies>2+(1*talent.sacrificed_souls.enabled)&cooldown.call_dreadstalkers.remains>17&talent.the_expendables;
	if talents[DE.Implosion] and mana >= 1000 and (buff[DE.WildImps].count > 9 and buff[DE.Tyrant].up and targets > 2 + ( 1 * (talents[DE.SacrificedSouls] and 1 or 0) ) and cooldown[DE.CallDreadstalkers].remains > 17 and talents[DE.TheExpendables]) then
		return DE.Implosion;
	end

	-- soul_strike,if=soul_shard<5&active_enemies>1;
	if talents[DE.SoulStrike] and cooldown[DE.SoulStrike].ready and (soulShards < 5 and targets > 1) then
		return DE.SoulStrike;
	end

	-- summon_soulkeeper,if=buff.tormented_soul.stack=10&active_enemies>1;
	if talents[DE.SummonSoulkeeper] and currentSpell ~= DE.SummonSoulkeeper and (buff[DE.TormentedSoul].count == 10 and targets > 1) then
		return DE.SummonSoulkeeper;
	end

	-- demonbolt,if=buff.demonic_core.up&soul_shard<4&variable.tyrant_cd>5;
	if talents[DE.Demonbolt] and mana >= 1000 and currentSpell ~= DE.Demonbolt and (buff[DE.DemonicCore].up and soulShards < 4 and tyrantCd > 5) then
		return DE.Demonbolt;
	end

	-- power_siphon,if=buff.demonic_core.stack<2&(buff.dreadstalkers.remains>gcd*3|buff.dreadstalkers.down);
	if talents[DE.PowerSiphon] and cooldown[DE.PowerSiphon].ready and (buff[DE.DemonicCore].count < 2 and ( buff[DE.Dreadstalkers].remains > gcd * 3 or not buff[DE.Dreadstalkers].up )) then
		return DE.PowerSiphon;
	end

	-- hand_of_guldan,if=soul_shard>2&(!talent.summon_demonic_tyrant|variable.tyrant_cd>variable.tyrant_prep_start+2)&(buff.demonic_calling.up|soul_shard>4|cooldown.call_dreadstalkers.remains>gcd);
	if soulShards >= 3 and currentSpell ~= DE.HandOfGuldan and (soulShards > 2 and ( not talents[DE.SummonDemonicTyrant] or tyrantCd > tyrantPrepStart + 2 ) and ( buff[DE.DemonicCalling].up or soulShards > 4 or cooldown[DE.CallDreadstalkers].remains > gcd )) then
		return DE.HandOfGuldan;
	end

	-- doom,target_if=refreshable;
	if talents[DE.Doom] and mana >= 500 and () then
		return DE.Doom;
	end

	-- soul_strike,if=soul_shard<5;
	if talents[DE.SoulStrike] and cooldown[DE.SoulStrike].ready and (soulShards < 5) then
		return DE.SoulStrike;
	end

	-- shadow_bolt;
	if mana >= 750 and currentSpell ~= DE.ShadowBolt then
		return DE.ShadowBolt;
	end
end
function Warlock:DemonologyItems()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
end

function Warlock:DemonologyOgcd()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
end

function Warlock:DemonologyTyrant()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local timeShift = fd.timeShift;
	local gcd = fd.gcd;
	local soulShards = UnitPower('player', Enum.PowerType.SoulShards);
	local soulShardsMax = UnitPowerMax('player', Enum.PowerType.SoulShards);
	local soulShardsPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local soulShardsRegen = select(2,GetPowerRegen());
	local soulShardsRegenCombined = soulShardsRegen + soulShards;
	local soulShardsDeficit = UnitPowerMax('player', Enum.PowerType.SoulShards) - soulShards;
	local soulShardsTimeToMax = soulShardsMax - soulShards / soulShardsRegen;
	local mana = UnitPower('player', Enum.PowerType.Mana);
	local manaMax = UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local manaRegen = select(2,GetPowerRegen());
	local manaRegenCombined = manaRegen + mana;
	local manaDeficit = UnitPowerMax('player', Enum.PowerType.Mana) - mana;
	local manaTimeToMax = manaMax - mana / manaRegen;

	-- variable,name=next_tyrant,op=set,value=time+13+cooldown.grimoire_felguard.ready+cooldown.summon_vilefiend.ready,if=variable.next_tyrant<=time&!equipped.neltharions_call_to_dominance;
	if nextTyrant <= GetTime() and not IsEquippedItem(NeltharionsCallToDominance) then
		local nextTyrant = GetTime() + 13 + cooldown[DE.GrimoireFelguard].ready + cooldown[DE.SummonVilefiend].ready;
	end

	-- power_siphon,if=buff.wild_imps.stack>1&!buff.nether_portal.up&buff.demonic_core.stack<3;
	if talents[DE.PowerSiphon] and cooldown[DE.PowerSiphon].ready and (buff[DE.WildImps].count > 1 and not buff[DE.NetherPortal].up and buff[DE.DemonicCore].count < 3) then
		return DE.PowerSiphon;
	end

	-- shadow_bolt,if=time<2&soul_shard<5;
	if mana >= 750 and currentSpell ~= DE.ShadowBolt and (GetTime() < 2 and soulShards < 5) then
		return DE.ShadowBolt;
	end

	-- nether_portal;
	if talents[DE.NetherPortal] and cooldown[DE.NetherPortal].ready and soulShards >= 1 and currentSpell ~= DE.NetherPortal then
		return DE.NetherPortal;
	end

	-- variable,name=next_tyrant,op=set,value=time+13+cooldown.grimoire_felguard.ready+cooldown.summon_vilefiend.ready,if=variable.next_tyrant<=time&equipped.neltharions_call_to_dominance;
	if nextTyrant <= GetTime() and IsEquippedItem(NeltharionsCallToDominance) then
		local nextTyrant = GetTime() + 13 + cooldown[DE.GrimoireFelguard].ready + cooldown[DE.SummonVilefiend].ready;
	end

	-- grimoire_felguard;
	if talents[DE.GrimoireFelguard] and cooldown[DE.GrimoireFelguard].ready and soulShards >= 1 then
		return DE.GrimoireFelguard;
	end

	-- summon_vilefiend;
	if talents[DE.SummonVilefiend] and cooldown[DE.SummonVilefiend].ready and soulShards >= 1 and currentSpell ~= DE.SummonVilefiend then
		return DE.SummonVilefiend;
	end

	-- call_dreadstalkers;
	-- DE.CallDreadstalkers;

	-- soulburn,if=buff.nether_portal.up&soul_shard>=2,line_cd=40;
	if talents[DE.Soulburn] and cooldown[DE.Soulburn].ready and soulShards >= 1 and (buff[DE.NetherPortal].up and soulShards >= 2) then
		return DE.Soulburn;
	end

	-- hand_of_guldan,if=variable.next_tyrant-time>2&(buff.nether_portal.up|soul_shard>2&variable.next_tyrant-time<12|soul_shard=5)&!cooldown.call_dreadstalkers.up;
	if soulShards >= 3 and currentSpell ~= DE.HandOfGuldan and (nextTyrant - GetTime() > 2 and ( buff[DE.NetherPortal].up or soulShards > 2 and nextTyrant - GetTime() < 12 or soulShards == 5 ) and not cooldown[DE.CallDreadstalkers].up) then
		return DE.HandOfGuldan;
	end

	-- hand_of_guldan,if=talent.soulbound_tyrant&variable.next_tyrant-time<4&variable.next_tyrant-time>action.summon_demonic_tyrant.cast_time;
	if soulShards >= 3 and currentSpell ~= DE.HandOfGuldan and (talents[DE.SoulboundTyrant] and nextTyrant - GetTime() < 4 and nextTyrant - GetTime() > timeShift) then
		return DE.HandOfGuldan;
	end

	-- summon_demonic_tyrant,if=variable.next_tyrant-time<cast_time*2+1|(buff.dreadstalkers.remains<cast_time+gcd&buff.dreadstalkers.up);
	if nextTyrant - GetTime() < timeShift * 2 + 1 or ( buff[DE.Dreadstalkers].remains < timeShift + gcd and buff[DE.Dreadstalkers].up ) then
		return DE.SummonDemonicTyrant;
	end

	-- demonbolt,if=buff.demonic_core.up;
	if talents[DE.Demonbolt] and mana >= 1000 and currentSpell ~= DE.Demonbolt and (buff[DE.DemonicCore].up) then
		return DE.Demonbolt;
	end

	-- soul_strike;
	if talents[DE.SoulStrike] and cooldown[DE.SoulStrike].ready then
		return DE.SoulStrike;
	end

	-- shadow_bolt;
	if mana >= 750 and currentSpell ~= DE.ShadowBolt then
		return DE.ShadowBolt;
	end
end

function Warlock:DemonologyVariables()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local talents = fd.talents;
	local timeToDie = fd.timeToDie;

	-- variable,name=tyrant_cd,op=setif,value=cooldown.invoke_power_infusion_0.remains,value_else=cooldown.summon_demonic_tyrant.remains_expected,condition=((((fight_remains+time)%%120<=85&(fight_remains+time)%%120>=25)|time>=210)&variable.shadow_timings)&cooldown.invoke_power_infusion_0.duration>0&!talent.grand_warlocks_design;
	if ( ( ( ( timeToDie + GetTime() ) / / 120 <= 85 and ( timeToDie + GetTime() ) / / 120 >= 25 ) or GetTime() >= 210 ) and shadowTimings ) and cooldown[DE.InvokePowerInfusion0].duration > 0 and not talents[DE.GrandWarlocksDesign] then
		local tyrantCd = cooldown[DE.InvokePowerInfusion0].remains;
	else
		local tyrantCd = cooldown[DE.SummonDemonicTyrant].remains;
	end

	-- variable,name=np_condition,op=set,value=cooldown.nether_portal.up|buff.nether_portal.up|pet.pit_lord.active|!talent.nether_portal|cooldown.nether_portal.remains>30;
	local npCondition = cooldown[DE.NetherPortal].up or buff[DE.NetherPortal].up or or not talents[DE.NetherPortal] or cooldown[DE.NetherPortal].remains > 30;
end

