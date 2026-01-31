# TDD 工作流程

## TDD 循环

```
┌─────────┐    失败    ┌─────────┐    通过    ┌──────────┐
│  RED    │ ────────→ │  GREEN  │ ────────→ │ REFACTOR │
│ 写测试  │           │  写代码  │           │   重构   │
└─────────┘           └─────────┘           └────┬─────┘
     ↑                                           │
     └───────────────── 下一功能 ←───────────────┘
```

## 详细步骤

### 1. RED（红灯）- 写失败的测试

**目标**: 编写描述期望行为的测试，测试必须失败

```gdscript
# 1. 分析需求：实现血量系统
# 2. 确定第一个行为：take_damage 减少血量

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

**MCP 工具**:
```
godot_generate_test scripts/systems/health_component.gd
godot_run_test_file tests/unit/systems/health_component_test.gd
```

**验证**: 测试失败（红灯）

### 2. GREEN（绿灯）- 写最小代码

**目标**: 编写刚好让测试通过的代码，不多不少

```gdscript
# scripts/systems/health_component.gd
class_name HealthComponent
extends Node

var max_health: int = 100
var current_health: int = 100

func take_damage(amount: int) -> void:
    current_health -= amount
```

**MCP 工具**:
```
godot_run_test_file tests/unit/systems/health_component_test.gd
godot_lint_file scripts/systems/health_component.gd
```

**验证**: 测试通过（绿灯）

### 3. REFACTOR（重构）- 改进代码

**目标**: 在测试保护下改进代码质量

```gdscript
# scripts/systems/health_component.gd
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100:
    set(value):
        max_health = maxi(1, value)
        current_health = mini(current_health, max_health)

var current_health: int = max_health

func take_damage(amount: int) -> void:
    var old_health := current_health
    current_health = maxi(0, current_health - amount)

    if current_health != old_health:
        health_changed.emit(current_health, max_health)

    if current_health == 0:
        died.emit()
```

**MCP 工具**:
```
godot_run_test_file tests/unit/systems/health_component_test.gd  # 确保测试仍然通过
godot_lint_file scripts/systems/health_component.gd
```

### 4. 重复循环

添加新测试，继续 RED → GREEN → REFACTOR：

```gdscript
# 新测试：血量不能低于 0
func test_take_damage_cannot_go_below_zero() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 50

    health.take_damage(100)

    assert_int(health.current_health).is_equal(0)

# 新测试：死亡信号
func test_take_lethal_damage_emits_died_signal() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 30

    # 监控信号
    var monitor := monitor_signals(health)

    health.take_damage(50)

    await assert_signal(health).is_emitted("died")
```

## TDD 规则

### 三定律

1. **不写生产代码，除非是为了让失败的测试通过**
2. **只写刚好使测试失败的测试代码**
3. **只写刚好使测试通过的生产代码**

### 测试优先思维

| 传统方式 | TDD 方式 |
|----------|----------|
| 思考如何实现 | 思考期望行为 |
| 写代码 → 写测试 | 写测试 → 写代码 |
| 测试验证实现 | 测试定义规范 |

## 完整示例：开发治疗功能

### RED

```gdscript
func test_heal_increases_health() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 50

    health.heal(30)

    assert_int(health.current_health).is_equal(80)

func test_heal_cannot_exceed_max_health() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 90

    health.heal(50)

    assert_int(health.current_health).is_equal(100)
```

运行测试 → 失败（heal 方法不存在）

### GREEN

```gdscript
func heal(amount: int) -> void:
    current_health = mini(current_health + amount, max_health)
    health_changed.emit(current_health, max_health)
```

运行测试 → 通过

### REFACTOR

```gdscript
func heal(amount: int) -> void:
    _set_health(current_health + amount)

func take_damage(amount: int) -> void:
    _set_health(current_health - amount)
    if current_health == 0:
        died.emit()

func _set_health(value: int) -> void:
    var old_health := current_health
    current_health = clampi(value, 0, max_health)
    if current_health != old_health:
        health_changed.emit(current_health, max_health)
```

运行测试 → 仍然通过

## 验收阶段

```
# 运行所有测试
godot_run_tests

# 检查覆盖率（目标 > 80%）
godot_get_test_coverage

# 代码质量检查
godot_lint_file scripts/systems/health_component.gd
godot_project_health
```

## MCP 工具速查

| 阶段 | 工具 | 用途 |
|------|------|------|
| RED | `godot_generate_test` | 生成测试桩 |
| RED | `godot_run_test_file` | 确认测试失败 |
| GREEN | `godot_run_test_file` | 确认测试通过 |
| GREEN | `godot_lint_file` | 检查代码质量 |
| REFACTOR | `godot_run_test_file` | 确保重构不破坏功能 |
| 验收 | `godot_run_tests` | 运行全部测试 |
| 验收 | `godot_get_test_coverage` | 检查覆盖率 |

## 常见问题

### 什么时候写测试？

- **新功能**: 先写测试
- **Bug 修复**: 先写复现 Bug 的测试
- **重构**: 确保已有测试覆盖

### 测试粒度

- 每个测试只验证一个行为
- 测试名称描述期望行为
- 测试失败时能快速定位问题

### 何时重构

- 测试通过后
- 代码有明显重复
- 命名可以更清晰
- 结构可以简化
