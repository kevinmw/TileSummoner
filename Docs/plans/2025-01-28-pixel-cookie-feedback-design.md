# PixelCookieFeedback - Godot 游戏反馈系统插件完整设计文档

> 创建日期：2025-01-28
> 状态：设计完成，待实现
> 预计开发周期：6-9 周

---

## 一、项目概述

### 1.1 什么是 PixelCookieFeedback？

**PixelCookieFeedback** 是一个 Godot 4.x 的游戏反馈（Game Feel/Juice）插件，灵感来自 Unity 的 Feel 插件。它通过可视化的**积木编辑器**让开发者配置反馈序列，保存为 `.pcf` 文件，运行时加载执行。

### 1.2 设计目标

- **通用插件**：可复用于多个项目，不依赖特定游戏逻辑
- **2D 优先**：先完善 2D 支持，后续扩展 3D
- **可视化编辑**：类似 Scratch 的堆叠式积木编辑器
- **灵活使用**：支持 Inspector 配置和代码调用两种方式

### 1.3 核心决策汇总

| 项目 | 决策 | 理由 |
|------|------|------|
| 插件名称 | PixelCookieFeedback | 品牌统一 |
| 文件格式 | `.pcf` (JSON) | 人类可读，Git 友好 |
| 目标平台 | 2D 优先 | 快速验证核心设计 |
| API 风格 | 混合模式 | Inspector + 代码，灵活性最高 |
| 动画后端 | Tween + _process | 简单动画用 Tween，Spring/Shaker 用 _process |
| 编辑器风格 | 堆叠式积木 | 直观，易上手 |
| 架构模式 | 完全模块化 | 高扩展性，支持复杂条件和时序 |

---

## 二、系统架构

### 2.1 三层架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      编辑器层 (Editor Layer)                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  积木编辑器 - 可视化配置反馈序列                           │  │
│  │  .pcf 文件管理 - 创建/保存/加载/导入/导出                 │  │
│  └───────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                      运行时层 (Runtime Layer)                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  PCFPlayer     - 加载并执行 .pcf 文件的节点组件           │  │
│  │  PCFSequencer  - 解析积木序列，控制并行/顺序执行          │  │
│  │  PCFContext    - 执行上下文（owner, root, params 等）     │  │
│  │  PCFSnapshot   - 状态快照，处理 Tween 打断恢复            │  │
│  │  PCFLoader     - .pcf 文件解析器                          │  │
│  │  PCF           - 静态快捷 API (Autoload)                  │  │
│  └───────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                       效果层 (Effect Layer)                      │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Transform : Scale, Position, Rotation, SquashStretch     │  │
│  │  Spring    : 弹簧物理驱动的动画系统                       │  │
│  │  Shaker    : 震动系统（位置、旋转、相机）                 │  │
│  │  Camera    : 震动、缩放、闪光、淡入淡出                   │  │
│  │  Audio     : 音效播放、随机音效、音高变化                 │  │
│  │  Particles : 粒子播放、粒子生成                           │  │
│  │  Timing    : 等待、循环、暂停                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 核心执行流程

```
用户调用 PCFPlayer.play()
         │
         ▼
┌─────────────────────┐
│  PCFLoader 加载      │  ← 解析 .pcf JSON 文件
│  .pcf 文件          │
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│  PCFSnapshot 拍快照  │  ← 记录目标节点的原始状态
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│  PCFSequencer 执行   │  ← 按行顺序，行内并行
│  sequence           │
└─────────┬───────────┘
         │
         ▼
    ┌────┴────┐
    │  Row 1  │  → [Block A] [Block B] [Block C]  ← 并行执行
    └────┬────┘
         │ 等待全部完成
         ▼
    ┌────┴────┐
    │  Row 2  │  → [Block D]                      ← 顺序执行
    └────┬────┘
         │
         ▼
┌─────────────────────┐
│  完成或恢复快照      │  ← 根据 interrupt_mode 决定
└─────────────────────┘
```

---

## 三、.pcf 文件格式规范

### 3.1 文件结构

```json
{
  "version": "1.0",
  "name": "PlayerJump",
  "description": "玩家跳跃时的反馈效果组合",

  "settings": {
    "interrupt_mode": "RestoreAfter",
    "intensity": 1.0
  },

  "sequence": [
    {
      "row": [
        {
          "type": "scale_punch",
          "target": "@owner",
          "params": {
            "scale": [1.3, 0.7],
            "duration": 0.2,
            "curve": "ease_out_back"
          }
        },
        {
          "type": "sound",
          "params": {
            "clip": "res://sfx/jump.wav",
            "volume": 0.8,
            "pitch": 1.0
          }
        },
        {
          "type": "camera_shake",
          "params": {
            "strength": 3,
            "duration": 0.15,
            "frequency": 20
          }
        }
      ]
    },
    {
      "row": [
        {
          "type": "wait",
          "params": {
            "duration": 0.1
          }
        }
      ]
    },
    {
      "row": [
        {
          "type": "particles",
          "target": "@owner",
          "params": {
            "scene": "res://vfx/dust.tscn",
            "position_offset": [0, -10]
          }
        }
      ]
    }
  ]
}
```

