extends Control

@onready var credits_label: Label = $CreditsLabel
@onready var btn_upgrade_dmg: Button = $PanelContainer/VBoxContainer/BtnUpgradeDmg
@onready var btn_upgrade_hp: Button = $PanelContainer/VBoxContainer/BtnUpgradeHp
@onready var btn_back: Button = $PanelContainer/VBoxContainer/BtnBack

func _ready() -> void:
	if btn_upgrade_dmg:
		btn_upgrade_dmg.pressed.connect(_on_btn_upgrade_dmg_pressed)
	if btn_upgrade_hp:
		btn_upgrade_hp.pressed.connect(_on_btn_upgrade_hp_pressed)
	if btn_back:
		btn_back.pressed.connect(_on_btn_back_pressed)

	_update_ui()

func _get_dmg_cost() -> int:
	return 50 * (Global.upgrade_dmg_lvl + 1)

func _get_hp_cost() -> int:
	return 50 * (Global.upgrade_hp_lvl + 1)

func _update_ui() -> void:
	var dmg_cost := _get_dmg_cost()
	var hp_cost := _get_hp_cost()

	if credits_label:
		credits_label.text = "Cyber-Crediti Totali: " + str(Global.total_credits) + " 💎"

	if btn_upgrade_dmg:
		btn_upgrade_dmg.text = "⚡ Danno Base (Lvl " + str(Global.upgrade_dmg_lvl) + " ➜ " + str(Global.upgrade_dmg_lvl + 1) + ") [+2 Dmg]\nCosto: " + str(dmg_cost) + " C"
		btn_upgrade_dmg.disabled = (Global.total_credits < dmg_cost)

	if btn_upgrade_hp:
		btn_upgrade_hp.text = "❤️ Max HP (Lvl " + str(Global.upgrade_hp_lvl) + " ➜ " + str(Global.upgrade_hp_lvl + 1) + ") [+20 HP]\nCosto: " + str(hp_cost) + " C"
		btn_upgrade_hp.disabled = (Global.total_credits < hp_cost)

func _on_btn_upgrade_dmg_pressed() -> void:
	var cost := _get_dmg_cost()
	if Global.total_credits >= cost:
		Global.total_credits -= cost
		Global.upgrade_dmg_lvl += 1
		Global.save_data()
		_update_ui()
		print("Danno permanentemente potenziato a Livello ", Global.upgrade_dmg_lvl)

func _on_btn_upgrade_hp_pressed() -> void:
	var cost := _get_hp_cost()
	if Global.total_credits >= cost:
		Global.total_credits -= cost
		Global.upgrade_hp_lvl += 1
		Global.save_data()
		_update_ui()
		print("Salute Massima permanentemente potenziata a Livello ", Global.upgrade_hp_lvl)

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
