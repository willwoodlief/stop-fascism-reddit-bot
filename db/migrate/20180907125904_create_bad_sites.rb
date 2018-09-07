class CreateBadSites < ActiveRecord::Migration[5.2]
  def change
    create_table :bad_sites do |t|
      t.string :url,null:false
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
