class Game < ApplicationRecord
  after_commit :log_new_game_details

  private

  def log_new_game_details
    Rails.logger.info("\n[GAME STARTING] GAME ##{id} HAS BEGUN.")
  end
end
