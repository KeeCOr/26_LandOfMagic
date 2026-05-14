# scripts/resources/FacilityData.gd
class_name FacilityData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var damage: float = 8.0
@export var attack_speed: float = 1.5
@export var attack_range: float = 180.0
@export var description: String = ""
@export var icon: Texture2D
@export var max_level: int = 3
