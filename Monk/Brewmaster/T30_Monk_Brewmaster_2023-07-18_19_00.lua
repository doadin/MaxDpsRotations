local _, addonTable = ...;

-- @type MaxDps;
if not MaxDps then return end;
local Monk = addonTable.Monk;
local MaxDps = MaxDps;

local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;

local itemID = GetInventoryItemID('player', INVSLOT_MAINHAND);

local mainHandSubClassID = itemID and  select(13, GetItemInfo(itemID));

local TwoHanderWepCheck = mainHandSubClassID and (mainHandSubClassID == 1 or mainHandSubClassID == 5 or mainHandSubClassID == 8 or mainHandSubClassID == 10);

local BR = {
	ChiBurst = 123986,
	ChiWave = 115098,
	Roll = 109132,
	ChiTorpedo = 115008,
	SpearHandStrike = 116705,
	InvokeNiuzaoTheBlackOx = 132578,
	WeaponsOfOrderDebuff = 312106,
	WeaponsOfOrder = 387184,
	KegSmash = 121253,
	PurifyingBrew = 119582,
	BlackoutCombo = 196736,
	PressTheAdvantage = 418359,
	BlackoutKick = 205523,
	RisingSunKick = 107428,
	BlackOxBrew = 115399,
	TigerPalm = 100780,
	BreathOfFire = 115181,
	CharredPassions = 386965,
	SummonWhiteTigerStatue = 388686,
	BonedustBrew = 386276,
	ExplodingKeg = 325153,
	RushingJadeWind = 116847,
	SpinningCraneKick = 322729,
	ExpelHarm = 322101,
};
local A = {
};
function Monk:Brewmaster()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local talents = fd.talents;
	local energy = UnitPower('player', Enum.PowerType.Energy);
	local energyMax = UnitPowerMax('player', Enum.PowerType.Energy);
	local energyPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local energyRegen = select(2,GetPowerRegen());
	local energyRegenCombined = energyRegen + energy;
	local energyDeficit = UnitPowerMax('player', Enum.PowerType.Energy) - energy;
	local energyTimeToMax = energyMax - energy / energyRegen;
	local mana = UnitPower('player', Enum.PowerType.Mana);
	local manaMax = UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local manaRegen = select(2,GetPowerRegen());
	local manaRegenCombined = manaRegen + mana;
	local manaDeficit = UnitPowerMax('player', Enum.PowerType.Mana) - mana;
	local manaTimeToMax = manaMax - mana / manaRegen;

	-- call_action_list,name=item_actions;
	local result = Monk:BrewmasterItemActions();
	if result then
		return result;
	end

	-- call_action_list,name=race_actions;
	local result = Monk:BrewmasterRaceActions();
	if result then
		return result;
	end

	-- invoke_niuzao_the_black_ox,if=debuff.weapons_of_order_debuff.stack>3;
	if talents[BR.InvokeNiuzaoTheBlackOx] and cooldown[BR.InvokeNiuzaoTheBlackOx].ready and (debuff[BR.WeaponsOfOrderDebuff].count > 3) then
		return BR.InvokeNiuzaoTheBlackOx;
	end

	-- invoke_niuzao_the_black_ox,if=!talent.weapons_of_order.enabled;
	if talents[BR.InvokeNiuzaoTheBlackOx] and cooldown[BR.InvokeNiuzaoTheBlackOx].ready and (not talents[BR.WeaponsOfOrder]) then
		return BR.InvokeNiuzaoTheBlackOx;
	end

	-- keg_smash,if=time<5&talent.weapons_of_order.enabled;
	if talents[BR.KegSmash] and cooldown[BR.KegSmash].ready and energy >= 40 and (GetTime() < 5 and talents[BR.WeaponsOfOrder]) then
		return BR.KegSmash;
	end

	-- weapons_of_order,if=(talent.weapons_of_order.enabled);
	if talents[BR.WeaponsOfOrder] and cooldown[BR.WeaponsOfOrder].ready and mana >= 0 and (( talents[BR.WeaponsOfOrder] )) then
		return BR.WeaponsOfOrder;
	end

	-- purifying_brew,if=(!buff.blackout_combo.up);
	if talents[BR.PurifyingBrew] and cooldown[BR.PurifyingBrew].ready and (( not buff[BR.BlackoutCombo].up )) then
		return BR.PurifyingBrew;
	end

	-- call_action_list,name=rotation_pta,if=talent.press_the_advantage.enabled;
	if talents[BR.PressTheAdvantage] then
		local result = Monk:BrewmasterRotationPta();
		if result then
			return result;
		end
	end

	-- call_action_list,name=rotation_boc,if=!talent.press_the_advantage.enabled;
	if not talents[BR.PressTheAdvantage] then
		local result = Monk:BrewmasterRotationBoc();
		if result then
			return result;
		end
	end
