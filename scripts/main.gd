extends Node2D

@export var obstacle_scene: PackedScene

var score: int = 0
var bulb_count: int = 0
var is_premium: bool = false
var is_premium_year: bool = false
var game_over: bool = false
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0
var difficulty_timer: float = 0.0

@onready var premium_label: Label = $CanvasLayer/Button_Control/Premium_Label


@onready var button_control: Control = $CanvasLayer/Button_Control
@onready var loading_label: Label = $CanvasLayer/Button_Control/Loading_Label
@onready var status_label: Label = $CanvasLayer/Button_Control/Status_Label

const VIEWPORT_WIDTH := 720
const VIEWPORT_HEIGHT := 1280


func _ready() -> void:
	
	# Ensure background covers full viewport



	# Store panel buttons
	_setup_store_panel()

	# Connect IAP signals (IapManager is autoload singleton)
	IapManager.purchase_completed.connect(_on_purchase_completed)
	IapManager.purchase_failed.connect(_on_purchase_failed)
	IapManager.products_loaded.connect(_on_products_loaded)
	IapManager.connection_changed.connect(_on_connection_changed)
	IapManager.loading_changed.connect(_on_loading_changed)

	# Load saved premium status
	_load_premium_status()

	#game_over_label.visible = false
	#restart_button.visible = false
	#store_overlay.visible = false
	#store_panel.visible = false
	#loading_label.visible = true
	#status_label.text = "Connecting..."

	update_ui()
	


func _setup_store_panel() -> void:
	# Connect store panel buttons

	#var buy_10_btn = store_panel.get_node_or_null("VBoxContainer/Buy10BulbsButton")
	#if buy_10_btn:
		#buy_10_btn.pressed.connect(_on_buy_10_bulbs_pressed)
#
	#var buy_30_btn = store_panel.get_node_or_null("VBoxContainer/Buy30BulbsButton")
	#if buy_30_btn:
		#buy_30_btn.pressed.connect(_on_buy_30_bulbs_pressed)
	
	var buy_premium_btn = button_control.get_node_or_null("BuyPremiumButton")
	print("buy_premium_btn " +str(buy_premium_btn))
	#if buy_premium_btn:
	buy_premium_btn.pressed.connect(_on_buy_premium_pressed)

	#var buy_premium_year_btn = store_panel.get_node_or_null("VBoxContainer/BuyPremiumYearButton")
	#if buy_premium_year_btn:
		#buy_premium_year_btn.pressed.connect(_on_buy_premium_year_pressed)
#
	#var restore_btn = store_panel.get_node_or_null("VBoxContainer/RestoreButton")
	#if restore_btn:
		#restore_btn.pressed.connect(_on_restore_pressed)








func _on_store_button_pressed() -> void:
	if not IapManager.store_connected:
		status_label.text = "Store not connected"
		return

	_update_store_panel_buttons()




func _on_buy_10_bulbs_pressed() -> void:
	IapManager.purchase_10_bulbs()


func _on_buy_30_bulbs_pressed() -> void:
	IapManager.purchase_30_bulbs()


func _on_buy_premium_pressed() -> void:
	if not is_premium:
		IapManager.purchase_premium()


func _on_buy_premium_year_pressed() -> void:
	if not is_premium_year:
		IapManager.purchase_premium_year()


func _on_restore_pressed() -> void:
	IapManager.restore_purchases()


func _on_purchase_completed(product_id: String) -> void:
	print("[Main] Purchase completed callback: %s" % product_id)
	match product_id:
		#"dev.hyo.martie.10bulbs":
			#bulb_count += 10
			#print("[Main] Bulb count: %d" % bulb_count)
		#"dev.hyo.martie.30bulbs":
			#bulb_count += 30
			#print("[Main] Bulb count: %d" % bulb_count)
		#"dev.hyo.martie.certified":
			#print("[Main] Certified purchased!")
		"no_ads":
			is_premium = true
			_save_premium_status()
		#"dev.hyo.martie.premium_year":
			#is_premium_year = true
			#_save_premium_status()
	update_ui()
	_update_store_panel_buttons()


func _on_purchase_failed(product_id: String, error: String) -> void:
	print("Purchase failed: %s - %s" % [product_id, error])
	status_label.text = "Purchase failed: %s" % error


func _on_products_loaded() -> void:
	print("[Main] Products loaded, updating button texts")
	_update_store_panel_buttons()
	update_ui()


func _on_connection_changed(connected: bool) -> void:
	if connected:
		status_label.text = "Connected"
		#store_button.disabled = false
	else:
		status_label.text = "Not connected"
		#store_button.disabled = true


func _on_loading_changed(loading: bool) -> void:
	loading_label.visible = loading
	if loading:
		status_label.text = "Loading..."
	elif IapManager.store_connected:
		status_label.text = "Ready"
	else:
		status_label.text = "Not connected"


func _save_premium_status() -> void:
	var config := ConfigFile.new()
	config.set_value("iap", "premium", is_premium)
	config.set_value("iap", "premium_year", is_premium_year)
	config.save("user://iap_data.cfg")


func _load_premium_status() -> void:
	var config := ConfigFile.new()
	if config.load("user://iap_data.cfg") == OK:
		is_premium = config.get_value("iap", "premium", false)
		is_premium_year = config.get_value("iap", "premium_year", false)


func update_ui() -> void:
	#score_label.text = "Score: %d" % score
	#bulb_label.text = "Bulbs: %d" % bulb_count

	if is_premium or is_premium_year:
		var premium_type = "Year" if is_premium_year else "Lifetime"
		premium_label.text = "Premium: %s" % premium_type
		premium_label.modulate = Color(1, 0.8, 0, 1)
	else:
		premium_label.text = "Premium: OFF"
		premium_label.modulate = Color(1, 1, 1, 1)



func _update_store_panel_buttons() -> void:
	_update_button_text("VBoxContainer/Buy10BulbsButton", IapManager.PRODUCT_10_BULBS, "10 Bulbs")
	_update_button_text("VBoxContainer/Buy30BulbsButton", IapManager.PRODUCT_30_BULBS, "30 Bulbs")
	_update_button_text("VBoxContainer/BuyPremiumButton", IapManager.PRODUCT_PREMIUM, "Premium")
	_update_button_text("VBoxContainer/BuyPremiumYearButton", IapManager.PRODUCT_PREMIUM_YEAR, "Premium Year")


func _update_button_text(button_path: String, product_id: String, fallback: String) -> void:
	#var button = store_panel.get_node_or_null(button_path)
	#if button == null:
		#return
	if IapManager.products.has(product_id):
		var product = IapManager.products[product_id]
		# Products are now typed objects (Types.ProductAndroid or Types.ProductIOS)
		# Access properties directly instead of using .get()
		var title = product.title if product.title else fallback
		var price = product.display_price if product.display_price else ""
		#if price != "":
			#button.text = "%s - %s" % [title, price]
		#else:
			#button.text = title
	#else:
		#button.text = fallback
