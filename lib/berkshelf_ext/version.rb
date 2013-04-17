module BerkshelfExt
  class Version < Gem::Version
  end

  VERSION = Version.new('1.0.12')
  BERKSHELF_CONSTRAINT = '~> 1.3.1'
end
