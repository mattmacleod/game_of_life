app.controls = 
	
	setup: ->

		$("#step_button").on "click", ->
			button = $(this)
			button.addClass "on"
			app.game.step()
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


		$("#clear_button").on "click", ->
			app.game.clear_grid()


		$("#randomize_button").on "click", ->
			app.game.randomize()