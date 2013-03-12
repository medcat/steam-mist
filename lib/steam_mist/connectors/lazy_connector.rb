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
        data[name]
      end

      # This provides access to {#each} on the data.
      #
      # @see {Hash#each}.
      def_delegator :data, :each

      # This makes sure that the data was requested before it was used by
      # checking if data is full (and if it isn't, fill it with the data from
      # {#force_request!}).
      #
      # @return [Hash] the data.
      def data
      	@data ||= force_request!
      end

    end
  end
end
