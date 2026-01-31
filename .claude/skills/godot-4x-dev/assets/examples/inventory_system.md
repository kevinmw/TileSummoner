# 背包系统完整示例

## 概述

这个示例展示如何实现一个完整的背包系统，包含：

- 物品数据定义
- 背包管理
- 物品堆叠
- UI 显示
- 物品使用

## 物品数据 Resource

```gdscript
# item_data.gd
class_name ItemData
extends Resource

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D

@export_group("Properties")
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var rarity: Rarity = Rarity.COMMON
@export var stack_size: int = 99
@export var sell_price: int = 0

@export_group("Consumable Effects")
@export var heal_amount: int = 0
@export var mana_restore: int = 0

@export_group("Equipment Stats")
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0


func get_rarity_color() -> Color:
    match rarity:
        Rarity.COMMON: return Color.WHITE
        Rarity.UNCOMMON: return Color.GREEN
        Rarity.RARE: return Color.BLUE
        Rarity.EPIC: return Color.PURPLE
        Rarity.LEGENDARY: return Color.ORANGE
    return Color.WHITE


func is_stackable() -> bool:
    return stack_size > 1


func can_use() -> bool:
    return item_type == ItemType.CONSUMABLE
```

## 背包槽

```gdscript
# inventory_slot.gd
class_name InventorySlot
extends RefCounted

signal changed

var item: ItemData = null
var quantity: int = 0


func is_empty() -> bool:
    return item == null or quantity <= 0


func can_add(new_item: ItemData, amount: int = 1) -> bool:
    if is_empty():
        return true
    if item.id == new_item.id and item.is_stackable():
        return quantity + amount <= item.stack_size
    return false


func add(new_item: ItemData, amount: int = 1) -> int:
    if is_empty():
        item = new_item
        quantity = mini(amount, new_item.stack_size)
        changed.emit()
        return amount - quantity  # 返回剩余数量

    if item.id == new_item.id and item.is_stackable():
        var space := item.stack_size - quantity
        var to_add := mini(amount, space)
        quantity += to_add
        changed.emit()
        return amount - to_add

    return amount  # 无法添加，返回全部


func remove(amount: int = 1) -> int:
    var removed := mini(amount, quantity)
    quantity -= removed

    if quantity <= 0:
        item = null
        quantity = 0

    changed.emit()
    return removed


func clear() -> void:
    item = null
    quantity = 0
    changed.emit()
```

## 背包管理器

```gdscript
# inventory.gd
class_name Inventory
extends RefCounted

signal item_added(item: ItemData, amount: int)
signal item_removed(item: ItemData, amount: int)
signal slot_changed(slot_index: int)

var slots: Array[InventorySlot] = []
var size: int


func _init(inventory_size: int = 20) -> void:
    size = inventory_size
    for i in size:
        var slot := InventorySlot.new()
        slot.changed.connect(_on_slot_changed.bind(i))
        slots.append(slot)


func add_item(item: ItemData, amount: int = 1) -> bool:
    var remaining := amount

    # 先尝试堆叠到现有槽
    if item.is_stackable():
        for slot in slots:
            if not slot.is_empty() and slot.item.id == item.id:
                remaining = slot.add(item, remaining)
                if remaining <= 0:
                    break

    # 再尝试放入空槽
    while remaining > 0:
        var empty_slot := get_first_empty_slot()
        if empty_slot:
            remaining = empty_slot.add(item, remaining)
        else:
            break  # 背包已满

    var added := amount - remaining
    if added > 0:
        item_added.emit(item, added)

    return remaining <= 0


func remove_item(item_id: String, amount: int = 1) -> bool:
    var remaining := amount

    for slot in slots:
        if not slot.is_empty() and slot.item.id == item_id:
            remaining -= slot.remove(remaining)
            if remaining <= 0:
                break

    return remaining <= 0


func has_item(item_id: String, amount: int = 1) -> bool:
    var count := get_item_count(item_id)
    return count >= amount


func get_item_count(item_id: String) -> int:
    var count := 0
    for slot in slots:
        if not slot.is_empty() and slot.item.id == item_id:
            count += slot.quantity
    return count


func get_first_empty_slot() -> InventorySlot:
    for slot in slots:
        if slot.is_empty():
            return slot
    return null


func get_slot(index: int) -> InventorySlot:
    if index >= 0 and index < slots.size():
        return slots[index]
    return null


func swap_slots(from_index: int, to_index: int) -> void:
    if from_index < 0 or from_index >= size:
        return
    if to_index < 0 or to_index >= size:
        return

    var temp_item := slots[from_index].item
    var temp_qty := slots[from_index].quantity

    slots[from_index].item = slots[to_index].item
    slots[from_index].quantity = slots[to_index].quantity

    slots[to_index].item = temp_item
    slots[to_index].quantity = temp_qty

    slot_changed.emit(from_index)
    slot_changed.emit(to_index)


func _on_slot_changed(slot_index: int) -> void:
    slot_changed.emit(slot_index)
```

