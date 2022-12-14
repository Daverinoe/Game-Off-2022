extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	Global.LootManager = self
	Event.connect("drop_loot", self, "create_drop")
	
	# Add all children items to groups for ease of access
	add_items_to_groups(self.get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func create_drop(monster_level, position : Vector3 = Vector3.ZERO) -> void:
	var roll = randf() * 100
		
	if roll >= 0 and roll < 40:
		return
	if roll >= 40 and roll < 50:
		drop(Item.ITEM_TYPE.GOLD, monster_level, position)
		return
	if roll >= 50 and roll < 60:
		drop(Item.ITEM_TYPE.POTION, monster_level, position)
		return
	if roll >= 60 and roll < 64:
		drop(Item.ITEM_TYPE.MELEE, monster_level, position)
		return
	if roll >= 64 and roll < 68:
		drop(Item.ITEM_TYPE.RANGED, monster_level, position)
		return
	if roll >= 68 and roll < 72:
		drop(Item.ITEM_TYPE.MAGIC, monster_level, position)
		return
	if roll >= 72 and roll < 76:
		drop(Item.ITEM_TYPE.SHIELD, monster_level, position)
		return
	if roll >= 76 and roll < 80:
		drop(Item.ITEM_TYPE.CHEST, monster_level, position)
		return
	if roll >= 80 and roll < 84:
		drop(Item.ITEM_TYPE.LEGS, monster_level, position)
		return
	if roll >= 84 and roll < 88:
		drop(Item.ITEM_TYPE.HANDS, monster_level, position)
		return
	if roll >= 88 and roll < 92:
		drop(Item.ITEM_TYPE.FEET, monster_level, position)
		return
	if roll >= 92 and roll < 96:
		drop(Item.ITEM_TYPE.BELT, monster_level, position)
		return
	if roll >= 96 and roll < 100:
		drop(Item.ITEM_TYPE.HEAD, monster_level, position)
		return


func drop(item_type : int, monster_level : int = 0, position : Vector3 = Vector3.ZERO, override = false) -> void:
	# Get the item type group
	var group_name = Item.ITEM_TYPE.keys()[item_type]
	var group = get_tree().get_nodes_in_group(group_name)
	
	if group.size() <= 0:
		return
	var item = group[randi() % group.size()].duplicate()
	
	item.drop_position = position
	
	var magic_chance = 1.0 - (monster_level / 30.0)
	var magic_roll = randf()
	if magic_roll >= magic_chance:
		item.rarity = Item.RARITY.MAGIC
		item.prefix = generate_prefix(item_type)
		item.suffix = generate_suffix(item_type, item.prefix)
	
	# Add to level as a child, synchronously to avoid errors
	Global.level_reference.get_node("items").add_child(item)
	
	item.is_dropped = true
	item.drop()


func add_items_to_groups(children) -> void:
	for child in children:
		if child.name.count("container") > 0:
			add_items_to_groups(child.get_children())
		else:
			child.add_to_group(Item.ITEM_TYPE.keys()[child.type])


func generate_prefix(item_type) -> Affix:
	var chance = randf()
	# 50% chance to have prefix. If no prefix, 100% chance of suffix.
	if chance < 0.49:
		return Affix.new()
	
	# Choose random prefix. If inappropriate, reroll.
	var prefix
	var index
	var prefix_chosen = false
	while !prefix_chosen:
		index = randi() % Item.PREFIXES.size()
		var key = Item.PREFIXES.keys()[index]
		prefix = Item.PREFIXES[key]
		if (prefix[0] as Array).has(item_type):
			prefix_chosen = true
	return Affix.new(
		Item.PREFIXES.keys()[index], 
		prefix[1], 
		prefix[2], 
		prefix[3], 
		prefix[4], 
		prefix[5], 
		prefix[6])


func generate_suffix(item_type, prefix) -> Affix:
	if prefix.display_text != "":
		var chance = randf()
		# If prefix exists, only 25% chance of suffix
		if chance < 0.74:
			return Affix.new()
	
	# Choose random prefix. If inappropriate, reroll.
	var suffix
	var index
	var suffix_chosen = false
	while !suffix_chosen:
		index = randi() % Item.SUFFIXES.size()
		var key = Item.SUFFIXES.keys()[index]
		suffix = Item.SUFFIXES[key]
		if (suffix[0] as Array).has(item_type):
			suffix_chosen = true
	return Affix.new(
		Item.SUFFIXES.keys()[index],
		suffix[1],
		suffix[2],
		suffix[3],
		suffix[4],
		suffix[5],
		suffix[6]
	)
