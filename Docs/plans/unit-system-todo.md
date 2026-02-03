# 单位系统 - 后续开发任务

> **创建日期**: 2026-02-03
> **关联计划**: [2026-02-03-unit-system.md](./2026-02-03-unit-system.md)

---

## 已完成功能

- [x] 基础数据结构 (UnitEnums, UnitConfig, UnitData)
- [x] 能力数据类 (UnitAbility, MeleeAttackAbility, RangedAttackAbility, SummonAbility, HealAbility)
- [x] 视觉渲染 (ShapeRenderer - 几何形状 + 血条边框)
- [x] Unit 场景和主脚本
- [x] AbilityInstance 基类
- [x] MeleeAttackInstance 近战攻击实例
- [x] AbilityManager 能力管理器
- [x] BehaviorManager 行为管理器
- [x] UnitFactory 单位工厂
- [x] UnitManager 单例 (AutoLoad)
- [x] 示例单位数据 (cavalry.tres)

---

## 待开发功能

### 高优先级

- [ ] **RangedAttackInstance** - 远程攻击能力实例
  - 投射物生成
  - 弹道计算
  - 命中检测

- [ ] **SummonInstance** - 召唤能力实例
  - 召唤单位生成
  - 召唤位置计算
  - 召唤数量控制

- [ ] **HealInstance** - 治疗能力实例
  - 范围治疗
  - 目标选择（自身/友军）
  - 治疗效果显示

- [ ] **TargetFinder** - 索敌工具
  - 全局单位扫描
  - 按优先级过滤 (NEAREST, LOWEST_HEALTH, HIGHEST_THREAT, BUILDING_FIRST)
  - 攻击范围判定

### 中优先级

- [ ] **投射物系统**
  - Projectile 基类
  - 弹道类型（直线、抛物线、追踪）
  - 命中效果

- [ ] **Buff 系统**
  - Buff 数据类
  - BuffInstance 运行时
  - 潜行 Buff（隐身效果）
  - 增益/减益效果

- [ ] **地形交互系统**
  - 单位词条与地块交互
  - 7档属性加成/减益
  - 地形特殊效果（灼烧/溺水/冻结等）

### 低优先级

- [ ] **更多能力实例**
  - AOE 攻击
  - 控制技能（眩晕/击退）
  - 护盾技能

- [ ] **死亡效果**
  - 死亡动画
  - 分裂单位
  - 自爆效果

- [ ] **单位 UI**
  - 血量数字显示
  - Buff 图标显示
  - 目标指示器

---

## 单位数据待创建

### 9种地形 x 3种单位 = 27种基础单位

| 地形 | 单位1 | 单位2 | 单位3 |
|------|-------|-------|-------|
| 水域 | 潮汐卫士 | 激流射手 | 海妖 |
| 沙漠 | 沙虫 | 沙行者 | 绿洲灵 |
| 岩石 | 山岳巨人 | 投石车 | 石墙塔 |
| 草地 | 草原骑兵 ✅ | 游侠 | 牧师 |
| 森林 | 远古树人 | 精灵刺客 | 德鲁伊 |
| 农田 | 麦田傀儡 | 农夫战士 | 丰收之灵 |
| 熔岩 | 熔岩巨像 | 火元素 | 烈焰术士 |
| 沼泽 | 毒藤巨怪 | 沼泽潜伏者 | 瘟疫使者 |
| 冰原 | 冰霜巨人 | 雪原刺客 | 冰棱法师 |

---

## 技术债务

- [ ] GdUnit4 与 Godot 4.6 兼容性问题（`get_as_text()` API 变更）
- [ ] 循环依赖问题（unit.gd 中使用 Node 类型代替具体类）
- [ ] 补充缺失的能力实例类型判断 (AbilityManager._create_instance)

---

## 参考文档

- [05_单位系统_完整.md](../game_design/05_单位系统_完整.md) - 单位设计文档
- [06_地形系统_完整.md](../game_design/06_地形系统_完整.md) - 地形交互规则
- [02_核心机制.md](../game_design/02_核心机制.md) - 核心玩法机制