## 背包 UI

```gdscript
# inventory_ui.gd
class_name InventoryUI
extends Control

const SLOT_SCENE := preload("res://src/ui/inventory_slot_ui.tscn")

@export var columns: int = 5

var inventory: Inventory
var slot_uis: Array[InventorySlotUI] = []

@onready var grid: GridContainer = $Panel/MarginContainer/GridContainer


func _ready() -> void:
    grid.columns = columns


func setup(inv: Inventory) -> void:
    inventory = inv
    inventory.slot_changed.connect(_on_slot_changed)

    # 清除现有槽
    for child in grid.get_children():
        child.queue_free()
    slot_uis.clear()

    # 创建槽 UI
    for i in inventory.size:
        var slot_ui: InventorySlotUI = SLOT_SCENE.instantiate()
        slot_ui.slot_index = i
        slot_ui.clicked.connect(_on_slot_clicked)
        grid.add_child(slot_ui)
        slot_uis.append(slot_ui)

    refresh()


func refresh() -> void:
    for i in slot_uis.size():
        var slot := inventory.get_slot(i)
        slot_uis[i].update_display(slot)


func _on_slot_changed(slot_index: int) -> void:
    if slot_index >= 0 and slot_index < slot_uis.size():
        var slot := inventory.get_slot(slot_index)
        slot_uis[slot_index].update_display(slot)


func _on_slot_clicked(slot_index: int) -> void:
    var slot := inventory.get_slot(slot_index)
    if not slot.is_empty():
        # 使用物品或显示详情
        if slot.item.can_use():
            use_item(slot_index)


func use_item(slot_index: int) -> void:
    var slot := inventory.get_slot(slot_index)
    if slot.is_empty() or not slot.item.can_use():
        return

    var item := slot.item

    # 应用效果
    if item.heal_amount > 0:
        EventBus.heal_player.emit(item.heal_amount)

    if item.mana_restore > 0:
        EventBus.restore_mana.emit(item.mana_restore)

    # 消耗物品
    slot.remove(1)
```

## 槽 UI 控件

```gdscript
# inventory_slot_ui.gd
class_name InventorySlotUI
extends Control

signal clicked(slot_index: int)

var slot_index: int = -1

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
@onready var rarity_border: Panel = $RarityBorder


func _ready() -> void:
    gui_input.connect(_on_gui_input)


func update_display(slot: InventorySlot) -> void:
    if slot.is_empty():
        icon.texture = null
        quantity_label.visible = false
        rarity_border.visible = false
    else:
        icon.texture = slot.item.icon
        quantity_label.text = str(slot.quantity)
        quantity_label.visible = slot.quantity > 1
        rarity_border.visible = true
        rarity_border.modulate = slot.item.get_rarity_color()


func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            clicked.emit(slot_index)
```

## 使用示例

```gdscript
# 在玩家或游戏管理器中
var inventory := Inventory.new(20)

func _ready() -> void:
    # 设置 UI
    $InventoryUI.setup(inventory)

    # 添加测试物品
    var potion := load("res://resources/items/health_potion.tres")
    inventory.add_item(potion, 5)
```
