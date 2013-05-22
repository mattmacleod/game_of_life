app.game =

	setup: ->
		@get_dimensions()
		@create_context()
		@create_grid()
		@clear_grid()
		@setup_event_handlers()
		@randomize()
		@start_animation_loop()

	get_dimensions: ->
		@width  = $("#grid").width()
		@height = $("#grid").height()
		@cols   = Math.floor (@width / 10)-1
		@rows   = Math.floor (@height / 10)-1

	create_context: ->
		@canvas = $("#main_canvas")
		@canvas.attr "width", $("#grid").width()
		@canvas.attr "height", $("#grid").height()
		@context = @canvas[0].getContext '2d'

	create_grid: ->
		@grid = new Array @cols
		for x in [0..@cols]
			@grid[x] = new Array @rows
			for y in [0..@rows]
				@grid[x][y] = false

	clear_grid: ->
		for x in [0..@cols]
			for y in [0..@rows]
				@clear_cell x, y

	toggle_cell: (x, y) ->
		@grid[x][y] = !@grid[x][y]
		@refresh_cell x, y

	set_cell: (x, y) ->
		@grid[x][y] = true
		@refresh_cell x, y

	clear_cell: (x, y) ->
		@grid[x][y] = false
		@refresh_cell x, y

	refresh_cell: (x, y) ->
		xy = @grid_to_xy x, y
		@context.fillStyle = if @grid[x][y] then app.config.color_active else app.config.color_inactive
		@context.fillRect xy.x, xy.y, 10, 10
		
	xy_to_grid: (x,y) ->
		x: Math.floor(x/10)
		y: Math.floor(y/10)

	grid_to_xy: (x,y) ->
		x: x*10
		y: y*10

	step: ->

		# Build an array to contain neighbour counts for each cell
		neighbour_counts = new Array @cols
		for x in [0..@cols]
			neighbour_counts[x] = new Array @rows
			for y in [0..@rows]
				neighbour_counts[x][y] = 0

		# Examine each cell. If it is active, then increment neighbour counter
		# of all surrounding cells.
		for x in [0..@cols]
			for y in [0..@rows]
				if @grid[x][y]
					neighbour_counts[ x + 1 ][ y + 1 ]++  if x < @cols && y < @rows
					neighbour_counts[ x     ][ y + 1 ]++  if y < @rows
					neighbour_counts[ x - 1 ][ y + 1 ]++  if x > 0 && y < @rows
					neighbour_counts[ x - 1 ][ y     ]++  if x > 0
					neighbour_counts[ x - 1 ][ y - 1 ]++  if x > 0 && y > 0
					neighbour_counts[ x     ][ y - 1 ]++  if y > 0
					neighbour_counts[ x + 1 ][ y - 1 ]++  if x < @cols && y > 0
					neighbour_counts[ x + 1 ][ y     ]++  if x < @cols

		# Toggle activity state of cells based on life rules
		# Any live cell with fewer than two live neighbours dies
		# Any live cell with two or three live neighbours lives
		# Any live cell with more than three live neighbours dies
		# Any dead cell with exactly three live neighbours becomes a live cell
		for x in [0..@cols]
			for y in [0..@rows]
				currently_active = @grid[x][y]
				neighbour_count  = neighbour_counts[x][y]
				if currently_active
					if neighbour_count < 2 || neighbour_count > 3
						@clear_cell x, y
				else if neighbour_count == 3
					@set_cell x, y


	# Hack in a requestAnimationFrame event
	start_animation_loop: ->
		requestAnimationFrame        = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
		window.requestAnimationFrame = requestAnimationFrame

		(stepper = _.throttle ->
			app.game.step() if $("#auto_button").hasClass("on")
			requestAnimationFrame stepper
		, 100
		).call()


	# Populate the game grid with random cells
	randomize: ->
		for x in [0..@cols]
			for y in [0..@rows]
				if Math.random() > 0.5
					@set_cell x, y

	setup_event_handlers: (rect) ->
		
		canvas_position = @canvas.offset()
		canvas_position_from_event = (e) =>
			x: e.pageX - canvas_position.left
			y: e.pageY - canvas_position.top

		grid_position_from_event = (e) =>
			event_position = canvas_position_from_event e
			@xy_to_grid event_position.x, event_position.y

		@canvas.on "mousedown", (e) =>
			grid_xy       = grid_position_from_event e
			toggled_cells = [grid_xy]

			@toggle_cell grid_xy.x, grid_xy.y
			active = @grid[grid_xy.x][grid_xy.y]

			@canvas.on "mousemove", (e2) =>
				move_xy = grid_position_from_event e2
				debugger
				if ! (_.contains toggled_cells, move_xy)
					toggled_cells.push move_xy
					if active
						app.game.set_cell move_xy.x, move_xy.y
					else
						app.game.clear_cell move_xy.x, move_xy.y


		$(window).on "mouseup mouseout", =>
			@canvas.off "mousemove"