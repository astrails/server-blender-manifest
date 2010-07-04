module Blender
  module Manifest
    # run the root manifest with shadow_puppet of the given VERSION
    # @param [String] shadow_puppet_version the version of the shadow_puppet gem to use
    def self.run(shadow_puppet_version)
      require 'blender/manifest/root'

      Root.new(:setup).execute && Root.new.execute
    end
  end
end
