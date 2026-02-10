# 单位系统实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现基于几何图形+icon的单位系统，支持6种模式形状、4种体型、组合式能力和自动战斗行为。

**Architecture:**
- 数据驱动设计：UnitData(Resource) 定义单位属性，UnitAbility(Resource) 定义能力数据
- 运行时分离：AbilityInstance(Node) 管理能力状态，BehaviorManager(Node) 管理行为决策
- 组合优于继承：使用子节点管理器（AbilityManager、BehaviorManager）而非深层继承

**Tech Stack:** Godot 4.5.1, GDScript, GdUnit4 测试框架

---

## Phase 1: 基础数据结构

### Task 1: 单位枚举定义

**Files:**
- Create: `Scripts/unit/unit_enums.gd`
- Test: `Scripts/test/unit/test_unit_enums.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit_enums.gd
class_name TestUnitEnums
extends GdUnitTestSuite

## 测试单位枚举定义


## 测试1：UnitMode 枚举包含6种模式
func test_unit_mode_has_six_types() -> void:
    assert_that(UnitEnums.UnitMode.size()).is_equal(6)


## 测试2：UnitSize 枚举包含4种体型
func test_unit_size_has_four_types() -> void:
    assert_that(UnitEnums.UnitSize.size()).is_equal(4)


## 测试3：ElementTag 枚举包含8种元素
func test_element_tag_has_eight_types() -> void:
    assert_that(UnitEnums.ElementTag.size()).is_equal(8)


## 测试4：MoveType 枚举包含2种移动类型
func test_move_type_has_two_types() -> void:
    assert_that(UnitEnums.MoveType.size()).is_equal(2)


## 测试5：AbilityTrigger 枚举包含所有触发类型
func test_ability_trigger_types() -> void:
    assert_that(UnitEnums.AbilityTrigger.AUTO).is_equal(0)
    assert_that(UnitEnums.AbilityTrigger.ON_COMBAT_START).is_equal(1)
    assert_that(UnitEnums.AbilityTrigger.PERIODIC).is_equal(2)


## 测试6：TargetPriority 枚举定义正确
func test_target_priority_types() -> void:
    assert_that(UnitEnums.TargetPriority.NEAREST).is_equal(0)
    assert_that(UnitEnums.TargetPriority.BUILDING_FIRST).is_equal(3)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_enums.gd`
Expected: FAIL - UnitEnums not defined

**Step 3: 实现枚举定义**

```gdscript
# Scripts/unit/unit_enums.gd
class_name UnitEnums
extends RefCounted

## 单位模式（决定几何形状）
enum UnitMode {
    TANK,      ## 肉盾型 - 六边形
    WARRIOR,   ## 战士型 - 八边形
    ASSASSIN,  ## 刺客型 - 三角形
    MAGE,      ## 法师型 - 圆形
    SUPPORT,   ## 辅助型 - 菱形
    BUILDING   ## 建筑型 - 正方形
}

## 单位体型（决定碰撞半径）
enum UnitSize {
    SMALL,   ## 小型 - 0.2格
    MEDIUM,  ## 中型 - 0.5格
    LARGE,   ## 大型 - 0.8格
    HUGE     ## 巨大型 - 1.2格
}

## 元素词条
enum ElementTag {
    EARTH,    ## 地
    WIND,     ## 风
    WATER,    ## 水
    FIRE,     ## 火
    GRASS,    ## 草
    METAL,    ## 金
    ICE,      ## 冰
    NEUTRAL   ## 通用
}

## 移动类型
enum MoveType {
    GROUND,  ## 地面
    FLYING   ## 飞行
}

## 能力触发类型
enum AbilityTrigger {
    AUTO,              ## 自动攻击（持续）
    ON_COMBAT_START,   ## 首次交战
    PERIODIC,          ## 周期性（每N秒）
    ON_HEALTH_BELOW,   ## 生命低于X%
    ON_ATTACK_COUNT,   ## 攻击N次后
    ON_HIT_COUNT,      ## 受击N次后
    ON_ENEMY_COUNT,    ## 范围内敌人>X
    ON_DEATH,          ## 死亡时
    ON_ENERGY_FULL     ## 能量槽满
}

## 目标优先级
enum TargetPriority {
    NEAREST,        ## 最近目标
    LOWEST_HEALTH,  ## 最低血量
    HIGHEST_THREAT, ## 最高威胁
    BUILDING_FIRST  ## 建筑优先
}
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_enums.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/unit_enums.gd Scripts/test/unit/test_unit_enums.gd
git commit -m "feat(unit): add unit enums for mode, size, element, and triggers"
```

---

### Task 2: 单位配置（体型半径）

**Files:**
- Create: `Scripts/unit/unit_config.gd`
- Test: `Scripts/test/unit/test_unit_config.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit_config.gd
class_name TestUnitConfig
extends GdUnitTestSuite

## 测试单位配置


## 测试1：获取小型单位半径
func test_small_size_radius() -> void:
    var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.SMALL)
    assert_that(radius).is_equal_approx(0.2, 0.01)


## 测试2：获取中型单位半径
func test_medium_size_radius() -> void:
    var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.MEDIUM)
    assert_that(radius).is_equal_approx(0.5, 0.01)


## 测试3：获取大型单位半径
func test_large_size_radius() -> void:
    var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.LARGE)
    assert_that(radius).is_equal_approx(0.8, 0.01)


## 测试4：获取巨大型单位半径
func test_huge_size_radius() -> void:
    var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.HUGE)
    assert_that(radius).is_equal_approx(1.2, 0.01)


## 测试5：获取模式对应的形状边数
func test_tank_mode_sides() -> void:
    var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.TANK)
    assert_that(sides).is_equal(6)  # 六边形


## 测试6：建筑模式为4边（正方形）
func test_building_mode_sides() -> void:
    var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.BUILDING)
    assert_that(sides).is_equal(4)


## 测试7：法师模式边数为0（表示圆形）
func test_mage_mode_is_circle() -> void:
    var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.MAGE)
    assert_that(sides).is_equal(0)  # 0表示圆形


## 测试8：刺客模式为3边（三角形）
func test_assassin_mode_sides() -> void:
    var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.ASSASSIN)
    assert_that(sides).is_equal(3)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_config.gd`
Expected: FAIL - UnitConfig not defined

**Step 3: 实现配置类**

```gdscript
# Scripts/unit/unit_config.gd
class_name UnitConfig
extends RefCounted

## 单位配置
## 提供体型半径、形状边数等配置查询


## 体型对应的碰撞半径（格为单位）
const SIZE_RADIUS: Dictionary = {
    UnitEnums.UnitSize.SMALL: 0.2,
    UnitEnums.UnitSize.MEDIUM: 0.5,
    UnitEnums.UnitSize.LARGE: 0.8,
    UnitEnums.UnitSize.HUGE: 1.2
}

## 模式对应的形状边数（0表示圆形）
const MODE_SIDES: Dictionary = {
    UnitEnums.UnitMode.TANK: 6,      # 六边形
    UnitEnums.UnitMode.WARRIOR: 8,   # 八边形
    UnitEnums.UnitMode.ASSASSIN: 3,  # 三角形
    UnitEnums.UnitMode.MAGE: 0,      # 圆形
    UnitEnums.UnitMode.SUPPORT: 4,   # 菱形（旋转45度的正方形）
    UnitEnums.UnitMode.BUILDING: 4   # 正方形
}

## 阵营颜色
const TEAM_COLORS: Dictionary = {
    0: Color.DODGER_BLUE,   # 己方 - 蓝色
    1: Color.INDIAN_RED     # 敌方 - 红色
}


## 获取体型对应的碰撞半径
static func get_size_radius(size: UnitEnums.UnitSize) -> float:
    return SIZE_RADIUS.get(size, 0.5)


## 获取模式对应的形状边数
static func get_shape_sides(mode: UnitEnums.UnitMode) -> int:
    return MODE_SIDES.get(mode, 4)


## 获取阵营颜色
static func get_team_color(team: int) -> Color:
    return TEAM_COLORS.get(team, Color.WHITE)


## 判断模式是否为圆形
static func is_circle_shape(mode: UnitEnums.UnitMode) -> bool:
    return get_shape_sides(mode) == 0


## 判断模式是否需要旋转（菱形）
static func needs_rotation(mode: UnitEnums.UnitMode) -> bool:
    return mode == UnitEnums.UnitMode.SUPPORT
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_config.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/unit_config.gd Scripts/test/unit/test_unit_config.gd
git commit -m "feat(unit): add unit config for size radius and shape sides"
```

