class CreateAdHocReports < ActiveRecord::Migration
  def change
    create_table :ad_hoc_reports do |t|
      t.string :label
      t.string :sparql_file
      t.string :results_file
      t.datetime :last_run
      t.boolean :active, default: false
      t.integer :background_id

      t.timestamps null: false
    end
  end
end
