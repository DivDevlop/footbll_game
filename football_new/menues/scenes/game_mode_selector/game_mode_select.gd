extends Control

@onready var mode := $Panel/VBoxContainer/GameMode
@onready var difficulty := $Panel/VBoxContainer/Difficulty

func _ready():
	mode.add_item("1v1")
	mode.add_item("1v2")
	mode.add_item("free")

	difficulty.add_item("EASY")
	difficulty.add_item("MEDIUM")
	difficulty.add_item("HARD")



func _on_button_pressed() -> void:
	GameData.game_mode = mode.get_item_text(mode.selected)
	GameData.difficulty = difficulty.get_item_text(difficulty.selected)

	get_tree().change_scene_to_file("res://MAPS/Map1.tscn")
