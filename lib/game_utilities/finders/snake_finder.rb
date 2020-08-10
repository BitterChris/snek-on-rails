# frozen_string_literal: true

module GameUtilities
  module Finders
    class SnakeFinder < Finder
      attr_accessor :snakes

      # Returns locations of all snakes on board as a flattened array of their coordinates
      def locations(include_snek: false)
        all_snakes = []

        unless include_snek
          snakes.delete_if { |snake| snake['id'] == snek['id']}
        end

        snakes.each do |snake|
          snake['body'].each { |pos| all_snakes << pos }
        end
        all_snakes
      end

      # Identify if snake is bigger or smaller
      def edible?
        #TODO: Make sure I'm looking at the right snake, check if I'm larger than it by length.
      end
    end
  end
end