### 3.2 执行规则

| 规则 | 说明 |
|------|------|
| `sequence` | 行数组，行与行**顺序执行** |
| `row` | 积木数组，同一行内**并行执行** |
| 行完成条件 | 该行所有积木都执行完毕 |
| 序列完成条件 | 所有行都执行完毕 |

### 3.3 Target 目标标记

| 标记 | 指向 | 典型用途 |
|------|------|----------|
| `@self` | PCFPlayer 节点本身 | 控制播放器自身 |
| `@owner` | PCFPlayer 的父节点 | 最常用，作用于角色/对象 |
| `@root` | 场景根节点 | 全局效果，如相机 |
| `"Sprite2D"` | 相对路径查找子节点 | 指定具体子节点 |
| `"../Sibling"` | 相对路径查找兄弟节点 | 跨节点效果 |

**示例：同一个 .pcf 被不同对象使用**

```
场景结构：
├── Player
│   ├── Sprite2D
│   └── JumpFeedback (PCFPlayer) → 加载 "jump.pcf"
│
├── Enemy
│   ├── Sprite2D
│   └── JumpFeedback (PCFPlayer) → 加载同一个 "jump.pcf"

jump.pcf 中 target: "@owner"
  → Player 调用时作用于 Player
  → Enemy 调用时作用于 Enemy
```

---

## 四、快照系统设计

### 4.1 问题背景

当 Tween 动画被打断时（如快速连续触发），需要正确处理状态：

```
缩放: 1.0 → 1.3 (执行中)
当前状态: 1.15 (执行到一半被打断)

问题：下次播放应该从哪里开始？
```

### 4.2 两种恢复模式

#### 模式 1：RestoreFirst（先恢复再播放）

```
执行中: [1.0 → 1.3] 当前 1.15
         ↓ 打断
恢复动画: [1.15 → 1.0] (平滑回到快照，如 0.1s)
         ↓ 恢复完成
新序列:  [1.0 → 1.3] 从快照状态开始
         ↓ 完成
结束状态: 1.3
```

**特点：**
- 每次播放都从相同的初始状态开始
- 有短暂的恢复过渡动画
- 适合需要精确控制的效果

#### 模式 2：RestoreAfter（继续执行，最后恢复）

```
执行中: [1.0 → 1.3] 当前 1.15
         ↓ 打断
新序列:  [1.15 → 1.3] 从当前状态继续到目标
         ↓ 完成
恢复快照: [1.3 → 1.0] 回到原始状态
         ↓
结束状态: 1.0
```

**特点：**
- 视觉连贯，不会突然跳变
- 最终一定回到原始状态
- 适合反复触发的效果（如攻击）

### 4.3 快照系统实现

```gdscript
# PCFSnapshot.gd
class_name PCFSnapshot
extends RefCounted

# 存储结构: { node_instance_id: { "property_name": original_value } }
var _snapshots: Dictionary = {}

## 拍摄快照 - 在执行反馈前调用
func capture(node: Node, properties: Array[String]) -> void:
    var node_id := node.get_instance_id()
    if not _snapshots.has(node_id):
        _snapshots[node_id] = {}

    for prop in properties:
        if not _snapshots[node_id].has(prop):  # 只记录第一次
            _snapshots[node_id][prop] = node.get(prop)

## 恢复快照 - 立即恢复
func restore_instant(node: Node) -> void:
    var node_id := node.get_instance_id()
    if _snapshots.has(node_id):
        for prop in _snapshots[node_id]:
            node.set(prop, _snapshots[node_id][prop])

## 恢复快照 - 平滑过渡
func restore_animated(node: Node, duration: float = 0.1) -> Tween:
    var node_id := node.get_instance_id()
    if not _snapshots.has(node_id):
        return null

    var tween := node.create_tween()
    for prop in _snapshots[node_id]:
        tween.parallel().tween_property(
            node, prop,
            _snapshots[node_id][prop],
            duration
        )
    return tween

## 清理快照
func clear() -> void:
    _snapshots.clear()

## 清理特定节点的快照
func clear_node(node: Node) -> void:
    _snapshots.erase(node.get_instance_id())
```

---

## 五、积木编辑器设计

### 5.1 界面布局