---

### Task 3: 能力数据基类

**Files:**
- Create: `Scripts/unit/ability/data/unit_ability.gd`
- Test: `Scripts/test/unit/ability/test_unit_ability.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_unit_ability.gd
class_name TestUnitAbility
extends GdUnitTestSuite

## 测试能力数据基类


## 测试1：UnitAbility 可实例化
func test_unit_ability_instantiation() -> void:
    var ability := UnitAbility.new()
    assert_that(ability).is_not_null()
    assert_that(ability).is_instanceof(Resource)


## 测试2：默认 id 为空
func test_default_id_empty() -> void:
    var ability := UnitAbility.new()
    assert_that(ability.id).is_equal(&"")


## 测试3：默认 trigger 为 AUTO
func test_default_trigger_auto() -> void:
    var ability := UnitAbility.new()
    assert_that(ability.trigger).is_equal(UnitEnums.AbilityTrigger.AUTO)


## 测试4：设置 id
func test_set_id() -> void:
    var ability := UnitAbility.new()
    ability.id = &"melee_attack"
    assert_that(ability.id).is_equal(&"melee_attack")


## 测试5：设置 trigger
func test_set_trigger() -> void:
    var ability := UnitAbility.new()
    ability.trigger = UnitEnums.AbilityTrigger.PERIODIC
    assert_that(ability.trigger).is_equal(UnitEnums.AbilityTrigger.PERIODIC)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_unit_ability.gd`
Expected: FAIL - UnitAbility not defined

**Step 3: 实现能力基类**

```gdscript
# Scripts/unit/ability/data/unit_ability.gd
@icon("res://Assets/Icons/UI/ability.svg")
class_name UnitAbility
extends Resource

## 能力数据基类
## 所有具体能力类型继承此类

## 能力唯一标识
@export var id: StringName = &""

## 触发类型
@export var trigger: UnitEnums.AbilityTrigger = UnitEnums.AbilityTrigger.AUTO
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_unit_ability.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/data/unit_ability.gd Scripts/test/unit/ability/test_unit_ability.gd
git commit -m "feat(unit): add UnitAbility base resource class"
```

---

### Task 4: 近战攻击能力数据

**Files:**
- Create: `Scripts/unit/ability/data/melee_attack_ability.gd`
- Test: `Scripts/test/unit/ability/test_melee_attack_ability.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_melee_attack_ability.gd
class_name TestMeleeAttackAbility
extends GdUnitTestSuite

## 测试近战攻击能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
    var ability := MeleeAttackAbility.new()
    assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认伤害为 10
func test_default_damage() -> void:
    var ability := MeleeAttackAbility.new()
    assert_that(ability.damage).is_equal(10)


## 测试3：默认攻击范围为 0.5
func test_default_attack_range() -> void:
    var ability := MeleeAttackAbility.new()
    assert_that(ability.attack_range).is_equal_approx(0.5, 0.01)


## 测试4：默认攻击间隔为 1.0
func test_default_attack_interval() -> void:
    var ability := MeleeAttackAbility.new()
    assert_that(ability.attack_interval).is_equal_approx(1.0, 0.01)


## 测试5：设置伤害值
func test_set_damage() -> void:
    var ability := MeleeAttackAbility.new()
    ability.damage = 25
    assert_that(ability.damage).is_equal(25)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_melee_attack_ability.gd`
Expected: FAIL - MeleeAttackAbility not defined

**Step 3: 实现近战攻击能力**

```gdscript
# Scripts/unit/ability/data/melee_attack_ability.gd
@icon("res://Assets/Icons/UI/sword.svg")
class_name MeleeAttackAbility
extends UnitAbility

## 近战攻击能力数据

## 伤害值
@export var damage: int = 10

## 攻击范围（格为单位）
@export var attack_range: float = 0.5

## 攻击间隔（秒）
@export var attack_interval: float = 1.0
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_melee_attack_ability.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/data/melee_attack_ability.gd Scripts/test/unit/ability/test_melee_attack_ability.gd
git commit -m "feat(unit): add MeleeAttackAbility data resource"
```

---

### Task 5: 远程攻击能力数据

**Files:**
- Create: `Scripts/unit/ability/data/ranged_attack_ability.gd`
- Test: `Scripts/test/unit/ability/test_ranged_attack_ability.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_ranged_attack_ability.gd
class_name TestRangedAttackAbility
extends GdUnitTestSuite

## 测试远程攻击能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
    var ability := RangedAttackAbility.new()
    assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认伤害为 10
func test_default_damage() -> void:
    var ability := RangedAttackAbility.new()
    assert_that(ability.damage).is_equal(10)


## 测试3：默认攻击范围为 3.0
func test_default_attack_range() -> void:
    var ability := RangedAttackAbility.new()
    assert_that(ability.attack_range).is_equal_approx(3.0, 0.01)


## 测试4：默认投射物速度为 5.0
func test_default_projectile_speed() -> void:
    var ability := RangedAttackAbility.new()
    assert_that(ability.projectile_speed).is_equal_approx(5.0, 0.01)


## 测试5：默认攻击间隔为 1.0
func test_default_attack_interval() -> void:
    var ability := RangedAttackAbility.new()
    assert_that(ability.attack_interval).is_equal_approx(1.0, 0.01)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_ranged_attack_ability.gd`
Expected: FAIL - RangedAttackAbility not defined

**Step 3: 实现远程攻击能力**

```gdscript
# Scripts/unit/ability/data/ranged_attack_ability.gd
@icon("res://Assets/Icons/UI/bow.svg")
class_name RangedAttackAbility
extends UnitAbility

## 远程攻击能力数据

## 伤害值
@export var damage: int = 10

## 攻击范围（格为单位）
@export var attack_range: float = 3.0

## 攻击间隔（秒）
@export var attack_interval: float = 1.0

## 投射物速度（格/秒）
@export var projectile_speed: float = 5.0
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_ranged_attack_ability.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/data/ranged_attack_ability.gd Scripts/test/unit/ability/test_ranged_attack_ability.gd
git commit -m "feat(unit): add RangedAttackAbility data resource"
```

---

### Task 6: 召唤能力数据

**Files:**
- Create: `Scripts/unit/ability/data/summon_ability.gd`
- Test: `Scripts/test/unit/ability/test_summon_ability.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_summon_ability.gd
class_name TestSummonAbility
extends GdUnitTestSuite

## 测试召唤能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
    var ability := SummonAbility.new()
    assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认召唤数量为 1
func test_default_summon_count() -> void:
    var ability := SummonAbility.new()
    assert_that(ability.summon_count).is_equal(1)


## 测试3：默认召唤偏移为零向量
func test_default_summon_offset() -> void:
    var ability := SummonAbility.new()
    assert_that(ability.summon_offset).is_equal(Vector2.ZERO)


## 测试4：默认无召唤单位数据
func test_default_no_summon_unit() -> void:
    var ability := SummonAbility.new()
    assert_that(ability.summon_unit).is_null()


## 测试5：设置召唤数量
func test_set_summon_count() -> void:
    var ability := SummonAbility.new()
    ability.summon_count = 3
    assert_that(ability.summon_count).is_equal(3)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_summon_ability.gd`
