# 对话系统完整示例

## 概述

这个示例展示如何实现一个完整的对话系统，包含：

- 对话数据结构
- 打字机效果
- 选项分支
- NPC 触发
- 对话事件

## 对话数据 Resource

```gdscript
# dialog_data.gd
class_name DialogData
extends Resource

@export var dialog_id: String
@export var speaker_name: String
@export var speaker_portrait: Texture2D

@export_group("Content")
@export_multiline var lines: Array[String] = []

@export_group("Choices")
@export var choices: Array[DialogChoice] = []

@export_group("Flow")
@export var next_dialog_id: String = ""
@export var trigger_event: String = ""


# dialog_choice.gd
class_name DialogChoice
extends Resource

@export var text: String
@export var next_dialog_id: String
@export var condition: String = ""  # 可选：检查条件
@export var set_flag: String = ""   # 可选：设置标志
```

## 对话管理器

```gdscript
# dialog_manager.gd (AutoLoad)
class_name DialogManager
extends CanvasLayer

signal dialog_started
signal dialog_ended
signal dialog_event(event_name: String)

var is_active: bool = false
var current_dialog: DialogData = null
var current_line_index: int = 0

var _dialog_database: Dictionary = {}
var _flags: Dictionary = {}

@onready var dialog_box: Control = $DialogBox
@onready var speaker_label: Label = $DialogBox/SpeakerLabel
@onready var portrait: TextureRect = $DialogBox/Portrait
@onready var text_label: RichTextLabel = $DialogBox/TextLabel
@onready var choices_container: VBoxContainer = $DialogBox/ChoicesContainer
@onready var continue_indicator: Control = $DialogBox/ContinueIndicator

const CHAR_DELAY: float = 0.03


func _ready() -> void:
    dialog_box.visible = false
    _load_dialogs()


func _load_dialogs() -> void:
    # 加载所有对话资源
    var dir := DirAccess.open("res://resources/dialogs/")
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var dialog: DialogData = load("res://resources/dialogs/" + file_name)
                if dialog:
                    _dialog_database[dialog.dialog_id] = dialog
            file_name = dir.get_next()


func _input(event: InputEvent) -> void:
    if not is_active:
        return

    if event.is_action_pressed("ui_accept"):
        if text_label.visible_ratio < 1.0:
            # 跳过打字效果
            text_label.visible_ratio = 1.0
        else:
            advance_dialog()


func start_dialog(dialog_id: String) -> void:
    if not _dialog_database.has(dialog_id):
        push_error("Dialog not found: " + dialog_id)
        return

    current_dialog = _dialog_database[dialog_id]
    current_line_index = 0
    is_active = true

    dialog_box.visible = true
    get_tree().paused = true

    dialog_started.emit()
    _show_current_line()


func advance_dialog() -> void:
    current_line_index += 1

    if current_line_index >= current_dialog.lines.size():
        # 所有行显示完毕
        if not current_dialog.choices.is_empty():
            _show_choices()
        elif not current_dialog.next_dialog_id.is_empty():
            start_dialog(current_dialog.next_dialog_id)
        else:
            end_dialog()
    else:
        _show_current_line()


func end_dialog() -> void:
    is_active = false
    dialog_box.visible = false
    get_tree().paused = false

    # 触发事件
    if current_dialog and not current_dialog.trigger_event.is_empty():
        dialog_event.emit(current_dialog.trigger_event)

    current_dialog = null
    dialog_ended.emit()


func _show_current_line() -> void:
    var line := current_dialog.lines[current_line_index]

    speaker_label.text = current_dialog.speaker_name
    portrait.texture = current_dialog.speaker_portrait

    choices_container.visible = false
    continue_indicator.visible = false

    # 打字机效果
    text_label.text = line
    text_label.visible_ratio = 0.0
    _typewriter_effect()


func _typewriter_effect() -> void:
    while text_label.visible_ratio < 1.0:
        text_label.visible_ratio += 1.0 / text_label.text.length()
        await get_tree().create_timer(CHAR_DELAY).timeout

        if not is_active:
            return

    continue_indicator.visible = true


func _show_choices() -> void:
    choices_container.visible = true
    continue_indicator.visible = false

    # 清除旧选项
    for child in choices_container.get_children():
        child.queue_free()

    # 创建选项按钮
    for choice in current_dialog.choices:
        if _check_condition(choice.condition):
            var button := Button.new()
            button.text = choice.text
            button.pressed.connect(_on_choice_selected.bind(choice))
            choices_container.add_child(button)

    # 聚焦第一个选项
    await get_tree().process_frame
    if choices_container.get_child_count() > 0:
        choices_container.get_child(0).grab_focus()


func _on_choice_selected(choice: DialogChoice) -> void:
    # 设置标志
    if not choice.set_flag.is_empty():
        _flags[choice.set_flag] = true

    # 进入下一个对话
    if not choice.next_dialog_id.is_empty():
        start_dialog(choice.next_dialog_id)
    else:
        end_dialog()


func _check_condition(condition: String) -> bool:
    if condition.is_empty():
        return true
    return _flags.get(condition, false)


func set_flag(flag_name: String, value: bool = true) -> void:
    _flags[flag_name] = value


func get_flag(flag_name: String) -> bool:
    return _flags.get(flag_name, false)
```

## NPC 对话触发

```gdscript
# dialog_trigger.gd
extends Area2D

@export var dialog_id: String
@export var interaction_prompt: String = "Press E to talk"

var player_in_range: bool = false

@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    prompt_label.text = interaction_prompt
    prompt_label.visible = false


func _input(event: InputEvent) -> void:
    if player_in_range and event.is_action_pressed("interact"):
        if not DialogManager.is_active:
            DialogManager.start_dialog(dialog_id)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_range = true
        prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_range = false
        prompt_label.visible = false
```

## 对话 UI 场景结构

```
DialogManager (CanvasLayer)
└── DialogBox (Control)
    ├── Panel (背景)
    ├── Portrait (TextureRect)
    ├── SpeakerLabel (Label)
    ├── TextLabel (RichTextLabel)
    ├── ChoicesContainer (VBoxContainer)
    └── ContinueIndicator (Control)
        └── AnimatedSprite2D (闪烁箭头)
```

## 对话数据示例

```
# resources/dialogs/npc_01_greeting.tres
dialog_id: "npc_01_greeting"
speaker_name: "老村长"
speaker_portrait: 村长头像.png
lines:
  - "欢迎来到我们的村庄，年轻的旅行者。"
  - "你来得正好，村子里最近发生了一些奇怪的事情..."
choices:
  - text: "发生了什么事？"
    next_dialog_id: "npc_01_quest"
  - text: "我只是路过。"
    next_dialog_id: "npc_01_goodbye"
```

## 使用示例

```gdscript
# 直接通过代码启动对话
DialogManager.start_dialog("npc_01_greeting")

# 监听对话事件
DialogManager.dialog_event.connect(func(event):
    match event:
        "quest_accepted":
            QuestManager.accept_quest("main_quest_01")
        "shop_opened":
            ShopUI.open()
)
```
