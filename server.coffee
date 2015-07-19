fs = require 'fs'
app = require './app'
console = require 'better-console'
conf = require './config'

if !conf.httpsOnly then http = require 'http'
https = require 'https'

onError = (error) ->
    if error.syscall != 'listen'
        throw error

    bind = 'Port ' + this.address().port

    switch error.code
        when 'EACCES'
            console.error(bind + ' requires elevated privileges')
            process.exit(1)
            break
        when 'EADDRINUSE'
            console.error(bind + ' is already in use')
            process.exit(1)
            break
        else
            throw error

if !conf.httpsOnly
    port = process.env.PORT || conf.port || 3000
    app.set 'port', port
    server = http.createServer app
    server.listen port
    server.on 'error', onError
    server.on 'listening',  ->
        console.info 'HTTP server listening on port ' + port


# Set certificates for HTTPS
options =
    key: fs.readFileSync './certs/server.key'
    cert: fs.readFileSync './certs/server.crt'

HTTPS_port = process.env.HTTPS_PORT || conf.HTTPS_port || 3001
app.set 'HTTPS_port', HTTPS_port

HTTPS_server = https.createServer options, app
HTTPS_server.listen HTTPS_port
HTTPS_server.on 'error', onError
HTTPS_server.on 'listening', ->
    console.info 'HTTPS server listening on port ' + HTTPS_port

