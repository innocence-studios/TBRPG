extends Control

var text : String:
	set(value):
		$HBoxContainer/VBoxContainer/name.text=value
		
var max_hp : int:
	set(value):
		$HBoxContainer/VBoxContainer/hp.max_value = value
var hp : int:
	set(value):
		$HBoxContainer/VBoxContainer/hp.value = value

var max_mp : int:
	set(value):
		$HBoxContainer/VBoxContainer/mp.max_value = value
var mp : int:
	set(value):
		$HBoxContainer/VBoxContainer/mp.value = value

var max_ap : int:
	set(value):
		$HBoxContainer/VBoxContainer/ap.max_value = value
var ap : int:
	set(value):
		$HBoxContainer/VBoxContainer/ap.value = value

var portrait : Texture2D:
	set(value):
		$HBoxContainer/portrait.texture = value
