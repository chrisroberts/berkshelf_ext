require 'berkshelf'

Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each do |ext_file|
  require ext_file
end
