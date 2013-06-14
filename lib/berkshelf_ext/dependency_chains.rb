module BerkshelfExt
  module DependencyChains
    module Berksfile
      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_dependency_chains_sources, :sources
            alias_method :sources, :dependency_chains_sources
            alias_method :non_dependency_chains_resolve, :resolve
            alias_method :resolve, :dependency_chains_resolve
          end
        end
      end
      def dependency_chains_sources(options = {})
        l_sources = @sources.collect { |name, source| source }.flatten

        cookbooks  = options[:skip_dependencies] ? Array(options.fetch(:cookbooks, nil)) : []
        except    = Array(options.fetch(:except, nil)).collect(&:to_sym)
        only      = Array(options.fetch(:only, nil)).collect(&:to_sym)

        case
        when !except.empty? && !only.empty?
          raise Berkshelf::ArgumentError, "Cannot specify both :except and :only"
        when !cookbooks.empty?
          if !except.empty? && !only.empty?
            Berkshelf.ui.warn "Cookbooks were specified, ignoring :except and :only"
          end
          l_sources.select { |source| options[:cookbooks].include?(source.name) }
        when !except.empty?
          l_sources.select { |source| (except & source.groups).empty? }
        when !only.empty?
          l_sources.select { |source| !(only & source.groups).empty? }
        else
          l_sources
        end
      end

      def dependency_chains_resolve(options={})
        resolver(options).resolve(options.fetch(:cookbooks, nil))
      end
    end
    
    module Resolver

      class << self
        def included(klass)
          klass.class_eval do
            alias_method :non_dependency_chains_resolve, :resolve
            alias_method :resolve, :dependency_chains_resolve
          end
        end
      end

      def defined_artifacts
        Hash[*(
            graph.artifacts.map do |art|
              [art.name, art]
            end
        ).flatten]
      end
      
      def chain_dependencies!
        defined_artifacts.each do |name, artifact|
          @sources[name].cached_cookbook.dependencies.each do |dep|
            dep << ">= 0.0.0" unless dep.size > 1
            artifact.depends(dep.first, dep.last)
          end
        end
      end

      def dependency_chains_resolve(demands = nil)
        demands = Array(demands) unless demands.is_a?(Array)
        if(demands.empty?)
          demands = [].tap do |l_demands|
            graph.artifacts.each do |artifact|
              l_demands << [artifact.name, artifact.version]
            end
          end
        end
        unless(@skip_dependencies)
          chain_dependencies!
        end
        # since we only get an error if the graph does not contain a
        # solution and not the dependency that caused the failure, run
        # each dependency through the graph individually so we can
        # provide a useful error string
        demands.reverse.each do |demand|
          begin
            solution = Solve.it!(graph, [demand])
          rescue Solve::Errors::NoSolutionError
            deps = @sources[demand.first].cached_cookbook.dependencies.map{|n,v| "#{n.strip}-#{v.sub(%r{^[^0-9]+}, '').strip}"}
            cur = @sources.values.map(&:cached_cookbook).map{|c| "#{c.metadata.name}-#{c.metadata.version}"}
            failed_on = Array(deps - cur)
            # TODO: if failed on is empty, resort and solve to attempt
            # to locate root cause
            raise Berkshelf::NoSolution.new(
              "\n\nFailed to resolve dependencies for:\n#{demand.join(': ')}\n" <<
              "Probable failure on: #{failed_on.empty? ? 'UNKNOWN!?' : failed_on.join(', ')}\n" << 
              "Dependencies:\n" <<
              @sources[demand.first].cached_cookbook.dependencies.map{|n,v| "  #{n}: #{v}"}.sort.join("\n") <<
              "\nCurrently loaded:\n" <<
              @sources.values.map(&:cached_cookbook).map{|c| "  #{c.name}: #{c.metadata.name} - #{c.metadata.version}"}.sort.join("\n") <<
              "\n"
            )
          end
        end
        solution = Solve.it!(graph, demands)
        [].tap do |cached_cookbooks|
          solution.each do |name, version|
            cached_cookbooks << get_source(name).cached_cookbook
          end
        end
      end
    end
  end
end

Berkshelf::Resolver.send(:include, BerkshelfExt::DependencyChains::Resolver)
Berkshelf::Berksfile.send(:include, BerkshelfExt::DependencyChains::Berksfile)
