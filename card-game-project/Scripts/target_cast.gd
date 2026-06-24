extends RefCounted
class_name TargetCast

##targeting system for enemies and aiming cards
##effects read only

var cell: Vector2i
var target: Node2D = null
var lane: Array[Vector2i] = []
