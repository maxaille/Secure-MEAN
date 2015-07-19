module.exports =
    port: 3000
    HTTPS_port: 3001

    mongoUrl: 'localhost'
    mongoPort: 27017
    mongoDatabase: 'Secure-MEAN'
    mongoUser: ''
    mongoPassword: ''

    tokenSecret: 'YOU SHALL NOT DECODE'
    tokenExpirationDelay: 60*1000

    appName: 'MyApp'
    httpsOnly: false