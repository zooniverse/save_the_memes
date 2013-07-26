AWS = require 'aws-sdk'
Canvas = require 'canvas'
express = require 'express'
fs = require 'fs'
http = require 'http'
request = require 'request'
shortId = require 'shortid'

Font = Canvas.Font
Image = Canvas.Image

impact = new Font 'Impact', __dirname + '/lib/Impact.ttf'

app = express()

app.use express.bodyParser()
app.use express.static(__dirname + '/public')

allowCrossDomain = (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
    
  if 'OPTIONS' is req.method
    res.send 200
  else
    next()
app.use allowCrossDomain

s3 = new AWS.S3
  accessKeyId: process.env.AMAZON_ACCESS_KEY_ID
  secretAccessKey: process.env.AMAZON_SECRET_ACCESS_KEY
  region: 'us-east-1'

app.post '/', (req, res) ->
	url = req.body.url
	topText = req.body.topText.toUpperCase()
	bottomText = req.body.bottomText.toUpperCase()

	request.head url, (err, response, body) ->
		if response.headers['content-length'] < 500000
			id = shortId.generate()

			originalImage = __dirname + '/uploads/' + id + '.jpg'
			ws = fs.createWriteStream originalImage
			r = request(url).pipe(ws)

			r.on 'finish', ->
				# Do meme stuff
				img = new Image

				img.onload = ->
					w = img.width
					h = img.height

					canvas = new Canvas w, h
					ctx = canvas.getContext '2d'
					ctx.addFont impact
					ctx.drawImage img, 0, 0, w, h, 0, 0, w, h

					ctx.font = '80px Impact bold'
					ctx.textAlign = 'center'
					ctx.textBaseline = 'middle'
					ctx.strokeStyle = 'black'
					ctx.lineWidth = 10
					ctx.fillStyle = 'white'

					ctx.strokeText topText, w / 2, 65 
					ctx.fillText topText, w / 2, 65

					ctx.strokeText bottomText, w / 2, h - 73
					ctx.fillText bottomText, w / 2, h - 73

					memedImage = __dirname + '/uploads/' + id + '-memed.jpg'
					out = fs.createWriteStream memedImage
					canvasStream = canvas.jpegStream()

					canvasStream.on 'data', (chunk) ->
						out.write chunk

					canvasStream.on 'end', ->
						setTimeout -> # this seems bad
							s3.putObject
								Bucket: 'www.snapshotserengeti.org'
								Key: 'meme/' + id + '.jpg'
								Body: fs.readFileSync memedImage
								(err, data) ->
									if err
										res.send 400
									else
										res.send 200, {url: "http://www.snapshotserengeti.org/meme/#{ id }.jpg"}
										fs.unlinkSync memedImage
										fs.unlinkSync originalImage
						, 100

				img.src = __dirname + '/uploads/' + id + '.jpg'

		else
			res.send 'too big file'
	# img = new Image

	# img.onload = ->

	# 	canvas = new Canvas 200,200
	# 	ctx = canvas.getContext '2d'

	# 	ctx.drawImage img, 0, 0, img.width / 4, 0, 0, img.height / 4

	# 	res.send 200

	# img.src = test

port = process.env.PORT || 3003
app.listen port, ->
  console.log "HELLO FROM PORT #{ port }"