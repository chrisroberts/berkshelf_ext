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
    cv.metadata.name cv.metadata.name.to_s.sub(/-#{Regexp.escape(cv.version)}$/, '').sub(/-[a-z0-9]{40}$/, '')
    cv.manifest['name'] = "#{cv.metadata.name}-#{cv.version}"
    cv.name = cv.manifest['cookbook_name'] = cv.metadata.name
    cv.freeze_version if upload_options.delete(:freeze)
    Chef::CookbookUploader.new([cv], cookbook.path, upload_options).upload_cookbooks
    @ckbk = cv
  end

  def chef_config!
    cwd = Dir.pwd.split('/')
    found = false
    until(found || cwd.empty?)
      knife_conf = File.join(cwd.join('/'), '.chef/knife.rb')
      if(found = File.exists?(knife_conf))
        Chef::Config.from_file(knife_conf)
      end
    end
    %w(chef_server_url validation_client_name validation_key client_key node_name).each do |k|
      key = k.to_sym
      if(value = Berkshelf::Config.instance[:chef][key])
        Chef::Config[key] = value
      end
    end
  end
      
end
