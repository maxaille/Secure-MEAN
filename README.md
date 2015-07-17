# Secure-MEAN
Seed for onepage MEAN app using https and JWT for secured sessions
Use CoffeeScript, Jade and Sass

# Dev
There is a watchers for the frontend for Coffee, Jade and Sass. You just need to run 
    npm install -g grunt
    grunt watch
and it will compile your files on saving to the build directory. You don't event need to reload the server.
You can also compile manually using:
    grunt

# Getting started
Run
    npm install
to downloads server's dependencies and
    npm install -g bower
for installing globally the tool for front-end dependencies.
Then do:
    bower install
to automatically download all front-end modules.

You also need a mongoDB server, so with apt-get (Debian like)
    sudo apt-get install mongodb-org
or on Archlinux
    pacman -S mongodb
    
# Run the app
You need coffeeScript to run the application, so do:
    npm install -g coffee-script
then to run the application:
    coffee ./bin/www
You can set PORT and HTTPS_PORT in the environment to change the port or in the config file (default is 3000 and 3001)
You can also set user, password, url and database for MongoDB in the environment or in the config file. Default values are: 
    MONGO_URL = localhost
    MONGO_PORT = 27017
    MONGO_DATABASE = Secure-MEAN
    MONGO_USER = ''
    MONGO_PASSWORD = ''
    
# Testing
Yeah, maybe, one day...