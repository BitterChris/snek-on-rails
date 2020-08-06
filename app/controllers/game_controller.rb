class GameController < ApplicationController
  include GameUtilities

  before_action :find_game, only: [:move, :end]

  def start
    @game = Game.create(game_params)

    if @game
      head :ok
    end
  end

  def move
    render json: MovementPlanner.new(move_params).move
  end

  def end
    Rails.logger.info("\n\nGAME OVER")

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

  def move_params
    {
        board: params[:board],
        snek: params[:you],
    }
  end

  def find_game
    @game ||= Game.find_by(game_id: params[:game][:id])
  end
end
