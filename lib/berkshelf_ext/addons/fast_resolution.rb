require 'chef'

module BerkshelfExt
  module FastResolution
    module CookbookStore

      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_fast_resolution_satisfy, :satisfy
            alias_method :satisfy, :fast_resolution_satisfy
            alias_method :non_fast_resolution_cookbooks, :cookbooks
            alias_method :cookbooks, :fast_resolution_cookbooks
          end
        end
      end
      
      def fast_resolution_satisfy(name, constraint)
        if(constraint.to_s.start_with?('='))
          get_version = constraint.version
        else
          graph = Solve::Graph.new
          cookbooks(name).each { |cookbook| graph.artifacts(name, cookbook.version) }
          get_version = Solve.it!(graph, [[name, constraint]]).first.last
        end
        c = cookbooks(name).detect{|ckbk| ckbk.version.to_s == get_version.to_s }
        ::Berkshelf::CachedCookbook.from_store_path(c.root_dir) if c
      rescue Solve::Errors::NoSolutionError
        nil
      end

      def fast_resolution_cookbooks(filter = nil)
        [].tap do |cookbooks|
          storage_path.each_child do |path|
            loader = ::Chef::Cookbook::CookbookVersionLoader.new(path)
            loader.load_cookbooks
            cv = loader.cookbook_version
            cb_name = cv.metadata.name.to_s.sub("-#{cv.version}", '')
            next if filter && cb_name != filter
            cookbooks << cv
          end
        end
      end
    end
  end
end

Berkshelf::CookbookStore.send(:include, BerkshelfExt::FastResolution::CookbookStore)
