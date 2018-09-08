#!/bin/bash


# change the directory
cd /home/will/htdocs/reddit_bot

# load rvm ruby
source /home/will/.rvm/environments/ruby-2.5.1@reddit_bot

bundle exec rake  reddit:bot RAILS_ENV="development" &>>  /home/will/htdocs/reddit_bot/log/bot_cron.log
