# frozen_string_literal: true

module GameUtilities
  module Finders
    class FoodFinder < Finder
      attr_accessor :food

      def nearest
        nearest_index = food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.min.last

        food[nearest_index]
      end

      def farthest
        farthest_index = food.each_with_object([]) do |food, score|
          score << (food['x'] - snek['head']['x']).abs + (food['y'] - snek['head']['y']).abs
        end.each_with_index.max.last

        food[farthest_index]
      end
    end
  end
end
