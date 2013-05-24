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


		$("#clear_button").on "click", ->
			app.game.clear_grid()
			app.game.set_zoom(1)
			app.game.align_grid()
			$("#zoom_slider").val(1)

		$("#randomize_button").on "click", ->
			app.game.randomize()

		# Set zoom slider values
		zoom_attrs = 
			min: 0.3
			max: 2
			step: 0.1
			value: 1

		$("#zoom_slider").attr(zoom_attrs).on "change", ->
			app.game.set_zoom $(this).val()