end
function Monk:BrewmasterItemActions()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
end

function Monk:BrewmasterRaceActions()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
end

function Monk:BrewmasterRotationBoc()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local targets = fd.targets and fd.targets or 1;
	local chi = UnitPower('player', Enum.PowerType.Chi);
	local chiMax = UnitPowerMax('player', Enum.PowerType.Chi);
	local chiPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local chiRegen = select(2,GetPowerRegen());
	local chiRegenCombined = chiRegen + chi;
	local chiDeficit = UnitPowerMax('player', Enum.PowerType.Chi) - chi;
	local chiTimeToMax = chiMax - chi / chiRegen;
	local mana = UnitPower('player', Enum.PowerType.Mana);
	local manaMax = UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local manaRegen = select(2,GetPowerRegen());
	local manaRegenCombined = manaRegen + mana;
	local manaDeficit = UnitPowerMax('player', Enum.PowerType.Mana) - mana;
	local manaTimeToMax = manaMax - mana / manaRegen;
	local energy = UnitPower('player', Enum.PowerType.Energy);
	local energyMax = UnitPowerMax('player', Enum.PowerType.Energy);
	local energyPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local energyRegen = select(2,GetPowerRegen());
	local energyRegenCombined = energyRegen + energy;
	local energyDeficit = UnitPowerMax('player', Enum.PowerType.Energy) - energy;
	local energyTimeToMax = energyMax - energy / energyRegen;

	-- blackout_kick;
	if cooldown[BR.BlackoutKick].ready then
		return BR.BlackoutKick;
	end

	-- rising_sun_kick;
	if talents[BR.RisingSunKick] and cooldown[BR.RisingSunKick].ready and chi >= 0 and mana >= 0 then
		return BR.RisingSunKick;
	end

	-- black_ox_brew,if=energy.deficit>=50;
	if talents[BR.BlackOxBrew] and cooldown[BR.BlackOxBrew].ready and (energyDeficit >= 50) then
		return BR.BlackOxBrew;
	end

	-- tiger_palm,if=buff.blackout_combo.up&active_enemies=1;
	if energy >= 25 and (buff[BR.BlackoutCombo].up and targets == 1) then
		return BR.TigerPalm;
	end

	-- breath_of_fire,if=buff.charred_passions.down;
	if talents[BR.BreathOfFire] and cooldown[BR.BreathOfFire].ready and (not buff[BR.CharredPassions].up) then
		return BR.BreathOfFire;
	end

	-- keg_smash,if=buff.weapons_of_order.up&debuff.weapons_of_order_debuff.stack<=3;
	if talents[BR.KegSmash] and cooldown[BR.KegSmash].ready and energy >= 40 and (buff[BR.WeaponsOfOrder].up and debuff[BR.WeaponsOfOrderDebuff].count <= 3) then
		return BR.KegSmash;
	end

	-- summon_white_tiger_statue,if=debuff.weapons_of_order_debuff.stack>3;
	if talents[BR.SummonWhiteTigerStatue] and cooldown[BR.SummonWhiteTigerStatue].ready and (debuff[BR.WeaponsOfOrderDebuff].count > 3) then
		return BR.SummonWhiteTigerStatue;
	end

	-- summon_white_tiger_statue,if=!talent.weapons_of_order.enabled;
	if talents[BR.SummonWhiteTigerStatue] and cooldown[BR.SummonWhiteTigerStatue].ready and (not talents[BR.WeaponsOfOrder]) then
		return BR.SummonWhiteTigerStatue;
	end

	-- bonedust_brew,if=(time<10&debuff.weapons_of_order_debuff.stack>3)|(time>10&talent.weapons_of_order.enabled);
	if talents[BR.BonedustBrew] and cooldown[BR.BonedustBrew].ready and (( GetTime() < 10 and debuff[BR.WeaponsOfOrderDebuff].count > 3 ) or ( GetTime() > 10 and talents[BR.WeaponsOfOrder] )) then
		return BR.BonedustBrew;
	end

	-- bonedust_brew,if=(!talent.weapons_of_order.enabled);
	if talents[BR.BonedustBrew] and cooldown[BR.BonedustBrew].ready and (( not talents[BR.WeaponsOfOrder] )) then
		return BR.BonedustBrew;
	end

	-- exploding_keg,if=(buff.bonedust_brew.up);
	if talents[BR.ExplodingKeg] and cooldown[BR.ExplodingKeg].ready and (( buff[BR.BonedustBrew].up )) then
		return BR.ExplodingKeg;
	end

	-- exploding_keg,if=(!talent.bonedust_brew.enabled);
	if talents[BR.ExplodingKeg] and cooldown[BR.ExplodingKeg].ready and (( not talents[BR.BonedustBrew] )) then
		return BR.ExplodingKeg;
	end

	-- keg_smash;
	if talents[BR.KegSmash] and cooldown[BR.KegSmash].ready and energy >= 40 then
		return BR.KegSmash;
	end

	-- rushing_jade_wind,if=talent.rushing_jade_wind.enabled;
	if talents[BR.RushingJadeWind] and cooldown[BR.RushingJadeWind].ready and chi >= 0 and (talents[BR.RushingJadeWind]) then
		return BR.RushingJadeWind;
	end

	-- breath_of_fire;
	if talents[BR.BreathOfFire] and cooldown[BR.BreathOfFire].ready then
		return BR.BreathOfFire;
	end

	-- tiger_palm,if=active_enemies=1&!talent.blackout_combo.enabled;
	if energy >= 25 and (targets == 1 and not talents[BR.BlackoutCombo]) then
		return BR.TigerPalm;
	end

	-- spinning_crane_kick,if=active_enemies>1;
	if energy >= 25 and (targets > 1) then
		return BR.SpinningCraneKick;
	end

	-- expel_harm;
	if cooldown[BR.ExpelHarm].ready and energy >= 15 and mana >= 0 then
		return BR.ExpelHarm;
	end

	-- chi_wave,if=talent.chi_wave.enabled;
	if talents[BR.ChiWave] and cooldown[BR.ChiWave].ready and (talents[BR.ChiWave]) then
		return BR.ChiWave;
	end

	-- chi_burst,if=talent.chi_burst.enabled;
	if talents[BR.ChiBurst] and cooldown[BR.ChiBurst].ready and currentSpell ~= BR.ChiBurst and (talents[BR.ChiBurst]) then
		return BR.ChiBurst;
	end
