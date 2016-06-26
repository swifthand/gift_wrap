# Presenter Library
module GiftWrap
  module Presenter

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, ActiveModel::Serializers::JSON)
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


    def attributes
      self.class.attributes.each.with_object({}) do |msg, attr_hash|
        attr_hash[msg.to_s] = self.send(msg)
      end
    end


    module ClassMethods


      def attributes
        @attributes ||= Set.new
      end


      def unwrapped_methods
        @unwrapped_methods ||= Set.new
      end


      def wrapped_association_defaults
        @wrapped_association_defaults ||= {}
      end


      def wrapped_as(reference)
        define_method(reference) do
          @wrapped_object
        end
        send(:private, reference)
      end


      def attribute(*names)
        names.flatten.each do |name|
          attributes << name
        end
      end


      def unwrap_for(*names, attribute: false, **options)
        names = names.flatten
        names.each do |name|
          unwrapped_methods << name
          attributes        << name if attribute
        end
        delegate(*names, to: :@wrapped_object)
      end


      def wrap_association(association, with: , as: association, **options)
        wrapped_association_defaults[as] = with
        define_method(as) do
          presenter_class = wrapped_association_presenter(as)
          associated      = @wrapped_object.send(association)
          if associated.respond_to?(:each)
            associated.map { |assoc| presenter_class.new(assoc, **options) }
          else
            presenter_class.new(associated, **options)
          end
        end
      end

    end

  end
end
