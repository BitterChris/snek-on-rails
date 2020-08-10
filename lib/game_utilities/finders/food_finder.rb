# frozen_string_literal: true

module GameUtilities
  module Finders
    class FoodFinder < Finder
      attr_accessor :food

      def directions_to_food
        nearest_coords = nearest
        nearest_x = nearest_coords['x'] <=> snek['head']['x']
        nearest_y = nearest_coords['y'] <=> snek['head']['y']

        if (nearest_x == 1 && nearest_y == 1) || (nearest_x == 1 && nearest_y == 0)
          %w(right up down left)
        elsif nearest_x == 1 && nearest_y == -1
          %w(right down up left)
        elsif (nearest_x == -1 && nearest_y == 1) || (nearest_x == -1 && nearest_y == 0)
          %w(left up down right)
        elsif nearest_x == -1 && nearest_y == -1
          %w(left down up right)
        elsif nearest_x == 0 && nearest_y == 1
          %w(up down left right)
        elsif nearest_x == 0 && nearest_y == -1
          %w(down up left right)
        end
      end

      private

      def nearest
        nearest_index = food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.min.last

        food[nearest_index]
      end

      # Not in use
      def farthest
        farthest_index = food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.max.last

        food[farthest_index]
      end
    end
  end
end
