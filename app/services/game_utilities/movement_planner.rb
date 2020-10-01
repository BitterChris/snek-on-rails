# frozen_string_literal: true

module GameUtilities
  class MovementPlanner
    include ActiveModel::Model

    MAX_STEPS = 2

    attr_accessor :board, :snek

    # Sends back the direction to move to the controller
    #
    # @return [Hash] The hash necessary to send back to the server as a JSON payload.
    def move
      direction = pick_direction

      Rails.logger.info("[MOVE] Going to go #{direction}.")

      { "move" => direction }
    end

    private

    # Determines what moves are available and returns the best one
    #
    # @private
    # @return [String] The decided upon direction to move (up, down, left, or right)
    def pick_direction
      moves = available_moves

      return moves.keys.first if moves.length == 1

      best_next_move(moves: moves)
    end

    # Looks at all available moves and returns an array of the only valid ones OR up (if no other valid options)
    #
    # @return [Array] Array of Hashes containing directions and their coordinates
    def available_moves
      moves = coordinates_from_location(location: snek['head'])
      valid_moves = moves.reject { |move| !valid_move?(coords: moves.dig(move)) }

      valid_moves.any? ? valid_moves : no_valid_moves
    end

    # A fallback method for if there are no valid moves. Logs and returns a default direction.
    #
    # @return [String] In the absence of any good directions to move, just go up.
    def no_valid_moves
      Rails.logger.info("\n\t[NO VALID MOVES]")

      'up'
    end

    # Attempts to find the best next move by identifying which moves towards food are valid moves and then
    # obtaining scores for them. Returns the best next move based on the highest scoring move.
    #
    # @param moves [Array] A list of available directions to move (previously determined to be valid and towards food)
    # @return [String] The direction determined to have the highest movement score
    def best_next_move(moves:)
      moves_towards_food = Finders::FoodFinder.new(food: board['food'], snek: snek).directions_to_food
      good_moves = moves_towards_food.reject { |move| !moves.include?(move) }
      move_scores = Hash.new(0)

      good_moves.each do |move|
        Rails.logger.info("[I'M CURRENTLY AT #{snek['head']}")
        Rails.logger.info("[MOVING #{move} WILL TAKE ME TO #{move_coords(move: move)}")
        move_scores[move] = score_paths(current_coords: move_coords(move: move))
        # Rails.logger.info("\tTHAT SCORE WILL BE #{move_scores[move]}")
      end

      Rails.logger.info("[MOVEMENT SCORES] #{move_scores}")
      move_scores.max_by { |_k, v| v }.first
    end

    # Gets the coordinates for the move given
    #
    # @param move [String] The direction of the move
    # @return [Hash] The coordinates that the move will take the snek head to.
    def move_coords(coords: snek['head'], move:)
      case move
      when 'up'
        { 'x' => coords['x'], 'y' => coords['y'] + 1 }
      when 'down'
        { 'x' => coords['x'], 'y' => coords['y'] - 1 }
      when 'left'
        { 'x' => coords['x'] - 1, 'y' => coords['y'] }
      when 'right'
        { 'x' => coords['x'] + 1, 'y' => coords['y'] }
      end
    end

    # Checks to see if moving to the coordinates given can be considered valid by making sure the snek isn't eating
    # itself, is still on the board, and isn't hitting another shake.
    #
    # @param coords [Hash] The x,y coordinates that are being validated
    # @return [Boolean] The decision of if the move will result in death or not
    def valid_move?(coords:)
      still_on_board?(coords) && !eating_self?(coords) && !hitting_snake?(coords)
    end

    # Looks to see if the coordinates are going to collide with any part of the snek body
    #
    # @param move_coords [Hash] The x,y coordinates that are being validated
    # @return [Boolean] Is the snek going to take a chomp of itself?
    def eating_self?(move_coords)
      snek['body'].any?(move_coords)
    end

    # Looks to see if the coordinates are going to take the snek off the board
    #
    # @param move_coords [Hash] The x,y coordinates that are being validated
    # @return [Boolean] Is the snek wandering off the board?
    def still_on_board?(move_coords)
      move_coords['x'].between?(0, board['width'] - 1) &&
          move_coords['y'].between?(0, board['height'] - 1)
    end

    # Looks to see if the coordinates are going to take the snek into another snake
    #
    # @param move_coords [Hash] The x,y coordinates that are being validated
    # @return [Boolean] Is the snek going to hit an enemy?
    def hitting_snake?(move_coords)
      snakes = Finders::SnakeFinder.new(snakes: board['snakes'], snek: snek).locations

      return false if snakes.empty?

      snakes.each do |position|
        return true if position == move_coords
      end

      false
    end

    # Gets coordinates for all available directions that can be moved.
    #
    # @param location [Hash] The x,y coordinates of the snek head
    # @return [Hash] Hash of Hashes where the key is a movement direction and the value is a Hash of x,y coordinates
    def coordinates_from_location(location:)
      {
          'up' =>  { 'x' => location['x'], 'y' => location['y'] + 1 } ,
          'down' => { 'x' => location['x'], 'y' => location['y'] - 1 },
          'left' => { 'x' => location['x'] - 1, 'y' => location['y'] },
          'right' => { 'x' => location['x'] + 1, 'y' => location['y'] },
      }
    end

    # Scores?
    #
    # @param step [Integer] The recursive depth counter
    # @param current_coords [Hash] x,y coordinates of where the head _thinks_ it is
    # @return [Integer] The score of the passed in move.
    def score_paths(step: 0, current_coords:)
      spacer = "--" * step
      score = step
      Rails.logger.info("#{spacer} | [THE SCORE RIGHT NOW IS #{score}]")
      directions = Finders::FoodFinder.new(food: board['food'], snek: snek).directions_to_food

      if step == MAX_STEPS
        Rails.logger.info("#{spacer} | [MAX STEPS REACHED - RETURNING #{score}]")
        return score
      end

      unless valid_move?(coords: current_coords)
        Rails.logger.info("#{spacer} | [MOVE TO #{current_coords} IS INVALID -- RETURNING 0]")
        return 0
      end

      directions.each do |direction|
        next_coordinates = move_coords(coords: current_coords, move: direction)

        Rails.logger.info("#{spacer} | [RECURSIVELY CHECKING MY MOVE #{direction} WHICH WILL TAKE ME TO #{next_coordinates}]")
        score += score_paths(step: step + 1, current_coords: next_coordinates)
      end

      Rails.logger.info("#{spacer} | [RETURNING THE SCORE #{score}]")
      score
    end
  end
end
