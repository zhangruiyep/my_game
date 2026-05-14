extends Control

func _ready():
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -100
	vbox.offset_top = -80
	vbox.offset_right = 100
	vbox.offset_bottom = 80
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)

	var title = Label.new()
	title.text = "FE Tactics"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)

	var new_game_btn = Button.new()
	new_game_btn.text = "开始新游戏"
	new_game_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_game_btn.pressed.connect(_on_new_game)
	vbox.add_child(new_game_btn)

	var leaderboard_btn = Button.new()
	leaderboard_btn.text = "排行榜"
	leaderboard_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leaderboard_btn.pressed.connect(_on_leaderboard)
	vbox.add_child(leaderboard_btn)

	var quit_btn = Button.new()
	quit_btn.text = "退出"
	quit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)

func _on_new_game():
	get_tree().change_scene_to_file("res://scenes/battle/BattleScene.tscn")

func _on_leaderboard():
	pass

func _on_quit():
	get_tree().quit()
