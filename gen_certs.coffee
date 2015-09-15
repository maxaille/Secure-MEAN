pem = require 'pem'
fs = require 'fs'
exec = require('child_process').execSync

pem.config
    pathOpenSSL: process.env.OPENSSL_PATH || '/usr/bin/openssl'

fs.mkdir './certs' unless fs.existsSync './certs'

pem.config pathOpenSSL: "C:/Program Files/OpenSSL/bin/openssl.exe"
pem.createCertificate days: 3600, selfSigned: true, (err, keys) ->
    if err
        console.log err
        process.exit 1
    fs.writeFile './certs/server.crt', keys.certificate, (err) ->
        if err then process.exit 1
    fs.writeFile './certs/server.key', keys.serviceKey, (err) ->
        if err then process.exit 1
