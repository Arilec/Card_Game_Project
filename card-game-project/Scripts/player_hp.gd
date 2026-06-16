extends HBoxContainer
class_name PlayerHP

@onready var player_name: Label = $Name

@onready var hp_amount: Label = $HPAmount
@onready var progress_bar: ProgressBar = $ProgressBar

func update_health(amount: int) -> void:
	hp_amount.text = str(amount)
	progress_bar.value = amount

func update_max_health(amount: int) -> void:
	progress_bar.max_value = amount
	
