# frozen_string_literal: true

class MovesController < ApplicationController
  include GameUtilities

  def move
    render json: MovementPlanner.new(move_params).move
  end

  private

  def move_params
    {
        board: params[:board],
        snek: params[:you],
    }
  end
end
