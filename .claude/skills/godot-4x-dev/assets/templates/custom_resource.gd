# 自定义 Resource 模板
# 使用方法：
# 1. 复制此模板，重命名为你的资源类型
# 2. 添加需要的属性
# 3. 在 FileSystem 中右键 → New Resource → 选择你的类型
# 4. 保存为 .tres 文件
class_name CustomResource
extends Resource

## 基础属性
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

## 使用示例：在脚本中引用
# @export var my_resource: CustomResource
# var loaded := preload("res://resources/my_resource.tres")


# =============================================================================
# 角色属性示例
# =============================================================================
# class_name CharacterStats
# extends Resource
#
# @export_group("Base Stats")
# @export var max_health: int = 100
# @export var max_mana: int = 50
# @export var attack: int = 10
# @export var defense: int = 5
#
# @export_group("Movement")
# @export var move_speed: float = 200.0
# @export var jump_force: float = 400.0
#
# @export_group("Experience")
# @export var level: int = 1
# @export var experience: int = 0
# @export var experience_to_next: int = 100
#
# func get_damage_reduction() -> float:
#     return defense / (defense + 100.0)


# =============================================================================
# 物品数据示例
# =============================================================================
# class_name ItemData
# extends Resource
#
# enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL }
# enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
#
# @export var id: String
# @export var display_name: String
# @export_multiline var description: String
# @export var icon: Texture2D
#
# @export_group("Properties")
# @export var item_type: ItemType = ItemType.CONSUMABLE
# @export var rarity: Rarity = Rarity.COMMON
# @export var stack_size: int = 99
# @export var value: int = 0
#
# @export_group("Effects")
# @export var heal_amount: int = 0
# @export var mana_restore: int = 0
# @export var buff_duration: float = 0.0
#
# func get_rarity_color() -> Color:
#     match rarity:
#         Rarity.COMMON: return Color.WHITE
#         Rarity.UNCOMMON: return Color.GREEN
#         Rarity.RARE: return Color.BLUE
#         Rarity.EPIC: return Color.PURPLE
#         Rarity.LEGENDARY: return Color.ORANGE
#     return Color.WHITE


# =============================================================================
# 技能数据示例
# =============================================================================
# class_name SkillData
# extends Resource
#
# enum TargetType { SELF, SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES }
#
# @export var id: String
# @export var skill_name: String
# @export_multiline var description: String
# @export var icon: Texture2D
#
# @export_group("Cost")
# @export var mana_cost: int = 10
# @export var cooldown: float = 1.0
#
# @export_group("Effect")
# @export var target_type: TargetType = TargetType.SINGLE_ENEMY
# @export var damage: int = 0
# @export var heal: int = 0
#
# @export_group("Visual")
# @export var effect_scene: PackedScene
# @export var sound_effect: AudioStream


# =============================================================================
# 对话数据示例
# =============================================================================
# class_name DialogData
# extends Resource
#
# @export var dialog_id: String
# @export var speaker_name: String
# @export var speaker_portrait: Texture2D
# @export_multiline var lines: Array[String] = []
#
# @export_group("Options")
# @export var choices: Array[DialogChoice] = []
# @export var next_dialog_id: String = ""
#
# class DialogChoice:
#     var text: String
#     var next_dialog_id: String
#     var condition: String = ""  # 可选条件表达式
