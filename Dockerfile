FROM ruby:2.4

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Set timezone
RUN echo "US/Eastern" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update -y && \
  apt-get install -y unzip xvfb \
  qt5-default libqt5webkit5-dev \
  gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x \
  freetds-dev \
  libnss3 libxi6 libgconf-2-4

# install chromedriver and place it in path
RUN wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip && \
	unzip chromedriver_linux64.zip && \
	mv chromedriver /usr/local/bin/

# MYSQL
RUN apt-get update \
  && apt-get install -y mysql-server mysql-client default-libmysqlclient-dev --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# pre-install used gems
ADD Gemfile /Gemfile
RUN echo v1
RUN bundle install

ENV PANDOC_VER=2.2.2.1
RUN apt-get update && apt-get -y --no-install-recommends install \
    wget \
    ca-certificates \
    texlive \
    texlive-xetex \
    texlive-fonts-extra \
    texlive-luatex \
    lmodern \
    netbase \
    && cd /opt && wget https://github.com/jgm/pandoc/releases/download/$PANDOC_VER/pandoc-$PANDOC_VER-1-amd64.deb \
    && dpkg -i pandoc-$PANDOC_VER-1-amd64.deb \
    && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/*

# Install deps + add Chrome Stable + purge all the things
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    --no-install-recommends \
    && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*


