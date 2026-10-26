class_name WeaponStats
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var id: String = ""
@export var display_name: String = ""
@export var base_damage: int = 10
@export var fire_rate: float = 0.3
@export var rarity: Rarity = Rarity.COMMON

## Calcola il danno finale applicando il moltiplicatore basato sulla rarità
func get_final_damage() -> int:
	var multiplier: float = 1.0
	match rarity:
		Rarity.COMMON:
			multiplier = 1.0
		Rarity.RARE:
			multiplier = 1.5
		Rarity.EPIC:
			multiplier = 2.0
		Rarity.LEGENDARY:
			multiplier = 3.0

	return int(base_damage * multiplier)
