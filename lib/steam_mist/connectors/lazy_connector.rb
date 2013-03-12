module SteamMist
  module Connectors

    # Lazily loads the data from Steam, which means the request is made only
    # when or if the data is accessed.
    class LazyConnector < Connector

      extend Forwardable

    	# Provides access to the data.
    	#
    	# @return [Object]
      def [](name)
        ensure_data[name]
      end

      # This provides access to {#each} on the data.
      #
      # @see {Hash#each}.
      def_delegator :ensure_data, :each

      private

      def ensure_data
      	@data ||= force_request!
      end

    end
  end
end
