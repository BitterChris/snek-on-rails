class GameController < ApplicationController

  def start
    @game = Game.create(game_params)

    if @game
      head :ok
    end
  end

  def move
  end

  def end
  end

  private

  def game_params
    {
      game_id: params[:game][:id],
      snek_id: params[:you][:id],
      board_width: params[:board][:width],
      board_height: params[:board][:height],
      turn: params[:turn],
    }
  end

  def find_game

  end

  def log_payload
    Rails.logger.info(params)
  end
end
