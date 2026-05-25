@tool
extends Resource
class_name Card

enum Type { ATTACK, SKILL, POWER }
enum Subtype { STARTER, NONE }
enum CharacterClass { WARRIOR, NONE }
enum DamageApplied { TARGET, ALL, WITHIN }

@export_group("Name Line")
@export var card_name: String = "card_name"
@export var ap_cost: int = 0

@export_group("Type Line")
@export var type: Type
@export var subtype: Subtype
@export var character_class: CharacterClass

@export_group("Abilities")
@export var does_damage: bool = false:
	set(value):
		does_damage = value
		notify_property_list_changed()

@export var damage: int = 0
@export var affects: DamageApplied

func _validate_property(property: Dictionary) -> void:
	if property.name in ["damage", "affects"] and not does_damage:
		property.usage = PROPERTY_USAGE_READ_ONLY
