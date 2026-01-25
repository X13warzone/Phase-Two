extends Node


var effect_db: float:
	set(new_v):
		effect_db = new_v
		if effect_db <= -20:
			effect_db = -999
		if effect_db >= 20:
			effect_db = 20
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effect"), effect_db)
var music_db: float:
	set(new_v):
		music_db = new_v
		if music_db <= -20:
			music_db = -999
		if music_db >= 20:
			music_db = 20
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
