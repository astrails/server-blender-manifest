module Blender::Manifest::Init
  def self.included(base)
    base.class_eval do
      recipe :create_blender_directories
    end
  end

  # create blender directories
  # @return dependency ref for the direcotires creation
  def create_blender_directories
    @create_blender_directories ||=
      begin
        file name = "/var/lib/blender", :owner => "root", :mode => 0700
        dep = file(name)
        file name = "/var/lib/blender/logs", :owner => "root", :mode => 0755, :require => dep
        dep = file(name)
        file name = "/var/lib/blender/tmp", :owner => "root", :mode => 0755, :require => dep
        dep = file(name)
      end
  end

  # @return dependency for blender directories
  def builder_deps
    create_blender_directories
  end
end
