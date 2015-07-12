model.exports = (req, res, next) ->
    req.internalError = (msg) ->
        res.status(500).json msg: msg