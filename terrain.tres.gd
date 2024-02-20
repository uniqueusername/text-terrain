extends GridContainer

@export var cols: int = columns
@export var rows: int = 40
@export var threshold = 0.5
@export var animate: bool = false

var label_settings = preload("res://menlo.tres")
@onready var heights: Image = generate_terrain()
@onready var grass: Image = generate_grass()

func _ready():
	render_terrain(heights, grass, 0.5)

func _process(delta):
	if animate: render_terrain(heights, grass, 0.1*sin(Time.get_ticks_msec()/1000.0)+0.2)
	
func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		heights = generate_terrain()
		grass = generate_grass()
		render_terrain(heights, grass, 0.5)
	
func generate_terrain():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi_range(1, 1000)
	noise.frequency = 0.02
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 1
	
	noise.domain_warp_enabled = true
	noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_BASIC_GRID
	noise.domain_warp_amplitude = 5
	noise.domain_warp_frequency = 3.92
	noise.domain_warp_fractal_octaves = 1
	
	return noise.get_image(cols, rows)

func generate_grass():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi_range(1, 1000)
	noise.frequency = 0.075
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	
	noise.domain_warp_enabled = true
	noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_BASIC_GRID
	noise.domain_warp_amplitude = 5
	noise.domain_warp_frequency = 5
	
	return noise.get_image(cols, rows)

func render_terrain(heights: Image, grass: Image, water_height: float):
	for child in get_children():
		child.queue_free()
	
	for i in range(rows):
		for j in range(cols):		
			var cell = Label.new()
			cell.label_settings = label_settings
			
			var value = heights.get_pixel(j, i).r
			if value > threshold*1.1:
				cell.text = "A"
				var greyness = randf_range(0.6, 1.0)
				cell.modulate = Color(greyness, greyness, greyness+0.1)
			elif value > threshold*0.9:
				var letter = randi_range(0, 1)
				if letter == 0: cell.text = "O"
				else: cell.text = "D"
				var brownnness = randf_range(0.6, 0.7)
				cell.modulate = Color(brownnness, brownnness-0.2, brownnness-0.2)
			elif value > threshold*0.6:
				cell.text = "o"
				var brownnness = randf_range(0.4, 0.6)
				cell.modulate = Color(brownnness, brownnness-0.1, brownnness-0.1)
			elif value > threshold*0.3:
				cell.text = "i"
				var brownnness = randf_range(0.4, 0.6)
				cell.modulate = Color(brownnness, brownnness-0.2, brownnness-0.2)
			else: 
				cell.text = ":"
				var brownnness = randf_range(0.3, 0.4)
				cell.modulate = Color(brownnness, brownnness-0.2, brownnness-0.2)
			
			var grass_value = grass.get_pixel(j, i).r
			if value < threshold*0.9 and grass_value < 0.45:
				var greennness = randf_range(0.7, 0.9)
				var caps = randi_range(0, 1)
				if caps == 0:	cell.text = "n"
				else: cell.text = "N"
				cell.modulate = Color(0.0, greennness, 0.0)
				
			if value < threshold*water_height:
				cell.modulate = Color(cell.modulate.r/2-0.3, cell.modulate.g/1.7-0.3, 0.5)
			
			add_child(cell)
