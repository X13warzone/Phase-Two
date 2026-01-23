extends Control


@onready var melee_combo_timer: Timer = $"../../MeleeComboTimer"
@onready var magic_pool_timer: Timer = $"../../MagicPoolTimer"
@onready var summon_skeleton_timer: Timer = $"../../SummonSkeletonTimer"


@onready var texture_progress_bar: TextureProgressBar = $CenterContainer/HBoxContainer/Panel/TextureProgressBar


func _process(delta: float) -> void:
	texture_progress_bar.value = melee_combo_timer.time_left
