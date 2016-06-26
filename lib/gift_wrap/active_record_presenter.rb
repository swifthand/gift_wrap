module GiftWrap
  module ActiveRecordPresenter

    def self.included(base)
      base.send(:include, ::GiftWrap::Presenter)
      base.extend(::GiftWrap::ActiveRecordPresenter::ClassMethods)
    end


    module ClassMethods

      def unwrap_columns_for(active_record_model, attribute: true, **options)
        columns = active_record_model.columns.map { |col| col.name.to_sym }
        if true == attribute || false == attribute
          unwrap_for(*columns, attribute: attribute, **options)
        elsif Hash === attribute
          as_attributes, not_attributes = partition_columns_for_attributes(columns, attribute)
          unwrap_for(*as_attributes,  attribute: true,  **options)
          unwrap_for(*not_attributes, attribute: false, **options)
        else
          unwrap_for(*columns, attribute: attribute, **options)
        end
      end

    private

      def partition_columns_for_attributes(columns, attribute_options)
        partitioned =
          if attribute_options.key?(:only)
            accepted_columns = [attribute_options.fetch(:only)].flatten
            columns.partition { |col| accepted_columns.include?(col) }
          elsif attribute_options.key?(:except)
            rejected_columns = [attribute_options.fetch(:except)].flatten
            columns.partition { |col| !rejected_columns.include?(col) }
          else
            [columns, []]
          end
        return *partitioned
      end

    end

  end
end
