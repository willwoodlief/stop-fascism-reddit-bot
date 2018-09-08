#!/bin/bash


# change the directory
cd /home/bot/htdocs/bot

# load rvm ruby
source /home/bot/.rvm/environments/ruby-2.5.1@reddit_bot

bundle exec rake  reddit:bot RAILS_ENV="production" 2>&1 >>  /home/bot/htdocs/bot/log/bot_cron.log
