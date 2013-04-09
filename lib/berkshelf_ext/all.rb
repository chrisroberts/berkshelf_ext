require 'berkshelf'

Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each do |ext_file|
  if(ENV['BERKSHELF_EXT_EXCEPT'])
    next if ENV['BERKSHELF_EXT_EXCEPT'].split(',').include?(File.basename(ext_file).sub('.rb', ''))
  end
  if(ENV['BERKSHELF_EXT_ONLY'])
    next unless ENV['BERKSHELF_EXT_ONLY'].split(',').include?(File.basename(ext_file).sub('.rb', ''))
  end
  require ext_file
end
