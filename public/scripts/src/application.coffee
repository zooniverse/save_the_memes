loadKey = (key) ->
 	unescape(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + escape(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1")) || false

$ ->
	$.scrollIt()
	
	# Some nice references.
	form = $('#generate-form').get(0)
	imageContainer = $('#image-container')
	imageUrlInput = $('#image-url')
	downloadButton = $('#download')


	# Show four perks. For now.
	while $('.perk-slider li.active').length < 4
		randomElement = Math.floor(Math.random() * $('.perk-slider li:not(.active)').length)
		$('.perk-slider li:not(.active)').eq(randomElement).addClass 'active'


	# Configure meme form.
	if (url = loadKey('u')) and (url.indexOf 'www.snapshotserengeti.org')
		img = new Image
		img.onload = ->
			imageContainer.html img
			imageUrlInput.css 'display', 'none'
			imageUrlInput.val url
		img.src = url

	else
		console.log 'no valid url'


	# Callback for generator form.
	handleGenerate = (e) ->
		e.preventDefault()

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


	# Register form callbacks.
	$('#generate').on 'click', handleGenerate
	$('#generate-form input').keypress (e) ->
		if e.which is 13
			e.preventDefault()
			handleGenerate e

	isHappy = true
	happyStoryBackground = $('#happy-story-background')
	sadStoryBackground = $('#sad-story-background')
	storyButton = $('#lets-watch')

	# Switch story
	storyButton.on 'click', (e) ->

		if isHappy
			happyStoryBackground.fadeOut 700
			sadStoryBackground.fadeIn 700
			isHappy = false
			storyButton.html 'Oh No!'

		else
			happyStoryBackground.fadeIn 700
			sadStoryBackground.fadeOut 700
			isHappy = true
			storyButton.html 'Let\'s Watch!'

	# Move navigation bar around
	$(window).on 'scroll', (e) ->

		navigation = $('#navigation')

		if $(window).scrollTop() > '800'
			navigation.css
				"position": "fixed"
				"top": "0"

		else
			navigation.attr 'style', ''
