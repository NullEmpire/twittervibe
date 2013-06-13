This is an experiment with Node.js, Twitter, Sphero and the Alchemy API.

* Pull tweets from the twitter streaming API
* Pass them to the Alchemy API to get the sentiment of the tweet
* Adjust the Sphero color accordingly

### We also tried it with 3 spheros and shoved them into an Ikea lamp

<img src="https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-prn1/936271_384882201628524_1089395683_n.jpg" />

## Resources
* Alchemy API - http://www.alchemyapi.com/
* Sphero - http://www.gosphero.com/

## Development

### Create a file called config.js in the root dir
It should look like this
````javascript
module.exports = {
	twitter : {
		consumerKey : 'your consumer key',
		consumerSecret : 'your consumer secret',
		accessTokenKey : 'your access token key',
		accessTokenSecret : 'your access token secret'
	},
	alchemy : {
		apiKey : 'your api key'
	}
}
````
The following command will watch and compile the Coffeescript.

* run `cake dev`

