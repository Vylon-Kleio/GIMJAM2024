extends Node2D

@onready var dungeon_music = $DungeonMusic
@onready var boss_1_music = $Boss1Music

func _ready():
	dungeon_music.play()


func _on_boss_music_trigger_body_entered(body):
	if body.is_in_group('player'):
		dungeon_music.stop()
		boss_1_music.play()
