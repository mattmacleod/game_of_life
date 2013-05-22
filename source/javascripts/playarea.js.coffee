app.playarea =

	setup: ->
		console.log "Setting up playarea..."
		@create_context()
		@create_grid()
		@clear_grid()
		@preload()
		@auto()
		@setup_buttons()

	create_context: ->
		@width = $("#playarea").width()
		@height = $("#playarea").height()
		@context = Raphael( $("#playarea").offset().left, $("#playarea").offset().top, @width, @height)

	create_grid: ->
		cols = Math.floor (@width / 10)-1
		rows = Math.floor (@height / 10)-1

		@grid = new Array(cols)

		for x in [0..cols]
			@grid[x] = new Array(rows)
			for y in [0..rows]
				rect = @context.rect x*10, y*10, 10, 10
				@setup_handlers rect
				rect.click app.playarea.handle_mouse
				rect.attr "stroke", "none"
				@grid[x][y] = 
					rect: rect
					active: false

	clear_grid: ->
		for col in @grid
			@clear_cell cell for cell in col
				

	setup_handlers: (rect) ->
		rect.click (e) ->
			xy = app.playarea.xy_to_grid e.layerX, e.layerY
			app.playarea.toggle_cell app.playarea.grid[xy.x][xy.y]
			app.playarea.refresh_cell app.playarea.grid[xy.x][xy.y]
		
		rect.mousedown (e) ->
			xy = app.playarea.xy_to_grid e.layerX, e.layerY
			cell = app.playarea.grid[xy.x][xy.y]
			active = !cell.active

	xy_to_grid: (x,y) ->
		x: Math.floor(x/10)
		y: Math.floor(y/10)

	toggle_cell: (cell) ->
		cell.active = !cell.active
		@refresh_cell cell

	activate_cell: (cell) ->
		cell.active = true
		@refresh_cell cell

	clear_cell: (cell) ->
		cell.active = false
		@refresh_cell cell

	refresh_cell: (cell) ->
		if cell.active
			cell.rect.attr "fill", "#f00"
		else
			cell.rect.attr "fill", "#eee"
		
	step: ->
		console.log "step"
		# Calculate neighbour count for each cell
		cols = Math.floor (@width / 10)-1
		rows = Math.floor (@height / 10)-1

		# Create neighbour array
		neighbours = new Array(rows)
		for x in [0..cols]
			neighbours[x] = new Array(rows)
			for y in [0..rows]
				neighbours[x][y] = 0

		# Loop through each cell and increment neighbouring cells'
		# neighbour count if active
		for x in [0..cols]
			for y in [0..rows]
				if @grid[x][y].active
					neighbours[x+1][y+1]++ if x<cols && y<cols
					neighbours[x][y+1]++ if y<cols
					neighbours[x-1][y+1]++ if x>0 && y<cols
					neighbours[x-1][y]++ if x>0
					neighbours[x-1][y-1]++ if x>0 && y>0
					neighbours[x][y-1]++ if y>0
					neighbours[x+1][y-1]++ if x<cols && y>0
					neighbours[x+1][y]++ if x<cols

		# Toggle activity state of cells based on life rules
		# Any live cell with fewer than two live neighbours dies, as if caused by under-population.
		# Any live cell with two or three live neighbours lives on to the next generation.
		# Any live cell with more than three live neighbours dies, as if by overcrowding.
		# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
		for x in [0..cols]
			for y in [0..rows]
				cell = @grid[x][y]
				neighbour_count = neighbours[x][y]
				if cell.active
					if neighbour_count < 2
						@toggle_cell cell
					else if neighbour_count > 3
						@toggle_cell cell
				else if neighbour_count == 3
					@toggle_cell cell


	auto: ->
		requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
		window.requestAnimationFrame = requestAnimationFrame

		stepper = ->
			if $("#auto_button").hasClass("on")
				app.playarea.step()
			requestAnimationFrame stepper

		stepper()

	preload: ->
		for col in @grid
			for cell in col
				if Math.random() > 0.5
					@activate_cell cell

	setup_buttons: ->

		$("#step_button").on "click", ->
			button = $(this)
			button.addClass "on"
			app.playarea.step()
			button.addClass "transition"
			_.delay ->
				button.removeClass "on"
			, 100

		$("#auto_button").on "click", ->
			button = $(this)
			button.toggleClass "on"
			if button.hasClass "on"
				button.text "Auto on"
			else
				button.text "Auto off"
