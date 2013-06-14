module BerkshelfExt
  module BerksfileLoaderContext
    module Berksfile
      def self.included(klass)
        klass.send(:include, InstanceMethods)
        klass.send(:extend, ClassMethods)
        klass.class_eval do
          alias_method :non_berksfile_loader_context_load, :load
          alias_method :load, :berksfile_loader_context_load
          alias_method :non_berksfile_loader_context_cookbook, :cookbook
          alias_method :cookbook, :berksfile_loader_context_cookbook
          class << self
            alias_method :non_berksfile_loader_context_from_file, :from_file
            alias_method :from_file, :berksfile_loader_context_from_file
          end
        end
      end
      module InstanceMethods
        def berksfile_loader_context_load(content, path='')
          initial_path = Dir.pwd
          begin
            Dir.chdir(File.dirname(path))
            instance_eval(content, File.expand_path(path), 1)
          rescue => e
            raise ::Berkshelf::BerksfileReadError.new(e), "An error occurred while reading the Berksfile (#{path}): #{e.to_s}"
          ensure
            Dir.chdir(initial_path)
          end
          self
        end
        def berksfile_loader_context_cookbook(*args)
          if(args.last.is_a?(Hash) && args.last[:path])
            args.last[:path] = File.expand_path(args.last[:path])
          end
          non_berksfile_loader_context_cookbook(*args)
        end
      end
      module ClassMethods
        def berksfile_loader_context_from_file(file)
          begin
            object = new(file)
            content = File.read(file)
            object.load(content, file.to_s)
          rescue Errno::ENOENT => e
            raise BerksfileNotFound, "No Berksfile or Berksfile.lock found at: #{file}"
          end
        end
      end
    end
  end
end

Berkshelf::Berksfile.send(:include, BerkshelfExt::BerksfileLoaderContext::Berksfile)
