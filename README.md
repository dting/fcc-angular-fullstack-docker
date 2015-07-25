# fcc-angular-fullstack-docker

Dockerized development environment for FreeCodeCamp basejumps.

## What's this for?

FreeCodeCamp's [tutorial](http://www.freecodecamp.com/challenges/waypoint-get-set-for-basejumps) for getting started on the base jump challenges includes using Cloud9 IDE. I've used Cloud9 before and think it's great but there is enough delay when reloading pages that I wanted to just develop on my local machine. This is the result of shaving the yak.

Using Docker allows for keeping the development environment isolated from the rest the your system while being able to edit the files and use the browser on the host.

## Prerequisites

* Docker (https://docs.docker.com/installation/)
* Docker compose (https://docs.docker.com/compose/install/)

If you aren't on a linux os I highly recommend using one of the following because of the huge slow down that boot2docker using mounted volumes with vboxsf causes (see http://stackoverflow.com/questions/30090007/whats-the-right-way-to-setup-a-development-environment-on-os-x-with-docker):
* https://github.com/blinkreaction/boot2docker-vagrant (What I used)
* https://github.com/codekitchen/dinghy
* https://github.com/leighmcculloch/docker-unison

## Example

An example boostrapped project source and app can be found:

https://github.com/dting/fcc-dev-docker-example

https://fcc-dev-docker-example.herokuapp.com/

## Setup and usage

Copy the Dockerfile and docker-compse.yml file into an empty the directory that will become your project directory. 

    mkdir fccapp
    cp /path/to/Dockerfile fccapp/
    cp /path/to/docker-compose.yml fccapp/
    cd fccapp

----
If you are using [boot2docker-vagrant](https://github.com/blinkreaction/boot2docker-vagrant):

    bash <(curl -s https://raw.githubusercontent.com/blinkreaction/boot2docker-vagrant/master/setup.sh)
    vagrant ssh
    
You are now in a vagrant vm and can run the same commands but from within the vm.

----

Edit the git config lines in the Dockerfile:

    RUN git config --global user.name "my.email@example.com"
    RUN git config --global user.email "my name"

#### Building image and getting to prompt

Run the following command.
    
    docker-compose run --rm --service-ports web bash
    
  
This will build the image and start a container with a bash prompt (--rm will be auto remove the container when it exits). You should see something like:

    devuser@31acd02e8faf:/app$
    
#### yo angular-fullstack generator
    
This is the prompt from inside the container. Sometimes you need to hit return again for this prompt to show up. Run the yo generator and pick options to match your project.

    devuser@31acd02e8faf:/app$ yo angular-fullstack

These are the options that I used:

    # Client

    ? What would you like to write scripts with? JavaScript
    ? Would you like to use Javascript ES6 in your client by preprocessing it with Babel? Yes
    ? What would you like to write markup with? HTML
    ? What would you like to write stylesheets with? Less
    ? What Angular router would you like to use? uiRouter
    ? Would you like to include Bootstrap? Yes
    ? Would you like to include UI Bootstrap? Yes

    # Server

    ? Would you like to use mongoDB with Mongoose for data modeling? Yes
    ? Would you scaffold out an authentication boilerplate? Yes
    ? Would you like to include additional oAuth strategies? Twitter
    ? Would you like to use socket.io? No
    
The generator will try to `bower install` and `npm install` the dependencies. This failed for me a couple times while testing I ended up having to delete the node_modules folder and `npm install` again.

#### App config

While waiting for the installs to finish, edit:

* server/config/environment/development.js:

  Change `uri: 'mongodb://localhost/app-dev'` to `uri: 'mongodb://db:27017/app-dev'`

* server/config/environment/development.js:

  Change `uri: 'mongodb://localhost/app-test'` to `uri: 'mongodb://db:27017/app-test'`
  
* server/config/environment/index.js:
 
  Change `ip: process.env.IP || 'localhost'` to `ip: process.env.IP || '0.0.0.0'`

* Gruntfile.js:

  Remove `'open'` tasks in line 597 and 623.
  
#### Grunt

After the config is edited and the installs are complete, `grunt` should run without errors. Exit the container and use the following command to bring up a container that is running `grunt serve`:

    docker-compose up
    
Open your browser on the host machine to `localhost:9000` (`boot2docker ip`:9000 or http://192.168.10.10:9000/ if using boot2docker-vagrant) and the welcome page for angular-fullstack should appear. Any changes to the files should trigger the live reload.

In another tab navigate back to the project dir (and if needed vagrant ssh). Use the following command to get a bash prompt:

    docker-compose run --rm web bash

This can be used while the `grunt serve` container is still running. If you need to to use the yo generator, bower or npm this is where to do it.

#### Heroku

To finish up the getting started guide, from the prompt:

    npm install grunt-contrib-imagemin --save-dev && npm install --save-dev && heroku login
    
after the installs type in your heroku login as prompted then:

    yo angular-fullstack:heroku
  
When that is finished choose a name and a region and your app should be deployed to heroku.

    cd dist
    heroku config:set NODE_ENV=production && heroku addons:add mongolab
    
You are now able to push releases to heroku by using `grunt && grunt buildcontrol:heroku`.

## Notes

For OSX this setup seems a bit clunky because you have to use vagrant to speed up the shared mount point.
