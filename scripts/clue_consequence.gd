class_name ClueConsequence
extends RefCounted

static func build(clue_name: String, relationship_delta: int, unlocked_room: String, event_name: String = "") -> Dictionary:
	return {
		"headline": "%s 발견" % clue_name,
		"relationship_delta": relationship_delta,
		"relationship_text": "관계 %+d" % relationship_delta,
		"next_choice": unlocked_room if not unlocked_room.is_empty() else "현재 방을 더 조사한다",
		"event_change": event_name if not event_name.is_empty() else "새로운 사건 없음",
		"room_state": "조사 완료" if not unlocked_room.is_empty() else "추가 조사 가능",
	}