Expected: FAIL - SummonAbility not defined

**Step 3: 实现召唤能力**

```gdscript
# Scripts/unit/ability/data/summon_ability.gd
@icon("res://Assets/Icons/UI/summon.svg")
class_name SummonAbility
extends UnitAbility

## 召唤能力数据

## 要召唤的单位数据（前向声明，避免循环依赖）
@export var summon_unit: Resource = null

## 召唤数量
@export var summon_count: int = 1

## 召唤位置偏移
@export var summon_offset: Vector2 = Vector2.ZERO
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_summon_ability.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/data/summon_ability.gd Scripts/test/unit/ability/test_summon_ability.gd
git commit -m "feat(unit): add SummonAbility data resource"
```

---

### Task 7: 治疗能力数据

**Files:**
- Create: `Scripts/unit/ability/data/heal_ability.gd`
- Test: `Scripts/test/unit/ability/test_heal_ability.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_heal_ability.gd
class_name TestHealAbility
extends GdUnitTestSuite

## 测试治疗能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
    var ability := HealAbility.new()
    assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认治疗量为 20
func test_default_heal_amount() -> void:
    var ability := HealAbility.new()
    assert_that(ability.heal_amount).is_equal(20)


## 测试3：默认治疗范围为 2.0
func test_default_heal_range() -> void:
    var ability := HealAbility.new()
    assert_that(ability.heal_range).is_equal_approx(2.0, 0.01)


## 测试4：默认间隔为 3.0
func test_default_interval() -> void:
    var ability := HealAbility.new()
    assert_that(ability.interval).is_equal_approx(3.0, 0.01)


## 测试5：默认治疗友军
func test_default_target_allies() -> void:
    var ability := HealAbility.new()
    assert_that(ability.target_allies).is_true()


## 测试6：默认不治疗自身
func test_default_not_target_self() -> void:
    var ability := HealAbility.new()
    assert_that(ability.target_self).is_false()
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_heal_ability.gd`
Expected: FAIL - HealAbility not defined

**Step 3: 实现治疗能力**

```gdscript
# Scripts/unit/ability/data/heal_ability.gd
@icon("res://Assets/Icons/UI/heal.svg")
class_name HealAbility
extends UnitAbility

## 治疗能力数据

## 治疗量
@export var heal_amount: int = 20

## 治疗范围（格为单位）
@export var heal_range: float = 2.0

## 治疗间隔（秒，用于 PERIODIC 触发）
@export var interval: float = 3.0

## 是否治疗自身
@export var target_self: bool = false

## 是否治疗友军
@export var target_allies: bool = true
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_heal_ability.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/data/heal_ability.gd Scripts/test/unit/ability/test_heal_ability.gd
git commit -m "feat(unit): add HealAbility data resource"
```

---

### Task 8: UnitData 资源

**Files:**
- Create: `Scripts/unit/unit_data.gd`
- Test: `Scripts/test/unit/test_unit_data.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit_data.gd
class_name TestUnitData
extends GdUnitTestSuite

## 测试单位数据资源


## 测试1：UnitData 可实例化
func test_unit_data_instantiation() -> void:
    var data := UnitData.new()
    assert_that(data).is_not_null()
    assert_that(data).is_instanceof(Resource)


## 测试2：默认 id 为空
func test_default_id_empty() -> void:
    var data := UnitData.new()
    assert_that(data.id).is_equal(&"")


## 测试3：默认模式为 WARRIOR
func test_default_mode_warrior() -> void:
    var data := UnitData.new()
    assert_that(data.unit_mode).is_equal(UnitEnums.UnitMode.WARRIOR)


## 测试4：默认体型为 MEDIUM
func test_default_size_medium() -> void:
    var data := UnitData.new()
    assert_that(data.unit_size).is_equal(UnitEnums.UnitSize.MEDIUM)


## 测试5：默认最大生命为 100
func test_default_max_health() -> void:
    var data := UnitData.new()
    assert_that(data.max_health).is_equal(100)


## 测试6：默认移动速度为 2.0
func test_default_move_speed() -> void:
    var data := UnitData.new()
    assert_that(data.move_speed).is_equal_approx(2.0, 0.01)


## 测试7：默认移动类型为地面
func test_default_move_type_ground() -> void:
    var data := UnitData.new()
    assert_that(data.move_type).is_equal(UnitEnums.MoveType.GROUND)


## 测试8：默认能力列表为空
func test_default_abilities_empty() -> void:
    var data := UnitData.new()
    assert_that(data.abilities).is_empty()


## 测试9：默认召唤数量为 1
func test_default_spawn_count() -> void:
    var data := UnitData.new()
    assert_that(data.spawn_count).is_equal(1)


## 测试10：设置能力列表
func test_set_abilities() -> void:
    var data := UnitData.new()
    var ability := MeleeAttackAbility.new()
    data.abilities.append(ability)
    assert_that(data.abilities.size()).is_equal(1)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_data.gd`
Expected: FAIL - UnitData not defined

**Step 3: 实现 UnitData**

```gdscript
# Scripts/unit/unit_data.gd
@icon("res://Assets/Icons/UI/unit.svg")
class_name UnitData
extends Resource

## 单位数据资源
## 定义单位的所有静态属性

# ============ 基础信息 ============

## 单位唯一标识
@export var id: StringName = &""

## 显示名称
@export var display_name: String = ""

## 单位图标
@export var icon: Texture2D = null

## 单位填充颜色
@export var base_color: Color = Color.WHITE

# ============ 模式与体型 ============

## 单位模式（决定几何形状）
@export var unit_mode: UnitEnums.UnitMode = UnitEnums.UnitMode.WARRIOR

## 单位体型（决定碰撞半径）
@export var unit_size: UnitEnums.UnitSize = UnitEnums.UnitSize.MEDIUM

# ============ 基础属性 ============

## 最大生命值
@export var max_health: int = 100

## 移动速度（格/秒）
@export var move_speed: float = 2.0

## 元素词条
@export var element_tag: UnitEnums.ElementTag = UnitEnums.ElementTag.NEUTRAL

## 移动类型
@export var move_type: UnitEnums.MoveType = UnitEnums.MoveType.GROUND

## 目标优先级
@export var target_priority: UnitEnums.TargetPriority = UnitEnums.TargetPriority.NEAREST

# ============ 能力列表 ============

## 单位拥有的能力
@export var abilities: Array[UnitAbility] = []

# ============ 召唤信息 ============

## 法力消耗
@export var mana_cost: int = 3

## 需要的地形类型
@export var required_terrain: StringName = &""

## 召唤数量（1-3，小组单位）
@export_range(1, 3) var spawn_count: int = 1
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_data.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/unit_data.gd Scripts/test/unit/test_unit_data.gd
git commit -m "feat(unit): add UnitData resource with mode, size, and abilities"
```

---

## Phase 2: 视觉渲染系统

### Task 9: 几何形状渲染器

