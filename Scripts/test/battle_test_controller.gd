# Scripts/test/battle_test_controller.gd
extends Node2D

## 建筑系统战斗测试控制器
## 用于验证塔、基地、护盾机制

# ============ 常量 ============

const BUILDING_SCENE := preload("res://Scenes/unit/building.tscn")
const UNIT_SCENE := preload("res://Scenes/unit/unit.tscn")
const TOWER_DATA := preload("res://Resources/Units/buildings/tower.tres")
const BASE_DATA := preload("res://Resources/Units/buildings/base.tres")
const CAVALRY_DATA := preload("res://Resources/Units/grass/cavalry.tres")

const GRID_SIZE := 80.0  # 像素/格

# ============ 子节点引用 ============

@onready var _buildings_container: Node2D = $Buildings
@onready var _units_container: Node2D = $Units
@onready var _debug_label: Label = $UILayer/DebugLabel
@onready var _status_label: Label = $UILayer/StatusLabel

# ============ 建筑控制器 ============

var _player_controller: BuildingController
var _enemy_controller: BuildingController

# ============ 建筑引用 ============

var _player_base: Building
var _player_towers: Array[Building] = []
var _enemy_base: Building
var _enemy_towers: Array[Building] = []

# ============ 测试单位 ============

var _test_units: Array[Unit] = []

# ============ 生命周期 ============

func _ready() -> void:
	await get_tree().process_frame
	_initialize_test()


func _process(_delta: float) -> void:
	_update_status()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_spawn_enemy_unit()
			KEY_2:
				_damage_player_tower(100)
			KEY_3:
				_damage_player_base(100)
			KEY_4:
				_kill_player_tower()
			KEY_R:
				_reset_test()
			KEY_ESCAPE:
				get_tree().quit()


# ============ 初始化 ============

func _initialize_test() -> void:
	print("[BattleTest] Initializing building test...")

	# 创建建筑控制器
	_player_controller = BuildingController.new()
	_player_controller.name = "PlayerController"
	add_child(_player_controller)

	_enemy_controller = BuildingController.new()
	_enemy_controller.name = "EnemyController"
	add_child(_enemy_controller)

	# 创建建筑
	_create_buildings()

	# 监听护盾事件
	_player_controller.shield_broken.connect(_on_player_shield_broken)
	_enemy_controller.shield_broken.connect(_on_enemy_shield_broken)

	print("[BattleTest] Test initialized")


func _create_buildings() -> void:
	var viewport_center := get_viewport().get_visible_rect().size / 2

	# 玩家阵营（左侧）
	var player_base_pos := Vector2(viewport_center.x - 300, viewport_center.y)
	var player_tower1_pos := Vector2(viewport_center.x - 200, viewport_center.y - 100)
	var player_tower2_pos := Vector2(viewport_center.x - 200, viewport_center.y + 100)

	_player_base = _create_building(BASE_DATA, 0, player_base_pos)
	_player_towers.append(_create_building(TOWER_DATA, 0, player_tower1_pos))
	_player_towers.append(_create_building(TOWER_DATA, 0, player_tower2_pos))

	_player_controller.set_base(_player_base)
	for tower in _player_towers:
		_player_controller.register_tower(tower)

	# 敌方阵营（右侧）
	var enemy_base_pos := Vector2(viewport_center.x + 300, viewport_center.y)
	var enemy_tower1_pos := Vector2(viewport_center.x + 200, viewport_center.y - 100)
	var enemy_tower2_pos := Vector2(viewport_center.x + 200, viewport_center.y + 100)

	_enemy_base = _create_building(BASE_DATA, 1, enemy_base_pos)
	_enemy_towers.append(_create_building(TOWER_DATA, 1, enemy_tower1_pos))
	_enemy_towers.append(_create_building(TOWER_DATA, 1, enemy_tower2_pos))

	_enemy_controller.set_base(_enemy_base)
	for tower in _enemy_towers:
		_enemy_controller.register_tower(tower)

	print("[BattleTest] Created 6 buildings (2 bases, 4 towers)")


