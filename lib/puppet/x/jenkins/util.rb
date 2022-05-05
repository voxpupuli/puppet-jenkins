# frozen_string_literal: true

require_relative '../jenkins'

module Puppet::X::Jenkins::Util
  def unundef(data)
    iterate(data) { |x| x == :undef ? nil : x }
  end
  module_function :unundef

  def undefize(data)
    iterate(data) { |x| x.nil? ? :undef : x }
  end
  module_function :undefize

  # loosely based on
  # https://stackoverflow.com/questions/16412013/iterate-nested-hash-that-contains-hash-and-or-array
  def iterate(data, &block)
    return data unless block_given?

    case data
    when Hash
      data.transform_values do |v|
        iterate(v, &block)
      end
    when Array
      data.map { |v| iterate(v, &block) }
    else
      yield data
    end
  end
  module_function :iterate
end
