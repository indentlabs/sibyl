class CreateCharacterImageQualities < ActiveRecord::Migration[5.2]
  def change
    create_table :character_image_qualities do |t|
      t.references :image, foreign_key: true
      t.string :gender
      t.string :skin_tone
      t.string :hair_color
      t.string :hair_length
      t.integer :age
      t.string :glasses
      t.string :analysis_source

      t.timestamps
    end
  end
end
