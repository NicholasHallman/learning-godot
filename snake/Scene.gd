extends Node2D

var apple = {
	x = 0,
	y = 0
};

var window = {
	width = floor(ProjectSettings.get_setting("display/window/size/viewport_width") / 40),
	height = floor(ProjectSettings.get_setting("display/window/size/viewport_height") / 40),
};

var snake_node;
var apple_node;
var gameover_node;
var win_node;
var tick_aggr = 0;
var state = "play";
var just_ate = false;
var direction = {
	x = 0,
	y = 1
};

var rng = RandomNumberGenerator.new();
var snake_positions = [{x = 0, y = 0}];
# Called when the node enters the scene tree for the first time.
func _ready():
	snake_positions[0].x = floor(window.width / 2);
	snake_positions[0].y = floor(window.height / 2);
	apple.x = rng.randi_range(0, window.width - 1);
	apple.y = rng.randi_range(0, window.height - 1);
	
	snake_node = self.get_child(0);
	apple_node = self.get_child(1);
	gameover_node = self.get_child(2);
	win_node = self.get_child(3);
	render()
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		print(event.physical_keycode)
		match event.physical_keycode:
			4194320: 
				direction.y = -1
				direction.x = 0
			4194321:
				direction.y = 0
				direction.x = 1
			4194322:
				direction.y = 1
				direction.x = 0
			4194319:
				direction.y = 0
				direction.x = -1
			_:
				pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tick_aggr += delta;
	if(tick_aggr > max(.5 - ((len(snake_positions) * 1.0) / 50), .02) && state == "play"):
		logic();
		render();
		tick_aggr = 0;

func logic():
	var new_pos = {
		x = snake_positions[0].x + direction.x,
		y = snake_positions[0].y + direction.y
	};

	snake_positions.push_front(new_pos);
		# handle snake touching apple
	if new_pos.x == apple.x && new_pos.y == apple.y:
		if len(snake_positions) == window.width * window.height:
			state = "gameover"
			win_node.visible = true;
			return;
		var body_node = snake_node.get_child(0);
		snake_node.add_child(body_node.duplicate());
		place_apple();
	else:
		snake_positions.pop_back();
	
	# handle game over case
	if out_of_bounds(new_pos) || ate_itself():
		state = "gameover"
		gameover_node.visible = true;

func render():
	for snake_pos_i in range(len(snake_positions)):
		var pos = snake_positions[snake_pos_i]
		snake_node.get_child(snake_pos_i).position = Vector2((pos.x * 40), (pos.y * 40));
	apple_node.position = Vector2((apple.x * 40), (apple.y * 40));

func place_apple():
	apple.x = rng.randi_range(0, window.width - 1);
	apple.y = rng.randi_range(0, window.height - 1);
	for snake_pos in snake_positions:
		if apple.x == snake_pos.x && apple.y == snake_pos.y:
			place_apple()
			
func out_of_bounds(new_pos):
	return new_pos.y >= window.height || new_pos.y < 0 || new_pos.x >= window.width || new_pos.x < 0;

func ate_itself():
	var head = snake_positions[0]
	for i in range(len(snake_positions)):
		if i == 0:
			continue;
		var piece = snake_positions[i];
		if piece.x == head.x && piece.y == head.y:
			return true;
	return false;