```
┌────────────────────────────────────────────────────────────────────────────┐
│  PixelCookieFeedback Editor                    [新建] [打开] [保存] [x]    │
├──────────────────┬─────────────────────────────────────────────────────────┤
│                  │                                                         │
│  积木面板         │   画布区域                                              │
│  (Block Palette) │   (Canvas)                                             │
│                  │                                                         │
│  ┌────────────┐  │   ┌───────────────────────────────────────────────┐     │
│  │ Transform  │  │   │ 🎬 PlayerJump                                 │     │
│  ├────────────┤  │   ├───────────────────────────────────────────────┤     │
│  │  ↔ 缩放弹跳│  │   │ ↔ 缩放弹跳 │ 🔊 播放音效 │ 📳 相机震动      │     │
│  │  ↕ 位置偏移│  │   ├───────────────────────────────────────────────┤     │
│  │  🔄 旋转   │  │   │ ⏱ 等待 0.1s                                   │     │
│  │  💫 挤压   │  │   ├───────────────────────────────────────────────┤     │
│  ├────────────┤  │   │ ✨ 粒子效果                                    │     │
│  │ Spring     │  │   └───────────────────────────────────────────────┘     │
│  ├────────────┤  │                                                         │
│  │  🎯 弹簧缩放│  │   ┌───────────────────────────────────────────────┐     │
│  │  🎯 弹簧位置│  │   │           + 点击添加新行                      │     │
│  ├────────────┤  │   └───────────────────────────────────────────────┘     │
│  │ Camera     │  │                                                         │
│  ├────────────┤  ├─────────────────────────────────────────────────────────┤
│  │  📳 震动   │  │  属性面板 (Property Panel)                              │
│  │  🔍 缩放   │  │                                                         │
│  │  💥 闪光   │  │  ┌─────────────────────────────────────────────────┐   │
│  ├────────────┤  │  │ 缩放弹跳 (scale_punch)                          │   │
│  │ Audio      │  │  ├─────────────────────────────────────────────────┤   │
│  ├────────────┤  │  │ Target:    [@owner           ▼]                 │   │
│  │  🔊 音效   │  │  │ Scale X:   [1.3        ]                        │   │
│  │  🎲 随机音效│  │  │ Scale Y:   [0.7        ]                        │   │
│  ├────────────┤  │  │ Duration:  [0.2        ] 秒                     │   │
│  │ Timing     │  │  │ Curve:     [EaseOutBack      ▼]                 │   │
│  ├────────────┤  │  │                                                  │   │
│  │  ⏱ 等待   │  │  │ [▶ 预览]  [重置]                                │   │
│  │  🔁 循环   │  │  └─────────────────────────────────────────────────┘   │
│  ├────────────┤  │                                                         │
│  │ Particles  │  │                                                         │
│  ├────────────┤  │                                                         │
│  │  ✨ 播放   │  │                                                         │
│  │  💫 生成   │  │                                                         │
│  └────────────┘  │                                                         │
│                  │                                                         │
└──────────────────┴─────────────────────────────────────────────────────────┘
```

### 5.2 交互设计

| 操作 | 行为 |
|------|------|
| 从左侧**拖拽**积木到画布行末尾 | 添加到该行（并行） |
| 从左侧**拖拽**积木到两行之间 | 插入新行（顺序） |
| **点击**画布中的积木 | 右侧显示属性面板 |
| **拖拽**画布中的积木 | 重新排序 |
| **右键**画布中的积木 | 菜单：删除/复制/禁用/剪切 |
| **双击**行 | 折叠/展开该行 |
| 点击**+ 添加新行** | 在末尾添加空行 |
| **Ctrl+S** | 保存文件 |
| **Ctrl+Z / Ctrl+Y** | 撤销/重做 |

### 5.3 积木视觉设计

```
单个积木样式：
┌─────────────────────────────┐
│ 🎵  播放音效                │  ← 图标 + 名称
│ jump.wav                    │  ← 关键参数预览（可选）
└─────────────────────────────┘

禁用状态：
┌─────────────────────────────┐
│ 🎵  播放音效          [x]   │  ← 半透明 + 删除线
│ jump.wav                    │
└─────────────────────────────┘

并行连接：
┌──────────┐ ┌──────────┐ ┌──────────┐
│ ↔ 缩放   │─│ 🔊 音效  │─│ 📳 震动  │  ← 水平连接线
└──────────┘ └──────────┘ └──────────┘
```

---

## 六、运行时核心类

### 6.1 PCFPlayer - 播放器节点

