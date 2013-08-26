require 'active_model/serializer'

module ActiveModel
  class Serializer
    class Association
      def initialize(name, options={})
        @name          = name
        @options       = options

        self.embed    = options[:embed]
        @embed_key    = options[:embed_key] || :id
        @include      = options[:include]
        @key          = options[:key]
        @embedded_key = options[:root]

        self.serializer_class = @options[:serializer]
      end

      attr_reader :name, :embed_ids, :embed_objects, :embed_key, :serializer_class, :options
      attr_accessor :include, :key, :embedded_key
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias include? include

      def serializer_class=(serializer)
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def embed_objects?
        @embed_objects || @embed_ids && @include
      end

      def build_serializer(object)
        @serializer_class ||= Serializer.serializer_for(object)

        if @serializer_class
          @serializer_class.new(object, @options)
        else
          object
        end
      end

      class HasOne < Association
        def initialize(*args)
          super
          @key  ||= "#{name}_id"
          @embedded_key ||= name.pluralize
        end
      end

      class HasMany < Association
        def initialize(*args)
          super
          @key ||= "#{name.singularize}_ids"
          @embedded_key ||= name
        end
      end
    end
  end
end
