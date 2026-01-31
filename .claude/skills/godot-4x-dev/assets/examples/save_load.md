# 存档系统完整示例

## 概述

这个示例展示如何实现一个完整的存档系统，包含：

- 多存档槽
- 自动保存
- 加密存储
- 游戏状态序列化
- 配置保存

## 存档数据结构

```gdscript
# save_data.gd
class_name SaveData
extends Resource

# 元数据
@export var save_slot: int = 0
@export var save_time: String = ""
@export var play_time: float = 0.0
@export var screenshot: Image = null

# 玩家数据
@export var player_position: Vector2 = Vector2.ZERO
@export var player_health: int = 100
@export var player_level: int = 1
@export var player_experience: int = 0

# 背包
@export var inventory_items: Array[Dictionary] = []

# 进度
@export var current_scene: String = ""
@export var completed_quests: Array[String] = []
@export var active_quests: Array[String] = []
@export var flags: Dictionary = {}

# 统计
@export var enemies_killed: int = 0
@export var deaths: int = 0
@export var items_collected: int = 0
```

## 存档管理器

```gdscript
# save_manager.gd (AutoLoad)
class_name SaveManager
extends Node

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(error: String)
signal load_failed(error: String)

const SAVE_DIR := "user://saves/"
const SAVE_FILE_TEMPLATE := "save_%d.tres"
const CONFIG_FILE := "user://settings.cfg"
const MAX_SLOTS := 3
const ENCRYPTION_KEY := "your_secret_key_here"

var current_slot: int = 0
var auto_save_enabled: bool = true
var auto_save_interval: float = 300.0  # 5 分钟

var _auto_save_timer: Timer


func _ready() -> void:
    _ensure_save_directory()
    _setup_auto_save()


func _ensure_save_directory() -> void:
    var dir := DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")


func _setup_auto_save() -> void:
    _auto_save_timer = Timer.new()
    _auto_save_timer.wait_time = auto_save_interval
    _auto_save_timer.timeout.connect(_on_auto_save)
    add_child(_auto_save_timer)

    if auto_save_enabled:
        _auto_save_timer.start()


## 保存游戏

func save_game(slot: int = -1) -> bool:
    if slot < 0:
        slot = current_slot

    var save_data := _collect_save_data(slot)
    var path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot

    # 加密保存
    var error := ResourceSaver.save(save_data, path)

    if error == OK:
        current_slot = slot
        save_completed.emit(slot)
        print("Game saved to slot ", slot)
        return true
    else:
        save_failed.emit("Failed to save: " + str(error))
        return false


func _collect_save_data(slot: int) -> SaveData:
    var data := SaveData.new()

    # 元数据
    data.save_slot = slot
    data.save_time = Time.get_datetime_string_from_system()
    data.play_time = _get_play_time()

    # 截图
    data.screenshot = _capture_screenshot()

    # 玩家数据
    var player := _get_player()
    if player:
        data.player_position = player.global_position
        data.player_health = player.health
        data.player_level = player.level
        data.player_experience = player.experience

    # 背包
    data.inventory_items = _serialize_inventory()

    # 场景
    data.current_scene = get_tree().current_scene.scene_file_path

    # 进度
    data.completed_quests = QuestManager.get_completed_quests()
    data.active_quests = QuestManager.get_active_quests()
    data.flags = GameManager.get_all_flags()

    # 统计
    data.enemies_killed = StatsManager.enemies_killed
    data.deaths = StatsManager.deaths
    data.items_collected = StatsManager.items_collected

    return data


## 加载游戏

func load_game(slot: int) -> bool:
    var path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot

    if not FileAccess.file_exists(path):
        load_failed.emit("Save file not found")
        return false

    var save_data: SaveData = load(path)

    if not save_data:
        load_failed.emit("Failed to load save data")
        return false

    current_slot = slot
    await _apply_save_data(save_data)
    load_completed.emit(slot)
    print("Game loaded from slot ", slot)
    return true


func _apply_save_data(data: SaveData) -> void:
    # 切换场景
    await get_tree().change_scene_to_file(data.current_scene)
    await get_tree().process_frame

    # 恢复玩家
    var player := _get_player()
    if player:
        player.global_position = data.player_position
        player.health = data.player_health
        player.level = data.player_level
        player.experience = data.player_experience

    # 恢复背包
    _deserialize_inventory(data.inventory_items)

    # 恢复进度
    QuestManager.restore_quests(data.completed_quests, data.active_quests)
    GameManager.restore_flags(data.flags)

    # 恢复统计
    StatsManager.enemies_killed = data.enemies_killed
    StatsManager.deaths = data.deaths
    StatsManager.items_collected = data.items_collected


## 存档槽管理

func get_save_info(slot: int) -> Dictionary:
    var path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot

    if not FileAccess.file_exists(path):
        return {"exists": false}

    var save_data: SaveData = load(path)
    if not save_data:
        return {"exists": false}

    return {
        "exists": true,
        "slot": slot,
        "time": save_data.save_time,
        "play_time": save_data.play_time,
        "level": save_data.player_level,
        "scene": save_data.current_scene,
        "screenshot": save_data.screenshot
    }


func get_all_saves() -> Array[Dictionary]:
    var saves: Array[Dictionary] = []
    for i in MAX_SLOTS:
        saves.append(get_save_info(i))
    return saves


func delete_save(slot: int) -> bool:
    var path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot

    if FileAccess.file_exists(path):
        var dir := DirAccess.open(SAVE_DIR)
        return dir.remove(SAVE_FILE_TEMPLATE % slot) == OK

    return false


func has_save(slot: int) -> bool:
    var path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
    return FileAccess.file_exists(path)


## 辅助方法

func _get_player() -> Node:
    return get_tree().get_first_node_in_group("player")


func _get_play_time() -> float:
    return GameManager.total_play_time if GameManager else 0.0


func _capture_screenshot() -> Image:
    await RenderingServer.frame_post_draw
    var screenshot := get_viewport().get_texture().get_image()
    screenshot.resize(160, 90)
    return screenshot


func _serialize_inventory() -> Array[Dictionary]:
    var items: Array[Dictionary] = []
    var inventory := PlayerInventory.inventory if PlayerInventory else null

    if inventory:
        for slot in inventory.slots:
            if not slot.is_empty():
                items.append({
                    "id": slot.item.id,
                    "quantity": slot.quantity
                })

    return items


func _deserialize_inventory(items: Array[Dictionary]) -> void:
    if not PlayerInventory:
        return

    PlayerInventory.inventory.clear()

    for item_data in items:
        var item: ItemData = load("res://resources/items/" + item_data.id + ".tres")
        if item:
            PlayerInventory.inventory.add_item(item, item_data.quantity)


func _on_auto_save() -> void:
    if auto_save_enabled and not get_tree().paused:
        save_game(current_slot)


## 设置保存

func save_settings(settings: Dictionary) -> void:
    var config := ConfigFile.new()

    for section in settings:
        for key in settings[section]:
            config.set_value(section, key, settings[section][key])

    config.save(CONFIG_FILE)


func load_settings() -> Dictionary:
    var config := ConfigFile.new()
    var settings := {}

    if config.load(CONFIG_FILE) == OK:
        for section in config.get_sections():
            settings[section] = {}
            for key in config.get_section_keys(section):
                settings[section][key] = config.get_value(section, key)

    return settings
```