```gdscript
## 反馈播放器 - 挂载到场景中的节点组件
class_name PCFPlayer
extends Node

## 打断恢复模式
enum InterruptMode {
    RESTORE_FIRST,   # 先恢复到快照再播放
    RESTORE_AFTER    # 播放完成后恢复到快照
}

#region 导出属性
@export_file("*.pcf") var feedback_file: String = ""
@export var auto_play: bool = false
@export_range(0.0, 2.0) var intensity: float = 1.0
@export var interrupt_mode: InterruptMode = InterruptMode.RESTORE_AFTER
#endregion

#region 信号
signal started()
signal completed()
signal interrupted()
#endregion

#region 私有变量
var _sequencer: PCFSequencer
var _snapshot: PCFSnapshot
var _is_playing: bool = false
var _data: Dictionary
#endregion

#region 生命周期
func _ready() -> void:
    if feedback_file:
        _data = PCFLoader.load(feedback_file)
    if auto_play:
        play()
#endregion

#region 公共方法
## 播放反馈
func play(params: Dictionary = {}) -> void:
    if _is_playing:
        _handle_interrupt()

    _is_playing = true
    started.emit()

    var context := PCFContext.new()
    context.player = self
    context.owner = get_parent()
    context.root = get_tree().root
    context.intensity = intensity
    context.params = params

    _snapshot = PCFSnapshot.new()
    _sequencer = PCFSequencer.new()
    await _sequencer.execute(_data, context, _snapshot)

    _is_playing = false
    completed.emit()

## 播放（可 await）
func play_async(params: Dictionary = {}) -> void:
    await play(params)

## 停止播放
func stop() -> void:
    if _sequencer:
        _sequencer.stop()
    _is_playing = false

## 是否正在播放
func is_playing() -> bool:
    return _is_playing
#endregion

#region 私有方法
func _handle_interrupt() -> void:
    interrupted.emit()
    _sequencer.stop()

    match interrupt_mode:
        InterruptMode.RESTORE_FIRST:
            await _snapshot.restore_animated(get_parent(), 0.1)
        InterruptMode.RESTORE_AFTER:
            pass  # 新序列完成后会自动恢复
#endregion
```

### 6.2 PCFSequencer - 序列执行器

```gdscript
## 序列执行器 - 解析并执行积木序列
class_name PCFSequencer
extends RefCounted

var _is_running: bool = false
var _current_blocks: Array = []

## 执行序列
func execute(data: Dictionary, context: PCFContext, snapshot: PCFSnapshot) -> void:
    _is_running = true

    var sequence: Array = data.get("sequence", [])

    for row_data in sequence:
        if not _is_running:
            break

        var row: Array = row_data.get("row", [])
        await _execute_row(row, context, snapshot)

    # 如果是 RestoreAfter 模式，在完成后恢复快照
    if context.player.interrupt_mode == PCFPlayer.InterruptMode.RESTORE_AFTER:
        await snapshot.restore_animated(context.owner, 0.1)

    _is_running = false

## 执行单行（并行）
func _execute_row(row: Array, context: PCFContext, snapshot: PCFSnapshot) -> void:
    _current_blocks.clear()
    var tasks: Array = []

    for block_data in row:
        var block := _create_block(block_data)
        if block:
            _current_blocks.append(block)
            # 让积木拍摄需要的快照
            block.capture_snapshot(context, snapshot)
            # 启动执行
            tasks.append(block.execute(context))

    # 等待所有积木完成
    for task in tasks:
        await task

## 停止执行
func stop() -> void:
    _is_running = false
    for block in _current_blocks:
        block.stop()

## 创建积木实例
func _create_block(data: Dictionary) -> PCFBlock:
    var block_type: String = data.get("type", "")
    var block_class := PCFBlockRegistry.get_block_class(block_type)

    if block_class:
        var block: PCFBlock = block_class.new()
        block.setup(data)
        return block

    push_warning("Unknown block type: " + block_type)
    return null
```

### 6.3 PCFContext - 执行上下文

```gdscript
## 执行上下文 - 传递给每个积木的运行时信息
class_name PCFContext
extends RefCounted

## 播放器节点
var player: PCFPlayer

## @owner 指向的节点（通常是 player 的父节点）
var owner: Node

## @root 指向的节点（场景根）
var root: Node

## 强度 (0.0 - 1.0)
var intensity: float = 1.0

## 自定义参数
var params: Dictionary = {}

## 解析 target 字符串，返回实际节点
func resolve_target(target: String) -> Node:
    match target:
        "@self":
            return player
        "@owner":
            return owner
        "@root":
            return root
        _:
            # 相对路径
            return owner.get_node_or_null(target)
```

### 6.4 PCFBlock - 积木基类

