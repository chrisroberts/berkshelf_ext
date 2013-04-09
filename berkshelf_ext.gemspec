$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'berkshelf_ext/version'
Gem::Specification.new do |s|
  s.name = 'berkshelf_ext'
  s.version = BerkshelfExt::VERSION.version
  s.summary = 'Extensions for Berkshelf'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'http://github.com/chrisroberts/berkshelf_ext'
  s.description = 'Extenstions for berkshelf'
  s.require_path = 'lib'
  s.executables = %w(berks_ext)
  s.add_dependency 'berkshelf', BerkshelfExt::BERKSHELF_CONSTRAINT
  s.files = Dir['**/*']
end
