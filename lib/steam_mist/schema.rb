require 'set'
require 'hashie/mash'

module SteamMist

  # Handles the Schema for games.
  #
  # @todo More tests.
  class Schema

    # Initialize the schema.  The first argument is the application id,
    # which valve uses internally to distinguish games from each other.
    #
    # @param app_id [Numeric]
    # @param lang [String] the language the schema should return its
    #   results in.
    def initialize(key, app_id, lang = nil)
      @app_id = app_id
      @session = Session.new
      @get_schema = @session.get_interface("IEconItems_#{app_id}").get_schema

      if lang
        @get_schema.with_arguments!(:language => lang)
      end
    end

    # Returns a list of items in the schema.
    #
    # @return [SortedSet<Item>]
    def items
      @_items ||= data.items
    end

    # Retrieves the data from the request.
    #
    # @return [Hashie::Mash]
    def data
      @_data ||= Hashie::Mash.new(@get_schema.get.data["result"])
    end

  end
end