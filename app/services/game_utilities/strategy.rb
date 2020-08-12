# frozen_string_literal: true

module GameUtilities
  class Strategy
    include ActiveModel::Model

    attr_accessor :board, :snek, :snakes, :food
  end
end
