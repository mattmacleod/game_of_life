app.game =

	generation_counter: 1
	zoom_factor: 1

	# Setup
	###################################################################
	setup: ->
		@get_dimensions()
		@create_context()
		@create_grid()
		@clear_grid()
		@setup_event_handlers()
		@randomize()
		@start_animation_loop()

		# Not clear why this has to be deferred. Need to step through the code.
		_.delay =>
			@align_grid()
		, 10

	get_dimensions: ->
		@width  = $("#grid").width()
		@height = $("#grid").height()
		@cols   = Math.floor (@width / 5)-1
		@rows   = Math.floor (@height / 5)-1

	create_context: ->
		@canvas = $("#main_canvas")
		@canvas.attr "width", @cols * 10
		@canvas.attr "height", @rows * 10
		@canvas.css
			width:  @cols*10
			height: @rows*10
		@context = @canvas[0].getContext '2d'

	create_grid: ->
		@grid = new Array @cols
		for x in [0..@cols]
			@grid[x] = new Array @rows
			for y in [0..@rows]
				@grid[x][y] = false

	align_grid: ->
		left = @canvas.attr("width")/2 - $("#grid").width()/2
		top = @canvas.attr("height")/2 - $("#grid").height()/2
		$("#grid").scrollLeft(left).scrollTop(top)


	# Accessor and display methods
	###################################################################
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
		


	# Calculation methods
	###################################################################
	xy_to_grid: (x,y) ->
		x: Math.floor(x / @zoom_factor / 10)
		y: Math.floor(y / @zoom_factor / 10)

	grid_to_xy: (x,y) ->
		x: x*10
		y: y*10



	# Main evolution method
	###################################################################
	step: ->

		$("#generation_counter").text ++@generation_counter

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




	# Animation methods
	###################################################################
	start_animation_loop: ->
		requestAnimationFrame        = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
		window.requestAnimationFrame = requestAnimationFrame

		(stepper = _.throttle ->
			app.game.step() if $("#auto_button").hasClass("on")
			requestAnimationFrame stepper
		, 100
		).call()



	# Event-handling methods
	###################################################################
	setup_event_handlers: (rect) ->

		@canvas.on "mousedown", (e) =>

			# Get the initial offset of the canvas, and prepare a function
			# which can subsequently be called to convert x,y mouse pointer
			# events into a position on the grid.
			canvas_offset = @canvas.offset()
			grid_position_from_event = (e) =>
				event_position = 
					x: e.pageX - canvas_offset.left
					y: e.pageY - canvas_offset.top
				@xy_to_grid event_position.x, event_position.y

			# This is the cell we moused down on. Add it to the list of toggled
			# cells, then toggle it.
			grid_xy       = grid_position_from_event e
			toggled_cells = [grid_xy]
			@toggle_cell grid_xy.x, grid_xy.y

			# If we initially moused down on an inactive cell, then we're turning
			# cells inactive. Otherwise, we're turning them active.
			active = @grid[grid_xy.x][grid_xy.y]

			# When the mouse is moved, toggle cells if they're not already the
			# correct status. Add all toggled cells to a list, and make sure
			# we only toggle them once.
			@canvas.on "mousemove", (e2) =>
				move_xy = grid_position_from_event e2

				if ! (_.contains toggled_cells, move_xy)
					toggled_cells.push move_xy

					if active
						app.game.set_cell move_xy.x, move_xy.y
					else
						app.game.clear_cell move_xy.x, move_xy.y

		# Whenever a mouse drag leaves the window or stops, then we need to
		# disable our mousemove event.
		$(window).on "mouseup", =>
			@canvas.off "mousemove"


	set_zoom: (factor) ->
		@zoom_factor = factor
		@canvas.css
			width: factor * @canvas.attr("width")
			height: factor * @canvas.attr("height")


	# High-level manipulation methods
	###################################################################
	randomize: ->
		for x in [0..@cols]
			for y in [0..@rows]
				if Math.random() > 0.5
					@set_cell x, y
				else
					@clear_cell x, y

	clear_grid: ->
		for x in [0..@cols]
			for y in [0..@rows]
				@clear_cell x, y
