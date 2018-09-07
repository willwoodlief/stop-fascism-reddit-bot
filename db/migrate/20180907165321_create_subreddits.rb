class CreateSubreddits < ActiveRecord::Migration[5.2]
  def change
    create_table :subreddits do |t|
      t.string :subreddit_name

      t.timestamps
    end
  end
end
