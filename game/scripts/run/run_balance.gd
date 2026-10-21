class_name RunBalance
extends RefCounted

## Balans runa (ciklus 1, 2026-10-21) — pravila koja dijele run, GameState i provjere.
##
## Sjeme: tip se bira TEŽINSKI po rijetkosti, ne ravnomjerno. ★1 nosi težinu 1, ★2 i ★3 nose
## rare2_mult / rare3_mult iz levela (rastu do levela 20 i kroz Endless). Ranije je ★3 padao
## jednako često kao ★1 (1/6), pa je zlatno sjeme stizalo prije ★1/★2 (playtest 2026-10-21).
##
## Brojevi: data/run_levels/levels.json. Simulacija: scripts/dev/economy_sim.gd.

## Brzina levela raste svakih RAMP_EVERY s (speed_ramp iz levela).
const RAMP_EVERY := 15.0
## Kad nema runa (dnevni poklon, Loot Burst bez cilja): težine kao level 1.
const BASE_RARE2 := 0.40
const BASE_RARE3 := 0.12


static func rarity_weight(rarity: int, rare2_mult: float, rare3_mult: float) -> float:
	if rarity >= 3:
		return rare3_mult
	if rarity == 2:
		return rare2_mult
	return 1.0


## Tip iz `pool` (paralelno `rarities`), težinski. `roll` ∈ [0, 1).
static func pick_weighted(pool: Array[String], rarities: Array[int], rare2_mult: float, rare3_mult: float, roll: float) -> String:
	if pool.is_empty():
		return ""
	var total := 0.0
	for i in pool.size():
		total += rarity_weight(rarities[i] if i < rarities.size() else 1, rare2_mult, rare3_mult)
	if total <= 0.0:
		return pool[mini(int(roll * pool.size()), pool.size() - 1)]
	var left := roll * total
	for i in pool.size():
		left -= rarity_weight(rarities[i] if i < rarities.size() else 1, rare2_mult, rare3_mult)
		if left < 0.0:
			return pool[i]
	return pool[pool.size() - 1]


## Udio ★r u `pool` pri datim težinama (za provjere i izvještaj).
static func rarity_share(rarities: Array[int], rarity: int, rare2_mult: float, rare3_mult: float) -> float:
	var total := 0.0
	var part := 0.0
	for r in rarities:
		var w := rarity_weight(r, rare2_mult, rare3_mult)
		total += w
		if r == rarity:
			part += w
	return 0.0 if total <= 0.0 else part / total


## Druga staza za par prepreka: susjedna ili suprotna, nikad ista. `roll` ∈ [0, 1).
static func pair_lane(lane: int, roll: float) -> int:
	var others: Array[int] = []
	for i in 3:
		if i != lane:
			others.append(i)
	return others[mini(int(roll * 2.0), 1)]
