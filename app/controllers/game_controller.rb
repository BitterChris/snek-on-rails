class GameController < ApplicationController
  include GameUtilities

  before_action :find_game, only: [:end]

  def start
    @game = Game.create(game_params)

    if @game
      Rails.logger.info("\n[GAME STARTING] GAME ##{@game.id} HAS BEGUN.")
      head :ok
    end
  end

  def end
    @game.update(result: game_result)

    Rails.logger.info("\n[GAME OVER] GAME ##{@game.id} HAS ENDED. YOU #{@game.result}!")

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
        solo_game: solo_game?,
    }
  end

  def find_game
    @game ||= Game.find_by(game_id: params[:game][:id])
  end

  def solo_game?
    params[:board][:snakes].length == 1
  end

  def game_result
    remaining_snake = params[:board][:snakes]

    return "SOLO PLAY" if @game.solo_game

    if remaining_snake.first.dig('id') == @game.snek_id
      "WON"
    elsif remaining_snake.empty?
      "DRAW"
    else
      "LOST"
    end
  end
end