**Files:**
- Create: `Scripts/unit/visual/shape_renderer.gd`
- Test: `Scripts/test/unit/visual/test_shape_renderer.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/visual/test_shape_renderer.gd
class_name TestShapeRenderer
extends GdUnitTestSuite

## 测试几何形状渲染器


## 辅助方法：创建渲染器
func _create_renderer() -> ShapeRenderer:
    var renderer := ShapeRenderer.new()
    add_child(renderer)
    auto_free(renderer)
    return renderer


## 测试1：ShapeRenderer 可实例化
func test_shape_renderer_instantiation() -> void:
    var renderer := _create_renderer()
    assert_that(renderer).is_not_null()
    assert_that(renderer).is_instanceof(Node2D)


## 测试2：默认模式为 WARRIOR
func test_default_mode() -> void:
    var renderer := _create_renderer()
    assert_that(renderer.unit_mode).is_equal(UnitEnums.UnitMode.WARRIOR)


## 测试3：默认体型为 MEDIUM
func test_default_size() -> void:
    var renderer := _create_renderer()
    assert_that(renderer.unit_size).is_equal(UnitEnums.UnitSize.MEDIUM)


## 测试4：默认填充颜色为白色
func test_default_fill_color() -> void:
    var renderer := _create_renderer()
    assert_that(renderer.fill_color).is_equal(Color.WHITE)


## 测试5：默认边框颜色为蓝色（己方）
func test_default_border_color() -> void:
    var renderer := _create_renderer()
    assert_that(renderer.border_color).is_equal(Color.DODGER_BLUE)


## 测试6：默认血量百分比为 1.0
func test_default_health_percent() -> void:
    var renderer := _create_renderer()
    assert_that(renderer.health_percent).is_equal_approx(1.0, 0.01)


## 测试7：设置模式后重绘
func test_set_mode_triggers_redraw() -> void:
    var renderer := _create_renderer()
    renderer.unit_mode = UnitEnums.UnitMode.TANK
    assert_that(renderer.unit_mode).is_equal(UnitEnums.UnitMode.TANK)


## 测试8：设置血量百分比
func test_set_health_percent() -> void:
    var renderer := _create_renderer()
    renderer.health_percent = 0.5
    assert_that(renderer.health_percent).is_equal_approx(0.5, 0.01)


## 测试9：获取半径
func test_get_radius() -> void:
    var renderer := _create_renderer()
    renderer.unit_size = UnitEnums.UnitSize.LARGE
    var radius := renderer.get_radius()
    # 0.8格 * 80像素/格 = 64像素
    assert_that(radius).is_greater(0.0)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/visual/test_shape_renderer.gd`
Expected: FAIL - ShapeRenderer not defined

**Step 3: 实现形状渲染器**

```gdscript
# Scripts/unit/visual/shape_renderer.gd
class_name ShapeRenderer
extends Node2D

## 几何形状渲染器
## 根据单位模式和体型绘制对应的几何形状

# ============ 导出变量 ============

## 单位模式（决定形状）
@export var unit_mode: UnitEnums.UnitMode = UnitEnums.UnitMode.WARRIOR:
    set(value):
        unit_mode = value
        queue_redraw()

## 单位体型（决定大小）
@export var unit_size: UnitEnums.UnitSize = UnitEnums.UnitSize.MEDIUM:
    set(value):
        unit_size = value
        queue_redraw()

## 填充颜色
@export var fill_color: Color = Color.WHITE:
    set(value):
        fill_color = value
        queue_redraw()

## 边框颜色（阵营色）
@export var border_color: Color = Color.DODGER_BLUE:
    set(value):
        border_color = value
        queue_redraw()

## 血量百分比（0-1）
@export_range(0.0, 1.0) var health_percent: float = 1.0:
    set(value):
        health_percent = clampf(value, 0.0, 1.0)
        queue_redraw()

## 边框宽度
@export var border_width: float = 3.0

## 每格像素数
@export var pixels_per_tile: float = 80.0

# ============ 公共方法 ============

## 获取当前半径（像素）
func get_radius() -> float:
    return UnitConfig.get_size_radius(unit_size) * pixels_per_tile


## 获取形状点集
func get_shape_points() -> PackedVector2Array:
    var radius := get_radius()
    var sides := UnitConfig.get_shape_sides(unit_mode)

    if sides == 0:
        # 圆形用多边形近似
        return _create_circle_points(radius, 32)
    else:
        return _create_polygon_points(radius, sides)


# ============ 绘制方法 ============

func _draw() -> void:
    var points := get_shape_points()

    # 绘制填充
    draw_colored_polygon(points, fill_color)

    # 绘制边框（血量比例）
    _draw_health_border(points)


func _draw_health_border(points: PackedVector2Array) -> void:
    if points.is_empty():
        return

    var total_length := _calculate_perimeter(points)
    var health_length := total_length * health_percent

    var current_length := 0.0
    for i in range(points.size()):
        var start := points[i]
        var end := points[(i + 1) % points.size()]
        var segment_length := start.distance_to(end)

        if current_length + segment_length <= health_length:
            # 整段都在血量范围内
            draw_line(start, end, border_color, border_width)
        elif current_length < health_length:
            # 部分在范围内
            var remaining := health_length - current_length
            var ratio := remaining / segment_length
            var mid := start.lerp(end, ratio)
            draw_line(start, mid, border_color, border_width)

        current_length += segment_length


# ============ 辅助方法 ============

func _create_polygon_points(radius: float, sides: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    var angle_offset := -PI / 2  # 从顶部开始

    # 菱形需要旋转45度
    if UnitConfig.needs_rotation(unit_mode):
        angle_offset += PI / 4

    for i in range(sides):
        var angle := angle_offset + TAU * i / sides
        points.append(Vector2(cos(angle), sin(angle)) * radius)

    return points


func _create_circle_points(radius: float, segments: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments):
        var angle := TAU * i / segments
        points.append(Vector2(cos(angle), sin(angle)) * radius)
    return points


func _calculate_perimeter(points: PackedVector2Array) -> float:
    var total := 0.0
    for i in range(points.size()):
        var start := points[i]
        var end := points[(i + 1) % points.size()]
        total += start.distance_to(end)
    return total
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/visual/test_shape_renderer.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/visual/shape_renderer.gd Scripts/test/unit/visual/test_shape_renderer.gd
git commit -m "feat(unit): add ShapeRenderer for geometric unit visuals"
```

---

### Task 10: Unit 场景和主脚本

**Files:**
- Create: `Scripts/unit/unit.gd`
- Create: `Scenes/unit/unit.tscn`
- Test: `Scripts/test/unit/test_unit.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit.gd
class_name TestUnit
extends GdUnitTestSuite

## 测试 Unit 主类


## 辅助方法：创建单位
func _create_unit() -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    add_child(unit)
    auto_free(unit)
    return unit


## 辅助方法：创建测试用 UnitData
func _create_test_data() -> UnitData:
    var data := UnitData.new()
    data.id = &"test_unit"
    data.display_name = "Test Unit"
    data.max_health = 100
    data.move_speed = 2.0
    return data


## 测试1：Unit 可实例化
func test_unit_instantiation() -> void:
    var unit := _create_unit()
    assert_that(unit).is_not_null()
    assert_that(unit).is_instanceof(CharacterBody2D)


## 测试2：初始化设置数据
func test_initialize_sets_data() -> void:
    var unit := _create_unit()
    var data := _create_test_data()

    unit.initialize(data, 0)

    assert_that(unit.data).is_equal(data)


## 测试3：初始化设置阵营
func test_initialize_sets_team() -> void:
    var unit := _create_unit()
    var data := _create_test_data()

    unit.initialize(data, 1)

    assert_that(unit.team).is_equal(1)


## 测试4：初始化设置当前血量
func test_initialize_sets_current_health() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    data.max_health = 150

    unit.initialize(data, 0)

    assert_that(unit.current_health).is_equal(150)


## 测试5：受伤减少血量
func test_take_damage_reduces_health() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    data.max_health = 100
    unit.initialize(data, 0)

    unit.take_damage(30, null)

    assert_that(unit.current_health).is_equal(70)


## 测试6：血量不会低于0
func test_health_cannot_go_below_zero() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    data.max_health = 100
    unit.initialize(data, 0)

    unit.take_damage(150, null)

    assert_that(unit.current_health).is_equal(0)


## 测试7：血量归零时死亡
func test_dies_when_health_zero() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    data.max_health = 100
    unit.initialize(data, 0)

    unit.take_damage(100, null)

    assert_that(unit.is_dead).is_true()


## 测试8：存活检查
func test_is_alive() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    unit.initialize(data, 0)

    assert_that(unit.is_alive()).is_true()

    unit.take_damage(1000, null)

    assert_that(unit.is_alive()).is_false()


## 测试9：获取攻击范围（无攻击能力返回0）
func test_get_attack_range_no_ability() -> void:
    var unit := _create_unit()
    var data := _create_test_data()
    unit.initialize(data, 0)

    var range := unit.get_attack_range()

    assert_that(range).is_equal(0.0)


## 测试10：shape_renderer 子节点存在
func test_has_shape_renderer() -> void:
    var unit := _create_unit()

    var renderer := unit.get_node_or_null("ShapeRenderer")

    assert_that(renderer).is_not_null()
    assert_that(renderer).is_instanceof(ShapeRenderer)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit.gd`
