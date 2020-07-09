class Game < ApplicationRecord
  after_save :log_new_game_details

  def initialize(attributes = {})
    super
  end

  private

  def log_new_game_details
    Rails.logger.info("[NEW GAME CREATED] #{game_id}")
  end
end
