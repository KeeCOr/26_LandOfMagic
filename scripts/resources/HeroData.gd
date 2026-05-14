# scripts/resources/HeroData.gd
class_name HeroData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var damage: float = 10.0
@export var attack_speed: float = 1.0   # 초당 공격 횟수
@export var attack_range: float = 200.0
@export var description: String = ""
@export var icon: Texture2D
