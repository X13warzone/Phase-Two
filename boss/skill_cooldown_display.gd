extends Control


@onready var melee_combo_timer: Timer = $"../../MeleeComboTimer"
@onready var magic_pool_timer: Timer = $"../../MagicPoolTimer"
@onready var summon_skeleton_timer: Timer = $"../../SummonSkeletonTimer"


@onready var mace_prog: TextureProgressBar = $CenterContainer/HBoxContainer/MarginContainer/MaceProg
@onready var poison_prog: TextureProgressBar = $CenterContainer/HBoxContainer/MarginContainer2/PoisonProg
@onready var skeleton_prog: TextureProgressBar = $CenterContainer/HBoxContainer/MarginContainer3/SkeletonProg


var magic_poison_unlocked: bool = false
var summon_skeleton_unlocked: bool = false


func _process(delta: float) -> void:
	mace_prog.value = melee_combo_timer.time_left - 1.2
	if magic_poison_unlocked:
		poison_prog.value = magic_pool_timer.time_left
	if summon_skeleton_unlocked:
		skeleton_prog.value = summon_skeleton_timer.time_left
