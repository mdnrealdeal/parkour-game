class_name PlayerBlackboard
extends ActorBlackboard

signal stat_changed(stat_name: String, new_value: Variant)
signal sprint_started
signal sprint_ended
signal wallrun_started
signal wallrun_ended

func start_wallrun_cooldown(duration: float) -> void:
	super.start_wallrun_cooldown(duration)
	wallrun_ended.emit()

func start_dash_cooldown(duration: float) -> void:
	super.start_dash_cooldown(duration)
	stat_changed.emit("dash_cooldown", duration)
