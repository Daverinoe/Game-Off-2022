extends Control
class_name Setting

# Signals

# Enums
enum {
	CHECK_BOX,
	OPTION_BUTTON,
	SLIDER,
	KEY_INPUT,
}

# Public vars

var setting_value setget set_value, get_value

# Vars
export(int, "Check Box", "Option Button", "Slider", "Key Input") var type : int setget set_type, get_type
var type_string : String
var name_string : String
var can_change : bool = false # If we don't have this, the sliders trigger
# changing the setting value straight away to 1.

# Onreadies
onready var references :  = [
	$HBoxContainer/CheckBox,
	$HBoxContainer/OptionButton,
	$HBoxContainer/HSlider,
]


func _ready() -> void:
	
	var text_parse = name.split("-")
	type_string = text_parse[0]
	name_string = text_parse[1]
	$HBoxContainer/Label.text = name_string.replace("_", " ")
	self.type = type
	
	
	if type == self.KEY_INPUT:
		var key_button : ChangeButton = ChangeButton.new()
		key_button.binding = name_string
		key_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		references.push_back(key_button)
		$HBoxContainer.add_child(key_button)
	
	var ref = references[type]
	ref.visible = true
	
	self.setting_value = SettingsManager.get_setting(type_string + "/" + name_string)
	match type:
		SLIDER:
			self.set_range([0, 1.0], 0.05)
			self.set_value(setting_value)
			can_change = true
	match name_string:
		"screen_resolution":
			if OS.has_feature("JavaScript"):
				self.queue_free()
				
			for resolution in SettingsManager.resolutions:
				(ref as OptionButton).add_item(resolution)
				
			self.set_value(setting_value)
		"fullscreen":
			if OS.has_feature("JavaScript"):
				self.queue_free()
		"colorblind":
			for index in SettingsManager.COLORBLIND_OPTIONS.size():
				ref = ref as OptionButton
				var name = SettingsManager.COLORBLIND_OPTIONS.keys()[index]
				ref.add_item(name)


func set_type(new_type : int) -> void:
	type = new_type


func get_type() -> int:
	return type


func set_range(slide_range : Array, new_step : float) -> void:
	references[type].min_value = slide_range[0]
	references[type].max_value = slide_range[1]
	references[type].step = new_step


func add_item(label: String, id: int = -1) -> void:
	references[self.OPTION_BUTTON].add_item(label, id)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	set_value(button_pressed)


func set_value(new_value) -> void:
	setting_value = new_value
	
	match type:
		KEY_INPUT:
			references[type].text = OS.get_scancode_string(setting_value)
		OPTION_BUTTON:
			(references[type] as OptionButton).select(SettingsManager.resolutions.find(setting_value))
		CHECK_BOX:
			references[type].pressed = setting_value
		SLIDER:
			references[type].value = setting_value
		
	SettingsManager.change_setting(self.type_string, self.name_string, self.setting_value)


func get_value():
	return setting_value


func _on_HSlider_value_changed(value: float) -> void:
	if can_change:
		set_value(value)


func _on_OptionButton_item_selected(index: int) -> void:
	var ref = (references[type] as OptionButton)
	var value = ref.get_item_text(ref.get_selected_id())
	set_value(value)

