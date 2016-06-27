module GiftWrap
  class Configuration

    attr_accessor :use_serializers

    def initialize
      @use_serializers = !!defined?(ActiveModel)
    end

    def use_serializers?
      @use_serializers
    end

  end
end
