express = require('express')
app = express()
server = require('http').createServer(app)
fs = require 'fs'
async = require 'async'
request = require 'request'
_ = require 'underscore'
config = require '../config'
roundRobot = require('node-sphero')
sphero = new roundRobot.Sphero()
twitter = require('ntwitter')

twit = new twitter
	consumer_key: config.twitter.consumerKey,
	consumer_secret: config.twitter.consumerSecret,
	access_token_key: config.twitter.accessTokenKey,
	access_token_secret: config.twitter.accessTokenSecret

tasks = []
text = []
current = {
	red : 0,
	blue : 0,
	green : 0
}
balls = []

sphero.on 'connected', (ball) ->

	ball.current = {
		red : 0,
		blue : 0,
		green : 0
	}
	ball.sentiment = {
		negative : 0,
		positive : 0,
		neutral : 0
	}

	balls.push ball

	console.log 'CONNECTED ---> ', balls.length + ' sphero(s) connected'

	requestInterval = setInterval () ->
		fetch()
	, 5000

fade  = (red, green, blue, speed, ball) ->
	if requestInterval?
		clearInterval(requestInterval)
		
	speed = speed ? 100
	step = 0
	fadeInterval = setInterval () ->
		if ball.current.red is red and
			ball.current.green is green and 
			ball.current.blue is blue
				clearInterval(fadeInterval)
				requestInterval = setInterval () ->
					fetch()
				, 5000

		# console.log ball.current.red, ball.current.green, ball.current.blue
		if ball.current.red < red
			 ball.current.red++
		else if  ball.current.red > red
			ball.current.red--

		if ball.current.green < green
			ball.current.green++
		else if ball.current.green > green
			ball.current.green--

		if ball.current.blue < blue
			ball.current.blue++
		else if ball.current.blue > blue
			ball.current.blue--
		
		if step is 3
			step = 0
			ball.setRGBLED(ball.current.red, ball.current.green, ball.current.blue, false)
		step++
	, speed

fetch = () ->

	for i in [0...5]
		t = text[i]
		do (t) ->
			tasks.push (cb) ->
				request 'http://access.alchemyapi.com/calls/text/TextGetTextSentiment?apikey='+config.alchemy.apiKey+'&outputMode=json&text='+t, (err, response, body) ->
					res = JSON.parse(body)
					console.log res
					if res.status is 'ERROR' or res.docSentiment.type is 'neutral'
						cb()
						return

					randomBall = balls[Math.floor(Math.random() * balls.length)]
					randomBall.sentiment = {
						negative : 0,
						positive : 0,
						neutral : 0
					}
					randomBall.sentiment[res.docSentiment.type]++

					cb()

	async.series tasks, () ->
		console.log 'done'
		
		if balls.length
			console.log balls.length
			for i in [0...balls.length]
				sort = []
				ball = balls[i]
				for i of ball.sentiment
					sort.push([i,ball.sentiment[i]])

				sort.sort (a, b) ->
					return a[1] - b[1]
				sort.reverse()
				s = sort[0][0]
				console.log sort

		
				if s is 'negative'
					fade(255, 0, 0, 50, ball)
				else if s is 'neutral'
					fade(255, 255, 255, 50, ball)
				else
					fade(0, 255, 0, 50, ball)

			text = []
			tasks = []

twit.stream 'statuses/sample', {}, (stream) ->

	stream.on 'data',  (data) ->
		text.push data.text

sphero.connect()

server.on 'disconnect', () ->
	console.log 'DISCONNECT'
	for i in [0...balls.length]
		balls[i].disconnect()

port = process.env.PORT or 3000
server.listen port, () -> 
  console.log "Server running on port " + port
  console.log 'waiting for Sphero to connect...'

