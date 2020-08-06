# frozen_string_literal: true

module GameUtilities
  module Finders
    class EmptySpaceFinder < Finder
      attr_accessor :board

      def empty_space
        snakes = SnakeFinder.new(snakes: board['snakes']).locations(include_snek: true)
        all_spaces = build_full_board

        all_spaces - snakes
      end

      private

      def build_full_board
        spaces = []

        board['width'].times do |x|
          board['height'].times do |y|
            spaces << { 'x' => x, 'y' => y }
          end
        end

        spaces
      end
    end
  end
end
