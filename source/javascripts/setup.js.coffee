@app = 

	setup: ->
		app.playarea.setup()

$(document).on "ready", app.setup
