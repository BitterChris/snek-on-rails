class GameController < ApplicationController
  before_action :log_payload, only: :start

  def start
    @game = Game.new(params)
  end

  def move
  end

  def end
  end

  private

  def game_params
    params.permit(:game, :board, :you)
  end

  def find_game

  end

  def log_payload
    Rails.logger.info(params)
  end
end
