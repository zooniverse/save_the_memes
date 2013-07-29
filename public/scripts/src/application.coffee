loadKey = (key) ->
 	unescape(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + escape(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1")) || false

formatNumber = (n) ->
  return n unless n
  n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

# Courtesy of http://bost.ocks.org/mike/shuffle/
Array::shuffle = ->
	m = @length

	while m
		i = Math.floor(Math.random() * m--)

		t = @[m]
		@[m] = @[i]
		@[i] = t

	@

serengetiImages = [
	'http://www.snapshotserengeti.org/subjects/standard/51e904fee0053a09c30b735c_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51a39bcfe18f49172b19777c_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51a332d6e18f49172b0cfe6f_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51e8ed42e0053a09c308b433_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51e8a9afe0053a09c300ea30_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51a3528ae18f49172b10c2b2_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/51a37abae18f49172b15876b_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c214508a607540b9038e41_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c213e98a607540b9033aff_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c2104f8a607540b90033c4_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c2163b8a607540b904f94b_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c219198a607540b9071e73_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c217ce8a607540b90627be_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c211e68a607540b90187a0_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c2113a8a607540b900f706_0.jpg'
	'http://www.snapshotserengeti.org/subjects/standard/50c217708a607540b905d640_0.jpg'
].shuffle()

CAMPAIGN_PROGRESS = 6900
CAMPAIGN_TOTAL = 33000

$ ->
	$.scrollIt()
	
	# Some nice references.
	form = $('#generate-form').get(0)
	imageContainer = $('#image-container')
	imageUrlInput = $('#image-url')
	downloadButton = $('#download')
	progressContainer = $('#progress-container')
	progressAmount = $('#progress-amount')


	# Set progress meter height
	setMeter = (campaignProgress) ->
		progressContainer.css 'height', ((campaignProgress / CAMPAIGN_TOTAL) * 100) + '%'
		progressAmount.html formatNumber campaignProgress

	window.callback = (campaignProgress) ->
		unless typeof campaignProgress is 'boolean'
			setMeter Number(campaignProgress.replace(/[^0-9\.]+/g,""))
		else
			setMeter CAMPAIGN_PROGRESS

	$.ajax
		url: 'http://indy-go-go.herokuapp.com/'
		dataType: 'jsonp'


	# Show four perks. For now.
	while $('.perk-slider li.active').length < 4
		randomElement = Math.floor(Math.random() * $('.perk-slider li:not(.active)').length)
		$('.perk-slider li:not(.active)').eq(randomElement).addClass 'active'


	# Configure meme form.
	if (url = loadKey('u')) and (url.indexOf 'www.snapshotserengeti.org')
		stage = $('#stage-two')
		img = new Image
		img.onload = ->
			imageContainer.html img
			imageUrlInput.val url
		img.src = url

	else
		stage = $('#stage-one')

		fragment = document.createDocumentFragment()
		for i in [0..11]
			img = new Image
			img.src = serengetiImages[i]
			
			column = document.createElement('div')
			column.className = 'column'
			column.appendChild img

			fragment.appendChild column

		$('#preset-images').append fragment

		stage.on 'click', 'img', (e) ->
			newStage = $('#stage-two')
			stage.hide()
			newStage.show()

			imageContainer.html e.currentTarget
			imageUrlInput.val e.currentTarget.src

	stage.show()


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

		request.fail ->
			imageContainer.html '<span>error :(</span>'


	# Register form callbacks.
	$('#generate').on 'click', handleGenerate
	$('#generate-form input').keypress (e) ->
		if e.which is 13
			e.preventDefault()
			handleGenerate e


	# Switch story
	isHappy = true
	happyStoryBackground = $('#happy-story-background')
	sadStoryBackground = $('#sad-story-background')
	storyButton = $('#lets-watch')

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
	navigation = $('#navigation')
	$(window).on 'scroll', (e) ->
		if $(window).scrollTop() > '800'
			navigation.css
				"position": "fixed"
				"top": "0"

		else
			navigation.attr 'style', ''
