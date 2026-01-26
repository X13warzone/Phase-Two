extends Control


@export var leaderboard_internal_name: String

@onready var entries_container: VBoxContainer = %Entries
@onready var username: TextEdit = %Username


const LEADERBOARD_ENTRY = preload("res://leaderboard/leaderboard_entry.tscn")


func _ready() -> void:
	await _load_entries()


func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var c = LEADERBOARD_ENTRY.instantiate()
	c.set_data(entry.position, entry.player_alias.identifier, entry.score)
	entries_container.add_child(c)


func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	for entry in Talo.leaderboards.get_cached_entries(leaderboard_internal_name):
		_create_entry(entry)


func _load_entries() -> void:
	var page = 0
	var done = false
	
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)
		var entries: Array[TaloLeaderboardEntry] = res.entries
		var count: int = res.count
		var is_last_page: bool = res.is_last_page
		
		if is_last_page:
			done = true
		else:
			page += 1
	
	_build_entries()


func _on_submit_button_pressed() -> void:
	await Talo.players.identify("username", username.text)
	
	var score := GlobalScript.wave
	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score)
	assert(is_instance_valid(res))
	%InfoLabel.text = "%s REACHED WAVE %d" % [username.text, score]
	_build_entries()
