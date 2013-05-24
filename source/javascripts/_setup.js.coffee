@app = 
	config:
		color_active: "#ff0066"
		color_inactive: "#eeeeee"
		grid_size: 400
		
	setup: ->
		app.game.setup()
		app.controls.setup()

$(document).on "ready", app.setup
