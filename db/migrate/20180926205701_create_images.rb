class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :title
      t.string :description
      t.string :bucket
      t.string :filename
      t.string :license
      t.string :author
      t.string :source_url

      t.timestamps
    end
  end
end
