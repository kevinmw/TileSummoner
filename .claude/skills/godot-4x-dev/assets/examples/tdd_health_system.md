# TDD 开发血量系统完整示例

本示例展示使用 TDD 工作流程从零开发一个完整的血量系统组件。

## 需求分析

血量系统需要支持：
- 最大血量和当前血量
- 受伤和治疗
- 血量变化信号
- 死亡检测
- 无敌帧

## TDD 循环

### 第一轮：基础伤害

#### RED - 编写失败的测试

```gdscript
# tests/unit/systems/health_component_test.gd
class_name TestHealthComponent
extends GdUnitTestSuite

var _sut: HealthComponent

func before_test() -> void:
    _sut = auto_free(HealthComponent.new())
    _sut.max_health = 100
    _sut.current_health = 100

func test_take_damage_reduces_health() -> void:
    _sut.take_damage(30)

    assert_int(_sut.current_health).is_equal(70)
```

运行测试：
```
godot_run_test_file tests/unit/systems/health_component_test.gd
```

**结果**: 失败 - `HealthComponent` 类不存在

#### GREEN - 编写最小代码

```gdscript
# scripts/systems/health_component.gd
class_name HealthComponent
extends Node

var max_health: int = 100
var current_health: int = 100

func take_damage(amount: int) -> void:
    current_health -= amount
```

运行测试：
```
godot_run_test_file tests/unit/systems/health_component_test.gd
```

**结果**: 通过 ✓

#### REFACTOR - 暂无需要重构

---

### 第二轮：血量下限

#### RED

```gdscript
func test_take_damage_cannot_go_below_zero() -> void:
    _sut.current_health = 50

    _sut.take_damage(100)

    assert_int(_sut.current_health).is_equal(0)
```

**结果**: 失败 - 当前返回 -50

#### GREEN

```gdscript
func take_damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
```

**结果**: 通过 ✓

---

### 第三轮：死亡信号

#### RED

```gdscript
func test_take_lethal_damage_emits_died_signal() -> void:
    _sut.current_health = 30

    _sut.take_damage(50)

    await assert_signal(_sut).is_emitted("died")
```

**结果**: 失败 - 信号不存在

#### GREEN

```gdscript
signal died

func take_damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
    if current_health == 0:
        died.emit()
```

**结果**: 通过 ✓

---

### 第四轮：血量变化信号

#### RED

```gdscript
func test_take_damage_emits_health_changed() -> void:
    _sut.take_damage(30)

    await assert_signal(_sut).is_emitted("health_changed", [70, 100])
```

**结果**: 失败 - 信号不存在

#### GREEN

```gdscript
signal health_changed(current: int, maximum: int)

func take_damage(amount: int) -> void:
    var old_health := current_health
    current_health = maxi(0, current_health - amount)

    if current_health != old_health:
        health_changed.emit(current_health, max_health)

    if current_health == 0:
        died.emit()
```

**结果**: 通过 ✓

---

### 第五轮：治疗

#### RED

```gdscript
func test_heal_increases_health() -> void:
    _sut.current_health = 50

    _sut.heal(30)

    assert_int(_sut.current_health).is_equal(80)

func test_heal_cannot_exceed_max_health() -> void:
    _sut.current_health = 90

    _sut.heal(50)

    assert_int(_sut.current_health).is_equal(100)
```

**结果**: 失败 - heal 方法不存在

#### GREEN

```gdscript
func heal(amount: int) -> void:
    var old_health := current_health
    current_health = mini(current_health + amount, max_health)

    if current_health != old_health:
        health_changed.emit(current_health, max_health)
```

**结果**: 通过 ✓

#### REFACTOR - 提取公共逻辑

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100

var current_health: int:
    get:
        return current_health
    set(value):
        var old := current_health
        current_health = clampi(value, 0, max_health)
        if current_health != old:
            health_changed.emit(current_health, max_health)
        if current_health == 0 and old > 0:
            died.emit()

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health -= amount

func heal(amount: int) -> void:
    current_health += amount
```

运行所有测试确保重构没有破坏功能：
```
godot_run_test_file tests/unit/systems/health_component_test.gd
```

**结果**: 全部通过 ✓

---

### 第六轮：无敌帧

#### RED

```gdscript
func test_take_damage_during_invincibility_does_nothing() -> void:
    _sut.current_health = 100
    _sut.start_invincibility(1.0)

    _sut.take_damage(50)

    assert_int(_sut.current_health).is_equal(100)

