class_name PerkData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var perk_type: String = ""
## Rarità dell'abilità: COMMON / RARE / EPIC / LEGENDARY (influenza probabilità e colore della card)
@export var rarity: String = "COMMON"
## Numero massimo di volte che l'abilità può essere presa nella stessa run (1 = unica)
@export var max_stacks: int = 1
