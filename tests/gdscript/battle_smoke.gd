extends SceneTree

const BattleScene = preload("res://scenes/battle/battle_root.tscn")
const BattleRootScript = preload("res://scripts/battle/battle_root.gd")
const RESULT_STATE := 11

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle = BattleScene.instantiate()
	root.add_child(battle)
	battle.configure(BattleRootScript.build_tower_demo_payload())
	await process_frame

	var snapshot: Dictionary = battle.get_battle_snapshot()
	_assert(Array(snapshot.get("party", [])).size() == 3, "party should be 3 fighters")
	_assert(Array(snapshot.get("enemies", [])).size() == 3, "enemies should be 3 fighters")

	battle.run_player_turn("tactics", {"slot": 2, "tactic": "直接指示"})
	await process_frame
	snapshot = battle.get_battle_snapshot()
	_assert(
		String(Array(snapshot.get("party", []))[2].get("tactic", "")) == "直接指示",
		"slot 3 tactic should switch to direct command"
	)

	battle.run_player_turn(
		"fight",
		{
			"direct_actions":
			{
				2:
				{
					"skill_id": "SKL-019",
					"target_side": "enemy",
					"target_index": 0,
				},
			},
		}
	)
	await process_frame
	snapshot = battle.get_battle_snapshot()
	var messages_after_direct := PackedStringArray(snapshot.get("messages", []))
	var saw_direct_effect := false
	for message in messages_after_direct:
		if "すす" in message or "ダメージ" in message:
			saw_direct_effect = true
			break
	_assert(
		saw_direct_effect,
		"direct command should resolve a visible skill effect"
	)

	battle.run_player_turn("item", {"item_index": 0, "target_side": "ally", "target_index": 0})
	await process_frame
	snapshot = battle.get_battle_snapshot()
	var inventory_after_item := Array(snapshot.get("inventory", []))
	_assert(
		int(inventory_after_item[0].get("quantity", 0)) == 1,
		"using the first item should consume one charge"
	)

	battle.run_player_turn("tactics", {"slot": 2, "tactic": "援護を頼む"})
	await process_frame

	var turn_count := 0
	while turn_count < 12:
		snapshot = battle.get_battle_snapshot()
		if String(snapshot.get("outcome", "")) == "victory":
			break
		battle.run_player_turn("fight")
		await process_frame
		turn_count += 1

	snapshot = battle.get_battle_snapshot()
	_assert(String(snapshot.get("outcome", "")) == "victory", "battle should end in victory")
	_assert(int(snapshot.get("state", -1)) == RESULT_STATE, "victory should enter result state")

	battle.free()

	if _failures.is_empty():
		print("battle smoke ok")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
