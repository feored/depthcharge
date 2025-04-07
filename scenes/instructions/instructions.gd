extends Node2D

@onready var panel1 = %Panel1
@onready var buttonPrev = %ButtonPrev
@onready var buttonNext = %ButtonNext
@onready var buttonMenu = %ButtonMenu

@onready var panels = [
    %Panel1,
    %Panel2,
    %Panel3,
]

var current_page = 0

func show_page(page: int) -> void:
    for i in range(panels.size()):
        panels[i].visible = (i == page)
    if page == 0:
        buttonPrev.disabled = true
    else:
        buttonPrev.disabled = false
    if page == panels.size() - 1:
        buttonNext.disabled = true
    else:
        buttonNext.disabled = false

func _ready() -> void:
    show_page(current_page)

func _on_button_prev_pressed() -> void:
    current_page -= 1
    if current_page < 0:
        current_page = 0
    show_page(current_page)

func _on_button_menu_pressed() -> void:
    await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)

func _on_button_next_pressed() -> void:
    current_page += 1
    if current_page >= panels.size():
        current_page = panels.size() - 1
    show_page(current_page)