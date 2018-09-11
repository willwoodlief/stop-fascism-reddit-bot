require File.dirname(__FILE__) + '/reddit_bot_basic'
require File.dirname(__FILE__) + '/reddit_bot_snapshot'
require File.dirname(__FILE__) + '/reddit_bot_chrome_manager'
module RedditBot
  def self.run_bot
    basic = RedditBotSnapshot.new
  end
end