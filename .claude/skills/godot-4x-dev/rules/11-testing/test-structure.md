# 测试目录结构规范

## 测试目录

```
project_root/
├── scripts/                    # 源代码
│   ├── characters/
│   │   └── player.gd
│   ├── systems/
│   │   └── health_component.gd
│   └── utils/
│       └── math_utils.gd
│
└── tests/                      # 测试代码（镜像 scripts 结构）
    ├── unit/                   # 单元测试（纯逻辑）
    │   ├── characters/
    │   │   └── player_test.gd
    │   ├── systems/
    │   │   └── health_component_test.gd
    │   └── utils/
    │       └── math_utils_test.gd
    │
    ├── integration/            # 集成测试（多组件交互）
    │   └── player_health_test.gd
    │
    └── scene/                  # 场景测试（完整场景）
        └── player_scene_test.gd
```

## 测试类型

### 单元测试 (unit/)

- 测试单个类/函数的逻辑
- 不依赖场景树
- 不依赖其他组件（使用 Mock）
- 执行速度快

```gdscript
# tests/unit/systems/health_component_test.gd
class_name TestHealthComponent
extends GdUnitTestSuite

func test_take_damage_reduces_health() -> void:
    var health := HealthComponent.new()
    health.max_health = 100
    health.current_health = 100

    health.take_damage(30)

    assert_int(health.current_health).is_equal(70)
    health.free()
```

### 集成测试 (integration/)

- 测试多个组件协作
- 可以依赖场景树
- 验证组件间通信

```gdscript
# tests/integration/player_health_test.gd
class_name TestPlayerHealthIntegration
extends GdUnitTestSuite

var _player: Player
var _enemy: Enemy

func before_test() -> void:
    _player = auto_free(Player.new())
    _enemy = auto_free(Enemy.new())
    add_child(_player)
    add_child(_enemy)

func test_enemy_attack_damages_player() -> void:
    var initial_health := _player.health_component.current_health

    _enemy.attack(_player)

    assert_int(_player.health_component.current_health).is_less(initial_health)
```

### 场景测试 (scene/)

- 测试完整场景行为
- 加载 .tscn 文件
- 模拟用户输入

```gdscript
# tests/scene/player_scene_test.gd
class_name TestPlayerScene
extends GdUnitTestSuite

var _player_scene: PackedScene
var _player: Player

func before() -> void:
    _player_scene = load("res://scripts/characters/player.tscn")

func before_test() -> void:
    _player = auto_free(_player_scene.instantiate())
    add_child(_player)

func test_player_can_jump() -> void:
    # 模拟跳跃输入
    simulate_key_press(KEY_SPACE)

    await await_idle_frame()

    assert_float(_player.velocity.y).is_less(0)
```

## 命名规范

### 测试文件

| 类型 | 格式 | 示例 |
|------|------|------|
| 测试文件 | `<source>_test.gd` | `player_test.gd` |
| 测试场景 | `<source>_test.tscn` | `player_test.tscn` |

### 测试类

| 类型 | 格式 | 示例 |
|------|------|------|
| 测试类 | `Test<ClassName>` | `TestPlayer` |
| 集成测试 | `Test<Feature>Integration` | `TestPlayerHealthIntegration` |
| 场景测试 | `Test<Scene>Scene` | `TestPlayerScene` |

### 测试方法

**格式**: `test_<行为>_<条件>_<预期>`

```gdscript
# 好的命名
func test_take_damage_reduces_health() -> void:
func test_take_damage_with_armor_reduces_damage() -> void:
func test_heal_at_max_health_does_nothing() -> void:
func test_die_emits_died_signal() -> void:

# 避免的命名
func test_1() -> void:           # 无意义
func test_health() -> void:       # 太模糊
func testTakeDamage() -> void:   # 驼峰命名
```

## 镜像原则

测试文件结构应镜像源代码结构：

```
scripts/characters/player.gd
    ↓
tests/unit/characters/player_test.gd

scripts/systems/inventory.gd
    ↓
tests/unit/systems/inventory_test.gd
```

## 测试文件模板

```gdscript
# tests/unit/systems/health_component_test.gd
class_name TestHealthComponent
extends GdUnitTestSuite

## 被测试对象
var _sut: HealthComponent  # SUT = System Under Test

func before_test() -> void:
    _sut = auto_free(HealthComponent.new())
    _sut.max_health = 100
    _sut.current_health = 100

## 基础功能测试

func test_initial_health_equals_max_health() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 50

    assert_int(health.current_health).is_equal(50)

## 伤害测试

func test_take_damage_reduces_health() -> void:
    _sut.take_damage(30)

    assert_int(_sut.current_health).is_equal(70)

func test_take_damage_cannot_go_negative() -> void:
    _sut.take_damage(150)

    assert_int(_sut.current_health).is_equal(0)
```

## MCP 工具

| 工具 | 说明 |
|------|------|
| `godot_generate_test` | 根据源文件生成测试桩 |
| `godot_run_tests` | 运行指定目录的测试 |
| `godot_validate_project` | 验证项目结构 |
