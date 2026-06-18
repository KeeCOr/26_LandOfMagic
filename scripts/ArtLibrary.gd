class_name ArtLibrary
extends RefCounted

const HERO_ART := {
	"archer": "res://assets/art/heroes/archer.png",
	"mage": "res://assets/art/heroes/mage.png",
	"knight": "res://assets/art/heroes/knight.png",
	"priest": "res://assets/art/heroes/priest.png",
	"alchemist": "res://assets/art/heroes/alchemist.png",
}

const ENEMY_ART := {
	"goblin": "res://assets/art/enemies/goblin.png",
	"goblin_archer": "res://assets/art/enemies/goblin_archer.png",
	"orc": "res://assets/art/enemies/orc.png",
	"troll": "res://assets/art/enemies/troll.png",
	"boss_stage1": "res://assets/art/enemies/boss_stage1.png",
}

const FACILITY_ART := {
	"crossbow": "res://assets/art/facilities/crossbow.png",
	"catapult": "res://assets/art/facilities/catapult.png",
	"spike_fence": "res://assets/art/facilities/spike_fence.png",
	"healing_fountain": "res://assets/art/facilities/healing_fountain.png",
	"mana_orb": "res://assets/art/facilities/mana_orb.png",
}

const ENVIRONMENT_ART := {
	"battlefield": "res://assets/art/environment/battlefield.png",
	"mansion": "res://assets/art/environment/mansion.png",
	"slot": "res://assets/art/ui/slot_frame.png",
	"projectile": "res://assets/art/effects/projectile_bolt.png",
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
	var err := image.load(path)
	if err != OK:
		push_warning("Could not load bitmap art asset: " + path)
		return null
	if not is_equal_approx(scale, 1.0):
		var target_size := Vector2i(
			max(1, int(round(image.get_width() * scale))),
			max(1, int(round(image.get_height() * scale)))
		)
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
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
