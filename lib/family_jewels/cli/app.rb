require 'thor'

module FamilyJewels
  module CLI
    class App < Thor
      include Thor::Actions

      desc 'init', 'Creates an example config file'
      def init
        puts "What does a fjb config file look like?"
      end
    end
  end
end
