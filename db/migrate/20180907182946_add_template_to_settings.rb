class AddTemplateToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :template, :string, default: nil , after: :archiver_program
  end
end
