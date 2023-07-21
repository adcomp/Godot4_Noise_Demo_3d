extends Node3D

const GRID_SIZE = 50
const MESH_SIZE = 20
const M_HEIGHT = 10

@export var fnoise : FastNoiseLite
@export var grad : GradientTexture1D

@onready var map = $Map
@onready var cam = $CamAxe/Camera3D
@onready var cam_axe = $CamAxe
@onready var cam_ang = $Control/CamAngle
@onready var offset_lbl = $Control/Lbl_Offset

var current_x_offset: int = 0
var current_y_offset: int = 0

var world_ready : bool = false
var direction : Vector2 = Vector2.ZERO
var timer_update : float = 0.0
var speed : float = 0.1 - (50 / 1000.0)

func _ready():
	# init control value
	$Control/Seed.value = fnoise.seed
	$Control/Frequency.value = fnoise.frequency
	$Control/Octaves.value = fnoise.fractal_octaves
	$Control/Lacunarity.value = fnoise.fractal_lacunarity
	$Control/Gain.value = fnoise.fractal_gain
	$Control/Strength.value = fnoise.fractal_weighted_strength
	
	create_world()
	world_ready = true

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	timer_update += delta
	if direction and timer_update > speed:
		timer_update = 0
		
		current_x_offset += direction.x
		current_y_offset += direction.y
		fnoise.offset.x = current_x_offset
		fnoise.offset.y = current_y_offset
		update_world()

func create_world():
	var noise : float
	var tile_instance
	var x : float
	var z : float
	var y : float
	var mat_mesh : StandardMaterial3D
	var new_mesh : MeshInstance3D
	
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			noise = get_noise(i, j)
			if noise < 2:
				y = M_HEIGHT / 2
			else:
				y = round(noise * M_HEIGHT)
			x = i * MESH_SIZE + MESH_SIZE/2
			z = j * MESH_SIZE + MESH_SIZE/2
#			tile_instance = mesh.instantiate()
			new_mesh = MeshInstance3D.new()
			new_mesh.mesh = BoxMesh.new()
			new_mesh.mesh.size = Vector3(MESH_SIZE, 50, MESH_SIZE)
			map.add_child(new_mesh)
			mat_mesh = StandardMaterial3D.new()
			mat_mesh.albedo_color = grad.gradient.get_color(floor(noise))
			new_mesh.mesh.material = mat_mesh
			new_mesh.position = Vector3(x, y, z)
			new_mesh.name = "Tile_" + str(i) + '_' + str(j)

	map.position = Vector3(-GRID_SIZE / 2.0 * MESH_SIZE, 0, -GRID_SIZE / 2.0 * MESH_SIZE)

func update_world():
	var noise : float
	var tile_mesh
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			noise = get_noise(i, j)
			tile_mesh = map.get_node("Tile_" + str(i) + '_' + str(j))
			tile_mesh.mesh.material.albedo_color = grad.gradient.get_color(floor(noise))
			if noise < 2:
				tile_mesh.position.y = M_HEIGHT / 2
			else:
				tile_mesh.position.y = round(noise * M_HEIGHT)
	offset_lbl.text = "Offset X,Y : " + str(current_x_offset) + " , " + str(current_y_offset)

func get_noise(x, y):
#	return s_noise.get_noise_2d(x, y)
	var n = remap(fnoise.get_noise_2d(x, y), -1.0, 1.0, 0.0, 10.0)
	return clampf(n, 0.0, 9.99)

func _on_cam_angle_value_changed(value):
	cam_axe.rotation.x = deg_to_rad(value)

func _on_seed_value_changed(value):
	if world_ready:
		fnoise.seed = value
		update_world()

func _on_frequency_value_changed(value):
	if world_ready:
		fnoise.frequency = value
		update_world()

func _on_octaves_value_changed(value):
	if world_ready:
		fnoise.fractal_octaves = value
		update_world()

func _on_lacunarity_value_changed(value):
	if world_ready:
		fnoise.fractal_lacunarity = value
		update_world()

func _on_gain_value_changed(value):
	if world_ready:
		fnoise.fractal_gain = value
		update_world()

func _on_strength_value_changed(value):
	if world_ready:
		fnoise.fractal_weighted_strength = value
		update_world()

func _on_cam_dist_value_changed(value):
	cam.position.z = value

func _on_bt_up_button_down():
	direction.y = -1

func _on_bt_up_left_button_down():
	direction.y = -1
	direction.x = -1

func _on_bt_up_right_button_down():
	direction.y = -1
	direction.x = 1

func _on_bt_left_button_down():
	direction.x = -1

func _on_bt_right_button_down():
	direction.x = 1

func _on_bt_down_left_button_down():
	direction.y = 1
	direction.x = -1

func _on_bt_down_button_down():
	direction.y = 1

func _on_bt_down_right_button_down():
	direction.y = 1
	direction.x = 1

func _on_bt_up():
	direction = Vector2.ZERO

func _on_speed_value_changed(value):
	speed = 0.1 - (value / 1000.0)
