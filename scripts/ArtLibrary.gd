class_name ArtLibrary
extends RefCounted

const HERO_ART := {
	"archer": "res://assets/art/heroes/archer.svg",
	"mage": "res://assets/art/heroes/mage.svg",
	"knight": "res://assets/art/heroes/knight.svg",
	"priest": "res://assets/art/heroes/priest.svg",
	"alchemist": "res://assets/art/heroes/alchemist.svg",
}

const ENEMY_ART := {
	"goblin": "res://assets/art/enemies/goblin.svg",
	"goblin_archer": "res://assets/art/enemies/goblin_archer.svg",
	"orc": "res://assets/art/enemies/orc.svg",
	"troll": "res://assets/art/enemies/troll.svg",
	"boss_stage1": "res://assets/art/enemies/boss_stage1.svg",
}

const FACILITY_ART := {
	"crossbow": "res://assets/art/facilities/crossbow.svg",
	"catapult": "res://assets/art/facilities/catapult.svg",
	"spike_fence": "res://assets/art/facilities/spike_fence.svg",
	"healing_fountain": "res://assets/art/facilities/healing_fountain.svg",
	"mana_orb": "res://assets/art/facilities/mana_orb.svg",
}

const ENVIRONMENT_ART := {
	"battlefield": "res://assets/art/environment/battlefield.svg",
	"mansion": "res://assets/art/environment/mansion.svg",
	"slot": "res://assets/art/ui/slot_frame.svg",
	"projectile": "res://assets/art/effects/projectile_bolt.svg",
}

static var _cache: Dictionary = {}

static func texture(path: String, scale: float = 1.0) -> Texture2D:
	var cache_key := "%s@%s" % [path, scale]
	if cache_key in _cache:
		return _cache[cache_key]
	if not FileAccess.file_exists(path):
		push_warning("Missing art asset: " + path)
		return null
	var image := Image.new()
	var err := image.load_svg_from_string(FileAccess.get_file_as_string(path), scale)
	if err != OK:
		push_warning("Could not load SVG art asset: " + path)
		return null
	var tex := ImageTexture.create_from_image(image)
	_cache[cache_key] = tex
	return tex

static func apply_sprite(sprite: Sprite2D, art_path: String, scale: float = 1.0) -> void:
	if sprite == null:
		return
	var tex := texture(art_path, scale)
	if tex:
		sprite.texture = tex
		sprite.centered = true

static func apply_data_sprite(sprite: Sprite2D, data, art_map: Dictionary, scale: float = 1.0) -> void:
	if data == null:
		return
	var data_id = data.get("id")
	if data_id == null:
		return
	var art_path = art_map.get(data_id, "")
	if art_path != "":
		apply_sprite(sprite, art_path, scale)
