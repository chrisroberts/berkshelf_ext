require 'berkshelf_ext/version'

berk_spec = Gem::Specification.find_by_name('berkshelf', BerkshelfExt::BERKSHELF_CONSTRAINT)

unless(berk_spec)
  raise "Failed to locate acceptable berkshelf version. (Constraint: #{BerkshelfExt::BERKSHELF_CONSTRAINT})"
end

berk_spec.activate_dependencies
berk_spec.activate
require File.join(berk_spec.full_gem_path, 'lib/berkshelf.rb')

require 'berkshelf_ext/all'