```gdscript
## 积木基类 - 所有反馈积木的父类
class_name PCFBlock
extends RefCounted

## 积木类型标识（子类重写）
static func get_type() -> String:
    return "base"

## 积木显示名称（子类重写）
static func get_display_name() -> String:
    return "Base Block"

## 积木图标（子类重写）
static func get_icon() -> String:
    return "res://addons/pixel_cookie_feedback/icons/default.svg"

## 需要记录快照的属性（子类重写）
func get_snapshot_properties() -> Array[String]:
    return []

#region 数据
var target: String = "@owner"
var params: Dictionary = {}
#endregion

#region 运行时
var _tween: Tween
var _target_node: Node
#endregion

## 从数据初始化
func setup(data: Dictionary) -> void:
    target = data.get("target", "@owner")
    params = data.get("params", {})

## 拍摄快照
func capture_snapshot(context: PCFContext, snapshot: PCFSnapshot) -> void:
    _target_node = context.resolve_target(target)
    if _target_node:
        snapshot.capture(_target_node, get_snapshot_properties())

## 执行积木（子类重写）
func execute(context: PCFContext) -> void:
    pass

## 停止执行
func stop() -> void:
    if _tween and _tween.is_valid():
        _tween.kill()
```

### 6.5 PCF - 静态快捷 API

```gdscript
## 快捷 API - 作为 Autoload 使用
extends Node

## 播放反馈文件
static func play(file_path: String, target: Node, params: Dictionary = {}) -> void:
    var data := PCFLoader.load(file_path)
    if data.is_empty():
        push_error("Failed to load feedback file: " + file_path)
        return

    var context := PCFContext.new()
    context.owner = target
    context.root = target.get_tree().root
    context.intensity = params.get("intensity", 1.0)
    context.params = params

    var snapshot := PCFSnapshot.new()
    var sequencer := PCFSequencer.new()
    sequencer.execute(data, context, snapshot)

## 快捷方法：缩放弹跳
static func scale_punch(target: Node, scale: Vector2 = Vector2(1.2, 0.8), duration: float = 0.2) -> void:
    var tween := target.create_tween()
    var original_scale: Vector2 = target.scale
    tween.tween_property(target, "scale", scale, duration * 0.3).set_ease(Tween.EASE_OUT)
    tween.tween_property(target, "scale", original_scale, duration * 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

## 快捷方法：相机震动
static func camera_shake(camera: Node2D, strength: float = 5.0, duration: float = 0.3) -> void:
    # 简化实现，实际会使用 Shaker 系统
    var original_pos: Vector2 = camera.position
    var tween := camera.create_tween()
    var steps := int(duration * 60)
    for i in steps:
        var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
        tween.tween_property(camera, "position", original_pos + offset, duration / steps)
    tween.tween_property(camera, "position", original_pos, 0.05)
```

---

## 七、积木类型详细设计

### 7.1 Transform 变换类

#### scale_punch - 缩放弹跳

```gdscript
class_name BlockScalePunch
extends PCFBlock

static func get_type() -> String: return "scale_punch"
static func get_display_name() -> String: return "缩放弹跳"
static func get_icon() -> String: return "res://.../scale.svg"

func get_snapshot_properties() -> Array[String]:
    return ["scale"]

func execute(context: PCFContext) -> void:
    var scale: Vector2 = Vector2(params.get("scale", [1.2, 0.8])[0], params.get("scale", [1.2, 0.8])[1])
    var duration: float = params.get("duration", 0.2) * context.intensity
    var curve: String = params.get("curve", "ease_out_back")

    var original_scale: Vector2 = _target_node.scale
    var punch_scale: Vector2 = original_scale * scale

    _tween = _target_node.create_tween()
    _tween.tween_property(_target_node, "scale", punch_scale, duration * 0.3)
    _tween.tween_property(_target_node, "scale", original_scale, duration * 0.7)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

    await _tween.finished
```

#### position - 位置偏移

```gdscript
class_name BlockPosition
extends PCFBlock

static func get_type() -> String: return "position"
static func get_display_name() -> String: return "位置偏移"

func get_snapshot_properties() -> Array[String]:
    return ["position"]

func execute(context: PCFContext) -> void:
    var offset: Vector2 = Vector2(params.get("offset", [0, 0])[0], params.get("offset", [0, 0])[1])
    var duration: float = params.get("duration", 0.3)
    var return_to_start: bool = params.get("return", true)

    var original_pos: Vector2 = _target_node.position
    var target_pos: Vector2 = original_pos + offset

    _tween = _target_node.create_tween()
    _tween.tween_property(_target_node, "position", target_pos, duration * 0.5)

    if return_to_start:
        _tween.tween_property(_target_node, "position", original_pos, duration * 0.5)

    await _tween.finished
```

### 7.2 Camera 相机类

