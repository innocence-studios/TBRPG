extends Control

var text : String:
	set(value):
		text=value
		$Border2/Label.text=value
