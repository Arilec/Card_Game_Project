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

#Attack and damaging abilities
@export var does_damage: bool = false:
	set(value):
		does_damage = value
		notify_property_list_changed()

@export var damage: int = 0
@export var affects: DamageApplied

#Block abilities
@export var gives_block: bool = false:
	set(value):
		gives_block = value
		notify_property_list_changed()

@export var block: int = 0


func _validate_property(property: Dictionary) -> void:
	if property.name in ["damage", "affects"] and not does_damage:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "block" and not gives_block:
		property.usage |= PROPERTY_USAGE_READ_ONLY

func play(target = "self"):
	match type:
		Type.ATTACK:
			if does_damage:
				print(card_name, " does ", damage, " to ")
				match affects:
					DamageApplied.TARGET:
						print("a target")
					DamageApplied.ALL:
						print("all adjacent enemies")
					DamageApplied.WITHIN:
						print("all in an area")
		Type.SKILL:
			if gives_block:
				print("you gain ", block, " block")
			else:
				print(card_name + " does something")
		Type.POWER:
			pass
	
