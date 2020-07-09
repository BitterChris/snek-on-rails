class Game < ApplicationRecord

  # attr_accessor :game_id, :snek_id, :board_width, :board_height, :turn

  after_commit :log_new_game_details

  def initialize(game_information)
    @game_id = game_information[:game][:id]
    @snek_id = game_information[:you][:id]
    @board_width = game_information[:board][:width]
    @board_height = game_information[:board][:height]
    @turn = game_information[:game][:turn]
  end

  private

  def log_new_game_details
    Rails.logger.info("[NEW GAME CREATED]")
  end
end
