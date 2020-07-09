class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :game_id
      t.string :snek_id
      t.integer :board_width
      t.integer :board_height
      t.integer :turn

      t.timestamps
    end
  end
end
