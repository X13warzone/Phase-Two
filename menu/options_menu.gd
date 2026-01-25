extends VBoxContainer

func _ready() -> void:
	$HBoxContainer/SoundSlider.value = GlobalSettings.effect_db
	$HBoxContainer2/MusicSlider.value = GlobalSettings.music_db


func _on_sound_slider_value_changed(value: float) -> void:
	GlobalSettings.effect_db = value


func _on_music_slider_value_changed(value: float) -> void:
	GlobalSettings.music_db = value
