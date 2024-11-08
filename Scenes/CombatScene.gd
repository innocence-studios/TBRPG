extends Node2D

signal end_player_turn
signal end_enemy_turn
signal player_end_turn

var hp = 100
var damage = 2
var enemy_list :Dictionary= {}

@export var combat : CombatEncounter
func _ready() -> void:
	init_combat()
	_enemy_turn()

func init_combat():
	for e in combat.enemies:
		var iterator = 0
		var test = enemy_list.has(e.name+str(iterator))
		while test:
			iterator+=1
			test = enemy_list.has(e.name+str(iterator))
		enemy_list[e.name+str(iterator)]={
			"damage":e.damage,
			"health":e.hp,
			}
			
func _enemy_turn():
	for e in enemy_list:
		hp-=enemy_list[e]["damage"]
		print(hp)
	emit_signal("end_enemy_turn")

func _player_turn():
	enemy_list[enemy_list.keys()[0]]["health"]=enemy_list[enemy_list.keys()[0]]["health"]-damage
	if enemy_list[enemy_list.keys()[0]]["health"]<=0:
		print("pouet")
		print(
			enemy_list.erase(
				enemy_list[
					enemy_list.keys()[0]
					]
				)
			)
	for e in enemy_list:
		print(
			enemy_list[e]["health"]
		)
	await player_end_turn
	emit_signal("end_player_turn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("player_end_turn")