Expected: FAIL - Scene or Unit not defined

**Step 3: 实现 Unit 脚本**

```gdscript
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
var data: UnitData

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

# ============ 公共方法 ============

## 初始化单位
func initialize(unit_data: UnitData, unit_team: int) -> void:
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
    # TODO: 从能力管理器获取
    return 0.0


## 向目标移动
func move_toward(target_pos: Vector2) -> void:
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

    var radius := UnitConfig.get_size_radius(data.unit_size) * 80.0
    var circle := CircleShape2D.new()
    circle.radius = radius
    collision_shape.shape = circle


func _update_health_visual() -> void:
    if shape_renderer:
        shape_renderer.health_percent = float(current_health) / float(max_health)


func _die() -> void:
    is_dead = true
    died.emit(last_attacker)
    # TODO: 播放死亡动画后删除
```

**Step 4: 创建 Unit 场景**

创建 `Scenes/unit/unit.tscn` 文件，结构如下：
```
Unit (CharacterBody2D) [script: unit.gd]
├── CollisionShape2D
├── ShapeRenderer (Node2D) [script: shape_renderer.gd]
│   └── IconSprite (Sprite2D)
└── (后续添加 AbilityManager、BehaviorManager)
```

**Step 5: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit.gd`
Expected: PASS

**Step 6: 提交**

```bash
git add Scripts/unit/unit.gd Scenes/unit/unit.tscn Scripts/test/unit/test_unit.gd
git commit -m "feat(unit): add Unit scene with ShapeRenderer and basic combat"
```

---

## Phase 3: 能力实例系统

### Task 11: AbilityInstance 基类

**Files:**
- Create: `Scripts/unit/ability/instance/ability_instance.gd`
- Test: `Scripts/test/unit/ability/instance/test_ability_instance.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/instance/test_ability_instance.gd
class_name TestAbilityInstance
extends GdUnitTestSuite

## 测试能力实例基类


## 辅助方法
func _create_instance() -> AbilityInstance:
    var instance := AbilityInstance.new()
    add_child(instance)
    auto_free(instance)
    return instance


func _create_mock_unit() -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    add_child(unit)
    auto_free(unit)
    return unit


## 测试1：AbilityInstance 是 Node
func test_is_node() -> void:
    var instance := _create_instance()
    assert_that(instance).is_instanceof(Node)


## 测试2：初始化设置数据和所有者
func test_initialize() -> void:
    var instance := _create_instance()
    var data := MeleeAttackAbility.new()
    var unit := _create_mock_unit()

    instance.initialize(data, unit)

    assert_that(instance.data).is_equal(data)
    assert_that(instance.owner_unit).is_equal(unit)


## 测试3：默认 is_ready 为 true
func test_default_is_ready() -> void:
    var instance := _create_instance()
    assert_that(instance.is_ready).is_true()


## 测试4：默认 cooldown_timer 为 0
func test_default_cooldown_timer() -> void:
    var instance := _create_instance()
    assert_that(instance.cooldown_timer).is_equal(0.0)


## 测试5：can_execute 返回 is_ready
func test_can_execute() -> void:
    var instance := _create_instance()
    assert_that(instance.can_execute()).is_true()

    instance.is_ready = false
    assert_that(instance.can_execute()).is_false()
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/instance/test_ability_instance.gd`
Expected: FAIL - AbilityInstance not defined

**Step 3: 实现 AbilityInstance 基类**

```gdscript
# Scripts/unit/ability/instance/ability_instance.gd
class_name AbilityInstance
extends Node

## 能力实例基类
## 管理能力的运行时状态

# ============ 属性 ============

## 能力数据
var data: UnitAbility

## 所属单位
var owner_unit: Unit

## 冷却计时器
var cooldown_timer: float = 0.0

## 是否就绪
var is_ready: bool = true

# ============ 公共方法 ============

## 初始化
func initialize(ability_data: UnitAbility, unit: Unit) -> void:
    data = ability_data
    owner_unit = unit
    name = str(ability_data.id) if ability_data.id else "ability"


## 是否可执行
func can_execute() -> bool:
    return is_ready


## 执行能力（子类重写）
func execute(target: Unit = null) -> void:
    pass


## 获取攻击范围（子类重写）
func get_attack_range() -> float:
    return 0.0


# ============ 生命周期 ============

func _process(delta: float) -> void:
    _update_cooldown(delta)
    _check_trigger()


func _update_cooldown(delta: float) -> void:
    if cooldown_timer > 0:
        cooldown_timer -= delta
        if cooldown_timer <= 0:
            cooldown_timer = 0.0
            is_ready = true


func _check_trigger() -> void:
    # 子类重写实现自动触发逻辑
    pass


# ============ 受保护方法 ============

func _start_cooldown(duration: float) -> void:
    cooldown_timer = duration
    is_ready = false
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/instance/test_ability_instance.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/instance/ability_instance.gd Scripts/test/unit/ability/instance/test_ability_instance.gd
git commit -m "feat(unit): add AbilityInstance base class for runtime state"
```

---

### Task 12: MeleeAttackInstance

**Files:**
- Create: `Scripts/unit/ability/instance/melee_attack_instance.gd`
- Test: `Scripts/test/unit/ability/instance/test_melee_attack_instance.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/instance/test_melee_attack_instance.gd
class_name TestMeleeAttackInstance
extends GdUnitTestSuite

## 测试近战攻击能力实例


## 辅助方法
func _create_instance() -> MeleeAttackInstance:
    var instance := MeleeAttackInstance.new()
    add_child(instance)
    auto_free(instance)
    return instance


func _create_unit_with_data() -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    var data := UnitData.new()
    data.max_health = 100
    add_child(unit)
    unit.initialize(data, 0)
    auto_free(unit)
    return unit


## 测试1：继承自 AbilityInstance
func test_extends_ability_instance() -> void:
    var instance := _create_instance()
    assert_that(instance).is_instanceof(AbilityInstance)


## 测试2：获取攻击范围
func test_get_attack_range() -> void:
    var instance := _create_instance()
    var data := MeleeAttackAbility.new()
    data.attack_range = 0.8
    instance.initialize(data, null)

    assert_that(instance.get_attack_range()).is_equal_approx(0.8, 0.01)


