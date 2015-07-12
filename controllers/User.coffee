User = require '../models/User'

routes =
    '/users': [
            type: 'post'
            isAuth: true
            fn: (req, res) ->
                user = new User
                    username: req.body.username
                    password: req.body.password

                user.save (err) ->
                    if err then return res.send (err)
                    res.json user
        ,
            type: 'get'
            isAuth: true
            fn: (req, res) ->
                User.find (err, users) ->
                    if err then return res.send err
                    res.json users
    ]

module.exports = routes