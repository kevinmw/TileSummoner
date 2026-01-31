# @export 变量导出

## 基础导出

```gdscript
# 基础类型自动推断编辑器控件
@export var speed: float = 200.0
@export var max_health: int = 100
@export var player_name: String = "Hero"
@export var is_invincible: bool = false
```

## 数值范围

```gdscript
# 范围滑块
@export_range(0, 100) var health: int = 100
@export_range(0.0, 10.0, 0.1) var damage_multiplier: float = 1.0

# 带后缀
@export_range(0, 360, 1, "degrees") var rotation_speed: float = 90.0
@export_range(0, 1000, 1, "suffix:px/s") var move_speed: float = 200.0

# 指数滑块（适合大范围值）
@export_exp_easing var easing: float = 1.0
```

## 枚举导出

```gdscript
enum DamageType { PHYSICAL, MAGICAL, TRUE }
@export var damage_type: DamageType = DamageType.PHYSICAL

# 字符串枚举（下拉选择）
@export_enum("Easy", "Normal", "Hard") var difficulty: String = "Normal"
@export_enum("Warrior:0", "Mage:1", "Rogue:2") var class_id: int = 0
```

## 资源导出

```gdscript
# 纹理
@export var icon: Texture2D
@export var sprite_frames: SpriteFrames

# 场景
@export var bullet_scene: PackedScene
@export var enemy_scenes: Array[PackedScene]

# 自定义资源
@export var stats: CharacterStats
@export var item_data: ItemData

# 音频
@export var hit_sound: AudioStream
@export var music: AudioStream
```

## 节点路径导出

```gdscript
# 节点路径（在编辑器中选择）
@export var target_path: NodePath
@export var spawn_point: NodePath

# 使用
func _ready() -> void:
    var target: Node2D = get_node(target_path)
```

## 颜色和曲线

```gdscript
@export var tint_color: Color = Color.WHITE
@export_color_no_alpha var base_color: Color = Color.RED

# 曲线（可在编辑器中绘制）
@export var acceleration_curve: Curve
@export var gradient: Gradient
```

## 数组导出

```gdscript
@export var waypoints: Array[Vector2] = []
@export var patrol_points: Array[NodePath] = []
@export var items: Array[ItemData] = []
@export var spawn_weights: Array[float] = [0.5, 0.3, 0.2]
```

## 分组和分类

```gdscript
@export_group("Movement")
@export var speed: float = 200.0
@export var jump_force: float = 400.0
@export var gravity_scale: float = 1.0

@export_group("Combat")
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5

@export_subgroup("Defense")
@export var armor: int = 5
@export var dodge_chance: float = 0.1

@export_category("Advanced Settings")
@export var debug_mode: bool = false
```

## 文件和目录路径

```gdscript
@export_file var config_path: String
@export_file("*.json") var data_file: String
@export_dir var save_directory: String
@export_global_file("*.png") var texture_path: String
```

## 多行文本

```gdscript
@export_multiline var description: String = ""
@export_multiline var dialog_text: String = ""
```

## Flags（位掩码）

```gdscript
@export_flags("Fire", "Water", "Earth", "Wind") var elements: int = 0

# 碰撞层
@export_flags_2d_physics var collision_layer: int
@export_flags_2d_render var render_layer: int
```

## 占位符文本

```gdscript
@export_placeholder("Enter player name...") var player_name: String = ""
```
