module BerkshelfExt
  module DependencyChains
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
        demands.each do |demand|
          begin
            solution = Solve.it!(graph, [demand])
          rescue Solve::Errors::NoSolutionError
            raise Berkshelf::NoSolution.new("Failed to resolve dependencies for: #{demand.join(': ')}")
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
