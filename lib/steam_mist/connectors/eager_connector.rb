module SteamMist
  module Connectors

    # An eager connector that forces the request on initialization.
    class EagerConnector < Connector

      extend Forwardable

      # Calls `super` and then {#force_request!}.
      def initialize(_)
        super

        @data = force_request!
      end

      # Implements the {#[]} method.
      def_delegator :@data, :[]

      # Implements the {#each} method.
      def_delegator :@data, :each
      
    end
  end
end
