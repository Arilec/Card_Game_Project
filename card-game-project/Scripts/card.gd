@tool
extends Resource
class_name Card

## Data center for card objects
## The visuals are handled by CardView
## resources are created for every individual card

# -- Enumerators: Type, Subtype, Character Class and Damage application
enum Type { ATTACK, SKILL, POWER }
enum Subtype { STARTER, NONE }
enum CharacterClass { WARRIOR, NONE }
enum DamageApplied { TARGET, ALL, WITHIN }
enum TargetType { SELF, POINT, PROJECTILE }

# -- Name line
@export_group("Name Line")
@export var card_name: String = "card_name"
@export var ap_cost: int = 0

# -- Type line
@export_group("Type Line")
@export var type: Type
@export var subtype: Subtype
@export var character_class: CharacterClass

# -- Abilities
@export_group("Abilities")

@export var effects: Array[CardEffect]

@export var damage: int = 0
@export var block: int = 0

@export var targets: DamageApplied

@export var target_type: TargetType
@export var range: int = 1



var reference_the_creator: String = "Ari"