## 测试3：执行后进入冷却
func test_execute_starts_cooldown() -> void:
    var instance := _create_instance()
    var data := MeleeAttackAbility.new()
    data.attack_interval = 1.5
    var attacker := _create_unit_with_data()
    var target := _create_unit_with_data()
    instance.initialize(data, attacker)

    instance.execute(target)

    assert_that(instance.is_ready).is_false()
    assert_that(instance.cooldown_timer).is_equal_approx(1.5, 0.01)


## 测试4：对目标造成伤害
func test_execute_deals_damage() -> void:
    var instance := _create_instance()
    var data := MeleeAttackAbility.new()
    data.damage = 25
    var attacker := _create_unit_with_data()
    var target := _create_unit_with_data()
    instance.initialize(data, attacker)

    instance.execute(target)

    assert_that(target.current_health).is_equal(75)


## 测试5：无目标不执行
func test_no_execute_without_target() -> void:
    var instance := _create_instance()
    var data := MeleeAttackAbility.new()
    var attacker := _create_unit_with_data()
    instance.initialize(data, attacker)

    instance.execute(null)

    assert_that(instance.is_ready).is_true()  # 未进入冷却
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/instance/test_melee_attack_instance.gd`
Expected: FAIL - MeleeAttackInstance not defined

**Step 3: 实现 MeleeAttackInstance**

```gdscript
# Scripts/unit/ability/instance/melee_attack_instance.gd
class_name MeleeAttackInstance
extends AbilityInstance

## 近战攻击能力实例


## 获取攻击范围
func get_attack_range() -> float:
    var ability := data as MeleeAttackAbility
    if ability:
        return ability.attack_range
    return 0.0


## 执行攻击
func execute(target: Unit = null) -> void:
    if not target or not can_execute():
        return

    var ability := data as MeleeAttackAbility
    if not ability:
        return

    # 播放攻击动画
    if owner_unit:
        owner_unit.play_attack(target.global_position)

    # 造成伤害
    target.take_damage(ability.damage, owner_unit)

    # 进入冷却
    _start_cooldown(ability.attack_interval)
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/instance/test_melee_attack_instance.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/instance/melee_attack_instance.gd Scripts/test/unit/ability/instance/test_melee_attack_instance.gd
git commit -m "feat(unit): add MeleeAttackInstance for melee combat"
```

---

### Task 13: AbilityManager 节点

**Files:**
- Create: `Scripts/unit/ability/ability_manager.gd`
- Test: `Scripts/test/unit/ability/test_ability_manager.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/ability/test_ability_manager.gd
class_name TestAbilityManager
extends GdUnitTestSuite

## 测试能力管理器


## 辅助方法
func _create_manager() -> AbilityManager:
    var manager := AbilityManager.new()
    add_child(manager)
    auto_free(manager)
    return manager


func _create_mock_unit() -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    var data := UnitData.new()
    data.max_health = 100
    add_child(unit)
    unit.initialize(data, 0)
    auto_free(unit)
    return unit


## 测试1：AbilityManager 是 Node
func test_is_node() -> void:
    var manager := _create_manager()
    assert_that(manager).is_instanceof(Node)


## 测试2：初始化后 owner_unit 被设置
func test_initialize_sets_owner() -> void:
    var manager := _create_manager()
    var unit := _create_mock_unit()

    manager.initialize(unit, [])

    assert_that(manager.owner_unit).is_equal(unit)


## 测试3：初始化创建能力实例子节点
func test_initialize_creates_ability_instances() -> void:
    var manager := _create_manager()
    var unit := _create_mock_unit()
    var ability := MeleeAttackAbility.new()
    ability.id = &"melee"

    manager.initialize(unit, [ability])

    assert_that(manager.get_child_count()).is_equal(1)


## 测试4：auto_attack 被缓存
func test_auto_attack_cached() -> void:
    var manager := _create_manager()
    var unit := _create_mock_unit()
    var ability := MeleeAttackAbility.new()
    ability.trigger = UnitEnums.AbilityTrigger.AUTO

    manager.initialize(unit, [ability])

    assert_that(manager.auto_attack).is_not_null()


## 测试5：try_attack 调用 auto_attack
func test_try_attack() -> void:
    var manager := _create_manager()
    var attacker := _create_mock_unit()
    var target := _create_mock_unit()
    var ability := MeleeAttackAbility.new()
    ability.damage = 20
    ability.trigger = UnitEnums.AbilityTrigger.AUTO

    manager.initialize(attacker, [ability])
    manager.try_attack(target)

    assert_that(target.current_health).is_equal(80)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_ability_manager.gd`
Expected: FAIL - AbilityManager not defined

**Step 3: 实现 AbilityManager**

```gdscript
# Scripts/unit/ability/ability_manager.gd
class_name AbilityManager
extends Node

## 能力管理器
## 管理单位的所有能力实例

# ============ 属性 ============

## 所属单位
var owner_unit: Unit

## 自动攻击能力（缓存）
var auto_attack: AbilityInstance

# ============ 公共方法 ============

## 初始化能力管理器
func initialize(unit: Unit, abilities: Array[UnitAbility]) -> void:
    owner_unit = unit

    for ability_data in abilities:
        var instance := _create_instance(ability_data)
        if instance:
            add_child(instance)
            _cache_auto_attack(instance, ability_data)


## 尝试执行自动攻击
func try_attack(target: Unit) -> void:
    if auto_attack and auto_attack.can_execute():
        auto_attack.execute(target)


## 获取最大攻击范围
func get_max_attack_range() -> float:
    var max_range := 0.0
    for child in get_children():
        if child is AbilityInstance:
            max_range = maxf(max_range, child.get_attack_range())
    return max_range


## 获取指定类型的能力实例
func get_ability_by_type(type: Variant) -> AbilityInstance:
    for child in get_children():
        if child is AbilityInstance and child.data is type:
            return child
    return null


## 获取指定触发类型的所有能力
func get_abilities_by_trigger(trigger: UnitEnums.AbilityTrigger) -> Array[AbilityInstance]:
    var result: Array[AbilityInstance] = []
    for child in get_children():
        if child is AbilityInstance and child.data.trigger == trigger:
            result.append(child)
    return result


# ============ 私有方法 ============

func _create_instance(ability_data: UnitAbility) -> AbilityInstance:
    var instance: AbilityInstance = null

    if ability_data is MeleeAttackAbility:
        instance = MeleeAttackInstance.new()
    elif ability_data is RangedAttackAbility:
        instance = RangedAttackInstance.new()
    elif ability_data is SummonAbility:
        instance = SummonInstance.new()
    elif ability_data is HealAbility:
        instance = HealInstance.new()
    else:
        instance = AbilityInstance.new()

    if instance:
        instance.initialize(ability_data, owner_unit)

    return instance


func _cache_auto_attack(instance: AbilityInstance, ability_data: UnitAbility) -> void:
    if ability_data.trigger != UnitEnums.AbilityTrigger.AUTO:
        return

    if ability_data is MeleeAttackAbility or ability_data is RangedAttackAbility:
        if not auto_attack:
            auto_attack = instance
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/ability/test_ability_manager.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/ability/ability_manager.gd Scripts/test/unit/ability/test_ability_manager.gd
git commit -m "feat(unit): add AbilityManager to manage ability instances"
```

---

## Phase 4: 行为系统

### Task 14: BehaviorManager 行为管理器

**Files:**
- Create: `Scripts/unit/behavior/behavior_manager.gd`
- Test: `Scripts/test/unit/behavior/test_behavior_manager.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/behavior/test_behavior_manager.gd
class_name TestBehaviorManager
extends GdUnitTestSuite

## 测试行为管理器


## 辅助方法
func _create_manager() -> BehaviorManager:
    var manager := BehaviorManager.new()
    add_child(manager)
    auto_free(manager)
    return manager


