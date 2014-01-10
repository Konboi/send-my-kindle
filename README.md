# Send My Kindle

## Download

`
$ git clone https://github.com/Konboi/send-my-kindle.git
`

## Setup

* install gem

`
$ cd send-my-kindle
$ bundle install --path vendor/bundle
`
* setup database

`
$ mysql -u root databasename < config/schma.sql
`

* setup tag

`
vim app.rb
`

* edit setting file

  * gmail username
  * gmail password
  * kindle email address

`
vim config/settings.json
`


## use

`
bundle exec ruby app.rb
`
