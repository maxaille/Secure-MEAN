pem = require 'pem'
fs = require 'fs'
exec = require('child_process').execSync

if /^win/.test(process.platform)
    openSSLPath = "C:/Program Files/OpenSSL/bin/openssl.exe"
else
    openSSLPath = '/usr/bin/openssl'

pem.config
    pathOpenSSL: process.env.OPENSSL_PATH || openSSLPath

fs.mkdir './certs' unless fs.existsSync './certs'

pem.createCertificate days: 3600, selfSigned: true, (err, keys) ->
    if err
        console.log err
        process.exit 1
    fs.writeFile './certs/server.crt', keys.certificate, (err) ->
        if err then process.exit 1
    fs.writeFile './certs/server.key', keys.serviceKey, (err) ->
        if err then process.exit 1
