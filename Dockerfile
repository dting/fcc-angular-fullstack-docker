FROM debian:jessie

RUN apt-get -yq update && \
    apt-get -yq install git curl net-tools sudo bzip2 libpng-dev locales-all libfontconfig-dev build-essential

RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
    apt-get -yq install nodejs

# Heroku Toolbelt
RUN apt-get -yq install openssh-client ruby
RUN curl https://toolbelt.heroku.com/install.sh | sh
ENV PATH $PATH:/usr/local/heroku/bin

RUN npm install -g npm
RUN npm install -g yo bower grunt-cli
RUN npm install -g generator-angular-fullstack

RUN adduser --disabled-password --gecos "" devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/devuser

RUN mkdir /app && chown devuser:devuser /app
WORKDIR /app

RUN git config --global user.name "my.email@example.com"
RUN git config --global user.email "my name"

USER devuser
CMD grunt serve
