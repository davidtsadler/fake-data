# FAKE-DATA

While working on various projects I often find that I require fake data for testing. The aim of this code is to hopefully generate this fake data from various sources and store in a database. I should then be able to extract this data and put into any format that I requrie.

One example is that I will be scanning my mp3 music collection and storing all the artist, album and track names. I can then turn this into some fake data for an ecommerce site if I need to. 

## Features

* Data stored in a sqlite database.
* ActiveRecord used to access the database.
* Rake tasks for generating the database.
* Rake tasks for exporting data into various formats.

## Usage

* Clone this repository with `git://github.com/davidtsadler/fake_data.git`
* Change into the directory `cd fake_data`
* Use the provided *config/config.yml.example* file as the basis for your configuration. `cp config/config.yml.example config/config.yml`
* Edit *config/config.yml* and specify any configuration settings you require.
* Create the required database tables with `rake fake_data:db:migrate` 
* Populate the database with `rake fake_data:db:populate`