#### camera_shake - 相机震动

```gdscript
class_name BlockCameraShake
extends PCFBlock

static func get_type() -> String: return "camera_shake"
static func get_display_name() -> String: return "相机震动"

func get_snapshot_properties() -> Array[String]:
    return ["offset"]  # Camera2D 使用 offset

func execute(context: PCFContext) -> void:
    var strength: float = params.get("strength", 5.0) * context.intensity
    var duration: float = params.get("duration", 0.3)
    var frequency: float = params.get("frequency", 20.0)

    var camera: Camera2D = _target_node as Camera2D
    if not camera:
        camera = context.root.get_viewport().get_camera_2d()

    if not camera:
        push_warning("No camera found for camera_shake")
        return

    var original_offset: Vector2 = camera.offset
    var elapsed: float = 0.0

    while elapsed < duration:
        var decay := 1.0 - (elapsed / duration)
        var offset := Vector2(
            randf_range(-strength, strength) * decay,
            randf_range(-strength, strength) * decay
        )
        camera.offset = original_offset + offset
        await context.player.get_tree().create_timer(1.0 / frequency).timeout
        elapsed += 1.0 / frequency

    camera.offset = original_offset
```

### 7.3 Audio 音频类

#### sound - 播放音效

```gdscript
class_name BlockSound
extends PCFBlock

static func get_type() -> String: return "sound"
static func get_display_name() -> String: return "播放音效"

func get_snapshot_properties() -> Array[String]:
    return []  # 音效不需要快照

func execute(context: PCFContext) -> void:
    var clip_path: String = params.get("clip", "")
    var volume: float = params.get("volume", 1.0)
    var pitch: float = params.get("pitch", 1.0)

    if clip_path.is_empty():
        return

    var clip: AudioStream = load(clip_path)
    if not clip:
        push_warning("Failed to load audio clip: " + clip_path)
        return

    var player := AudioStreamPlayer.new()
    player.stream = clip
    player.volume_db = linear_to_db(volume * context.intensity)
    player.pitch_scale = pitch

    context.root.add_child(player)
    player.play()

    await player.finished
    player.queue_free()
```

### 7.4 Timing 时序类

#### wait - 等待

```gdscript
class_name BlockWait
extends PCFBlock

static func get_type() -> String: return "wait"
static func get_display_name() -> String: return "等待"

func execute(context: PCFContext) -> void:
    var duration: float = params.get("duration", 0.5)
    await context.player.get_tree().create_timer(duration).timeout
```

#### loop - 循环

```gdscript
class_name BlockLoop
extends PCFBlock

static func get_type() -> String: return "loop"
static func get_display_name() -> String: return "循环"

func execute(context: PCFContext) -> void:
    var count: int = params.get("count", 2)  # -1 = 无限
    var blocks: Array = params.get("blocks", [])

    var iteration := 0
    while count == -1 or iteration < count:
        for block_data in blocks:
            var block := PCFBlockRegistry.create_block(block_data)
            if block:
                await block.execute(context)
        iteration += 1
```

---

## 八、弹簧系统设计

### 8.1 SpringFloat - 浮点弹簧

```gdscript
## 浮点弹簧 - 实现物理弹簧行为
class_name SpringFloat
extends RefCounted

## 阻尼 (0-1)，值越大弹簧越"硬"
@export_range(0.0, 1.0) var damping: float = 0.5

## 频率 (Hz)，值越大振荡越快
@export_range(0.1, 20.0) var frequency: float = 5.0

## 当前值
var current_value: float = 0.0

## 目标值
var target_value: float = 0.0

## 速度
var velocity: float = 0.0

## 初始值
var initial_value: float = 0.0

## 是否静止（用于优化）
var is_resting: bool = true

const REST_THRESHOLD := 0.001

## 移动到目标值
func move_to(target: float) -> void:
    target_value = target
    is_resting = false

## 冲击弹簧
func bump(amount: float) -> void:
    velocity += amount
    is_resting = false

## 立即设置值
func set_instant(value: float) -> void:
    current_value = value
    target_value = value
    velocity = 0.0
    is_resting = true

## 每帧更新
func update(delta: float) -> void:
    if is_resting:
        return

    var angular_freq := frequency * TAU
    var damping_coef := damping * 2.0 * angular_freq

    var delta_value := target_value - current_value
    var spring_force := delta_value * angular_freq * angular_freq
    var damping_force := -damping_coef * velocity

    var acceleration := spring_force + damping_force
    velocity += acceleration * delta
    current_value += velocity * delta

    # 检查是否静止
    if absf(velocity) < REST_THRESHOLD and absf(delta_value) < REST_THRESHOLD:
        current_value = target_value
        velocity = 0.0
        is_resting = true

## 恢复初始值
func restore() -> void:
    move_to(initial_value)
```

