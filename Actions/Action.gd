extends Resource
class_name Action

@export var name : String
@export_file("*.png") var cursor : String
@export var shape : Array[Vector3i]
@export var mp_cost : int
@export var ap_cost : int
@export var range : float
@export var line_of_sight : bool
@export var action_script : Script