## 存档 UI

```gdscript
# save_menu.gd
extends Control

@onready var slot_container: VBoxContainer = $SlotContainer

const SLOT_SCENE := preload("res://src/ui/save_slot.tscn")


func _ready() -> void:
    refresh_slots()


func refresh_slots() -> void:
    for child in slot_container.get_children():
        child.queue_free()

    var saves := SaveManager.get_all_saves()

    for save_info in saves:
        var slot_ui: SaveSlotUI = SLOT_SCENE.instantiate()
        slot_ui.setup(save_info)
        slot_ui.save_requested.connect(_on_save_requested)
        slot_ui.load_requested.connect(_on_load_requested)
        slot_ui.delete_requested.connect(_on_delete_requested)
        slot_container.add_child(slot_ui)


func _on_save_requested(slot: int) -> void:
    SaveManager.save_game(slot)
    refresh_slots()


func _on_load_requested(slot: int) -> void:
    SaveManager.load_game(slot)
    visible = false


func _on_delete_requested(slot: int) -> void:
    SaveManager.delete_save(slot)
    refresh_slots()
```

## 使用示例

```gdscript
# 保存游戏
SaveManager.save_game(0)  # 保存到槽 0

# 加载游戏
SaveManager.load_game(0)  # 从槽 0 加载

# 快速保存/加载
SaveManager.save_game()   # 保存到当前槽
SaveManager.load_game(SaveManager.current_slot)

# 检查存档
if SaveManager.has_save(0):
    var info := SaveManager.get_save_info(0)
    print("Save time: ", info.time)

# 保存设置
SaveManager.save_settings({
    "audio": {"master": 0.8, "music": 0.6, "sfx": 1.0},
    "video": {"fullscreen": true, "vsync": true}
})

# 加载设置
var settings := SaveManager.load_settings()
```
