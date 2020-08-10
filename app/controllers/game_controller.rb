class GameController < ApplicationController
  include GameUtilities

  before_action :find_game, only: [:end]

  def start
    @game = Game.create(game_params)

    if @game
      head :ok
    end
  end

  def end
    Rails.logger.info("\n[GAME OVER] GAME ##{@game.id} HAS ENDED.")

    head :ok
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
    @game ||= Game.find_by(game_id: params[:game][:id])
  end
end
