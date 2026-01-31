# 场景测试

## 场景加载

### 预加载场景

```gdscript
class_name TestPlayerScene
extends GdUnitTestSuite

var _player_scene: PackedScene

func before() -> void:
    _player_scene = load("res://scripts/characters/player.tscn")
```

### 实例化场景

```gdscript
var _player: Player

func before_test() -> void:
    _player = auto_free(_player_scene.instantiate())
    add_child(_player)

func test_player_exists() -> void:
    assert_that(_player).is_not_null()
    assert_object(_player).is_instanceof(Player)
```

## 节点交互

### 访问子节点

```gdscript
func test_player_has_required_nodes() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)

    # 验证子节点存在
    assert_that(player.get_node_or_null("Sprite2D")).is_not_null()
    assert_that(player.get_node_or_null("CollisionShape2D")).is_not_null()
    assert_that(player.get_node_or_null("AnimationPlayer")).is_not_null()
```

### 修改属性

```gdscript
func test_player_position_update() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)

    player.position = Vector2(100, 50)

    await await_idle_frame()

    assert_vector2(player.position).is_equal(Vector2(100, 50))
```

## 输入模拟

### 使用 InputEvent

```gdscript
func test_player_movement() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)

    # 模拟按键事件
    var key_event := InputEventKey.new()
    key_event.keycode = KEY_D
    key_event.pressed = true
    Input.parse_input_event(key_event)

    # 等待物理帧处理
    for i in 5:
        await await_physics_frame()

    # 验证移动
    assert_float(player.velocity.x).is_greater(0)

    # 清理输入状态
    key_event.pressed = false
    Input.parse_input_event(key_event)
```

### 使用 Input Actions

```gdscript
func test_jump_action() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)
    player.position = Vector2(0, 0)

    # 确保在地面
    await await_physics_frame()

    # 模拟跳跃
    Input.action_press("jump")
    await await_physics_frame()
    Input.action_release("jump")

    # 验证跳跃
    assert_float(player.velocity.y).is_less(0)
```

### 模拟鼠标

```gdscript
func test_mouse_click() -> void:
    var button := auto_free(Button.new())
    add_child(button)
    button.position = Vector2(100, 100)
    button.size = Vector2(50, 30)

    var clicked := false
    button.pressed.connect(func(): clicked = true)

    # 模拟点击
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    click.position = Vector2(125, 115)  # 按钮中心
    button._gui_input(click)

    assert_bool(clicked).is_true()
```

## 物理测试

### 碰撞检测

```gdscript
func test_player_collects_coin() -> void:
    var player := auto_free(_player_scene.instantiate())
    var coin := auto_free(coin_scene.instantiate())
    add_child(player)
    add_child(coin)

    player.position = Vector2(0, 0)
    coin.position = Vector2(50, 0)

    var initial_coins := player.coins

    # 移动玩家到金币位置
    player.position = coin.position

    await await_physics_frame()
    await await_physics_frame()

    assert_int(player.coins).is_greater(initial_coins)
```

### 射线检测

```gdscript
func test_raycast_detection() -> void:
    var player := auto_free(_player_scene.instantiate())
    var wall := auto_free(wall_scene.instantiate())
    add_child(player)
    add_child(wall)

    player.position = Vector2(0, 0)
    wall.position = Vector2(100, 0)

    await await_physics_frame()

    var can_see := player.can_see_position(wall.position)

    assert_bool(can_see).is_true()
```

## Area2D 测试

### 进入区域

```gdscript
func test_damage_zone() -> void:
    var player := auto_free(_player_scene.instantiate())
    var damage_zone := auto_free(damage_zone_scene.instantiate())
    add_child(player)
    add_child(damage_zone)

    var initial_health := player.health

    # 移动玩家进入伤害区域
    player.position = damage_zone.position

    # 等待碰撞检测
    await await_physics_frame()
    await await_physics_frame()

    assert_int(player.health).is_less(initial_health)
```

## 动画测试

### 播放动画

```gdscript
func test_attack_animation() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)

    player.attack()

    assert_str(player.animation_player.current_animation).is_equal("attack")
```

### 等待动画结束

```gdscript
func test_animation_completion() -> void:
    var player := auto_free(_player_scene.instantiate())
    add_child(player)

    player.play_death_animation()

    await player.animation_player.animation_finished

    assert_bool(player.is_dead).is_true()
```

## UI 场景测试

### 按钮测试

```gdscript
func test_start_button() -> void:
    var menu := auto_free(main_menu_scene.instantiate())
    add_child(menu)

    var start_button: Button = menu.get_node("StartButton")

    var signal_received := false
    menu.game_started.connect(func(): signal_received = true)

    start_button.emit_signal("pressed")

    assert_bool(signal_received).is_true()
```

### 文本输入

```gdscript
func test_name_input() -> void:
    var dialog := auto_free(name_dialog_scene.instantiate())
    add_child(dialog)

    var line_edit: LineEdit = dialog.get_node("NameInput")

    line_edit.text = "TestPlayer"
    line_edit.emit_signal("text_submitted", "TestPlayer")

    await await_idle_frame()

    assert_str(dialog.player_name).is_equal("TestPlayer")
```

## 场景切换测试

```gdscript
func test_level_transition() -> void:
    var level1 := auto_free(level1_scene.instantiate())
    add_child(level1)

    var door: Area2D = level1.get_node("ExitDoor")
    var player := level1.get_node("Player")

    # 模拟进入门
    player.position = door.position
    await await_physics_frame()
    await await_physics_frame()

    # 验证切换信号
    await assert_signal(level1).is_emitted("level_completed")
```

## 最佳实践

### 1. 使用 auto_free

```gdscript
# 好：自动清理
var player := auto_free(_player_scene.instantiate())

# 避免：手动管理可能忘记清理
var player := _player_scene.instantiate()
# ... 忘记调用 player.free()
```

### 2. 等待物理帧

```gdscript
# 碰撞检测需要物理帧
await await_physics_frame()

# 有时需要多帧
for i in 3:
    await await_physics_frame()
```

### 3. 清理输入状态

```gdscript
func after_test() -> void:
    # 释放所有可能按下的键
    Input.action_release("move_left")
    Input.action_release("move_right")
    Input.action_release("jump")
```

### 4. 隔离测试

```gdscript
# 每个测试独立创建场景
func before_test() -> void:
    _player = auto_free(_player_scene.instantiate())
    add_child(_player)
    # 每次都是新的实例
```
