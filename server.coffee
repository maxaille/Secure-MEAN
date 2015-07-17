fs = require 'fs'
app = require './app'
console = require 'better-console'
http = require 'http'
https = require 'https'

conf = require './config'

normalizePort = (val) ->
    port = parseInt val, 10
    if isNaN port
        return val
    if port >= 0
        return port
    return false

onError = (error) ->
    if error.syscall != 'listen'
        throw error

    bind = if typeof port == 'string' then 'Pipe ' + port else 'Port ' + port

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

port = normalizePort process.env.PORT || conf.port || 3000
HTTPS_port = normalizePort process.env.HTTPS_PORT || conf.HTTPS_port || 3001
app.set 'port', port
app.set 'HTTPS_port', HTTPS_port

# Set certificates for HTTPS
options =
    key: fs.readFileSync './certs/server.key'
    cert: fs.readFileSync './certs/server.crt'

server = http.createServer app
HTTPS_server = https.createServer options, app

server.listen port
HTTPS_server.listen HTTPS_port

server.on 'error', onError
HTTPS_server.on 'error', onError

server.on 'listening',  ->
    addr = server.address()
    bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
    console.info 'HTTP server listening on ' + bind
HTTPS_server.on 'listening', ->
    addr = HTTPS_server.address()
    bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
    console.info 'HTTPS server listening on ' + bind

