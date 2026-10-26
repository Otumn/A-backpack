class_name PickableCurrency
extends Pickable

@export var amount:int = 1
@export var type:CurrencyType = CurrencyType.COINS
enum CurrencyType {COINS, VALUE, FUEL}

func pick_up(_player: PlayerBackpack):
	match type:
		CurrencyType.COINS:
			GblMainLogic.add_coins(amount)
		CurrencyType.VALUE:
			GblMainLogic.add_value(amount)
		CurrencyType.FUEL:
			pass
	
	super.pick_up(_player)
