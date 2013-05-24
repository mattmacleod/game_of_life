@app = 
	config:
		color_active: "#ff0066"
		color_inactive: "#eeeeee"
		grid_width: 500
		grid_height: 300
		cell_size: 10
		
	setup: ->
		app.game.setup()
		app.controls.setup()

$(document).on "ready", app.setup
