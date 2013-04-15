require 'chef'
require 'chef/cookbook_uploader'

module Ridley
  class << self
    def new(options)
      RidleyMocker.new(options)
    end
  end
end

class RidleyMocker
  def initialize(options)
  end

  def method_missing(sym, *args)
    if(@ckbk)
      @ckbk.send(sym, *args)
    else
      super
    end
  end
  
  def cookbook
    self
  end

  def alive?
    false
  end

  def path
    @path
  end
  
  def upload(path, upload_options)
    chef_config!
    @path = path
    loader = Chef::Cookbook::CookbookVersionLoader.new(path)
    loader.load_cookbooks
    cv = loader.cookbook_version
    cv.send(:generate_manifest)
    cv.manifest['name'] = "#{cv.metadata.name}-#{cv.version}"
    cv.name = cv.manifest['cookbook_name'] = cv.metadata.name
    cv.freeze_version if upload_options.delete(:freeze)
    Chef::CookbookUploader.new([cv], cookbook.path, upload_options).upload_cookbooks
    @ckbk = cv
  end

  def chef_config!
    cwd = Dir.pwd.split('/')
    until(cwd.empty?)
      knife_conf = File.join(cwd.join('/'), '.chef/knife.rb')
      if(File.exists?(knife_conf))
        Chef::Config.from_file(knife_conf)
        return
      end
    end
    raise 'Failed to locate knife.rb file to configure chef!'
  end
      
end
