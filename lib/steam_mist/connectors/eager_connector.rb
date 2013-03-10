module SteamMist
  module Connectors

    # An eager connector that forces the request on initialization.
    class EagerConnector < Connector

      # Calls `super` and then [#force_request!].
      def initialize(_)
        super

        @data = force_request!
      end
      
    end
  end
end
