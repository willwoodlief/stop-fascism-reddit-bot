class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.boolean :is_running
      t.boolean :dry_run
      t.string :archiver_program

      t.timestamps
    end
  end
end
