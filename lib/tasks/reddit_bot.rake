namespace :reddit do
  desc "continually polls mails queue for this environment (each environments/db each have their own queue) "
  task bot: :environment do


    require (Rails.root.to_s) + '/lib/modules/reddit_bot/reddit_bot.rb'
    RedditBot.run_bot


  end

end