func _create_mock_unit() -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    var data := UnitData.new()
    data.max_health = 100
    add_child(unit)
    unit.initialize(data, 0)
    auto_free(unit)
    return unit


## 测试1：BehaviorManager 是 Node
func test_is_node() -> void:
    var manager := _create_manager()
    assert_that(manager).is_instanceof(Node)


## 测试2：初始化设置 owner_unit
func test_initialize_sets_owner() -> void:
    var manager := _create_manager()
    var unit := _create_mock_unit()

    manager.initialize(unit)

    assert_that(manager.owner_unit).is_equal(unit)


## 测试3：默认搜索间隔为 0.5 秒
func test_default_search_interval() -> void:
    var manager := _create_manager()
    assert_that(manager.search_interval).is_equal_approx(0.5, 0.01)


## 测试4：默认无目标
func test_default_no_target() -> void:
    var manager := _create_manager()
    assert_that(manager.current_target).is_null()
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/behavior/test_behavior_manager.gd`
Expected: FAIL - BehaviorManager not defined

**Step 3: 实现 BehaviorManager**

```gdscript
# Scripts/unit/behavior/behavior_manager.gd
class_name BehaviorManager
extends Node

## 行为管理器
## 管理单位的自动战斗行为（移动、索敌、攻击）

# ============ 导出变量 ============

## 索敌间隔（秒）
@export var search_interval: float = 0.5

# ============ 属性 ============

## 所属单位
var owner_unit: Unit

## 当前目标
var current_target: Unit = null

## 搜索计时器
var _search_timer: float = 0.0

# ============ 公共方法 ============

## 初始化
func initialize(unit: Unit) -> void:
    owner_unit = unit


# ============ 生命周期 ============

func _process(delta: float) -> void:
    if not owner_unit or owner_unit.is_dead:
        return

    _update_target(delta)
    _update_movement()
    _update_abilities()


# ============ 私有方法 ============

func _update_target(delta: float) -> void:
    _search_timer -= delta
    if _search_timer <= 0:
        _search_timer = search_interval
        _find_target()


func _find_target() -> void:
    # TODO: 使用 TargetFinder 查找目标
    pass


func _update_movement() -> void:
    if not owner_unit:
        return

    if current_target and is_instance_valid(current_target) and current_target.is_alive():
        var distance := owner_unit.global_position.distance_to(current_target.global_position)
        var attack_range := _get_attack_range()

        if distance > attack_range:
            owner_unit.move_toward(current_target.global_position)
        else:
            owner_unit.stop_moving()
    else:
        owner_unit.move_toward_enemy_base()


func _update_abilities() -> void:
    if not owner_unit:
        return

    var ability_manager := owner_unit.get_node_or_null("AbilityManager") as AbilityManager
    if not ability_manager:
        return

    # 尝试自动攻击
    if current_target and is_instance_valid(current_target) and current_target.is_alive():
        var distance := owner_unit.global_position.distance_to(current_target.global_position)
        var attack_range := _get_attack_range()

        if distance <= attack_range:
            ability_manager.try_attack(current_target)


func _get_attack_range() -> float:
    var ability_manager := owner_unit.get_node_or_null("AbilityManager") as AbilityManager
    if ability_manager:
        return ability_manager.get_max_attack_range() * 80.0  # 转换为像素
    return 0.0
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/behavior/test_behavior_manager.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/behavior/behavior_manager.gd Scripts/test/unit/behavior/test_behavior_manager.gd
git commit -m "feat(unit): add BehaviorManager for auto-combat behavior"
```

---

### Task 15: UnitFactory 工厂

**Files:**
- Create: `Scripts/unit/unit_factory.gd`
- Test: `Scripts/test/unit/test_unit_factory.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit_factory.gd
class_name TestUnitFactory
extends GdUnitTestSuite

## 测试单位工厂


## 辅助方法
func _create_test_data() -> UnitData:
    var data := UnitData.new()
    data.id = &"test_unit"
    data.max_health = 100
    data.spawn_count = 1
    return data


## 测试1：create 返回 Unit 实例
func test_create_returns_unit() -> void:
    var data := _create_test_data()

    var unit := UnitFactory.create(data, Vector2(100, 100), 0)

    if unit:
        add_child(unit)
        auto_free(unit)

    assert_that(unit).is_not_null()
    assert_that(unit).is_instanceof(Unit)


## 测试2：create 设置位置
func test_create_sets_position() -> void:
    var data := _create_test_data()
    var pos := Vector2(200, 150)

    var unit := UnitFactory.create(data, pos, 0)

    if unit:
        add_child(unit)
        auto_free(unit)

    assert_that(unit.global_position).is_equal(pos)


## 测试3：create 设置阵营
func test_create_sets_team() -> void:
    var data := _create_test_data()

    var unit := UnitFactory.create(data, Vector2.ZERO, 1)

    if unit:
        add_child(unit)
        auto_free(unit)

    assert_that(unit.team).is_equal(1)


## 测试4：null 数据返回 null
func test_create_null_data_returns_null() -> void:
    var unit := UnitFactory.create(null, Vector2.ZERO, 0)
    assert_that(unit).is_null()


## 测试5：create_group 返回正确数量
func test_create_group_returns_correct_count() -> void:
    var data := _create_test_data()
    data.spawn_count = 3

    var units := UnitFactory.create_group(data, Vector2(100, 100), 0)

    for unit in units:
        add_child(unit)
        auto_free(unit)

    assert_that(units.size()).is_equal(3)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_factory.gd`
Expected: FAIL - UnitFactory not defined

**Step 3: 实现 UnitFactory**

```gdscript
# Scripts/unit/unit_factory.gd
class_name UnitFactory
extends RefCounted

## 单位工厂
## 负责创建和初始化单位

const UNIT_SCENE: PackedScene = preload("res://Scenes/unit/unit.tscn")
const TILE_SIZE: float = 80.0


## 创建单个单位
static func create(data: UnitData, pos: Vector2, team: int) -> Unit:
    if not data:
        push_error("UnitFactory.create: UnitData is null")
        return null

    var unit: Unit = UNIT_SCENE.instantiate()
    unit.initialize(data, team)
    unit.global_position = pos
    return unit


## 创建单位组（小队）
static func create_group(data: UnitData, pos: Vector2, team: int) -> Array[Unit]:
    var units: Array[Unit] = []

    if not data:
        push_error("UnitFactory.create_group: UnitData is null")
        return units

    var spawn_count := data.spawn_count

    for i in spawn_count:
        var offset := _get_group_offset(i, spawn_count)
        var unit := create(data, pos + offset, team)
        if unit:
            units.append(unit)

    return units


## 获取小队成员的位置偏移
static func _get_group_offset(index: int, total: int) -> Vector2:
    if total == 1:
        return Vector2.ZERO

    # 小组成员围绕中心点分布
    var angle := TAU * index / total
    var radius := 0.3 * TILE_SIZE
    return Vector2(cos(angle), sin(angle)) * radius
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_factory.gd`
Expected: PASS

**Step 5: 提交**

```bash
git add Scripts/unit/unit_factory.gd Scripts/test/unit/test_unit_factory.gd
git commit -m "feat(unit): add UnitFactory for creating units and groups"
```

---

## Phase 5: 集成与完善

### Task 16: 更新 Unit 场景（添加管理器节点）

**Files:**
- Modify: `Scenes/unit/unit.tscn`
- Modify: `Scripts/unit/unit.gd`

**Step 1: 更新 unit.gd 添加管理器引用**

在 `Scripts/unit/unit.gd` 中添加：

```gdscript
# 添加子节点引用
@onready var ability_manager: AbilityManager = $AbilityManager
@onready var behavior_manager: BehaviorManager = $BehaviorManager

