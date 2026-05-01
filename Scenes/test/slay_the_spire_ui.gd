extends Control
class_name SlayUIController

@onready var turn_label: Label = $TopBar/TurnLabel
@onready var end_turn_button: Button = $TopBar/EndTurnButton
@onready var enemy_hp_bar: ProgressBar = $EnemyArea/EnemyHPBar
@onready var player_hp_bar: ProgressBar = $PlayerArea/PlayerHPBar

var current_turn: int = 1

func _ready() -> void:
    end_turn_button.pressed.connect(_on_end_turn_pressed)
    _update_turn_display()

func _on_end_turn_pressed() -> void:
    current_turn += 1
    _update_turn_display()

func _update_turn_display() -> void:
    turn_label.text = "Turn %d" % current_turn
