app.controls = 
	
	setup: ->
		@setup_step()
		@setup_auto()

	setup_step: ->
		$("#step_button").on "click", ->
			button = $(this)
			button.addClass "on"
			app.game.step()
			button.addClass "transition"
			_.delay ->
				button.removeClass "on"
			, 100


	setup_auto: ->
		$("#auto_button").on "click", ->
			button = $(this)
			button.toggleClass "on"
			if button.hasClass "on"
				button.text "Auto on"
			else
				button.text "Auto off"