# frozen_string_literal: true

module Enums
  module ValuesList
    include Enumerable

    def each(&block)
      values.each(&block)
    end

    delegate :include?, to: :values

    def to_ary
      values
    end

    def values
      @values ||= constants(false).map do |constant|
        const_get(constant)
      end.freeze
    end

    def assert_has!(value)
      unless include?(value)
        raise ArgumentError, "Unexpected constant value: #{value}"
      end
    end

    delegate :+, to: :values
  end
end