### 8.2 SpringVector2 - Vector2 弹簧

```gdscript
class_name SpringVector2
extends RefCounted

var x: SpringFloat
var y: SpringFloat

var current_value: Vector2:
    get: return Vector2(x.current_value, y.current_value)

var target_value: Vector2:
    get: return Vector2(x.target_value, y.target_value)

func _init(damping: float = 0.5, frequency: float = 5.0) -> void:
    x = SpringFloat.new()
    y = SpringFloat.new()
    x.damping = damping
    x.frequency = frequency
    y.damping = damping
    y.frequency = frequency

func move_to(target: Vector2) -> void:
    x.move_to(target.x)
    y.move_to(target.y)

func bump(amount: Vector2) -> void:
    x.bump(amount.x)
    y.bump(amount.y)

func update(delta: float) -> void:
    x.update(delta)
    y.update(delta)
```

---

## 九、目录结构

```
addons/pixel_cookie_feedback/
├── plugin.cfg                      # 插件配置
├── plugin.gd                       # 插件入口
│
├── core/                           # 核心运行时
│   ├── pcf_player.gd              # 播放器节点
│   ├── pcf_sequencer.gd           # 序列执行器
│   ├── pcf_context.gd             # 执行上下文
│   ├── pcf_snapshot.gd            # 快照系统
│   ├── pcf_loader.gd              # .pcf 文件加载器
│   ├── pcf_block_registry.gd      # 积木注册表
│   └── pcf.gd                     # 静态快捷 API (Autoload)
│
├── blocks/                         # 积木定义
│   ├── pcf_block.gd               # 积木基类
│   │
│   ├── transform/                 # 变换类
│   │   ├── block_scale_punch.gd
│   │   ├── block_position.gd
│   │   ├── block_rotation.gd
│   │   └── block_squash_stretch.gd
│   │
│   ├── spring/                    # 弹簧类
│   │   ├── block_spring_scale.gd
│   │   ├── block_spring_position.gd
│   │   └── block_spring_bump.gd
│   │
│   ├── camera/                    # 相机类
│   │   ├── block_camera_shake.gd
│   │   ├── block_camera_zoom.gd
│   │   └── block_camera_flash.gd
│   │
│   ├── audio/                     # 音频类
│   │   ├── block_sound.gd
│   │   └── block_random_sound.gd
│   │
│   ├── timing/                    # 时序类
│   │   ├── block_wait.gd
│   │   └── block_loop.gd
│   │
│   └── particles/                 # 粒子类
│       ├── block_particles_play.gd
│       └── block_particles_spawn.gd
│
├── spring/                         # 弹簧系统
│   ├── spring_float.gd
│   ├── spring_vector2.gd
│   └── spring_color.gd
│
├── shaker/                         # 震动系统
│   ├── shaker_base.gd
│   ├── position_shaker.gd
│   ├── rotation_shaker.gd
│   └── camera_shaker.gd
│
├── editor/                         # 积木编辑器
│   ├── pcf_editor_plugin.gd       # 编辑器插件入口
│   ├── pcf_editor_main.gd         # 主编辑器窗口
│   ├── pcf_editor_main.tscn       # 主编辑器场景
│   ├── pcf_block_palette.gd       # 左侧积木面板
│   ├── pcf_canvas.gd              # 中间画布
│   ├── pcf_canvas_row.gd          # 画布中的行
│   ├── pcf_property_panel.gd      # 右侧属性面板
│   ├── pcf_block_ui.gd            # 积木 UI 组件
│   └── pcf_block_ui.tscn          # 积木 UI 场景
│
├── icons/                          # 积木图标
│   ├── scale.svg
│   ├── position.svg
│   ├── rotation.svg
│   ├── sound.svg
│   ├── camera_shake.svg
│   ├── wait.svg
│   ├── particles.svg
│   └── ...
│
└── examples/                       # 示例文件
    ├── example_jump.pcf
    ├── example_hit.pcf
    ├── example_pickup.pcf
    └── demo_scene.tscn
```

---

## 十、实现阶段与时间表

### Phase 1：核心运行时（1-2 周）

**目标：** 可以手写 .pcf 文件并执行

**任务清单：**
- [ ] 创建插件框架 (plugin.cfg, plugin.gd)
- [ ] 实现 PCFLoader（解析 JSON）
- [ ] 实现 PCFContext
- [ ] 实现 PCFSnapshot
- [ ] 实现 PCFSequencer（并行/顺序执行）
- [ ] 实现 PCFPlayer 节点
- [ ] 实现 PCFBlock 基类
- [ ] 实现 3 个基础积木：scale_punch, wait, sound
- [ ] 编写测试场景验证

