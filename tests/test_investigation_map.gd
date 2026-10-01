extends GutTest

const InvestigationMapModel = preload("res://scripts/investigation_map.gd")

func test_room_distinguishes_unknown_danger_and_completed_evidence() -> void:
	var unknown = InvestigationMapModel.describe_room("서재", false, false, [])
	assert_eq(unknown.state, "미확인")
	assert_eq(unknown.danger, "미확인 위험")
	var done = InvestigationMapModel.describe_room("응접실", true, true, ["진흙 발자국"])
	assert_true(done.has_basis)

func test_representative_room_scene_requires_inference_and_reaction() -> void:
	var scene = InvestigationMapModel.complete_room_scene({"headline": "편지 발견"}, "범인은 내부인", "관리인이 숨을 고른다")
	assert_true(scene.complete)
