class_name RecruitmentService
extends RefCounted

const OwnedMonsterScript = preload("res://scripts/monster/owned_monster.gd")

var _rng := RandomNumberGenerator.new()
var _failure_streaks: Dictionary = {}


func _init(seed: int = 7017) -> void:
	_rng.seed = seed


func resolve_victory_recruit(
	battle_result: Dictionary, collection, roll_override: int = -1
) -> Dictionary:
	if String(battle_result.get("outcome", "")) != "victory":
		return {"attempted": false, "reason": "not_victory"}

	var candidate := _pick_candidate(Array(battle_result.get("recruit_contexts", [])))
	if candidate.is_empty():
		return {"attempted": false, "reason": "no_candidate"}

	var monster_id := String(candidate.get("monster_id", ""))
	var failure_streak := int(_failure_streaks.get(monster_id, 0))
	var party_avg_level: int = collection.average_party_level()
	var duplicate_penalty := -12 if collection.has_species(monster_id) else 0
	var pity_bonus := _calc_pity_bonus(failure_streak, String(candidate.get("rank", "")))
	var score := clampi(
		(
			int(candidate.get("base_recruit", 0))
			+ _hp_bonus(float(candidate.get("hp_ratio", 1.0)))
			+ _status_bonus(Dictionary(candidate.get("ailments", {})))
			+ int(candidate.get("recruit_bonus", 0))
			+ clampi(party_avg_level - int(candidate.get("level", 1)), -8, 12)
			+ pity_bonus
			+ duplicate_penalty
			- _rank_penalty(String(candidate.get("rank", "")))
		),
		1,
		90
	)
	var roll := roll_override if roll_override >= 0 else _rng.randi_range(1, 100)
	var success := roll <= score
	if success:
		_failure_streaks[monster_id] = 0
	else:
		_failure_streaks[monster_id] = failure_streak + 1

	return {
		"attempted": true,
		"success": success,
		"monster_id": monster_id,
		"name": String(candidate.get("name", monster_id)),
		"nickname": String(candidate.get("name", "")),
		"level": int(candidate.get("level", 1)),
		"rate": score,
		"roll": roll,
		"reaction": _rate_reaction(score),
		"bait_item_id": String(candidate.get("last_bait_item_id", "")),
		"bait_family_match": bool(candidate.get("bait_family_match", false)),
		"pity_bonus": pity_bonus,
		"owned_monster":
		(
			OwnedMonsterScript
			. from_dict(
				{
					"instance_id": "%s-%d" % [monster_id, Time.get_ticks_usec()],
					"monster_id": monster_id,
					"nickname": "",
					"level": int(candidate.get("level", 1)),
					"tactic": "まかせた",
					"locked": false,
					"loyalty": 30,
					"joined_at_utc": Time.get_datetime_string_from_system(true, true),
					"source": "recruit",
				}
			)
			. to_dict()
		),
	}


func serialize_failure_streaks() -> Dictionary:
	return _failure_streaks.duplicate(true)


func load_failure_streaks(payload: Dictionary) -> void:
	_failure_streaks = payload.duplicate(true)


func _pick_candidate(recruit_contexts: Array) -> Dictionary:
	var best: Dictionary = {}
	var best_weight := -100000
	for context_variant in recruit_contexts:
		if not context_variant is Dictionary:
			continue
		var context: Dictionary = context_variant
		if bool(context.get("alive", true)):
			continue
		if not bool(context.get("scoutable", false)):
			continue
		if String(context.get("last_bait_item_id", "")).is_empty():
			continue
		var weight := int(context.get("recruit_bonus", 0)) * 10
		weight += int(round((1.0 - float(context.get("hp_ratio", 1.0))) * 100.0))
		if weight > best_weight:
			best = context
			best_weight = weight
	return best


func _hp_bonus(hp_ratio: float) -> int:
	return int(floor(clampf(1.0 - hp_ratio, 0.0, 1.0) * 25.0))


func _status_bonus(ailments: Dictionary) -> int:
	var bonus := 0
	if int(ailments.get("poison", 0)) > 0:
		bonus += 3
	if int(ailments.get("paralysis", 0)) > 0:
		bonus += 6
	if int(ailments.get("sleep", 0)) > 0:
		bonus += 10
	if int(ailments.get("soot", 0)) > 0:
		bonus += 4
	return bonus


func _rank_penalty(rank: String) -> int:
	match rank:
		"D":
			return 4
		"C":
			return 8
		"B":
			return 16
		"A":
			return 28
		"S":
			return 999
	return 0


func _calc_pity_bonus(failure_streak: int, rank: String) -> int:
	var base_bonus := 0
	if failure_streak >= 8:
		base_bonus = 10
	elif failure_streak >= 5:
		base_bonus = 5
	if rank in ["B", "A", "S"]:
		base_bonus = int(floor(float(base_bonus) * 0.5))
	return base_bonus


func _rate_reaction(rate: int) -> String:
	if rate >= 70:
		return "ついてきたがっている"
	if rate >= 50:
		return "かなり気を許したようだ"
	if rate >= 30:
		return "すこしこちらを見ている"
	if rate >= 15:
		return "まだ警戒している"
	return "まったく気を許していない"
