require 'ruby-debug'

module Blender
  module Manifest; end
  module Recipes; end
end

require 'blender/manifest/init'
require 'blender/manifest/nodes'
require 'blender/manifest/roles'
require 'blender/manifest/mixer'

class Root < ::ShadowPuppet::Manifest
  include Blender::Manifest::Init
  include Blender::Manifest::Nodes
  include Blender::Manifest::Roles

  @@mixed_recipes = []
  def self.mixed_recipes
    @@mixed_recipes
  end

  def execute_user_recipe
    raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

    code = open(recipe).read
    instance_eval(code, recipe)
  end
  recipe :execute_user_recipe
end

include Blender::Manifest::Mixer

# "project" recipe directory
$: << "recipes"

# add all libs in the ./cookbook directory to the path
$:.concat Dir["cookbook/*/recipes"]