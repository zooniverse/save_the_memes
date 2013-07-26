$ ->
	$.scrollIt()
	
	while $('.perk-slider li.active').length < 4
		randomElement = Math.floor(Math.random() * $('.perk-slider li:not(.active)').length)
		$('.perk-slider li:not(.active)').eq(randomElement).addClass 'active'

	handleGenerate = (e) ->
		e.preventDefault()

		form = $('#generate-form').get(0)
		imageContainer = $('#image-container')
		downloadButton = $('#download')

		request = $.ajax
			type: 'POST'
			url: '/'
			data:
				url: form[0].value
				topText: form[1].value
				bottomText: form[2].value

		imageContainer.html ''
		loading = new Spinner().spin imageContainer.get(0)

		request.done ({url}) ->
			img = new Image
			img.onload = ->
				loading.stop()
				imageContainer.html img
				downloadButton.show()
				downloadButton.parent().first().attr 'href', url

			img.src = url

			console.log 'request success'
		request.fail ->
			console.log 'failure'
		request.always ->
			console.log 'always'

	$('#generate').on 'click', handleGenerate
	$('#generate-form input').keypress (e) ->
		if e.which is 13
			e.preventDefault()
			handleGenerate e

	# Move navigation bar around
	$(window).on 'scroll', (e) ->

		navigation = $('#navigation')

		if $(window).scrollTop() > '800'
			navigation.css
				"position": "fixed"
				"top": "0"

		else
			navigation.attr 'style', ''
