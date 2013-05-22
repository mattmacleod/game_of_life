@app = 
	config:
		color_active: "#ff0066"
		color_inactive: "#eeeeee"
		
	setup: ->
		app.game.setup()
		app.controls.setup()

$(document).on "ready", app.setup