end

function Monk:BrewmasterRotationPta()
	local fd = MaxDps.FrameData;
	local timeTo35 = fd.timeToDie;
	local timeTo20 = fd.timeToDie;
	local targetHp = MaxDps:TargetPercentHealth() * 100;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local chi = UnitPower('player', Enum.PowerType.Chi);
	local chiMax = UnitPowerMax('player', Enum.PowerType.Chi);
	local chiPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local chiRegen = select(2,GetPowerRegen());
	local chiRegenCombined = chiRegen + chi;
	local chiDeficit = UnitPowerMax('player', Enum.PowerType.Chi) - chi;
	local chiTimeToMax = chiMax - chi / chiRegen;
	local mana = UnitPower('player', Enum.PowerType.Mana);
	local manaMax = UnitPowerMax('player', Enum.PowerType.Mana);
	local manaPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local manaRegen = select(2,GetPowerRegen());
	local manaRegenCombined = manaRegen + mana;
	local manaDeficit = UnitPowerMax('player', Enum.PowerType.Mana) - mana;
	local manaTimeToMax = manaMax - mana / manaRegen;
	local energy = UnitPower('player', Enum.PowerType.Energy);
	local energyMax = UnitPowerMax('player', Enum.PowerType.Energy);
	local energyPct = UnitPower('player')/UnitPowerMax('player') * 100;
	local energyRegen = select(2,GetPowerRegen());
	local energyRegenCombined = energyRegen + energy;
	local energyDeficit = UnitPowerMax('player', Enum.PowerType.Energy) - energy;
	local energyTimeToMax = energyMax - energy / energyRegen;

	-- rising_sun_kick,if=(buff.press_the_advantage.stack<6|buff.press_the_advantage.stack>9);
	if talents[BR.RisingSunKick] and cooldown[BR.RisingSunKick].ready and chi >= 0 and mana >= 0 and (( buff[BR.PressTheAdvantage].count < 6 or buff[BR.PressTheAdvantage].count > 9 )) then
		return BR.RisingSunKick;
	end

	-- blackout_kick;
	if cooldown[BR.BlackoutKick].ready then
		return BR.BlackoutKick;
	end

	-- black_ox_brew,if=energy.deficit>=50;
	if talents[BR.BlackOxBrew] and cooldown[BR.BlackOxBrew].ready and (energyDeficit >= 50) then
		return BR.BlackOxBrew;
	end

	-- summon_white_tiger_statue,if=debuff.weapons_of_order_debuff.stack>3;
	if talents[BR.SummonWhiteTigerStatue] and cooldown[BR.SummonWhiteTigerStatue].ready and (debuff[BR.WeaponsOfOrderDebuff].count > 3) then
		return BR.SummonWhiteTigerStatue;
	end

	-- summon_white_tiger_statue,if=!talent.weapons_of_order.enabled;
	if talents[BR.SummonWhiteTigerStatue] and cooldown[BR.SummonWhiteTigerStatue].ready and (not talents[BR.WeaponsOfOrder]) then
		return BR.SummonWhiteTigerStatue;
	end

	-- bonedust_brew,if=(time<10&debuff.weapons_of_order_debuff.stack>3)|(time>10&talent.weapons_of_order.enabled);
	if talents[BR.BonedustBrew] and cooldown[BR.BonedustBrew].ready and (( GetTime() < 10 and debuff[BR.WeaponsOfOrderDebuff].count > 3 ) or ( GetTime() > 10 and talents[BR.WeaponsOfOrder] )) then
		return BR.BonedustBrew;
	end

	-- bonedust_brew,if=(!talent.weapons_of_order.enabled);
	if talents[BR.BonedustBrew] and cooldown[BR.BonedustBrew].ready and (( not talents[BR.WeaponsOfOrder] )) then
		return BR.BonedustBrew;
	end

	-- exploding_keg,if=(buff.bonedust_brew.up);
	if talents[BR.ExplodingKeg] and cooldown[BR.ExplodingKeg].ready and (( buff[BR.BonedustBrew].up )) then
		return BR.ExplodingKeg;
	end

	-- exploding_keg,if=(!talent.bonedust_brew.enabled);
	if talents[BR.ExplodingKeg] and cooldown[BR.ExplodingKeg].ready and (( not talents[BR.BonedustBrew] )) then
		return BR.ExplodingKeg;
	end

	-- breath_of_fire,if=!(buff.press_the_advantage.stack>6&buff.blackout_combo.up);
	if talents[BR.BreathOfFire] and cooldown[BR.BreathOfFire].ready and (not ( buff[BR.PressTheAdvantage].count > 6 and buff[BR.BlackoutCombo].up )) then
		return BR.BreathOfFire;
	end

	-- keg_smash,if=!(buff.press_the_advantage.stack>6&buff.blackout_combo.up);
	if talents[BR.KegSmash] and cooldown[BR.KegSmash].ready and energy >= 40 and (not ( buff[BR.PressTheAdvantage].count > 6 and buff[BR.BlackoutCombo].up )) then
		return BR.KegSmash;
	end

	-- rushing_jade_wind,if=talent.rushing_jade_wind.enabled;
	if talents[BR.RushingJadeWind] and cooldown[BR.RushingJadeWind].ready and chi >= 0 and (talents[BR.RushingJadeWind]) then
		return BR.RushingJadeWind;
	end

	-- expel_harm;
	if cooldown[BR.ExpelHarm].ready and energy >= 15 and mana >= 0 then
		return BR.ExpelHarm;
	end

	-- chi_wave,if=talent.chi_wave.enabled;
	if talents[BR.ChiWave] and cooldown[BR.ChiWave].ready and (talents[BR.ChiWave]) then
		return BR.ChiWave;
	end

	-- chi_burst,if=talent.chi_burst.enabled;
	if talents[BR.ChiBurst] and cooldown[BR.ChiBurst].ready and currentSpell ~= BR.ChiBurst and (talents[BR.ChiBurst]) then
		return BR.ChiBurst;
	end
end

