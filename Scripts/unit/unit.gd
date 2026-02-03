# Scripts/unit/unit.gd
class_name Unit
extends CharacterBody2D

## 单位主类
## 管理单位的生命周期、属性和子系统

# ============ 信号 ============

signal health_changed(current: int, max_val: int)
signal died(killer: Unit)
signal attack_performed(target: Unit)

# ============ 属性 ============

## 单位数据
var data: UnitData = null

## 所属阵营（0=己方，1=敌方）
var team: int = 0

## 当前生命值
var current_health: int = 0

## 最大生命值
var max_health: int = 0

## 是否已死亡
var is_dead: bool = false

## 最后攻击者
var last_attacker: Unit = null

# ============ 子节点引用 ============

@onready var shape_renderer: ShapeRenderer = $ShapeRenderer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var icon_sprite: Sprite2D = $ShapeRenderer/IconSprite
## 能力管理器（使用 Node 类型避免循环依赖）
@onready var ability_manager: Node = $AbilityManager
## 行为管理器（使用 Node 类型避免循环依赖）
@onready var behavior_manager: Node = $BehaviorManager

# ============ 公共方法 ============

## 初始化单位
func initialize(unit_data: UnitData, unit_team: int) -> void:
	if not unit_data:
		push_error("UnitData is null")
		return

	data = unit_data
	team = unit_team

	# 设置属性
	max_health = data.max_health
	current_health = max_health
	is_dead = false

	# 配置外观
	_setup_visuals()

	# 配置碰撞
	_setup_collision()

	# 初始化能力管理器
	if ability_manager:
		ability_manager.initialize(self, data.abilities)

	# 初始化行为管理器
	if behavior_manager:
		behavior_manager.initialize(self)


## 受到伤害
func take_damage(amount: int, attacker: Unit) -> void:
	if is_dead:
		return

	last_attacker = attacker
	current_health = maxi(0, current_health - amount)

	_update_health_visual()
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_die()


## 治疗
func heal(amount: int) -> void:
	if is_dead:
		return

	current_health = mini(max_health, current_health + amount)
	_update_health_visual()
	health_changed.emit(current_health, max_health)


## 是否存活
func is_alive() -> bool:
	return not is_dead


## 获取攻击范围
func get_attack_range() -> float:
	if ability_manager:
		return ability_manager.get_max_attack_range()
	return 0.0


## 向目标移动
func move_toward(target_pos: Vector2) -> void:
	if not data:
		return
	var direction := (target_pos - global_position).normalized()
	velocity = direction * data.move_speed * 80.0  # 80像素/格
	move_and_slide()


## 停止移动
func stop_moving() -> void:
	velocity = Vector2.ZERO


## 向敌方基地移动
func move_toward_enemy_base() -> void:
	# TODO: 获取敌方基地位置
	pass


## 播放攻击动画
func play_attack(target_pos: Vector2) -> void:
	if not shape_renderer:
		return

	var dir := (target_pos - global_position).normalized()
	var target_rotation := dir.angle()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)

	# 旋转朝向 + 放大
	tween.tween_property(shape_renderer, "rotation", target_rotation, 0.1)
	tween.parallel().tween_property(shape_renderer, "scale", Vector2(1.2, 1.2), 0.1)

	# 缩回原状
	tween.tween_property(shape_renderer, "scale", Vector2.ONE, 0.1)
	tween.tween_property(shape_renderer, "rotation", 0.0, 0.1)


# ============ 私有方法 ============

func _setup_visuals() -> void:
	if not shape_renderer:
		return

	if not data:
		return

	shape_renderer.unit_mode = data.unit_mode
	shape_renderer.unit_size = data.unit_size
	shape_renderer.fill_color = data.base_color
	shape_renderer.border_color = UnitConfig.get_team_color(team)
	shape_renderer.health_percent = 1.0

	if icon_sprite and data.icon:
		icon_sprite.texture = data.icon


func _setup_collision() -> void:
	if not collision_shape:
		return

	if not data:
		return

	var radius := UnitConfig.get_size_radius(data.unit_size) * 80.0
	var circle := CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle


func _update_health_visual() -> void:
	if shape_renderer and max_health > 0:
		shape_renderer.health_percent = float(current_health) / float(max_health)


func _die() -> void:
	is_dead = true
	died.emit(last_attacker)
	# TODO: 播放死亡动画后删除
