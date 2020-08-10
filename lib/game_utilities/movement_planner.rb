# frozen_string_literal: true

module GameUtilities
  class MovementPlanner
    include ActiveModel::Model

    attr_accessor :board, :snek

    def move
      direction = pick_direction

      Rails.logger.info("[MOVE] Going to go #{direction}.")

      { "move" => direction }
    end

    private

    def pick_direction
      moves = available_moves

      return moves.keys.first if moves.length == 1

      best_next_move(moves: moves)
    end

    def available_moves
      moves = coordinates_from_location(location: snek['head'])
      valid_moves = moves.reject { |move| !valid_move?(coords: moves.dig(move)) }

      valid_moves.any? ? valid_moves : no_valid_moves
    end

    def no_valid_moves
      Rails.logger.info('No good moves. Guess I\'ll die')

      'up'
    end

    def best_next_move(moves:)
      moves_towards_food = Finders::FoodFinder.new(food: board['food'], snek: snek).directions_to_food
      good_moves = moves_towards_food.reject { |move| !moves.include?(move) }
      best_moves = []

      if good_moves.length >= 2
        good_moves.reject do |move|
          best_moves << move if safe_next_move?(move: move)
        end
      elsif good_moves.length == 1
        return good_moves.sample
      else
        return no_valid_moves
      end

      best_moves.first
    end

    def safe_next_move?(move:)
      location = move_coords(move: move)
      next_coords = coordinates_from_location(location: location)

      next_coords.each do |_move, coord|
        return true if valid_move?(coords: coord)
      end

      false
    end

    def move_coords(move:)
      case move
      when 'up'
        { 'x' => snek['head']['x'], 'y' => snek['head']['y'] + 1 }
      when 'down'
        { 'x' => snek['head']['x'], 'y' => snek['head']['y'] - 1 }
      when 'left'
        { 'x' => snek['head']['x'] - 1, 'y' => snek['head']['y'] }
      when 'right'
        { 'x' => snek['head']['x'] + 1, 'y' => snek['head']['y'] }
      end
    end

    def valid_move?(coords:)
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

    def coordinates_from_location(location:)
      {
          'up' =>  { 'x' => location['x'], 'y' => location['y'] + 1 } ,
          'down' => { 'x' => location['x'], 'y' => location['y'] - 1 },
          'left' => { 'x' => location['x'] - 1, 'y' => location['y'] },
          'right' => { 'x' => location['x'] + 1, 'y' => location['y'] },
      }
    end
  end
end
