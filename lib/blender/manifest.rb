module Blender
  module Manifest
    ROOT = File.expand_path("../manifest/root.rb", __FILE__)

    # run the root manifest with shadow_puppet of the given VERSION
    # @param [String] shadow_puppet_version the version of the shadow_puppet gem to use
    def self.run(shadow_puppet_version)
      system "shadow_puppet", "_#{shadow_puppet_version}_", ROOT
    end
  end
end
