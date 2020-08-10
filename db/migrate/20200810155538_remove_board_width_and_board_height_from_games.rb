class RemoveBoardWidthAndBoardHeightFromGames < ActiveRecord::Migration[6.0]
  def change
    remove_columns :games, :board_height, :board_width
  end
end
