module BerkshelfExt
  module NonRecommendsDepends
    module CachedCookbook
      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_non_recommends_depends_dependencies, :dependencies
            alias_method :dependencies, :non_recommends_depends_dependencies
          end
        end
      end
      
      def non_recommends_depends_dependencies
        metadata.dependencies
      end
    end
  end
end

Berkshelf::CachedCookbook.send(:include, BerkshelfExt::NonRecommendsDepends::CachedCookbook)
