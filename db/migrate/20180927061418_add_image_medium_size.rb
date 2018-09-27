class AddImageMediumSize < ActiveRecord::Migration[5.2]
  def change
      add_column :images, :medium_source_url, :string
  end
end
