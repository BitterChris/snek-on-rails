# frozen_string_literal: true

module GameUtilities
  module Finders
    class SnakeFinder < Finder
      attr_accessor :snakes

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
    end
  end
end
