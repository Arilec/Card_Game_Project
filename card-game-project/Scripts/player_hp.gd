extends HBoxContainer
class_name PlayerHP

##player hp graphical interface script
##player_controller administrates changes.

# -- player name
@onready var player_name: Label = $Name

# -- player health and block
@onready var hp_amount: Label = $HPAmount
@onready var health_bar: ProgressBar = $HealthBar
@onready var block_amount: Label = $ColorRect/BlockAmount


# -- player health updates

##updates health values. this is updated when damaged and healed
##amount: int
func update_health(amount: int) -> void:
	hp_amount.text = str(amount)
	health_bar.value = amount

##updates health maximum
##amount: int
func update_max_health(amount: int) -> void:
	health_bar.max_value = amount

func update_block(amount: int) -> void:
	block_amount.text = str(amount)
