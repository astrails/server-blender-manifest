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

    # first load user's recipe
    code = open(recipe).read
    instance_eval(code, recipe)

    # next load OS specific recipe. This gives user's recipe
    # the opportunity to redefine it if needed
    _os = os.downcase
    unless respond_to?(_os)
      mix _os
    end
    send _os

  end
  recipe :execute_user_recipe
end

include Blender::Manifest::Mixer

# "project" recipe directory
$: << "recipes"

# add all recipes in the cookbooks directory to the path
$:.concat Dir["cookbooks/*/recipes"]