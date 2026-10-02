class_name InvestigationMap
extends RefCounted

static func describe_room(room_name: String, investigated: bool, danger_known: bool, evidence: Array[String]) -> Dictionary:
	return {
		"room": room_name,
		"state": "조사 완료" if investigated else "미확인",
		"danger": "위험 확인" if danger_known else "미확인 위험",
		"evidence": evidence,
		"has_basis": investigated and not evidence.is_empty(),
	}

static func complete_room_scene(clue: Dictionary, inference: String, reaction: String) -> Dictionary:
	return {
		"clue": clue,
		"inference": inference,
		"reaction": reaction,
		"complete": not inference.is_empty() and not reaction.is_empty(),
	}
