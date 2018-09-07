class Post < ApplicationRecord
  def self.already_processed(url)
     ! Post.where(post_url: url).blank?
  end
end
