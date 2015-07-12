console = require 'better-console'
express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
jwt = require 'jwt-simple'

conf = require './config'

app = express()

# *********** DB ***********
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/myApp'
mongoose.connection.once 'open', ->
    console.info 'DB Connected'


# ******* CONFIGURATION *******
app.set 'view engine', 'jade'

app.use methodOverride 'X-HTTP-Method-Override'
app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type'
    next()
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: false
app.use cookieParser()
app.use require('express-session')
    secret: 'lama is love lama is life'
    cookie: maxAge: 600000

# ********** CORS ************
app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type,Authorization'

    next()
app.options "*", (req, res) ->
    res.status(200).send()

# ********** STATIC  **********
app.use express.static path.join(__dirname, 'public/build')

# ******* AUTHENTICATION *******
app = require('./utils/authentication')(app)

# ******* JWT MIDDLEWARE *******
app.get '/api/*', (req, res, next) ->
    #handle jwt
    token = (req.body && req.body.access_token) or
        (req.query && req.query.access_token) or
        req.headers['access-token'] or (req.headers['authorization'] && req.headers['authorization'].split('Bearer ')[1])
    if !token or token and jwt.decode(token, conf.tokenSecret).exp * 1000 < Date.now() then return res.status(401).send()
    next()

# ******** REST *********
controllers = require './controllers'
for controller in controllers
    for route, fns of controller
        route = app.route '/api' + route
        for obj in fns
            # todo: is auth
            route[obj.type] obj.fn


# ******* ERRORS ********
# catch 404 and forward to error handler
app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

app.use (err, req, res) ->
    err.status = err.status or 500
    res.status err.status
    res.render 'error',
        err: {msg: err.message}

module.exports = app