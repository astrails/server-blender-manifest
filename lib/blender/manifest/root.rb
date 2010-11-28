# latest activesupport  producess a TON of warnings. use 2.3.5
gem 'activesupport', '2.3.5'
require 'shadow_puppet'
require 'puppet/darwinport_fix'
require 'puppet/dmgapp'

module Blender
  module Manifest; end
  module Recipes
    module Os; end
  end
end

require 'blender/manifest/nodes'
require 'blender/manifest/roles'
require 'blender/manifest/mixer'

# FIXME: this whole setup/regular execution is ugly. need to think of a better scheme
# Motivation behind the 'setup' thing:
# - on some platforms we need to do stuff *before* any of the real recipes are running
#   an example is Darwin where you need to change the default package provider
#   to 'ports' BEFORE you define any package resources
# - so we create 2 manifests. one that executes the 'setup' recipes, and another one that executes the rest.
class Root < ::ShadowPuppet::Manifest
  include Blender::Manifest::Nodes
  include Blender::Manifest::Roles

  @@mixed_recipes = []
  def self.mixed_recipes
    @@mixed_recipes
  end

  # Currently running operating system
  #
  # @return [String] name of the OS that is running
  def os
    Facter.value(:operatingsystem)
  end

  def execute_user_recipe
    mix "os/#{os.downcase}"

    if :setup == @stage
      # run OS specific setup recipe.
      m = "#{os.downcase}_setup"
      send(m) if respond_to?(m)
      # run gemeric setup
      send(:setup) if respond_to?(:setup)
      return
    end

    raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

    # run OS specific recipe.
    m = os.downcase
    send m if respond_to?(m)

    # load user's recipe
    code = open(recipe).read
    instance_eval(code, recipe)
  end

  recipe :execute_user_recipe

  def initialize(stage = :execute)
    super()
    @stage = stage
  end

  # Create a catalog of all contained Puppet Resources and apply that
  # catalog to the currently running system
  def apply(bucket = nil)
    bucket ||= export()
    catalog = bucket.to_catalog
    res = catalog.apply
    catalog.clear
    res
  end

  # Execute this manifest, applying all resources defined. Execute returns
  # true if successfull, and false if unsucessfull. By default, this
  # will only execute a manifest that has not already been executed?.
  # The +force+ argument, if true, removes this check.
  def execute(force=false)
    return false if executed? && !force
    evaluate_recipes
    ! apply.any_failed?
  rescue Exception => e
    STDERR.puts "\n\nException: #{e}\n#{e.backtrace * "\n"}"
    false
  ensure
    @executed = true
  end


end

include Blender::Manifest::Mixer

# "project" recipe directory
$: << "recipes"

# add all recipes in the cookbooks directory to the path
$:.concat Dir["cookbooks/*/lib"]