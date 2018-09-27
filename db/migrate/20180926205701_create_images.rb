class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :title
      t.string :description
      t.string :license
      t.string :author_name
      t.string :author_url
      t.string :raw_source_url
      t.string :raw_source_height
      t.string :raw_source_width
      t.string :thumb_source_url
      t.string :page_source_url

      t.timestamps
    end
  end
end
