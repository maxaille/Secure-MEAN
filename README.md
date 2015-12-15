# Secure-MEAN
Seed for onepage MEAN app using HTTPS and JWT for secured sessions. Use Coffee Script, Jade and Sass.

# Dev
There is a watcher for the frontend for Coffee, Jade and Sass. You just need to run 

    npm install -g gulp
    gulp watch
and it will compile your files to the build/ directory when saving any of them. You don't event need to reload the server.
You can also compile manually using:

    gulp
Only for editing the index you should restart the server. It's served as a dynamic page to set some variables like the application name.

# Getting started
Run

    npm install
to download servers dependencies and

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

    npm start
You can set PORT and HTTPS_PORT in the environment to change the port or in the config file (default is 3000 and 3001)
You can also set user, password, url and database for MongoDB in the environment or in the config file. Default values are: 

    MONGO_URL = localhost
    MONGO_PORT = 27017
    MONGO_DATABASE = Secure-MEAN
    MONGO_USER = ''
    MONGO_PASSWORD = ''
# Testing
API is fully tested (or not ? I will check...)
Run

    mocha --compilers coffee:coffee-script/register