func _create_building(data: BuildingData, team: int, pos: Vector2) -> Building:
	var building: Building = BUILDING_SCENE.instantiate()
	building.position = pos
	_buildings_container.add_child(building)
	building.initialize(data, team)
	return building


# ============ 测试功能 ============

func _spawn_enemy_unit() -> void:
	var viewport_center := get_viewport().get_visible_rect().size / 2
	var spawn_pos := Vector2(viewport_center.x + 100, viewport_center.y + randf_range(-50, 50))

	var unit: Unit = UNIT_SCENE.instantiate()
	unit.position = spawn_pos
	_units_container.add_child(unit)
	unit.initialize(CAVALRY_DATA, 1)

	_test_units.append(unit)
	print("[BattleTest] Spawned enemy cavalry at %s" % spawn_pos)


func _damage_player_tower(amount: int) -> void:
	for tower in _player_towers:
		if tower.is_alive():
			tower.take_damage(amount, null)
			print("[BattleTest] Damaged tower for %d (HP: %d/%d)" % [
				amount, tower.current_health, tower.max_health
			])
			return
	print("[BattleTest] No alive towers to damage")


func _damage_player_base(amount: int) -> void:
	if _player_base.is_alive():
		var before_hp := _player_base.current_health
		_player_base.take_damage(amount, null)
		var after_hp := _player_base.current_health

		if before_hp == after_hp:
			print("[BattleTest] Base shield blocked %d damage" % amount)
		else:
			print("[BattleTest] Base took %d damage (HP: %d/%d)" % [
				amount, _player_base.current_health, _player_base.max_health
			])


func _kill_player_tower() -> void:
	for tower in _player_towers:
		if tower.is_alive():
			tower.take_damage(tower.current_health, null)
			print("[BattleTest] Killed tower")
			return
	print("[BattleTest] No alive towers to kill")


func _reset_test() -> void:
	print("[BattleTest] Resetting test...")

	# 清理单位
	for unit in _test_units:
		if is_instance_valid(unit):
			unit.queue_free()
	_test_units.clear()

	# 清理建筑
	for child in _buildings_container.get_children():
		child.queue_free()
	_player_towers.clear()
	_enemy_towers.clear()

	# 重新创建
	await get_tree().process_frame
	_create_buildings()

	# 重新注册监听
	_player_controller.set_base(_player_base)
	for tower in _player_towers:
		_player_controller.register_tower(tower)

	_enemy_controller.set_base(_enemy_base)
	for tower in _enemy_towers:
		_enemy_controller.register_tower(tower)

	print("[BattleTest] Test reset complete")


# ============ 信号处理 ============

func _on_player_shield_broken() -> void:
	print("[BattleTest] PLAYER SHIELD BROKEN!")


func _on_enemy_shield_broken() -> void:
	print("[BattleTest] ENEMY SHIELD BROKEN!")


# ============ UI 更新 ============

func _update_status() -> void:
	if not _status_label:
		return

	var lines: Array[String] = []

	# 玩家状态
	lines.append("=== PLAYER ===")
	lines.append("Base: %d/%d %s" % [
		_player_base.current_health if _player_base else 0,
		_player_base.max_health if _player_base else 0,
		"[SHIELD]" if _player_controller.is_shield_active() else ""
	])
	lines.append("Towers: %d alive" % _player_controller.get_alive_tower_count())

	for i in range(_player_towers.size()):
		var tower := _player_towers[i]
		var status := "ALIVE" if tower.is_alive() else "DEAD"
		lines.append("  Tower %d: %d/%d [%s]" % [
			i + 1, tower.current_health, tower.max_health, status
		])

	lines.append("")

	# 敌方状态
	lines.append("=== ENEMY ===")
	lines.append("Base: %d/%d %s" % [
		_enemy_base.current_health if _enemy_base else 0,
		_enemy_base.max_health if _enemy_base else 0,
		"[SHIELD]" if _enemy_controller.is_shield_active() else ""
	])
	lines.append("Towers: %d alive" % _enemy_controller.get_alive_tower_count())

	_status_label.text = "\n".join(lines)
