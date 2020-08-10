# frozen_string_literal: true

module GameUtilities
  module Finders
    class FoodFinder < Finder
      attr_accessor :food

      def directions_to_food
        nearest_coords = food[nearest]
        nearest_x = nearest_coords['x'] <=> snek['head']['x']
        nearest_y = nearest_coords['y'] <=> snek['head']['y']

        if (nearest_x == 1 && nearest_y == 1) || (nearest_x == 1 && nearest_y == 0)
          %w(right up down)
        elsif nearest_x == 1 && nearest_y == -1
          %w(right down up)
        elsif (nearest_x == -1 && nearest_y == 1) || (nearest_x == -1 && nearest_y == 0)
          %w(left up down)
        elsif nearest_x == -1 && nearest_y == -1
          %w(left down up)
        elsif nearest_x == 0 && nearest_y == 1
          %w(up down left)
        elsif nearest_x == 0 && nearest_y == -1
          %w(down up left)
        end
      end

      private

      def nearest
        @nearest ||= food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.min.last
      end

      def farthest
        @farthest ||= food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.max.last
      end
    end
  end
end