func test_invincibility_expires() -> void:
    _sut.current_health = 100
    add_child(_sut)  # 需要在场景树中处理计时
    _sut.start_invincibility(0.1)

    await get_tree().create_timer(0.2).timeout

    _sut.take_damage(50)

    assert_int(_sut.current_health).is_equal(50)
```

**结果**: 失败 - 方法不存在

#### GREEN

```gdscript
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0

func _process(delta: float) -> void:
    if _is_invincible:
        _invincibility_timer -= delta
        if _invincibility_timer <= 0:
            _is_invincible = false

func start_invincibility(duration: float) -> void:
    _is_invincible = true
    _invincibility_timer = duration

func is_invincible() -> bool:
    return _is_invincible

func take_damage(amount: int) -> void:
    if _is_invincible:
        return
    current_health -= amount
```

**结果**: 通过 ✓

---

## 最终代码

```gdscript
# scripts/systems/health_component.gd
class_name HealthComponent
extends Node

## 信号
signal health_changed(current: int, maximum: int)
signal died

## 配置
@export var max_health: int = 100

## 状态
var current_health: int:
    get:
        return current_health
    set(value):
        var old := current_health
        current_health = clampi(value, 0, max_health)
        if current_health != old:
            health_changed.emit(current_health, max_health)
        if current_health == 0 and old > 0:
            died.emit()

var _is_invincible: bool = false
var _invincibility_timer: float = 0.0


func _ready() -> void:
    current_health = max_health


func _process(delta: float) -> void:
    if _is_invincible:
        _invincibility_timer -= delta
        if _invincibility_timer <= 0:
            _is_invincible = false


## 公共方法

func take_damage(amount: int) -> void:
    if _is_invincible:
        return
    current_health -= amount


func heal(amount: int) -> void:
    current_health += amount


func start_invincibility(duration: float) -> void:
    _is_invincible = true
    _invincibility_timer = duration


func is_invincible() -> bool:
    return _is_invincible


func get_health_percent() -> float:
    return float(current_health) / float(max_health)


func is_dead() -> bool:
    return current_health == 0
```

## 完整测试文件

```gdscript
# tests/unit/systems/health_component_test.gd
class_name TestHealthComponent
extends GdUnitTestSuite

var _sut: HealthComponent

func before_test() -> void:
    _sut = auto_free(HealthComponent.new())
    _sut.max_health = 100
    _sut.current_health = 100

## 伤害测试

func test_take_damage_reduces_health() -> void:
    _sut.take_damage(30)
    assert_int(_sut.current_health).is_equal(70)

func test_take_damage_cannot_go_below_zero() -> void:
    _sut.current_health = 50
    _sut.take_damage(100)
    assert_int(_sut.current_health).is_equal(0)

func test_take_lethal_damage_emits_died_signal() -> void:
    _sut.current_health = 30
    _sut.take_damage(50)
    await assert_signal(_sut).is_emitted("died")

func test_take_damage_emits_health_changed() -> void:
    _sut.take_damage(30)
    await assert_signal(_sut).is_emitted("health_changed", [70, 100])

## 治疗测试

func test_heal_increases_health() -> void:
    _sut.current_health = 50
    _sut.heal(30)
    assert_int(_sut.current_health).is_equal(80)

func test_heal_cannot_exceed_max_health() -> void:
    _sut.current_health = 90
    _sut.heal(50)
    assert_int(_sut.current_health).is_equal(100)

## 无敌帧测试

func test_take_damage_during_invincibility_does_nothing() -> void:
    _sut.start_invincibility(1.0)
    _sut.take_damage(50)
    assert_int(_sut.current_health).is_equal(100)

func test_invincibility_expires() -> void:
    add_child(_sut)
    _sut.start_invincibility(0.1)
    await get_tree().create_timer(0.2).timeout
    _sut.take_damage(50)
    assert_int(_sut.current_health).is_equal(50)

## 辅助方法测试

func test_get_health_percent() -> void:
    _sut.current_health = 75
    assert_float(_sut.get_health_percent()).is_equal(0.75)

func test_is_dead() -> void:
    assert_bool(_sut.is_dead()).is_false()
    _sut.current_health = 0
    assert_bool(_sut.is_dead()).is_true()
```

## 验收

```
# 运行所有测试
godot_run_tests

# 检查覆盖率
godot_get_test_coverage

# 代码质量
godot_lint_file scripts/systems/health_component.gd
```

## 总结

通过 TDD 开发：

1. **测试驱动设计**: 先思考行为，再实现
2. **小步前进**: 每次只添加一个功能
3. **持续重构**: 保持代码整洁
4. **高覆盖率**: 每个功能都有测试保护
5. **文档作用**: 测试即文档，描述系统行为
