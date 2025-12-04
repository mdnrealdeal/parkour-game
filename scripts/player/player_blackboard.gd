class_name PlayerBlackboard
extends ActorBlackboard

@warning_ignore_start("unused_signal")
signal stat_changed(stat_name: String, new_value: Variant)
signal sprint_started
signal sprint_ended
signal wallrun_started
signal wallrun_ended
@warning_ignore_restore("unused_signal")

func start_wallrun_cooldown(duration: float) -> void:
	super.start_wallrun_cooldown(duration)
	wallrun_ended.emit()

func start_dash_cooldown(duration: float) -> void:
	super.start_dash_cooldown(duration)
	stat_changed.emit("dash_cooldown", duration)

func _on_sprinting_changed(_active: bool) -> void:
	if _active: sprint_started.emit()
	else: sprint_ended.emit()
