class AddResultToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :result, :text, null: true
  end
end
