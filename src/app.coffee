express = require('express')
app = express()
server = require('http').createServer(app)
passport = require 'passport'
config = require './config/config'
fs = require 'fs'
async = require 'async'
request = require 'request'
_ = require 'underscore'

# Connect to the DB
# mongoose = require 'mongoose'
# mongoose.connect(config.dbURI)

# Models
models = __dirname + '/models'
fs.readdirSync(models).forEach (file) ->
  require(models + '/'  +file)

# Passport Config
require('./config/passport')(passport, config)

# Express Config
require('./config/express')(app, passport)

# Routes
require('./config/routes')(app, passport)

# Socket Events
# io.sockets.on 'connection', (socket) ->
#   socket.emit 'hello', {data : 'Hi!'}
roundRobot = require('node-sphero')
sphero = new roundRobot.Sphero()
twitter = require('ntwitter')
twit = new twitter
	consumer_key: '8hGJaqkwHDwWvDRJfRxjg',
	consumer_secret: 'EG7QU6IQ492SJ93VKKdAsUYpQL3L955WY4mINjWmo',
	access_token_key: '121854213-5F2uJ8Ulu1xTXLy1qnwvG9PmWWkVvm0wXB0raHpS',
	access_token_secret: 'R3j49Sk5i0mpziJtK8ea39uUYTC2vfL6yK6OehHKZ7w'

sentiment = {
	negative : 0,
	positive : 0,
	neutral : 0
}
tasks = []
text = []

current = {
	red : 0,
	blue : 0,
	green : 0
}

requestInterval = false

sphero.on 'connected', (ball) ->

	console.log 'CONNECTED'
	fade  = (red, green, blue, speed) ->
		clearInterval(requestInterval)
		speed = speed ? 100
		step = 0
		fadeInterval = setInterval () ->
			if current.red is red and
				current.green is green and 
				current.blue is blue
					clearInterval(fadeInterval)
					requestInterval = setInterval () ->
						fetch()
					, 5000
			console.log current.red, current.green, current.blue
			if current.red < red
				current.red++
			else if current.red > red
				current.red--

			if current.green < green
				current.green++
			else if current.green > green
				current.green--

			if current.blue < blue
				current.blue++
			else if current.blue > blue
				current.blue--
			
			if step is 3
				step = 0
				ball.setRGBLED(current.red, current.green, current.blue, false)
			step++
		, speed

	fetch = () ->

		for i in [0...5]
			t = text[i]
			do (t) ->
				tasks.push (cb) ->
					request 'http://access.alchemyapi.com/calls/text/TextGetTextSentiment?apikey=c66401c4852d9fd88e7f66657056f3fabbb7680e&outputMode=json&text='+t, (err, response, body) ->
						res = JSON.parse(body)
						if res.status is 'ERROR' or res.docSentiment.type is 'neutral'
							cb()
							return

						sentiment[res.docSentiment.type]++
						cb()

		async.series tasks, () ->
			console.log 'done'
			sort = []
			for i of sentiment
				sort.push([i,sentiment[i]])

			sort.sort (a, b) ->
				return a[1] - b[1]
			sort.reverse()
			s = sort[0][0]
			console.log sort

			if s is 'negative'
				fade(255, 0, 0, 50)
			else if s is 'neutral'
				fade(255, 255, 255, 50)
			else
				fade(0, 255, 0, 50)

			text = []
			tasks = []
			sentiment = {
				negative : 0,
				positive : 0,
				neutral : 0
			}

	# twit.stream 'statuses/sample', {}, (stream) ->

	# 	stream.on 'data',  (data) ->
	# 		text.push data.text

	# requestInterval = setInterval () ->
	# 	fetch()
	# , 5000

	# TEST
	fadeTest  = (red, green, blue, speed) ->

		speed = speed ? 100
		step = 0
		fadeInterval = setInterval () ->
			if current.red is red and
				current.green is green and 
				current.blue is blue
					clearInterval(testInterval)
					testInterval = setInterval () ->
						fade(test[Math.floor(Math.random() * test.length)], test[Math.floor(Math.random() * test.length)], test[Math.floor(Math.random() * test.length)], 50)
					, 1000
			console.log current.red, current.green, current.blue
			if current.red < red
				current.red++
			else if current.red > red
				current.red--

			if current.green < green
				current.green++
			else if current.green > green
				current.green--

			if current.blue < blue
				current.blue++
			else if current.blue > blue
				current.blue--
			
			if step is 3
				step = 0
				ball.setRGBLED(current.red, current.green, current.blue, false)
			step++
		, speed

	test = [255, 0]

	testInterval = setInterval () ->
		fade(test[Math.floor(Math.random() * test.length)], test[Math.floor(Math.random() * test.length)], test[Math.floor(Math.random() * test.length)], 50)
	, 1000

sphero.connect()

port = process.env.PORT or 1333
server.listen port, () -> 
  console.log "Server running on port " + port

