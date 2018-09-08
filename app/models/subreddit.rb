class Subreddit < ApplicationRecord
  def self.update_list(subreddit_array)
    return if subreddit_array.blank?
      Subreddit.delete_all
      subreddit_array.each do |com|
        next if com.to_s.strip.blank?
        s = Subreddit.new
        s.subreddit_name = com
        s.save!
      end
  end
end