**验收标准：**
```gdscript
# 手写一个 test.pcf，以下代码能正常工作
$PCFPlayer.feedback_file = "res://test.pcf"
$PCFPlayer.play()
```

---

### Phase 2：积木库扩展（1-2 周）

**目标：** 常用积木全部可用

**任务清单：**
- [ ] Transform: position, rotation, squash_stretch
- [ ] Camera: camera_shake, camera_zoom, camera_flash
- [ ] Audio: random_sound
- [ ] Timing: loop
- [ ] Particles: particles_play, particles_spawn
- [ ] 实现 PCFBlockRegistry（积木注册表）
- [ ] 实现 PCF 静态快捷 API

**验收标准：**
- 所有积木可通过 .pcf 文件配置
- PCF.play() 快捷方法可用

---

### Phase 3：弹簧系统（1 周）

**目标：** 弹簧物理效果可用

**任务清单：**
- [ ] 实现 SpringFloat
- [ ] 实现 SpringVector2
- [ ] 实现 SpringColor
- [ ] 实现 spring_scale, spring_position, spring_bump 积木
- [ ] 实现 ShakerBase
- [ ] 实现 PositionShaker, CameraShaker

**验收标准：**
- 弹簧积木效果符合物理预期
- Damping 和 Frequency 参数可调

---

### Phase 4：积木编辑器（2-3 周）

**目标：** 可视化编辑器可用

**任务清单：**
- [ ] 实现 PCFEditorPlugin（编辑器插件入口）
- [ ] 实现 PCFBlockPalette（积木面板）
- [ ] 实现 PCFCanvas（画布区域）
- [ ] 实现 PCFCanvasRow（行组件）
- [ ] 实现 PCFBlockUI（积木 UI 组件）
- [ ] 实现 PCFPropertyPanel（属性面板）
- [ ] 实现拖拽交互
- [ ] 实现保存/加载 .pcf 文件
- [ ] 实现撤销/重做
- [ ] 绘制积木图标

**验收标准：**
- 可以拖拽创建反馈序列
- 可以保存和加载 .pcf 文件
- 属性面板可以编辑参数

---

### Phase 5：打磨（1 周）

**目标：** 可发布状态

**任务清单：**
- [ ] 完善快捷 API
- [ ] 编写使用文档
- [ ] 创建示例 .pcf 文件
- [ ] 创建演示场景
- [ ] 在 TileSummoner 中集成测试
- [ ] 修复 Bug

**验收标准：**
- 文档完整
- 示例可运行
- 无已知 Bug

---

## 十一、验证方式

### Phase 1 验证
```gdscript
# 手写 test.pcf:
{
  "version": "1.0",
  "name": "Test",
  "sequence": [
    { "row": [{ "type": "scale_punch", "target": "@owner", "params": {"scale": [1.3, 0.7]} }] },
    { "row": [{ "type": "wait", "params": {"duration": 0.2} }] },
    { "row": [{ "type": "sound", "params": {"clip": "res://sfx/test.wav"} }] }
  ]
}

# 测试代码:
func _ready():
    $PCFPlayer.play()
    await $PCFPlayer.completed
    print("Feedback completed!")
```

### Phase 4 验证
1. 打开 Godot 编辑器
2. 菜单栏点击 PixelCookieFeedback → Open Editor
3. 从左侧拖拽积木到画布
4. 点击积木，修改属性
5. 保存为 .pcf 文件
6. 新建场景，添加 PCFPlayer，加载刚才保存的文件
7. 运行场景，效果正确

### 最终验证
在 TileSummoner 项目中：
1. 创建 `tile_place.pcf`（地块放置反馈）
2. 创建 `unit_spawn.pcf`（单位召唤反馈）
3. 创建 `damage.pcf`（伤害反馈）
4. 集成到游戏逻辑中，验证效果

---

## 十二、风险与对策

| 风险 | 可能性 | 影响 | 对策 |
|------|--------|------|------|
| 编辑器开发超时 | 高 | 高 | Phase 4 可拆分，先实现基础功能 |
| Tween 打断处理复杂 | 中 | 中 | 快照系统已设计，边实现边完善 |
| 弹簧物理不自然 | 低 | 低 | 参考成熟实现，调参 |
| 编辑器 UI 在不同分辨率下显示问题 | 中 | 低 | 使用 Godot 原生 UI 控件 |

---

## 十三、后续扩展（不在 v1.0 范围内）

- 3D 支持（Node3D, Camera3D）
- 更多积木类型（Shader, PostProcess）
- 积木预设库
- 动画曲线编辑器
- 运行时预览
- 导出为 GDScript 代码
