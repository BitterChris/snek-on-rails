# frozen_string_literal: true

module GameUtilities
  class MovementPlanner
    include ActiveModel::Model

    attr_accessor :board, :snek

    AVAILABLE_MOVES = %w(up down left right)
    VERTICAL_MOVES = %w(up down)
    HORIZONTAL_MOVES = %w(left right)

    X_MOVE_MAPS = {
        'right' => 1,
        'left' => -1,
    }

    Y_MOVE_MAPS = {
        'up' => 1,
        'down' => -1,
    }

    def move
      { "move" => pick_direction }
    end

    private

    def pick_direction
      moves = available_moves

      if moves.length >= 2
        directions_to_food(food_coords: nearest_food_coords, available_moves: moves)
      else
        moves.first
      end
    end

    def available_moves(moves: AVAILABLE_MOVES)
      # [ 'up' ]
      valid_moves = moves.reject { |move| !valid_move?(move: move) }

      Rails.logger.info(valid_moves) #['up', 'left', 'down']

      valid_moves.any? ? valid_moves : no_valid_moves
    end

    def available_future_moves(moves:)
      # ['up', 'left']
      moves.each_with_object({}) do |choice, future_moves|
        future_moves[choice] = available_moves(moves: moves).count
        Rails.logger.info(future_moves)
      end.max_by { |_k, v| v }.first
    end

    def no_valid_moves
      Rails.logger.info('No good moves. Guess I\'ll die')

      ['up']
    end

    def nearest_food_coords
      Finders::FoodFinder.new(food: board['food'], snek: snek).nearest
    end

    def directions_to_food(food_coords:, available_moves:)
      nearest_x = food_coords['x'] <=> snek['head']['x']
      nearest_y = food_coords['y'] <=> snek['head']['y']
      moves = []

      if nearest_x == 1
        moves << 'right'
      elsif nearest_x == -1
        moves << 'left'
      end

      if nearest_y == 1
        moves << 'up'
      elsif nearest_y == -1
        moves << 'down'
      end

      good_moves = available_moves - moves # ['up', 'left']

      if good_moves.length == 2
        available_future_moves(moves: moves)
      else
        good_moves.first
      end
    end

    #TODO: These all got more complex than they should've. They need to be simplified.
    def vertical_move_coords(move:, coords: {})
      x = coords['x'] || snek['head']['x']
      y = coords['y'] || snek['head']['y']

      {
        'x' => x,
        'y' => y + Y_MOVE_MAPS.dig(move),
      }
    end

    def horizontal_move_coords(move:, coords: {})
      x = coords['x'] || snek['head']['x']
      y = coords['y'] || snek['head']['y']

      {
        'x' => x + X_MOVE_MAPS.dig(move),
        'y' => y,
      }
    end

    def next_vertical_move_coords(move:)
      vertical_move_coords(move: move, coords: vertical_move_coords(move: move))
    end

    def next_horizontal_move_coords(move:)
      horizontal_move_coords(move: move, coords: horizontal_move_coords(move: move))
    end
  end

  def valid_move?(move:)
    coords = if VERTICAL_MOVES.include?(move)
               vertical_move_coords(move: move)
             elsif HORIZONTAL_MOVES.include?(move)
               horizontal_move_coords(move: move)
             end

    still_on_board?(coords) && !eating_self?(coords) && !hitting_snake?(coords)
  end

  def eating_self?(move_coords)
    snek['body'].any?(move_coords)
  end

  def still_on_board?(move_coords)
    move_coords['x'].between?(0, board['width'] - 1) &&
        move_coords['y'].between?(0, board['height'] - 1)
  end

  def hitting_snake?(move_coords)
    snakes = Finders::SnakeFinder.new(snakes: board['snakes'], snek: snek).locations

    return false if snakes.empty?

    snakes.each do |position|
      return true if position == move_coords
    end

    false
  end

end
