class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.belongs_to  :bad_sites, index: true
      t.integer     :added_ts, default: nil
      t.boolean     :is_dry_run, default: false
      t.string      :domain, default: nil
      t.string      :subreddit, default: nil
      t.string      :post_url, default: nil
      t.string      :op_url, default: nil
      t.string      :archive_url

      t.string      :thumbnail, default: nil
      t.string      :title, default: nil
      t.text        :reddit_response, default: nil
      t.timestamps
    end

    add_index :posts, :added_ts,  :unique => false
    add_index :posts, :domain,  :unique => false, :length => 100
    add_index :posts, :subreddit,  :unique => true, :length => 50
    add_index :posts, :post_url,  :unique => false, :length => 150
    add_index :posts, :op_url,  :unique => true, :length => 150


    add_foreign_key :posts, :bad_sites, name: "post_has_bad_site_id_fk",column: "bad_sites_id"
  end
end