# 修改 initialize 方法
func initialize(unit_data: UnitData, unit_team: int) -> void:
    data = unit_data
    team = unit_team

    max_health = data.max_health
    current_health = max_health
    is_dead = false

    _setup_visuals()
    _setup_collision()

    # 初始化能力管理器
    if ability_manager:
        ability_manager.initialize(self, data.abilities)

    # 初始化行为管理器
    if behavior_manager:
        behavior_manager.initialize(self)


# 修改 get_attack_range 方法
func get_attack_range() -> float:
    if ability_manager:
        return ability_manager.get_max_attack_range()
    return 0.0
```

**Step 2: 更新场景结构**

修改 `Scenes/unit/unit.tscn`，添加节点：
```
Unit (CharacterBody2D)
├── CollisionShape2D
├── ShapeRenderer (Node2D)
│   └── IconSprite (Sprite2D)
├── AbilityManager (Node) [script: ability_manager.gd]
└── BehaviorManager (Node) [script: behavior_manager.gd]
```

**Step 3: 运行所有测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/`
Expected: All PASS

**Step 4: 提交**

```bash
git add Scenes/unit/unit.tscn Scripts/unit/unit.gd
git commit -m "feat(unit): integrate AbilityManager and BehaviorManager into Unit scene"
```

---

### Task 17: UnitManager 单例

**Files:**
- Create: `Scripts/unit/unit_manager.gd`
- Test: `Scripts/test/unit/test_unit_manager.gd`

**Step 1: 创建测试文件**

```gdscript
# Scripts/test/unit/test_unit_manager.gd
class_name TestUnitManager
extends GdUnitTestSuite

## 测试单位管理器


## 辅助方法
func _create_mock_unit(team: int) -> Unit:
    var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
    var data := UnitData.new()
    data.max_health = 100
    add_child(unit)
    unit.initialize(data, team)
    auto_free(unit)
    return unit


## 测试前重置
func before_test() -> void:
    UnitManager._units.clear()


## 测试1：register 添加单位
func test_register_adds_unit() -> void:
    var unit := _create_mock_unit(0)

    UnitManager.register(unit)

    assert_that(UnitManager._units.size()).is_equal(1)


## 测试2：unregister 移除单位
func test_unregister_removes_unit() -> void:
    var unit := _create_mock_unit(0)
    UnitManager.register(unit)

    UnitManager.unregister(unit)

    assert_that(UnitManager._units.size()).is_equal(0)


## 测试3：get_enemies 返回敌方单位
func test_get_enemies() -> void:
    var ally := _create_mock_unit(0)
    var enemy := _create_mock_unit(1)
    UnitManager.register(ally)
    UnitManager.register(enemy)

    var enemies := UnitManager.get_enemies(0)

    assert_that(enemies.size()).is_equal(1)
    assert_that(enemies[0]).is_equal(enemy)


## 测试4：get_allies 返回友方单位
func test_get_allies() -> void:
    var ally1 := _create_mock_unit(0)
    var ally2 := _create_mock_unit(0)
    var enemy := _create_mock_unit(1)
    UnitManager.register(ally1)
    UnitManager.register(ally2)
    UnitManager.register(enemy)

    var allies := UnitManager.get_allies(0)

    assert_that(allies.size()).is_equal(2)
```

**Step 2: 运行测试验证失败**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_manager.gd`
Expected: FAIL - UnitManager not defined

**Step 3: 实现 UnitManager**

```gdscript
# Scripts/unit/unit_manager.gd
extends Node

## 单位管理器（AutoLoad 单例）
## 跟踪战场上的所有单位

# ============ 属性 ============

var _units: Array[Unit] = []

# ============ 公共方法 ============

## 注册单位
func register(unit: Unit) -> void:
    if unit and not _units.has(unit):
        _units.append(unit)


## 注销单位
func unregister(unit: Unit) -> void:
    _units.erase(unit)


## 获取敌方单位
func get_enemies(team: int) -> Array[Unit]:
    return _units.filter(func(u): return u.team != team and u.is_alive())


## 获取友方单位
func get_allies(team: int) -> Array[Unit]:
    return _units.filter(func(u): return u.team == team and u.is_alive())


## 获取范围内的单位
func get_units_in_range(pos: Vector2, radius: float) -> Array[Unit]:
    return _units.filter(func(u):
        return u.is_alive() and pos.distance_to(u.global_position) <= radius
    )


## 清空所有单位
func clear() -> void:
    _units.clear()
```

**Step 4: 运行测试验证通过**

Run: `godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://Scripts/test/unit/test_unit_manager.gd`
Expected: PASS

**Step 5: 配置 AutoLoad**

在 `project.godot` 中添加：
```ini
[autoload]
UnitManager="*res://Scripts/unit/unit_manager.gd"
```

**Step 6: 提交**

```bash
git add Scripts/unit/unit_manager.gd Scripts/test/unit/test_unit_manager.gd project.godot
git commit -m "feat(unit): add UnitManager singleton for tracking all units"
```

---

### Task 18: 创建示例单位数据

**Files:**
- Create: `Resources/Units/grass/cavalry.tres`

**Step 1: 创建草原骑兵数据**

在编辑器中创建 `Resources/Units/grass/cavalry.tres`：

```gdscript
# 使用编辑器创建 UnitData 资源
[gd_resource type="Resource" script_class="UnitData"]

[resource]
script = ExtResource("res://Scripts/unit/unit_data.gd")
id = &"cavalry"
display_name = "草原骑兵"
unit_mode = 1  # WARRIOR
unit_size = 2  # LARGE
max_health = 150
move_speed = 3.0
element_tag = 4  # GRASS
move_type = 0  # GROUND
target_priority = 0  # NEAREST
mana_cost = 4
required_terrain = &"grassland"
spawn_count = 1
```

**Step 2: 提交**

```bash
git add Resources/Units/grass/cavalry.tres
git commit -m "feat(unit): add cavalry unit data example"
```

---

## 总结

### 文件清单

| 目录 | 文件 | 描述 |
|------|------|------|
| `Scripts/unit/` | `unit_enums.gd` | 枚举定义 |
| | `unit_config.gd` | 配置常量 |
| | `unit_data.gd` | 单位数据资源 |
| | `unit.gd` | 单位主类 |
| | `unit_factory.gd` | 单位工厂 |
| | `unit_manager.gd` | 单位管理器(AutoLoad) |
| `Scripts/unit/visual/` | `shape_renderer.gd` | 几何形状渲染 |
| `Scripts/unit/ability/data/` | `unit_ability.gd` | 能力基类 |
| | `melee_attack_ability.gd` | 近战能力数据 |
| | `ranged_attack_ability.gd` | 远程能力数据 |
| | `summon_ability.gd` | 召唤能力数据 |
| | `heal_ability.gd` | 治疗能力数据 |
| `Scripts/unit/ability/instance/` | `ability_instance.gd` | 能力实例基类 |
| | `melee_attack_instance.gd` | 近战能力实例 |
| `Scripts/unit/ability/` | `ability_manager.gd` | 能力管理器 |
| `Scripts/unit/behavior/` | `behavior_manager.gd` | 行为管理器 |
| `Scenes/unit/` | `unit.tscn` | 单位模板场景 |

### 后续 TODO

- [ ] RangedAttackInstance（远程攻击实例）
- [ ] SummonInstance（召唤实例）
- [ ] HealInstance（治疗实例）
- [ ] TargetFinder（索敌工具）
- [ ] 地形交互系统
- [ ] Buff 系统
- [ ] 投射物系统
