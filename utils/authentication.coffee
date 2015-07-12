jwt = require 'jwt-simple'

User = require '../models/User'
config = require '../config'

generateToken = (user) ->
    payload =
        id: user.id
        username: user.username
        isd: Math.floor Date.now() / 1000
        exp: Math.floor (Date.now() + config.tokenExpirationDelay)/1000
    return jwt.encode payload, config.tokenSecret, 'HS256'

formatUser = (user) ->
    result =
        username: user.username
    return result

module.exports = (app) ->
    # Handle authentication
    app.post '/login', (req, res) ->
        return res.status(400).json err: 'invalid parameters' unless req.body.username and req.body.password
        User.findOne username:req.body.username, (err, user) ->
            if err then return res.status(401).json err: 'invalid credentials'
            user.verifyPassword req.body.password, (err, isMatch) ->
                if err then return req.internalError(msg: 'Failed to check password')
                if isMatch
                    token = generateToken user
                    result =
                        user: formatUser user
                        token: token
                        exp: Math.floor (Date.now() + config.tokenExpirationDelay)/1000
                    res.json result
                else
                    res.status(401).json err: 'invalid credentials'


    app.post '/register', (req, res) ->
        User.create username: req.body.username, password: req.body.password, (err, user) ->
            if err then return res.status(400).send()
            res.send formatUser user

    return app