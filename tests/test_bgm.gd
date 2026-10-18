extends GutTest

func test_bgm_is_single_persistent_loop() -> void:
	var manager = load("res://autoloads/AudioManager.gd").new()
	add_child_autofree(manager)
	manager.start_bgm()
	var player = manager.get_node("BackgroundMusic")
	manager.start_bgm()
	assert_eq(manager.get_child_count(), 1, "Repeated start must reuse the music player")
	assert_true(player.stream.loop, "Existing music stream must loop")
	assert_true(player.playing)
	manager.set_bgm_muted(true)
	assert_eq(player.volume_db, -80.0)
