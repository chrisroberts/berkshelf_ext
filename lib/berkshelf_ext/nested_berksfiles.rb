module BerkshelfExt
  module NestedBerksfiles
    module Cli
      class << self
        def included(klass)
          klass.tasks['upload'].options[:nested_berksfiles] = Thor::Option.new(
            'nested_berksfiles', :type => :boolean, :default => false,
            :desc => 'Use Berksfiles found within cookbooks specifed in Berksfile'
          )
        end
      end
    end

    module Berksfile
      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_nested_berksfiles_resolver, :resolver
            alias_method :resolver, :nested_berksfiles_resolver
          end
        end
      end
      
      def nested_berksfiles_resolver(options={})
        Berkshelf::Resolver.new(
          self.downloader,
          sources: sources(options),
          skip_dependencies: options[:skip_dependencies],
          nested_berksfiles: options[:nested_berksfiles]
        )
      end
    end

    module Resolver

      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_nested_berksfiles_initialize, :initialize
            alias_method :initialize, :nested_berksfiles_initialize
          end
        end
      end
      
      def nested_berksfiles_initialize(downloader, options={})
        skip_deps = options[:skip_dependencies]
        options[:skip_dependencies] = true
        non_nested_berksfiles_initialize(downloader, options)
        @skip_dependencies = options[:skip_dependencies] = skip_deps
        if(options[:nested_berksfiles])
          process_nested_berksfiles(options[:sources])
        end
        unless(options[:skip_dependencies])
          @sources.values.each do |source|
            add_source_dependencies(source)
          end
        end
      end

      def process_nested_berksfiles(srcs)
        srcs.map(&:name).each do |name|
          berks_path = File.join(@sources[name].cached_cookbook.path, 'Berksfile')
          if(File.exists?(berks_path))
            berksfile = Berkshelf::Berksfile.from_file(berks_path)
            new_sources = berksfile.sources.delete_if do |new_src|
              @sources.has_key?(new_src.name)
            end
            new_sources.each do |source|
              add_source(source, false)
            end
            process_nested_berksfiles(new_sources)
          end
        end
      end

    end
  end
end

Berkshelf::Cli.send(:include, BerkshelfExt::NestedBerksfiles::Cli)
Berkshelf::Berksfile.send(:include, BerkshelfExt::NestedBerksfiles::Berksfile)
Berkshelf::Resolver.send(:include, BerkshelfExt::NestedBerksfiles::Resolver)
