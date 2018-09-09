class RebuildKeyOnPosts < ActiveRecord::Migration[5.2]
  def change
    remove_index :posts, :subreddit
    add_index :posts, :subreddit,  :unique => false, :length => 50
  end
end
