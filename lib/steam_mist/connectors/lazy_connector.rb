module SteamMist
  module Connectors

    # Lazily loads the data from Steam, which means the request is made only
    # when or if the data is accessed.
    class LazyConnector < Connector

      def [](name)
        (@data ||= force_request!)[name]
      end
    end
  end
end
