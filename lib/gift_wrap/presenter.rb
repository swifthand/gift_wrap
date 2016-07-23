module GiftWrap
  module Presenter

    def self.included(base)
      base.extend(ClassMethods)
      if GiftWrap.config.use_serializers? && defined? ActiveModel::Serializers::JSON
        base.send(:include, ActiveModel::Serializers::JSON)
      end
    end

    ##
    # Current options:
    # - associations: a hash mapping association names to the presenter class
    #   to use when wrapping the association. Used to override the :with setting of
    #   a call to ::wrap_association at an instance level.
    def initialize(wrapped_object, **options)
      @wrapped_object                 = wrapped_object
      @wrapped_association_presenters = options.fetch(:associations, {})
    end

    ##
    # Used in methods defined by ::wrap_association to determine the presenter class that
    # is used for a particular association name. First checks any instance-specific options
    # for the association name, and falls back to those defined by the :with option passed
    # to any ::wrap_association call for said association_name.
    def wrapped_association_presenter(association_name)
      if @wrapped_association_presenters.none?
        self.class.wrapped_association_defaults.fetch(association_name) do |name|
          raise NoMethodError.new("No association registered as '#{name}'.")
        end
      else
        @wrapped_association_presenters.fetch(
          association_name,
          self.class.wrapped_association_defaults.fetch(association_name) do |name|
            raise NoMethodError.new("No association registered as '#{name}'.")
          end)
      end
    end

    ##
    # For use by ActiveModel::Serializers::JSON in building a default set of values
    # when calling #as_json or #to_json
    def attributes
      self.class.attributes.each.with_object({}) do |msg, attr_hash|
        attr_hash[msg.to_s] = self.send(msg)
      end
    end


    module ClassMethods

      ##
      # Contains the of messages (which are used as hash keys) to send to self and collect
      # when building an attributes hash.
      def attributes
        @attributes ||= Set.new
      end

      ##
      # Contains the list of methods which will be delegated to the wrapped object rather than
      # defined on presenter class itself.
      def unwrapped_methods
        @unwrapped_methods ||= Set.new
      end

      ##
      # Contains the default settings for building any associations. These may be overridden
      # on a per-intance basis.
      def wrapped_association_defaults
        @wrapped_association_defaults ||= {}
      end

      ##
      # Defines a private method name by which the wrapped object may be referenced internally.
      def wrapped_as(reference)
        define_method(reference) do
          @wrapped_object
        end
        send(:private, reference)
      end

      ##
      # Declares one or more messages (method names) to be attributes.
      def attribute(*names)
        names.flatten.each do |name|
          attributes << name
        end
      end

      ##
      # Declares that one or more received messages (method calls) should be delegated directly
      # to the wrapped object, and which may be optionally declared as attributes.
      #
      def unwrap_for(*names, attribute: false, **options)
        names = names.flatten
        names.each do |name|
          unwrapped_methods << name
          attributes        << name if attribute
        end
        delegate(*names, to: :@wrapped_object)
      end

      ##
      # Declares that the result of a delegated method call should be wrapped in another
      # presenter, as defined by the :with keyword argument.
      # This results in a method by the name of the first parameter by default, but may be
      # customized with the :as keyword argument.
      # Associations whose method produces an enumerable (ideally an Array) will have each
      # item wrapped in the presenter and collected in an Array which is then returned.
      def wrap_association(association, with: , as: association, **options)
        wrapped_association_defaults[as] = with
        define_method(as) do
          presenter_class = wrapped_association_presenter(as)
          associated      = @wrapped_object.send(association)
          memoized_within = "@#{as}"
          instance_variable_get(memoized_within) ||
            instance_variable_set(memoized_within,
              if associated.respond_to?(:each)
                associated.map { |assoc| presenter_class.new(assoc, **options) }
              else
                presenter_class.new(associated, **options)
              end
          )
        end
      end

    end

  end
end
